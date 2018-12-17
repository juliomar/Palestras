unit Teste.Calculadora;

interface

uses
  Classe.Calculadora,
  DUnitX.TestFramework;

type

  [TestFixture]
  TCalculadoraTeste = class(TObject)
  private
    Calculadora: TCalculadora;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [TestCase('1 e 1','1,1,2')]
    [TestCase('1 e 5','1,5,6')]
    procedure TesteAdicao(AValue1, AValue2, Experado : integer);

    [TesteCase]
    procedure TesteFalha;
  end;

implementation

procedure TCalculadoraTeste.Setup;
begin
  Calculadora := TCalculadora.Create;

end;

procedure TCalculadoraTeste.TearDown;
begin
  Calculadora.Free;
end;

procedure TCalculadoraTeste.TesteAdicao(AValue1, AValue2, Experado: integer);
var
  Atual : integer;
begin
  Atual := Calculadora.Add(AValue1, AValue2);
  Assert.AreEqual(Atual, Experado, 'Teste passou com sucesso');

end;

procedure TCalculadoraTeste.TesteFalha;
begin
  Assert.Fail('Erro no m�todo');
end;

initialization

TDUnitX.RegisterTestFixture(TCalculadoraTeste);

end.
