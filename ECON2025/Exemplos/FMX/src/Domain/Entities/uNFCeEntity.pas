unit uNFCeEntity;

interface

uses
  System.Generics.Collections,
  uCustomerEntity,
  uProductEntity;

type
  TNFCeStatus = (nsNone, nsPending, nsIssued, nsCanceled, nsError);

  TNFCeItemEntity = class
  private
    FId: Integer;
    FNFCeId: Integer;
    FProduct: TProductEntity;
    FQuantity: Double;
    FUnitPrice: Currency;
    FTotalPrice: Currency;
  public
    constructor Create;
    destructor Destroy; override;

    property Id: Integer read FId write FId;
    property NFCeId: Integer read FNFCeId write FNFCeId;
    property Product: TProductEntity read FProduct write FProduct;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property TotalPrice: Currency read FTotalPrice write FTotalPrice;

    procedure CalculateTotal;
    function IsValid: Boolean;
  end;

  TNFCeEntity = class
  private
    FId: Integer;
    FNumber: Integer;
    FSeries: Integer;
    FCustomer: TCustomerEntity;
    FIssueDate: TDateTime;
    FTotalValue: Currency;
    FXMLContent: string;
    FPDFPath: string;
    FStatus: TNFCeStatus;
    FItems: TObjectList<TNFCeItemEntity>;
  public
    constructor Create;
    destructor Destroy; override;

    property Id: Integer read FId write FId;
    property Number: Integer read FNumber write FNumber;
    property Series: Integer read FSeries write FSeries;
    property Customer: TCustomerEntity read FCustomer write FCustomer;
    property IssueDate: TDateTime read FIssueDate write FIssueDate;
    property TotalValue: Currency read FTotalValue write FTotalValue;
    property XMLContent: string read FXMLContent write FXMLContent;
    property PDFPath: string read FPDFPath write FPDFPath;
    property Status: TNFCeStatus read FStatus write FStatus;
    property Items: TObjectList<TNFCeItemEntity> read FItems;

    function AddItem(AProduct: TProductEntity; AQuantity: Double; AUnitPrice: Currency): TNFCeItemEntity;
    procedure RemoveItem(AItem: TNFCeItemEntity);
    procedure CalculateTotal;
    function IsValid: Boolean;
    function GetStatusDescription: string;
    function GetFormattedTotal: string;
    function HasItems: Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TNFCeItemEntity }

constructor TNFCeItemEntity.Create;
begin
  inherited Create;
  FId := 0;
  FNFCeId := 0;
  FProduct := nil;
  FQuantity := 0;
  FUnitPrice := 0;
  FTotalPrice := 0;
end;

destructor TNFCeItemEntity.Destroy;
begin
  // Não libera FProduct pois pode ser compartilhado
  inherited Destroy;
end;

procedure TNFCeItemEntity.CalculateTotal;
begin
  FTotalPrice := FQuantity * FUnitPrice;
end;

function TNFCeItemEntity.IsValid: Boolean;
begin
  Result := Assigned(FProduct) and
    FProduct.IsValid and
    (FQuantity > 0) and
    (FUnitPrice > 0);
end;

{ TNFCeEntity }

constructor TNFCeEntity.Create;
begin
  inherited Create;
  FId := 0;
  FNumber := 0;
  FSeries := 1;
  FCustomer := nil;
  FIssueDate := Now;
  FTotalValue := 0;
  FXMLContent := '';
  FPDFPath := '';
  FStatus := nsNone;
  FItems := TObjectList<TNFCeItemEntity>.Create(True);
end;

destructor TNFCeEntity.Destroy;
begin
  FItems.Free;
  // Não libera FCustomer pois pode ser compartilhado
  inherited Destroy;
end;

function TNFCeEntity.AddItem(AProduct: TProductEntity; AQuantity: Double; AUnitPrice: Currency): TNFCeItemEntity;
begin
  Result := TNFCeItemEntity.Create;
  Result.Product := AProduct;
  Result.Quantity := AQuantity;
  Result.UnitPrice := AUnitPrice;
  Result.CalculateTotal;

  FItems.Add(Result);
  CalculateTotal;
end;

procedure TNFCeEntity.CalculateTotal;
var
  Item: TNFCeItemEntity;
begin
  FTotalValue := 0;
  for Item in FItems do
  begin
    Item.CalculateTotal;
    FTotalValue := FTotalValue + Item.TotalPrice;
  end;
end;

function TNFCeEntity.GetFormattedTotal: string;
begin
  Result := FormatCurr('R$ #,##0.00', FTotalValue);
end;

function TNFCeEntity.GetStatusDescription: string;
begin
  case FStatus of
    nsNone:
      Result := 'Nenhum';
    nsPending:
      Result := 'Pendente';
    nsIssued:
      Result := 'Emitida';
    nsCanceled:
      Result := 'Cancelada';
    nsError:
      Result := 'Erro';
  else
    Result := 'Desconhecido';
  end;
end;

function TNFCeEntity.HasItems: Boolean;
begin
  Result := FItems.Count > 0;
end;

function TNFCeEntity.IsValid: Boolean;
begin
  Result := (FNumber > 0) and
    (FSeries > 0) and
    HasItems and
    (FTotalValue > 0);
end;

procedure TNFCeEntity.RemoveItem(AItem: TNFCeItemEntity);
begin
  if Assigned(AItem) and (FItems.IndexOf(AItem) >= 0) then
  begin
    FItems.Remove(AItem);
    CalculateTotal;
  end;
end;

end.

