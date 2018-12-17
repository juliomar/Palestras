unit Classe.Pessoa;

interface

uses
  System.dateutils, System.SysUtils;

type
  TPessoa = class
  private
    fnascimento: tdate;
    fid: integer;
    FIdade: integer;
    fnome: string;
    fSalario: double;
    procedure SetIdade(const Value: integer);
    procedure setnascimento(const Value: tdate);
  public
    property id : integer read fid write fid;
    property nome : string read fnome write fnome;
    property nascimento : tdate read fnascimento write setnascimento;
    property Idade : integer read fIdade ;
    property Salario : double read fSalario write fSalario;

    function ImpostoRenda(ASalario : double): double;
  end;

implementation

{ TPessoa }

function TPessoa.ImpostoRenda(ASalario: double): double;
var
  taxa : double;
begin
  if ASalario <= 0 then
    raise Exception.Create('Não é possível calcular');

  if ASalario < 1000 then
    taxa := 5
  else
  if (ASalario >= 1000) and (ASalario <= 1500) then
    taxa := 9
  else
    taxa := 15;


  Result := (ASalario * taxa) / 100;
end;

procedure TPessoa.SetIdade(const Value: integer);
begin
  FIdade := Value;
end;

procedure TPessoa.setnascimento(const Value: tdate);
begin
  fnascimento := Value;

  SetIdade( YearsBetween(now, nascimento));
end;

end.
