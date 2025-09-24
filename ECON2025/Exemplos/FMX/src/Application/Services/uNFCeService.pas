unit uNFCeService;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  uINFCeService,
  uINFCeRepository,
  uIProductRepository,
  uICustomerRepository,
  uNFCeEntity,
  uProductEntity,
  uCustomerEntity;

type
  TNFCeService = class(TInterfacedObject, INFCeService)
  private
    FNFCeRepository: INFCeRepository;
    FProductRepository: IProductRepository;
    FCustomerRepository: ICustomerRepository;
  public
    constructor Create(ANFCeRepository: INFCeRepository; AProductRepository: IProductRepository; ACustomerRepository: ICustomerRepository);

    function CreateNFCe(ACustomer: TCustomerEntity = nil): TNFCeEntity;
    function AddItemToNFCe(ANFCe: TNFCeEntity; AProduct: TProductEntity; AQuantity: Double): Boolean;
    function RemoveItemFromNFCe(ANFCe: TNFCeEntity; AItemIndex: Integer): Boolean;
    function IssueNFCe(ANFCe: TNFCeEntity): Boolean;
    function GeneratePDF(ANFCe: TNFCeEntity): string;
    function CancelNFCe(ANFCe: TNFCeEntity): Boolean;
    function GetNFCeList: TObjectList<TNFCeEntity>;
    function GetNFCeById(AId: Integer): TNFCeEntity;
    function ValidateNFCe(ANFCe: TNFCeEntity): string;
  end;

implementation

uses
  System.DateUtils,
  uDMACBr;

constructor TNFCeService.Create(ANFCeRepository: INFCeRepository; AProductRepository: IProductRepository; ACustomerRepository: ICustomerRepository);
begin
  inherited Create;
  FNFCeRepository := ANFCeRepository;
  FProductRepository := AProductRepository;
  FCustomerRepository := ACustomerRepository;
end;

function TNFCeService.AddItemToNFCe(ANFCe: TNFCeEntity; AProduct: TProductEntity; AQuantity: Double): Boolean;
var
  ValidationError: string;
begin
  Result := False;

  if not Assigned(ANFCe) then
    raise Exception.Create('NFCe não pode ser nula');

  if not Assigned(AProduct) then
    raise Exception.Create('Produto não pode ser nulo');

  if AQuantity <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero');

  if not AProduct.IsValid then
    raise Exception.Create('Produto inválido');

  try
    // Adicionar item à NFCe
    ANFCe.AddItem(AProduct, AQuantity, AProduct.Price);

    // Validar NFCe após adicionar item
    ValidationError := ValidateNFCe(ANFCe);
    if ValidationError <> '' then
    begin
      // Remover o último item adicionado se a validação falhar
      if ANFCe.Items.Count > 0 then
        ANFCe.RemoveItem(ANFCe.Items.Last);
      raise Exception.Create('Erro na validação: ' + ValidationError);
    end;

    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao adicionar item à NFCe: ' + E.Message);
  end;
end;

function TNFCeService.CancelNFCe(ANFCe: TNFCeEntity): Boolean;
begin
  Result := False;

  if not Assigned(ANFCe) then
    raise Exception.Create('NFCe não pode ser nula');

  if ANFCe.Status <> nsIssued then
    raise Exception.Create('Apenas NFCe emitidas podem ser canceladas');

  try
    ANFCe.Status := nsCanceled;
    Result := FNFCeRepository.Update(ANFCe);
  except
    on E: Exception do
      raise Exception.Create('Erro ao cancelar NFCe: ' + E.Message);
  end;
end;

function TNFCeService.CreateNFCe(ACustomer: TCustomerEntity): TNFCeEntity;
begin
  Result := TNFCeEntity.Create;
  try
    Result.Number := FNFCeRepository.GetNextNumber(1);
    Result.Series := 1;
    Result.Customer := ACustomer;
    Result.IssueDate := Now;
    Result.Status := nsPending;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao criar NFCe: ' + E.Message);
    end;
  end;
end;

function TNFCeService.GeneratePDF(ANFCe: TNFCeEntity): string;
begin
  Result := '';

  if not Assigned(ANFCe) then
    raise Exception.Create('NFCe não pode ser nula');

  if ANFCe.Status <> nsIssued then
    raise Exception.Create('Apenas NFCe emitidas podem gerar PDF');

  try
    // Gerar PDF usando ACBr
    Result := TDMACBr.GetInstance.GeneratePDF(ANFCe);

    // Atualizar caminho do PDF na entidade
    ANFCe.PDFPath := Result;
    FNFCeRepository.Update(ANFCe);
  except
    on E: Exception do
      raise Exception.Create('Erro ao gerar PDF: ' + E.Message);
  end;
end;

function TNFCeService.GetNFCeById(AId: Integer): TNFCeEntity;
begin
  try
    Result := FNFCeRepository.GetById(AId);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar NFCe: ' + E.Message);
  end;
end;

function TNFCeService.GetNFCeList: TObjectList<TNFCeEntity>;
begin
  try
    Result := FNFCeRepository.GetAll;
  except
    on E: Exception do
      raise Exception.Create('Erro ao listar NFCe: ' + E.Message);
  end;
end;

function TNFCeService.IssueNFCe(ANFCe: TNFCeEntity): Boolean;
var
  ValidationError: string;
begin
  Result := False;

  if not Assigned(ANFCe) then
    raise Exception.Create('NFCe não pode ser nula');

  // Validar NFCe antes de emitir
  ValidationError := ValidateNFCe(ANFCe);
  if ValidationError <> '' then
    raise Exception.Create('NFCe inválida: ' + ValidationError);

  try
    // Salvar NFCe com itens se ainda não foi salva
    if ANFCe.Id = 0 then
    begin
      if not FNFCeRepository.SaveWithItems(ANFCe) then
        raise Exception.Create('Erro ao salvar NFCe');
    end;

    // Emitir NFCe usando ACBr
    if not TDMACBr.GetInstance.IssueNFCe(ANFCe) then
      raise Exception.Create('Erro na emissão da NFCe pelo ACBr');

    // Atualizar status para emitida
    ANFCe.Status := nsIssued;

    // Atualizar no banco
    Result := FNFCeRepository.Update(ANFCe);

    if not Result then
      raise Exception.Create('Erro ao atualizar status da NFCe');
  except
    on E: Exception do
    begin
      ANFCe.Status := nsError;
      FNFCeRepository.Update(ANFCe);
      raise Exception.Create('Erro ao emitir NFCe: ' + E.Message);
    end;
  end;
end;

function TNFCeService.RemoveItemFromNFCe(ANFCe: TNFCeEntity; AItemIndex: Integer): Boolean;
begin
  Result := False;

  if not Assigned(ANFCe) then
    raise Exception.Create('NFCe não pode ser nula');

  if (AItemIndex < 0) or (AItemIndex >= ANFCe.Items.Count) then
    raise Exception.Create('Índice do item inválido');

  try
    ANFCe.RemoveItem(ANFCe.Items[AItemIndex]);
    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao remover item da NFCe: ' + E.Message);
  end;
end;

function TNFCeService.ValidateNFCe(ANFCe: TNFCeEntity): string;
begin
  Result := '';

  if not Assigned(ANFCe) then
  begin
    Result := 'NFCe não pode ser nula';
    Exit;
  end;

  if ANFCe.Number <= 0 then
  begin
    Result := 'Número da NFCe deve ser maior que zero';
    Exit;
  end;

  if ANFCe.Series <= 0 then
  begin
    Result := 'Série da NFCe deve ser maior que zero';
    Exit;
  end;

  if not ANFCe.HasItems then
  begin
    Result := 'NFCe deve ter pelo menos um item';
    Exit;
  end;

  if ANFCe.TotalValue <= 0 then
  begin
    Result := 'Valor total da NFCe deve ser maior que zero';
    Exit;
  end;

  // Validar se já existe uma NFCe com o mesmo número e série
  if Assigned(FNFCeRepository.GetByNumber(ANFCe.Number, ANFCe.Series)) then
  begin
    Result := Format('Já existe uma NFCe com número %d e série %d',
      [ANFCe.Number, ANFCe.Series]);
    Exit;
  end;
end;

end.

