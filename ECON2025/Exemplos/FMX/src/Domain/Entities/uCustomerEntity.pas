unit uCustomerEntity;

interface

type
  TCustomerEntity = class
  private
    FId: Integer;
    FName: string;
    FDocument: string;
    FEmail: string;
    FPhone: string;
    FAddress: string;
    FCity: string;
    FState: string;
    FZipCode: string;
  public
    constructor Create;

    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property Document: string read FDocument write FDocument;
    property Email: string read FEmail write FEmail;
    property Phone: string read FPhone write FPhone;
    property Address: string read FAddress write FAddress;
    property City: string read FCity write FCity;
    property State: string read FState write FState;
    property ZipCode: string read FZipCode write FZipCode;

    function IsValid: Boolean;
    function GetFullAddress: string;
    function HasDocument: Boolean;
  end;

implementation

uses
  System.SysUtils;

constructor TCustomerEntity.Create;
begin
  inherited Create;
  FId := 0;
  FName := '';
  FDocument := '';
  FEmail := '';
  FPhone := '';
  FAddress := '';
  FCity := '';
  FState := '';
  FZipCode := '';
end;

function TCustomerEntity.GetFullAddress: string;
begin
  Result := Trim(FAddress);
  if (Trim(FCity) <> '') then
  begin
    if (Result <> '') then
      Result := Result + ', ';
    Result := Result + FCity;
  end;

  if (Trim(FState) <> '') then
  begin
    if (Result <> '') then
      Result := Result + ' - ';
    Result := Result + FState;
  end;

  if (Trim(FZipCode) <> '') then
  begin
    if (Result <> '') then
      Result := Result + ' - ';
    Result := Result + FZipCode;
  end;
end;

function TCustomerEntity.HasDocument: Boolean;
begin
  Result := Trim(FDocument) <> '';
end;

function TCustomerEntity.IsValid: Boolean;
begin
  Result := Trim(FName) <> '';
end;

end.

