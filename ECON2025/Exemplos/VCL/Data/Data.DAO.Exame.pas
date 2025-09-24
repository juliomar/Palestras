unit Data.DAO.Exame;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.Connection,
  Model.Exame,
  Interfaces.DAO;

type
  /// <summary>
  /// Implementação do DAO para Exame
  /// Segue os princípios SOLID e Clean Code
  /// </summary>
  TExameDAO = class(TInterfacedObject, IExameDAO)
  private
    FConnection: TDataConnection;

    function CreateExameFromQuery(const Query: TFDQuery): TExame;
    procedure SetExameParameters(const Query: TFDQuery; const Exame: TExame);

  public
    constructor Create;
    destructor Destroy; override;

    // Métodos da interface IBaseDAO<TExame>
    function Insert(const Entity: TExame): Boolean;
    function Update(const Entity: TExame): Boolean;
    function Delete(const Id: Integer): Boolean;
    function GetById(const Id: Integer): TExame;
    function GetAll: TObjectList<TExame>;
    function GetCount: Integer;

    // Métodos específicos da interface IExameDAO
    function GetByGestante(const GestanteId: Integer): TObjectList<TExame>;
    function GetByTipo(const TipoExame: string): TObjectList<TExame>;
    function GetByPeriodo(const DataInicio, DataFim: TDateTime): TObjectList<TExame>;
    function GetByLaboratorio(const Laboratorio: string): TObjectList<TExame>;
    function GetExamesPendentes: TObjectList<TExame>;
    function GetExamesUrgentes: TObjectList<TExame>;
    function GetEstatisticasPorTipo(const DataInicio, DataFim: TDateTime): TStringList;
    function GetExamesPorGestanteETipo(const GestanteId: Integer; const TipoExame: string): TObjectList<TExame>;
  end;

implementation

uses
  System.DateUtils,
  System.Variants;

{ TExameDAO }

constructor TExameDAO.Create;
begin
  inherited Create;
  FConnection := TDataConnection.GetInstance;
end;

destructor TExameDAO.Destroy;
begin
  // Não libera FConnection pois é Singleton
  inherited Destroy;
end;

function TExameDAO.CreateExameFromQuery(const Query: TFDQuery): TExame;
begin
  Result := TExame.Create;
  try
    Result.Id := Query.FieldByName('id').AsInteger;
    Result.GestanteId := Query.FieldByName('gestante_id').AsInteger;
    Result.TipoExame := Query.FieldByName('tipo_exame').AsString;
    Result.DataExame := Query.FieldByName('data_exame').AsDateTime;
    Result.Resultado := Query.FieldByName('resultado').AsString;
    Result.Observacoes := Query.FieldByName('observacoes').AsString;
    Result.MedicoSolicitante := Query.FieldByName('medico_solicitante').AsString;
    Result.Laboratorio := Query.FieldByName('laboratorio').AsString;
    Result.DataCadastro := Query.FieldByName('data_cadastro').AsDateTime;
  except
    Result.Free;
    raise;
  end;
end;

procedure TExameDAO.SetExameParameters(const Query: TFDQuery; const Exame: TExame);
begin
  Query.ParamByName('gestante_id').AsInteger := Exame.GestanteId;
  Query.ParamByName('tipo_exame').AsString := Exame.TipoExame;
  Query.ParamByName('data_exame').AsDateTime := Exame.DataExame;
  Query.ParamByName('resultado').AsString := Exame.Resultado;
  Query.ParamByName('observacoes').AsString := Exame.Observacoes;
  Query.ParamByName('medico_solicitante').AsString := Exame.MedicoSolicitante;
  Query.ParamByName('laboratorio').AsString := Exame.Laboratorio;
end;

function TExameDAO.Insert(const Entity: TExame): Boolean;
var
  Query: TFDQuery;
  SQL: string;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;

    SQL := 'INSERT INTO exames (' +
      '  gestante_id, tipo_exame, data_exame, resultado, ' +
      '  observacoes, medico_solicitante, laboratorio, data_cadastro' +
      ') VALUES (' +
      '  :gestante_id, :tipo_exame, :data_exame, :resultado, ' +
      '  :observacoes, :medico_solicitante, :laboratorio, CURRENT_TIMESTAMP' +
      ')';

    Query.SQL.Text := SQL;
    SetExameParameters(Query, Entity);

    Query.ExecSQL;

    // Recupera o ID gerado
    Query.SQL.Text := 'SELECT last_insert_rowid() as id';
    Query.Open;
    Entity.Id := Query.FieldByName('id').AsInteger;

    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao inserir exame: ' + E.Message);
  end;
  Query.Free;
end;

function TExameDAO.Update(const Entity: TExame): Boolean;
var
  Query: TFDQuery;
  SQL: string;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;

    SQL := 'UPDATE exames SET ' +
      '  gestante_id = :gestante_id, tipo_exame = :tipo_exame, ' +
      '  data_exame = :data_exame, resultado = :resultado, ' +
      '  observacoes = :observacoes, medico_solicitante = :medico_solicitante, ' +
      '  laboratorio = :laboratorio ' +
      'WHERE id = :id';

    Query.SQL.Text := SQL;
    SetExameParameters(Query, Entity);
    Query.ParamByName('id').AsInteger := Entity.Id;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar exame: ' + E.Message);
  end;
  Query.Free;
end;

function TExameDAO.Delete(const Id: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'DELETE FROM exames WHERE id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao excluir exame: ' + E.Message);
  end;
  Query.Free;
end;

function TExameDAO.GetById(const Id: Integer): TExame;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames WHERE id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.Open;

    if not Query.Eof then
      Result := CreateExameFromQuery(Query);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar exame por ID: ' + E.Message);
  end;
  Query.Free;
end;

function TExameDAO.GetAll: TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ORDER BY data_exame DESC';
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar todos os exames: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetCount: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM exames';
    Query.Open;
    Result := Query.FieldByName('total').AsInteger;
  except
    on E: Exception do
      raise Exception.Create('Erro ao contar exames: ' + E.Message);
  end;
  Query.Free;
end;

function TExameDAO.GetByGestante(const GestanteId: Integer): TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames WHERE gestante_id = :gestante_id ORDER BY data_exame DESC';
    Query.ParamByName('gestante_id').AsInteger := GestanteId;
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames por gestante: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetByTipo(const TipoExame: string): TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ' +
      'WHERE tipo_exame LIKE :tipo_exame ' +
      'ORDER BY data_exame DESC';
    Query.ParamByName('tipo_exame').AsString := '%' + TipoExame + '%';
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames por tipo: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetByPeriodo(const DataInicio, DataFim: TDateTime): TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ' +
      'WHERE data_exame BETWEEN :data_inicio AND :data_fim ' +
      'ORDER BY data_exame DESC';
    Query.ParamByName('data_inicio').AsDateTime := DataInicio;
    Query.ParamByName('data_fim').AsDateTime := DataFim;
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames por período: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetByLaboratorio(const Laboratorio: string): TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ' +
      'WHERE laboratorio LIKE :laboratorio ' +
      'ORDER BY data_exame DESC';
    Query.ParamByName('laboratorio').AsString := '%' + Laboratorio + '%';
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames por laboratório: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetExamesPendentes: TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ' +
      'WHERE (resultado IS NULL OR resultado = "") ' +
      'ORDER BY data_exame';
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames pendentes: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetExamesUrgentes: TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
  TiposUrgentes: string;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    TiposUrgentes := 'CARDIOTOCOGRAFIA,PERFIL BIOFÍSICO FETAL,DOPPLER,AMNIOCENTESE,GLICEMIA,HEMOGRAMA';

    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ' +
      'WHERE UPPER(tipo_exame) IN (' +
      '  "CARDIOTOCOGRAFIA", "PERFIL BIOFÍSICO FETAL", "DOPPLER", ' +
      '  "AMNIOCENTESE", "GLICEMIA", "HEMOGRAMA"' +
      ') ' +
      'ORDER BY data_exame';
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames urgentes: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetEstatisticasPorTipo(const DataInicio, DataFim: TDateTime): TStringList;
var
  Query: TFDQuery;
begin
  Result := TStringList.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT tipo_exame, COUNT(*) as total_exames ' +
      'FROM exames ' +
      'WHERE data_exame BETWEEN :data_inicio AND :data_fim ' +
      'GROUP BY tipo_exame ' +
      'ORDER BY total_exames DESC';
    Query.ParamByName('data_inicio').AsDateTime := DataInicio;
    Query.ParamByName('data_fim').AsDateTime := DataFim;
    Query.Open;

    while not Query.Eof do
    begin
      Result.Add(Format('%s=%d', [
            Query.FieldByName('tipo_exame').AsString,
            Query.FieldByName('total_exames').AsInteger
          ]));
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar estatísticas por tipo: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TExameDAO.GetExamesPorGestanteETipo(const GestanteId: Integer; const TipoExame: string): TObjectList<TExame>;
var
  Query: TFDQuery;
  Exame: TExame;
begin
  Result := TObjectList<TExame>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM exames ' +
      'WHERE gestante_id = :gestante_id ' +
      'AND tipo_exame LIKE :tipo_exame ' +
      'ORDER BY data_exame DESC';
    Query.ParamByName('gestante_id').AsInteger := GestanteId;
    Query.ParamByName('tipo_exame').AsString := '%' + TipoExame + '%';
    Query.Open;

    while not Query.Eof do
    begin
      Exame := CreateExameFromQuery(Query);
      Result.Add(Exame);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar exames por gestante e tipo: ' + E.Message);
    end;
  end;
  Query.Free;
end;

end.

