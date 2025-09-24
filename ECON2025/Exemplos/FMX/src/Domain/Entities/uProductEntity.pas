unit uProductEntity;

interface

type
  TProductEntity = class
  private
    FId: Integer;
    FCode: string;
    FName: string;
    FDescription: string;
    FPrice: Currency;
    FStockQuantity: Integer;
    FNCM: string;
    FCFOP: string;
    FUnit: string;
  public
    constructor Create;

    property Id: Integer read FId write FId;
    property Code: string read FCode write FCode;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Price: Currency read FPrice write FPrice;
    property StockQuantity: Integer read FStockQuantity write FStockQuantity;
    property NCM: string read FNCM write FNCM;
    property CFOP: string read FCFOP write FCFOP;
    property &Unit: string read FUnit write FUnit;

    function IsValid: Boolean;
    function HasStock: Boolean;
    function GetFormattedPrice: string;
    function CalculateTotal(AQuantity: Double): Currency;
  end;

implementation

uses
  System.SysUtils;

constructor TProductEntity.Create;
begin
  inherited Create;
  FId := 0;
  FCode := '';
  FName := '';
  FDescription := '';
  FPrice := 0;
  FStockQuantity := 0;
  FNCM := '';
  FCFOP := '5102'; // CFOP padrão para venda
  FUnit := 'UN';   // Unidade padrão
end;

function TProductEntity.CalculateTotal(AQuantity: Double): Currency;
begin
  Result := FPrice * AQuantity;
end;

function TProductEntity.GetFormattedPrice: string;
begin
  Result := FormatCurr('R$ #,##0.00', FPrice);
end;

function TProductEntity.HasStock: Boolean;
begin
  Result := FStockQuantity > 0;
end;

function TProductEntity.IsValid: Boolean;
begin
  Result := (Trim(FCode) <> '') and
    (Trim(FName) <> '') and
    (FPrice > 0);
end;

end.

