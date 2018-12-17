unit Unitx.Pessoa.test;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TClassePessoaTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    [TestCase('ValorBaixo','900')]
    [TestCase('ValorAlto','2000')]
    [TestCase('Erro','-300')]
    procedure Test1(const AValue1 : double);
  end;

implementation

uses
  Classe.Pessoa, System.SysUtils;

procedure TClassePessoaTest.Setup;
begin
end;

procedure TClassePessoaTest.TearDown;
begin
end;

procedure TClassePessoaTest.Test1(const AValue1 : double);
var
  My : TPessoa;
begin
  My := TPessoa.Create;
  try
    TDUnitX.CurrentRunner.Status(Format('Teste passou : Salario %n Imposto %n',[Avalue1,My.ImpostoRenda(AValue1)]));
  finally
    my.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TClassePessoaTest);

end.
