unit Data.DAO.Gestante;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.Connection,
  Model.Gestante,
  Interfaces.DAO;

type
  /// <summary>
  /// Implementação do DAO para Gestante
  /// Segue os princípios SOLID e Clean Code
  /// </summary>
  TGestanteDAO = class(TInterfacedObject, IGestanteDAO)
  private
    FConnection: TDataConnection;

    function CreateGestanteFromQuery(const Query: TFDQuery): TGestante;
    procedure SetGestanteParameters(const Query: TFDQuery; const Gestante: TGestante);

  public
    constructor Create;
    destructor Destroy; override;

    // Métodos da interface IBaseDAO<TGestante>
    function Insert(const Entity: TGestante): Boolean;
    function Update(const Entity: TGestante): Boolean;
    function Delete(const Id: Integer): Boolean;
    function GetById(const Id: Integer): TGestante;
    function GetAll: TObjectList<TGestante>;
    function GetCount: Integer;

    // Métodos específicos da interface IGestanteDAO
    function GetByCPF(const CPF: string): TGestante;
    function GetByNome(const Nome: string): TObjectList<TGestante>;
    function GetAtivas: TObjectList<TGestante>;
    function GetInativas: TObjectList<TGestante>;
    function ExistsCPF(const CPF: string; const ExcludeId: Integer = 0): Boolean;
    function GetGestantesComConsultasRecentes(const Dias: Integer = 30): TObjectList<TGestante>;
    function GetGestantesPorIdadeGestacional(const SemanaMin, SemanaMax: Integer): TObjectList<TGestante>;
  end;

implementation

uses
  System.DateUtils,
  System.Variants;

{ TGestanteDAO }

constructor TGestanteDAO.Create;
begin
  inherited Create;
  FConnection := TDataConnection.GetInstance;
end;

destructor TGestanteDAO.Destroy;
begin
  // Não libera FConnection pois é Singleton
  inherited Destroy;
end;

function TGestanteDAO.CreateGestanteFromQuery(const Query: TFDQuery): TGestante;
begin
  Result := TGestante.Create;
  try
    Result.Id := Query.FieldByName('id').AsInteger;
    Result.Nome := Query.FieldByName('nome').AsString;
    Result.CPF := Query.FieldByName('cpf').AsString;
    Result.RG := Query.FieldByName('rg').AsString;
    Result.DataNascimento := Query.FieldByName('data_nascimento').AsDateTime;
    Result.Telefone := Query.FieldByName('telefone').AsString;
    Result.Celular := Query.FieldByName('celular').AsString;
    Result.Email := Query.FieldByName('email').AsString;
    Result.Endereco := Query.FieldByName('endereco').AsString;
    Result.CEP := Query.FieldByName('cep').AsString;
    Result.Cidade := Query.FieldByName('cidade').AsString;
    Result.Estado := Query.FieldByName('estado').AsString;

    if not Query.FieldByName('data_ultima_menstruacao').IsNull then
      Result.DataUltimaMenstruacao := Query.FieldByName('data_ultima_menstruacao').AsDateTime;

    if not Query.FieldByName('data_provavel_parto').IsNull then
      Result.DataProvavelParto := Query.FieldByName('data_provavel_parto').AsDateTime;

    Result.TipoSanguineo := Query.FieldByName('tipo_sanguineo').AsString;
    Result.PesoInicial := Query.FieldByName('peso_inicial').AsFloat;
    Result.Altura := Query.FieldByName('altura').AsFloat;
    Result.Observacoes := Query.FieldByName('observacoes').AsString;
    Result.Ativo := Query.FieldByName('ativo').AsBoolean;
    Result.DataCadastro := Query.FieldByName('data_cadastro').AsDateTime;
    Result.DataAlteracao := Query.FieldByName('data_alteracao').AsDateTime;
  except
    Result.Free;
    raise;
  end;
end;

procedure TGestanteDAO.SetGestanteParameters(const Query: TFDQuery; const Gestante: TGestante);
begin
  Query.ParamByName('nome').AsString := Gestante.Nome;
  Query.ParamByName('cpf').AsString := Gestante.CPF;
  Query.ParamByName('rg').AsString := Gestante.RG;
  Query.ParamByName('data_nascimento').AsDateTime := Gestante.DataNascimento;
  Query.ParamByName('telefone').AsString := Gestante.Telefone;
  Query.ParamByName('celular').AsString := Gestante.Celular;
  Query.ParamByName('email').AsString := Gestante.Email;
  Query.ParamByName('endereco').AsString := Gestante.Endereco;
  Query.ParamByName('cep').AsString := Gestante.CEP;
  Query.ParamByName('cidade').AsString := Gestante.Cidade;
  Query.ParamByName('estado').AsString := Gestante.Estado;

  if Gestante.DataUltimaMenstruacao > 0 then
    Query.ParamByName('data_ultima_menstruacao').AsDateTime := Gestante.DataUltimaMenstruacao
  else
    Query.ParamByName('data_ultima_menstruacao').Clear;

  if Gestante.DataProvavelParto > 0 then
    Query.ParamByName('data_provavel_parto').AsDateTime := Gestante.DataProvavelParto
  else
    Query.ParamByName('data_provavel_parto').Clear;

  Query.ParamByName('tipo_sanguineo').AsString := Gestante.TipoSanguineo;
  Query.ParamByName('peso_inicial').AsFloat := Gestante.PesoInicial;
  Query.ParamByName('altura').AsFloat := Gestante.Altura;
  Query.ParamByName('observacoes').AsString := Gestante.Observacoes;
  Query.ParamByName('ativo').AsBoolean := Gestante.Ativo;
end;

function TGestanteDAO.Insert(const Entity: TGestante): Boolean;
var
  Query: TFDQuery;
  SQL: string;
begin

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;

    SQL := 'INSERT INTO gestantes (' +
      '  nome, cpf, rg, data_nascimento, telefone, celular, email, ' +
      '  endereco, cep, cidade, estado, data_ultima_menstruacao, ' +
      '  data_provavel_parto, tipo_sanguineo, peso_inicial, altura, ' +
      '  observacoes, ativo, data_cadastro, data_alteracao' +
      ') VALUES (' +
      '  :nome, :cpf, :rg, :data_nascimento, :telefone, :celular, :email, ' +
      '  :endereco, :cep, :cidade, :estado, :data_ultima_menstruacao, ' +
      '  :data_provavel_parto, :tipo_sanguineo, :peso_inicial, :altura, ' +
      '  :observacoes, :ativo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP' +
      ')';

    Query.SQL.Text := SQL;
    SetGestanteParameters(Query, Entity);

    Query.ExecSQL;

    // Recupera o ID gerado
    Query.SQL.Text := 'SELECT last_insert_rowid() as id';
    Query.Open;
    Entity.Id := Query.FieldByName('id').AsInteger;

    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao inserir gestante: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.Update(const Entity: TGestante): Boolean;
var
  Query: TFDQuery;
  SQL: string;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;

    SQL := 'UPDATE gestantes SET ' +
      '  nome = :nome, cpf = :cpf, rg = :rg, ' +
      '  data_nascimento = :data_nascimento, telefone = :telefone, ' +
      '  celular = :celular, email = :email, endereco = :endereco, ' +
      '  cep = :cep, cidade = :cidade, estado = :estado, ' +
      '  data_ultima_menstruacao = :data_ultima_menstruacao, ' +
      '  data_provavel_parto = :data_provavel_parto, ' +
      '  tipo_sanguineo = :tipo_sanguineo, peso_inicial = :peso_inicial, ' +
      '  altura = :altura, observacoes = :observacoes, ativo = :ativo, ' +
      '  data_alteracao = CURRENT_TIMESTAMP ' +
      'WHERE id = :id';

    Query.SQL.Text := SQL;
    SetGestanteParameters(Query, Entity);
    Query.ParamByName('id').AsInteger := Entity.Id;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar gestante: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.Delete(const Id: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'DELETE FROM gestantes WHERE id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao excluir gestante: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.GetById(const Id: Integer): TGestante;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes WHERE id = :id';
    Query.ParamByName('id').AsInteger := Id;
    Query.Open;

    if not Query.Eof then
      Result := CreateGestanteFromQuery(Query);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar gestante por ID: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.GetAll: TObjectList<TGestante>;
var
  Query: TFDQuery;
  Gestante: TGestante;
begin
  Result := TObjectList<TGestante>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes ORDER BY nome';
    Query.Open;

    while not Query.Eof do
    begin
      Gestante := CreateGestanteFromQuery(Query);
      Result.Add(Gestante);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar todas as gestantes: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TGestanteDAO.GetCount: Integer;
var
  Query: TFDQuery;
begin

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM gestantes';
    Query.Open;
    Result := Query.FieldByName('total').AsInteger;
  except
    on E: Exception do
      raise Exception.Create('Erro ao contar gestantes: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.GetByCPF(const CPF: string): TGestante;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes WHERE cpf = :cpf';
    Query.ParamByName('cpf').AsString := CPF;
    Query.Open;

    if not Query.Eof then
      Result := CreateGestanteFromQuery(Query);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar gestante por CPF: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.GetByNome(const Nome: string): TObjectList<TGestante>;
var
  Query: TFDQuery;
  Gestante: TGestante;
begin
  Result := TObjectList<TGestante>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes WHERE nome LIKE :nome ORDER BY nome';
    Query.ParamByName('nome').AsString := '%' + Nome + '%';
    Query.Open;

    while not Query.Eof do
    begin
      Gestante := CreateGestanteFromQuery(Query);
      Result.Add(Gestante);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar gestantes por nome: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TGestanteDAO.GetAtivas: TObjectList<TGestante>;
var
  Query: TFDQuery;
  Gestante: TGestante;
begin
  Result := TObjectList<TGestante>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes WHERE ativo = 1 ORDER BY nome';
    Query.Open;

    while not Query.Eof do
    begin
      Gestante := CreateGestanteFromQuery(Query);
      Result.Add(Gestante);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar gestantes ativas: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TGestanteDAO.GetInativas: TObjectList<TGestante>;
var
  Query: TFDQuery;
  Gestante: TGestante;
begin
  Result := TObjectList<TGestante>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes WHERE ativo = 0 ORDER BY nome';
    Query.Open;

    while not Query.Eof do
    begin
      Gestante := CreateGestanteFromQuery(Query);
      Result.Add(Gestante);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar gestantes inativas: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TGestanteDAO.ExistsCPF(const CPF: string; const ExcludeId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM gestantes WHERE cpf = :cpf AND id <> :exclude_id';
    Query.ParamByName('cpf').AsString := CPF;
    Query.ParamByName('exclude_id').AsInteger := ExcludeId;
    Query.Open;
    Result := Query.FieldByName('total').AsInteger > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao verificar CPF existente: ' + E.Message);
  end;
  Query.Free;
end;

function TGestanteDAO.GetGestantesComConsultasRecentes(const Dias: Integer): TObjectList<TGestante>;
var
  Query: TFDQuery;
  Gestante: TGestante;
  DataLimite: TDateTime;
begin
  Result := TObjectList<TGestante>.Create;
  Query := TFDQuery.Create(nil);
  try
    DataLimite := IncDay(Now, -Dias);
    Query.Connection := FConnection.GetConnection;

    Query.SQL.Text := 'SELECT DISTINCT g.* FROM gestantes g ' +
      'INNER JOIN consultas c ON g.id = c.gestante_id ' +
      'WHERE c.data_consulta >= :data_limite ' +
      'ORDER BY g.nome';

    Query.ParamByName('data_limite').AsDateTime := DataLimite;
    Query.Open;

    while not Query.Eof do
    begin
      Gestante := CreateGestanteFromQuery(Query);
      Result.Add(Gestante);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar gestantes com consultas recentes: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TGestanteDAO.GetGestantesPorIdadeGestacional(const SemanaMin, SemanaMax: Integer): TObjectList<TGestante>;
var
  Query: TFDQuery;
  Gestante: TGestante;
  DataMin, DataMax: TDateTime;
begin
  Result := TObjectList<TGestante>.Create;
  Query := TFDQuery.Create(nil);
  try
    // Calcula as datas baseadas nas semanas gestacionais
    DataMax := IncDay(Now, -(SemanaMin * 7));
    DataMin := IncDay(Now, -(SemanaMax * 7));

    Query.Connection := FConnection.GetConnection;
    Query.SQL.Text := 'SELECT * FROM gestantes ' +
      'WHERE data_ultima_menstruacao BETWEEN :data_min AND :data_max ' +
      'AND ativo = 1 ' +
      'ORDER BY data_ultima_menstruacao DESC';

    Query.ParamByName('data_min').AsDateTime := DataMin;
    Query.ParamByName('data_max').AsDateTime := DataMax;
    Query.Open;

    while not Query.Eof do
    begin
      Gestante := CreateGestanteFromQuery(Query);
      Result.Add(Gestante);
      Query.Next;
    end;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.Create('Erro ao buscar gestantes por idade gestacional: ' + E.Message);
    end;
  end;
  Query.Free;
end;

end.

