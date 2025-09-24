unit uNFCeBuilder;

interface

uses
  System.SysUtils,
  uNFCeEntity,
  uCustomerEntity,
  uProductEntity,
  uINFCeService;

type
  INFCeBuilder = interface
    ['{F2C9E6B3-1A4D-5E8F-9C2B-3D4E5F6A7B8C}']
    function WithCustomer(ACustomer: TCustomerEntity): INFCeBuilder;
    function WithNumber(ANumber: Integer): INFCeBuilder;
    function WithSeries(ASeries: Integer): INFCeBuilder;
    function AddItem(AProduct: TProductEntity; AQuantity: Double): INFCeBuilder; overload;
    function AddItem(AProduct: TProductEntity; AQuantity: Double; AUnitPrice: Currency): INFCeBuilder; overload;
    function Build: TNFCeEntity;
    function BuildAndIssue: TNFCeEntity;
  end;

  TNFCeBuilder = class(TInterfacedObject, INFCeBuilder)
  private
    FNFCe: TNFCeEntity;
    FNFCeService: INFCeService;
  public
    constructor Create(ANFCeService: INFCeService);
    destructor Destroy; override;

    function WithCustomer(ACustomer: TCustomerEntity): INFCeBuilder;
    function WithNumber(ANumber: Integer): INFCeBuilder;
    function WithSeries(ASeries: Integer): INFCeBuilder;
    function AddItem(AProduct: TProductEntity; AQuantity: Double): INFCeBuilder; overload;
    function AddItem(AProduct: TProductEntity; AQuantity: Double; AUnitPrice: Currency): INFCeBuilder; overload;
    function Build: TNFCeEntity;
    function BuildAndIssue: TNFCeEntity;

    class function New(ANFCeService: INFCeService): INFCeBuilder;
  end;

implementation

constructor TNFCeBuilder.Create(ANFCeService: INFCeService);
begin
  inherited Create;
  FNFCeService := ANFCeService;
  FNFCe := FNFCeService.CreateNFCe;
end;

destructor TNFCeBuilder.Destroy;
begin
  // Não libera FNFCe aqui pois pode ter sido retornada pelo Build
  inherited Destroy;
end;

function TNFCeBuilder.AddItem(AProduct: TProductEntity; AQuantity: Double): INFCeBuilder;
begin
  if not Assigned(AProduct) then
    raise Exception.Create('Produto não pode ser nulo');

  if AQuantity <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero');

  if not FNFCeService.AddItemToNFCe(FNFCe, AProduct, AQuantity) then
    raise Exception.Create('Erro ao adicionar item à NFCe');

  Result := Self;
end;

function TNFCeBuilder.AddItem(AProduct: TProductEntity; AQuantity: Double; AUnitPrice: Currency): INFCeBuilder;
var
  OriginalPrice: Currency;
begin
  if not Assigned(AProduct) then
    raise Exception.Create('Produto não pode ser nulo');

  if AQuantity <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero');

  if AUnitPrice <= 0 then
    raise Exception.Create('Preço unitário deve ser maior que zero');

  // Temporariamente alterar o preço do produto
  OriginalPrice := AProduct.Price;
  try
    AProduct.Price := AUnitPrice;

    if not FNFCeService.AddItemToNFCe(FNFCe, AProduct, AQuantity) then
      raise Exception.Create('Erro ao adicionar item à NFCe');
  finally
    // Restaurar preço original
    AProduct.Price := OriginalPrice;
  end;

  Result := Self;
end;

function TNFCeBuilder.Build: TNFCeEntity;
var
  ValidationError: string;
begin
  ValidationError := FNFCeService.ValidateNFCe(FNFCe);
  if ValidationError <> '' then
    raise Exception.Create('NFCe inválida: ' + ValidationError);

  Result := FNFCe;
  FNFCe := nil; // Transferir ownership
end;

function TNFCeBuilder.BuildAndIssue: TNFCeEntity;
begin
  Result := Build;
  try
    if not FNFCeService.IssueNFCe(Result) then
      raise Exception.Create('Erro ao emitir NFCe');
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao construir e emitir NFCe: ' + E.Message);
    end;
  end;
end;

class function TNFCeBuilder.New(ANFCeService: INFCeService): INFCeBuilder;
begin
  Result := TNFCeBuilder.Create(ANFCeService);
end;

function TNFCeBuilder.WithCustomer(ACustomer: TCustomerEntity): INFCeBuilder;
begin
  FNFCe.Customer := ACustomer;
  Result := Self;
end;

function TNFCeBuilder.WithNumber(ANumber: Integer): INFCeBuilder;
begin
  if ANumber <= 0 then
    raise Exception.Create('Número da NFCe deve ser maior que zero');

  FNFCe.Number := ANumber;
  Result := Self;
end;

function TNFCeBuilder.WithSeries(ASeries: Integer): INFCeBuilder;
begin
  if ASeries <= 0 then
    raise Exception.Create('Série da NFCe deve ser maior que zero');

  FNFCe.Series := ASeries;
  Result := Self;
end;

end.

