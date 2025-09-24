unit uDMACBr;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  ACBrBase,
  ACBrDFe,
  ACBrNFe,
  ACBrNFeDANFeClass,
  ACBrNFCeDANFeFPDF,
  ACBrUtil.FilesIO,
  ACBrUtil.Strings,
  pcnConversao,
  pcnConversaoNFE,
  ACBrNFe.Classes,
  pcnNFeW,
  uNFCeEntity,
  uCustomerEntity,
  uProductEntity;

type
  TDMACBr = class
  private
    FACBrNFe: TACBrNFe;
    FACBrNFCeDANFeFPDF: TACBrNFCeDANFeFPDF;
    FConfigPath: string;
    FSchemaPath: string;
    FLogPath: string;
    FPDFPath: string;

    class var
      FInstance: TDMACBr;
    constructor Create;
    destructor Destroy; override;
    class destructor Destroy;

    procedure ConfigureACBr;
    procedure ConfigurePaths;
    procedure ConfigureWebService;
    procedure ConfigureDANFe;
    procedure LoadConfiguration;
    procedure SaveConfiguration;

    function GetNextNumber: Integer;
    procedure FillNFeFromEntity(ANFCe: TNFCeEntity);
    procedure FillEmitente;
    procedure FillDestinario(ACustomer: TCustomerEntity);
    procedure FillProducts(ANFCe: TNFCeEntity);
    procedure FillTotals(ANFCe: TNFCeEntity);
    procedure FillPayment;

  public
    class function GetInstance: TDMACBr;
    function IssueNFCe(ANFCe: TNFCeEntity): Boolean;
    function GeneratePDF(ANFCe: TNFCeEntity): string;
    function CancelNFCe(ANFCe: TNFCeEntity; const AReason: string): Boolean;
    function ValidateXML(const AXMLContent: string): Boolean;
  end;

implementation

uses
  System.IOUtils,
  FMX.Dialogs;

{ TDMACBr }

constructor TDMACBr.Create;
begin
  inherited;

  // Create dynamic components
  FACBrNFe := TACBrNFe.Create(nil);
  FACBrNFCeDANFeFPDF := TACBrNFCeDANFeFPDF.Create(nil);

  // Configure ACBr
  try
    ConfigureACBr;
    LoadConfiguration;
  except
    on E: Exception do
      ShowMessage('Erro ao inicializar ACBr: ' + E.Message);
  end;
end;

destructor TDMACBr.Destroy;
begin
  try
    SaveConfiguration;
  except
    // Ignorar erros ao salvar configuração
  end;

  FACBrNFCeDANFeFPDF.Free;
  FACBrNFe.Free;
  inherited;
end;

class destructor TDMACBr.Destroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TDMACBr.GetInstance: TDMACBr;
begin
  if FInstance = nil then
  begin
    FInstance := TDMACBr.Create;
  end;
  Result := FInstance;
end;

procedure TDMACBr.ConfigureACBr;
begin
  // Configurações gerais
  FACBrNFe.Configuracoes.Geral.ModeloDF := moNFCe;
  FACBrNFe.Configuracoes.Geral.VersaoDF := ve400;
  FACBrNFe.Configuracoes.Geral.FormaEmissao := teOffLine;
  FACBrNFe.Configuracoes.Geral.Salvar := True;
  FACBrNFe.Configuracoes.Geral.ExibirErroSchema := True;
  FACBrNFe.Configuracoes.Geral.RetirarAcentos := True;
  FACBrNFe.Configuracoes.Geral.RetirarEspacos := True;

  // Configurar caminhos
  ConfigurePaths;

  // Configurar WebService (mesmo offline, precisa das configurações)
  ConfigureWebService;

  // Configurar DANFe
  ConfigureDANFe;
end;

procedure TDMACBr.ConfigureDANFe;
begin
  // Configurações do PDF para NFCe
  FACBrNFCeDANFeFPDF.MostraPreview := False;
  FACBrNFCeDANFeFPDF.MostraStatus := False;
  FACBrNFCeDANFeFPDF.Logo := ExtractFilePath(ParamStr(0)) + 'logo.bmp';
//  FACBrNFCeDANFeFPDF.ArquivoPDF := FPDFPath;
end;

procedure TDMACBr.ConfigurePaths;
begin
  FConfigPath := ExtractFilePath(ParamStr(0)) + 'Config\';
  FSchemaPath := ExtractFilePath(ParamStr(0)) + 'Schemas\';
  FLogPath := ExtractFilePath(ParamStr(0)) + 'Logs\';
  FPDFPath := ExtractFilePath(ParamStr(0)) + 'PDFs\';

  // Criar diretórios se não existirem
  if not DirectoryExists(FConfigPath) then
    ForceDirectories(FConfigPath);
  if not DirectoryExists(FSchemaPath) then
    ForceDirectories(FSchemaPath);
  if not DirectoryExists(FLogPath) then
    ForceDirectories(FLogPath);
  if not DirectoryExists(FPDFPath) then
    ForceDirectories(FPDFPath);

  // Configurar caminhos no ACBr
  FACBrNFe.Configuracoes.Arquivos.PathSchemas := FSchemaPath;
  FACBrNFe.Configuracoes.Arquivos.PathNFe := FConfigPath + 'NFe\';
  FACBrNFe.Configuracoes.Arquivos.PathInu := FConfigPath + 'Inutilizacao\';
  FACBrNFe.Configuracoes.Arquivos.PathEvento := FConfigPath + 'Eventos\';
  FACBrNFe.Configuracoes.Arquivos.PathSalvar := FConfigPath + 'Salvos\';

  // Criar subdiretórios
  ForceDirectories(FACBrNFe.Configuracoes.Arquivos.PathNFe);
  ForceDirectories(FACBrNFe.Configuracoes.Arquivos.PathInu);
  ForceDirectories(FACBrNFe.Configuracoes.Arquivos.PathEvento);
  ForceDirectories(FACBrNFe.Configuracoes.Arquivos.PathSalvar);
end;

procedure TDMACBr.ConfigureWebService;
begin
  // Configurações do WebService (necessário mesmo para offline)
  FACBrNFe.Configuracoes.WebServices.UF := 'SP'; // Configurar conforme sua UF
  FACBrNFe.Configuracoes.WebServices.Ambiente := taHomologacao; // ou taProducao
  FACBrNFe.Configuracoes.WebServices.Visualizar := False;
  FACBrNFe.Configuracoes.WebServices.Salvar := True;
  FACBrNFe.Configuracoes.WebServices.AjustaAguardaConsultaRet := True;
  FACBrNFe.Configuracoes.WebServices.Tentativas := 3;
  FACBrNFe.Configuracoes.WebServices.IntervaloTentativas := 1000;
  FACBrNFe.Configuracoes.WebServices.TimeOut := 30000;

  // Proxy (se necessário)
  FACBrNFe.Configuracoes.WebServices.ProxyHost := '';
  FACBrNFe.Configuracoes.WebServices.ProxyPort := '';
  FACBrNFe.Configuracoes.WebServices.ProxyUser := '';
  FACBrNFe.Configuracoes.WebServices.ProxyPass := '';
end;

function TDMACBr.CancelNFCe(ANFCe: TNFCeEntity; const AReason: string): Boolean;
begin
  Result := False;
  // TODO: Implementar cancelamento de NFCe
  // Para NFCe offline, o cancelamento deve ser feito quando houver conexão
  ShowMessage('Cancelamento de NFCe offline não implementado nesta versão');
end;

procedure TDMACBr.FillDestinario(ACustomer: TCustomerEntity);
begin
  with FACBrNFe.NotasFiscais.Items[0].NFe.Dest do
  begin
    if Assigned(ACustomer) then
    begin
      xNome := ACustomer.Name;

      // Verificar se é CPF ou CNPJ
      if Length(ACustomer.Document) = 11 then
        CNPJCPF := ACustomer.Document
      else if Length(ACustomer.Document) = 14 then
        CNPJCPF := ACustomer.Document;

      // Endereço
      EnderDest.xLgr := ACustomer.Address;
      EnderDest.xMun := ACustomer.City;
      EnderDest.UF := ACustomer.State;
      EnderDest.CEP := StrToIntDef(OnlyNumber(ACustomer.ZipCode), 0);
      EnderDest.cPais := 1058; // Brasil
      EnderDest.xPais := 'BRASIL';

      // Contato
      if ACustomer.Email <> '' then
        Email := ACustomer.Email;
    end
    else
    begin
      // Consumidor final
      xNome := 'CONSUMIDOR FINAL';
      indIEDest := inNaoContribuinte;
    end;
  end;
end;

procedure TDMACBr.FillEmitente;
begin
  with FACBrNFe.NotasFiscais.Items[0].NFe.Emit do
  begin
    // Configurar dados do emitente (empresa)
    CNPJCPF := '12345678000195'; // Substituir pelo CNPJ real
    xNome := 'EMPRESA EXEMPLO LTDA';
    xFant := 'EMPRESA EXEMPLO';

    // Endereço
    EnderEmit.xLgr := 'RUA EXEMPLO, 123';
    EnderEmit.nro := '123';
    EnderEmit.xBairro := 'CENTRO';
    EnderEmit.cMun := 3550308; // Código do município (São Paulo)
    EnderEmit.xMun := 'SAO PAULO';
    EnderEmit.UF := 'SP';
    EnderEmit.CEP := 01000000;
    EnderEmit.cPais := 1058;
    EnderEmit.xPais := 'BRASIL';
    EnderEmit.fone := '1133334444';

    // Inscrições
    IE := '123456789012'; // Substituir pela IE real
    CRT := crtSimplesNacional; // ou crtRegimeNormal
  end;
end;

procedure TDMACBr.FillNFeFromEntity(ANFCe: TNFCeEntity);
begin
  FACBrNFe.NotasFiscais.Clear;
  FACBrNFe.NotasFiscais.Add;

  with FACBrNFe.NotasFiscais.Items[0].NFe do
  begin
    // Identificação
    Ide.cNF := Random(99999999);
    Ide.natOp := 'VENDA';
    Ide.modelo := 65; // NFCe
    Ide.serie := ANFCe.Series;
    Ide.nNF := ANFCe.Number;
    Ide.dEmi := ANFCe.IssueDate;
    Ide.tpNF := tnSaida;
    Ide.idDest := doInterna;
    Ide.cMunFG := 3550308; // Código do município
    Ide.tpImp := tiNFCe;
    Ide.tpEmis := teOffLine;
    Ide.tpAmb := taHomologacao; // ou taProducao
    Ide.finNFe := fnNormal;
    Ide.indFinal := cfConsumidorFinal;
    Ide.indPres := pcPresencial;
    Ide.procEmi := peAplicativoContribuinte;
    Ide.verProc := '1.0.0';

    // Preencher emitente
    FillEmitente;

    // Preencher destinatário
    FillDestinario(ANFCe.Customer);

    // Preencher produtos
    FillProducts(ANFCe);

    // Preencher totais
    FillTotals(ANFCe);

    // Preencher forma de pagamento
    FillPayment;
  end;
end;

procedure TDMACBr.FillPayment;
begin
  with FACBrNFe.NotasFiscais.Items[0].NFe do
  begin
    pag.Add;
    pag.Items[0].tPag := fpDinheiro; // ou fpCartaoCredito, fpCartaoDebito, etc.
    pag.Items[0].vPag := Total.ICMSTot.vNF;

    // Para NFCe, informar troco se houver
    pag.vTroco := 0;
  end;
end;

procedure TDMACBr.FillProducts(ANFCe: TNFCeEntity);
var
  I: Integer;
  Item: TNFCeItemEntity;
  Det: TDetCollectionItem;
begin
  for I := 0 to ANFCe.Items.Count - 1 do
  begin
    Item := ANFCe.Items[I];
    Det := FACBrNFe.NotasFiscais.Items[0].NFe.Det.Add;

    Det.Prod.nItem := I + 1;
    Det.Prod.cProd := Item.Product.Code;
    Det.Prod.cEAN := '';
    Det.Prod.xProd := Item.Product.Name;
    Det.Prod.NCM := Item.Product.NCM;
    Det.Prod.CFOP := Item.Product.CFOP;
    Det.Prod.uCom := Item.Product.&Unit;
    Det.Prod.qCom := Item.Quantity;
    Det.Prod.vUnCom := Item.UnitPrice;
    Det.Prod.vProd := Item.TotalPrice;
    Det.Prod.cEANTrib := '';
    Det.Prod.uTrib := Item.Product.&Unit;
    Det.Prod.qTrib := Item.Quantity;
    Det.Prod.vUnTrib := Item.UnitPrice;
    Det.Prod.indTot := itSomaTotalNFe;

    // ICMS Simples Nacional
    Det.Imposto.ICMS.orig := oeNacional;
    Det.Imposto.ICMS.CSOSN := csosn102; // Tributada sem permissão de crédito

    // PIS
    Det.Imposto.PIS.CST := pis99;
    Det.Imposto.PIS.vBC := 0;
    Det.Imposto.PIS.pPIS := 0;
    Det.Imposto.PIS.vPIS := 0;

    // COFINS
    Det.Imposto.COFINS.CST := cof99;
    Det.Imposto.COFINS.vBC := 0;
    Det.Imposto.COFINS.pCOFINS := 0;
    Det.Imposto.COFINS.vCOFINS := 0;
  end;
end;

procedure TDMACBr.FillTotals(ANFCe: TNFCeEntity);
begin
  with FACBrNFe.NotasFiscais.Items[0].NFe.Total do
  begin
    ICMSTot.vBC := 0;
    ICMSTot.vICMS := 0;
    ICMSTot.vICMSDeson := 0;
    ICMSTot.vBCST := 0;
    ICMSTot.vST := 0;
    ICMSTot.vProd := ANFCe.TotalValue;
    ICMSTot.vFrete := 0;
    ICMSTot.vSeg := 0;
    ICMSTot.vDesc := 0;
    ICMSTot.vII := 0;
    ICMSTot.vIPI := 0;
    ICMSTot.vPIS := 0;
    ICMSTot.vCOFINS := 0;
    ICMSTot.vOutro := 0;
    ICMSTot.vNF := ANFCe.TotalValue;
    ICMSTot.vTotTrib := 0;
  end;
end;

function TDMACBr.GeneratePDF(ANFCe: TNFCeEntity): string;
var
  PDFFileName: string;
begin
  Result := '';

  if ANFCe.XMLContent = '' then
    raise Exception.Create('NFCe deve ser emitida antes de gerar o PDF');

  try
    // Carregar XML na memória
    FACBrNFe.NotasFiscais.Clear;
    FACBrNFe.NotasFiscais.LoadFromString(ANFCe.XMLContent);

    // Gerar nome do arquivo PDF
    PDFFileName := FPDFPath + Format('NFCe_%d_%d.pdf', [ANFCe.Series, ANFCe.Number]);

    // Configurar arquivo de saída
//    FACBrNFCeDANFeFPDF.ArquivoPDF := PDFFileName;

    // Gerar PDF
    FACBrNFCeDANFeFPDF.ImprimirDANFE;

    if FileExists(PDFFileName) then
      Result := PDFFileName
    else
      raise Exception.Create('Erro ao gerar arquivo PDF');
  except
    on E: Exception do
      raise Exception.Create('Erro ao gerar PDF: ' + E.Message);
  end;
end;

function TDMACBr.GetNextNumber: Integer;
var
  IniFile: TIniFile;
begin
  Result := 1;
  IniFile := TIniFile.Create(FConfigPath + 'config.ini');
  try
    Result := IniFile.ReadInteger('NFCe', 'UltimoNumero', 0) + 1;
    IniFile.WriteInteger('NFCe', 'UltimoNumero', Result);
  finally
    IniFile.Free;
  end;
end;

function TDMACBr.IssueNFCe(ANFCe: TNFCeEntity): Boolean;
begin
  Result := False;

  try
    // Preencher dados da NFCe
    FillNFeFromEntity(ANFCe);

    // Gerar XML
    FACBrNFe.NotasFiscais.Items[0].GerarXML;
//    FACBrNFe.NotasFiscais.Items[0].XML';

    // Validar XML
    if not FACBrNFe.NotasFiscais.Items[0].Confirmada then
    begin
      FACBrNFe.NotasFiscais.Validar;
    end;

    // Salvar XML
    ANFCe.XMLContent := FACBrNFe.NotasFiscais.Items[0].XML;

    // Para emissão offline, apenas gerar o XML
    // Em um cenário real, seria necessário transmitir quando houver conexão

    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao emitir NFCe: ' + E.Message);
  end;
end;

procedure TDMACBr.LoadConfiguration;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(FConfigPath + 'config.ini');
  try
    // Carregar configurações salvas
    FACBrNFe.Configuracoes.WebServices.UF := IniFile.ReadString('WebService', 'UF', 'SP');

    if IniFile.ReadBool('WebService', 'Producao', False) then
      FACBrNFe.Configuracoes.WebServices.Ambiente := taProducao
    else
      FACBrNFe.Configuracoes.WebServices.Ambiente := taHomologacao;
  finally
    IniFile.Free;
  end;
end;

procedure TDMACBr.SaveConfiguration;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(FConfigPath + 'config.ini');
  try
    // Salvar configurações
    IniFile.WriteString('WebService', 'UF', FACBrNFe.Configuracoes.WebServices.UF);
    IniFile.WriteBool('WebService', 'Producao',
      FACBrNFe.Configuracoes.WebServices.Ambiente = taProducao);
  finally
    IniFile.Free;
  end;
end;

function TDMACBr.ValidateXML(const AXMLContent: string): Boolean;
begin
  Result := False;
  try
    FACBrNFe.NotasFiscais.Clear;
    FACBrNFe.NotasFiscais.LoadFromString(AXMLContent);
    FACBrNFe.NotasFiscais.Validar;
    Result := True;
  except
    on E: Exception do
    begin
      // Log do erro de validação
      Result := False;
    end;
  end;
end;

end.

