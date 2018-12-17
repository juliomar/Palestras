program Exemplo3;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  TestInsight.DUnitX,
  System.SysUtils,
  Classe.Calculadora in 'Classe.Calculadora.pas',
  Teste.Calculadora in 'Teste.Calculadora.pas';

begin
  RunRegisteredTests;

  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
