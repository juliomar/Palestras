program Exemplo1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Classe.Pessoa in 'Classe.Pessoa.pas';

var
  MinhaPessoa: TPessoa;

begin
  try
    MinhaPessoa := TPessoa.Create;
    try
      MinhaPessoa.id         := 1;
      MinhaPessoa.nome       := 'Juliomar Marchetti';
      MinhaPessoa.nascimento := StrToDate('02/02/1984');
      MinhaPessoa.Salario := 1200;


      Writeln(format('%d - %s - %s', [MinhaPessoa.id, MinhaPessoa.nome, datetostr(MinhaPessoa.nascimento)]));
      Writeln(format('A idade é : %d', [MinhaPessoa.Idade]));

      Writeln(format('Salário R$ %n e imposto R$ %n ' ,[  MinhaPessoa.Salario,  MinhaPessoa.ImpostoRenda(  MinhaPessoa.Salario)]));

    finally
      MinhaPessoa.Free;
    end;

    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
