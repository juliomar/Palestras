unit Data.DAO.Consulta;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.Connection,
  Model.Consulta,
  Interfaces.DAO;

type
  /// <summary>
  /// Implementação do DAO para Consulta
  /// Segue os princípios SOLID e Clean Code
  /// </summary>
  TConsultaDAO = class(TInterfacedObject, IConsultaDAO)
  private
    FConnection: TDataConnection;

    function CreateConsultaFromQuery(const Query: TFDQuery): TConsulta;
    procedure SetConsultaParameters(const Query: TFDQuery; const Consulta: TConsulta);

  public
    constructor Create;
    destructor Destroy; override;

    // Métodos da interface IBaseDAO<TConsulta>
    function Insert(const Entity: TConsulta): Boolean;
    function Update(const Entity: TConsulta): Boolean;
    function Delete(const Id: Integer): Boolean;
    function GetById(const Id: Integer): TConsulta;
    function GetAll: TObjectList<TConsulta>;
    function GetCount: Integer;

    // Métodos específicos da interface IConsultaDAO
    function GetByGestante(const GestanteId: Integer): TObjectList<TConsulta>;
    function GetByPeriodo(const DataInicio, DataFim: TDateTime): TObjectList<TConsulta>;
    function GetByMedico(const Medico: string): TObjectList<TConsulta>;
    function GetUltimaConsulta(const GestanteId: Integer): TConsulta;
    function GetConsultasHoje: TObjectList<TConsulta>;
    function GetConsultasPorSemana(const DataInicio: TDateTime): TObjectList<TConsulta>;
    function GetEstatisticasPorMedico(const DataInicio, DataFim: TDateTime): TStringList;
  end;

implementation

uses
  System.DateUtils,
  System.Variants;

{ TConsultaDAO }

constructor TConsultaDAO.Create;
begin
  inherited Create;
  FConnection := TDataConnection.GetInstance;
end;

destructor TConsultaDAO.Destroy;
begin
  // Não libera FConnection pois é Singleton
  inherited Destroy;
end;

function TConsultaDAO.CreateConsultaFromQuery(const Query: TFDQuery): TConsulta;
begin
  Result := TConsulta.Create;
  try
    Result.Id := Query.FieldByName('id').AsInteger;
    Result.GestanteId := Query.FieldByName('gestante_id').AsInteger;
    Result.DataConsulta := Query.FieldByName('data_consulta').AsDateTime;
    Result.PesoAtual := Query.FieldByName('peso_atual').AsFloat;
    Result.PressaoArterial := Query.FieldByName('pressao_arterial').AsString;
    Result.AlturaUterina := Query.FieldByName('altura_uterina').AsFloat;
    Result.BatimentosFetais := Query.FieldByName('batimentos_fetais').AsInteger;
    Result.IdadeGestacional := Query.FieldByName('idade_gestacional').AsString;
    Result.Observacoes := Query.FieldByName('observacoes').AsString;
    Result.MedicoResponsavel := Query.FieldByName('medico_responsavel').AsString;
    Result.DataCadastro := Query.FieldByName('data_cadastro').AsDateTime;
  except
    Result.Free;
    raise;
  end;
end;

procedure TConsultaDAO.SetConsultaParameters(const Query: TFDQuery; const Consulta: TConsulta);
begin
  Query.ParamByName('gestante_id').AsInteger := Consulta.GestanteId;
  Query.ParamByName('data_consulta').AsDateTime := Consulta.DataConsulta;
  Query.ParamByName('peso_atual').AsFloat := Consulta.PesoAtual;
  Query.ParamByName('pressao_arterial').AsString := Consulta.PressaoArterial;
  Query.ParamByName('altura_uterina').AsFloat := Consulta.AlturaUterina;
  Query.ParamByName('batimentos_fetais').AsInteger := Consulta.BatimentosFetais;
  Query.ParamByName('idade_gestacional').AsString := Consulta.IdadeGestacional;
  Query.ParamByName('observacoes').AsString := Consulta.Observacoes;
  Query.ParamByName('medico_responsavel').AsString := Consulta.MedicoResponsavel;
end;

function TConsultaDAO.Insert(const Entity: TConsulta): Boolean;
var
  Query: TFDQuery;
  SQL: string;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;

    SQL := 'INSERT INTO consultas (' +
      '  gestante_id, data_consulta, peso_atual, pressao_arterial, ' +
      '  altura_uterina, batimentos_fetais, idade_gestacional, ' +
      '  observacoes, medico_responsavel, data_cadastro' +
      ') VALUES (' +
      '  :gestante_id, :data_consulta, :peso_atual, :pressao_arterial, ' +
      '  :altura_uterina, :batimentos_fetais, :idade_gestacional, ' +
      '  :observacoes, :medico_responsavel, CURRENT_TIMESTAMP' +
      ')';

    Query.SQL.Text := SQL;
    SetConsultaParameters(Query, Entity);

    Query.ExecSQL;

    // Recupera o ID gerado
    Query.SQL.Text := 'SELECT last_insert_rowid() as id';
    Query.Open;
    Entity.Id := Query.FieldByName('id').AsInteger;

    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao inserir consulta: ' + E.Message);
  end;
  Query.Free;
end;

function TConsultaDAO.Update(const Entity: TConsulta): Boolean;
var
  Query: TFDQuery;
  SQL: string;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;

    SQL := 'UPDATE consultas SET ' +
      '  gestante_id = :gestante_id, data_consulta = :data_consulta, ' +
      '  peso_atual = :peso_atual, pressao_arterial = :pressao_arterial, ' +
      '  altura_uterina = :altura_uterina, batimentos_fetais = :batimentos_fetais, ' +
      '  idade_gestacional = :idade_gestacional, observacoes = :observacoes, ' +
      '  medico_responsavel = :medico_responsavel ' +
      'WHERE id = :id';

    Query.SQL.Text := SQL;
    SetConsultaParameters(Query, Entity);
    Query.ParamByName('id').AsInteger := Entity.Id;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar consulta: ' + E.Message);
  end;
  Query.Free;
end;

function TConsultaDAO.Delete(const Id: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'DELETE FROM consultas WHERE id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao excluir consulta: ' + E.Message);
  end;
  Query.Free;
end;

function TConsultaDAO.GetById(const Id: Integer): TConsulta;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas WHERE id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.Open;

    if not Query.Eof then
      Result := CreateConsultaFromQuery(Query);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar consulta por ID: ' + E.Message);
  end;
  Query.Free;
end;

function TConsultaDAO.GetAll: TObjectList<TConsulta>;
var
  Query: TFDQuery;
  Consulta: TConsulta;
begin
  Result := TObjectList<TConsulta>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas ORDER BY data_consulta DESC';
    Query.Open;

    while not Query.Eof do
    begin
      Consulta := CreateConsultaFromQuery(Query);
      Result.Add(Consulta);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar todas as consultas: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TConsultaDAO.GetCount: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM consultas';
    Query.Open;
    Result := Query.FieldByName('total').AsInteger;
  except
    on E: Exception do
      raise Exception.Create('Erro ao contar consultas: ' + E.Message);
  end;
  Query.Free;
end;

function TConsultaDAO.GetByGestante(const GestanteId: Integer): TObjectList<TConsulta>;
var
  Query: TFDQuery;
  Consulta: TConsulta;
begin
  Result := TObjectList<TConsulta>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas WHERE gestante_id = :gestante_id ORDER BY data_consulta DESC';
    Query.ParamByName('gestante_id').AsInteger := GestanteId;
    Query.Open;

    while not Query.Eof do
    begin
      Consulta := CreateConsultaFromQuery(Query);
      Result.Add(Consulta);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar consultas por gestante: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TConsultaDAO.GetByPeriodo(const DataInicio, DataFim: TDateTime): TObjectList<TConsulta>;
var
  Query: TFDQuery;
  Consulta: TConsulta;
begin
  Result := TObjectList<TConsulta>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas ' +
      'WHERE data_consulta BETWEEN :data_inicio AND :data_fim ' +
      'ORDER BY data_consulta DESC';
    Query.ParamByName('data_inicio').AsDateTime := DataInicio;
    Query.ParamByName('data_fim').AsDateTime := DataFim;
    Query.Open;

    while not Query.Eof do
    begin
      Consulta := CreateConsultaFromQuery(Query);
      Result.Add(Consulta);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar consultas por período: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TConsultaDAO.GetByMedico(const Medico: string): TObjectList<TConsulta>;
var
  Query: TFDQuery;
  Consulta: TConsulta;
begin
  Result := TObjectList<TConsulta>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas ' +
      'WHERE medico_responsavel LIKE :medico ' +
      'ORDER BY data_consulta DESC';
    Query.ParamByName('medico').AsString := '%' + Medico + '%';
    Query.Open;

    while not Query.Eof do
    begin
      Consulta := CreateConsultaFromQuery(Query);
      Result.Add(Consulta);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar consultas por médico: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TConsultaDAO.GetUltimaConsulta(const GestanteId: Integer): TConsulta;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas ' +
      'WHERE gestante_id = :gestante_id ' +
      'ORDER BY data_consulta DESC LIMIT 1';
    Query.ParamByName('gestante_id').AsInteger := GestanteId;
    Query.Open;

    if not Query.Eof then
      Result := CreateConsultaFromQuery(Query);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar última consulta: ' + E.Message);
  end;
  Query.Free;
end;

function TConsultaDAO.GetConsultasHoje: TObjectList<TConsulta>;
var
  Query: TFDQuery;
  Consulta: TConsulta;
  Hoje: TDateTime;
begin
  Result := TObjectList<TConsulta>.Create;
  Query := TFDQuery.Create(nil);
  try
    Hoje := Date;
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas ' +
      'WHERE DATE(data_consulta) = DATE(:hoje) ' +
      'ORDER BY data_consulta';
    Query.ParamByName('hoje').AsDateTime := Hoje;
    Query.Open;

    while not Query.Eof do
    begin
      Consulta := CreateConsultaFromQuery(Query);
      Result.Add(Consulta);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar consultas de hoje: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TConsultaDAO.GetConsultasPorSemana(const DataInicio: TDateTime): TObjectList<TConsulta>;
var
  Query: TFDQuery;
  Consulta: TConsulta;
  DataFim: TDateTime;
begin
  Result := TObjectList<TConsulta>.Create;
  Query := TFDQuery.Create(nil);
  try
    DataFim := IncDay(DataInicio, 6);
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM consultas ' +
      'WHERE data_consulta BETWEEN :data_inicio AND :data_fim ' +
      'ORDER BY data_consulta';
    Query.ParamByName('data_inicio').AsDateTime := DataInicio;
    Query.ParamByName('data_fim').AsDateTime := DataFim;
    Query.Open;

    while not Query.Eof do
    begin
      Consulta := CreateConsultaFromQuery(Query);
      Result.Add(Consulta);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar consultas por semana: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TConsultaDAO.GetEstatisticasPorMedico(const DataInicio, DataFim: TDateTime): TStringList;
var
  Query: TFDQuery;
begin
  Result := TStringList.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT medico_responsavel, COUNT(*) as total_consultas ' +
      'FROM consultas ' +
      'WHERE data_consulta BETWEEN :data_inicio AND :data_fim ' +
      'GROUP BY medico_responsavel ' +
      'ORDER BY total_consultas DESC';
    Query.ParamByName('data_inicio').AsDateTime := DataInicio;
    Query.ParamByName('data_fim').AsDateTime := DataFim;
    Query.Open;

    while not Query.Eof do
    begin
      Result.Add(Format('%s=%d', [
            Query.FieldByName('medico_responsavel').AsString,
            Query.FieldByName('total_consultas').AsInteger
          ]));
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar estatísticas por médico: ' + E.Message);
    end;
  end;
  Query.Free;
end;

end.

