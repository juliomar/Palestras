unit Classe.Calculadora;

interface

type
  TCalculadora = class
    function Add(x, y: integer): integer;
  end;

implementation

{ TCalculadora }
function TCalculadora.Add(x, y: integer): integer;
begin
  result := x+Y;
end;

end.
