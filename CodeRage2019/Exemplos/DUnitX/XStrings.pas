unit XStrings;

interface

uses
  System.SysUtils;

type
  TXStrings = class
  private
    FDescricao : string;
    function GetDescricao: string;
    procedure SetDescricao(const Value: string);
  public

    function SomenteNumeros(AValue: String): String;
    procedure ExemploMetodoComExcecao;
    property Descricao : string read GetDescricao write SetDescricao;
  end;

implementation

{ TTratamentoStrins }

function TXStrings.GetDescricao: string;
begin
  Result := FDescricao;
end;

procedure TXStrings.SetDescricao(const Value: string);
begin
  FDescricao := Value;
end;

function TXStrings.SomenteNumeros(AValue: String): String;
var
  I: Integer;
  Erro: String;
begin
  Result := '';
  Erro := 'AAA';

  for I := 1 to Length(AValue) do
  begin
    if AValue[I] in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'] then
    begin
      Result := Result + AValue[I];
    end;
  end;

  Result := Result ;
end;

procedure TXStrings.ExemploMetodoComExcecao;
begin
  if FDescricao = '' then
    raise Exception.Create('Necessário uma descrição!');
end;

end.
