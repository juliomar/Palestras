unit Data.Connection;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Comp.DataSet;

type
  /// <summary>
  /// Classe Singleton para gerenciar a conexão com o banco SQLite
  /// Implementa o padrão Singleton garantindo uma única instância de conexão
  /// </summary>
  TDataConnection = class
  private
    class var
      FInstance: TDataConnection;
      FConnection: TFDConnection;
      FGUIxWaitCursor: TFDGUIxWaitCursor;
      FPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;

    constructor Create;
    procedure ConfigureConnection;
    procedure CreateDatabase;
    procedure CreateTables;

  public
    /// <summary>
    /// Destrutor da classe
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Método para obter a instância única da classe (Singleton)
    /// </summary>
    /// <returns>Instância única de TDataConnection</returns>
    class function GetInstance: TDataConnection;

    /// <summary>
    /// Libera a instância Singleton
    /// </summary>
    class procedure ReleaseInstance;

    /// <summary>
    /// Retorna a conexão FireDAC
    /// </summary>
    /// <returns>Instância de TFDConnection</returns>
    function GetConnection: TFDConnection;

    /// <summary>
    /// Testa a conectividade com o banco
    /// </summary>
    /// <returns>True se conectado com sucesso</returns>
    function TestConnection: Boolean;

    /// <summary>
    /// Inicia uma transação
    /// </summary>
    procedure StartTransaction;

    /// <summary>
    /// Confirma uma transação
    /// </summary>
    procedure Commit;

    /// <summary>
    /// Desfaz uma transação
    /// </summary>
    procedure Rollback;

    /// <summary>
    /// Verifica se está em transação
    /// </summary>
    /// <returns>True se em transação</returns>
    function InTransaction: Boolean;
  end;

implementation

uses
  System.IOUtils;

{ TDataConnection }

constructor TDataConnection.Create;
begin
  inherited Create;

  // Cria os componentes FireDAC
  FGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FPhysSQLiteDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  FConnection := TFDConnection.Create(nil);

  // Configura a conexão
  ConfigureConnection;

  // Cria o banco e as tabelas se necessário
  CreateDatabase;
  CreateTables;
end;

destructor TDataConnection.Destroy;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Connected := False;
    FreeAndNil(FConnection);
  end;

  FreeAndNil(FPhysSQLiteDriverLink);
  FreeAndNil(FGUIxWaitCursor);

  inherited Destroy;
end;

class function TDataConnection.GetInstance: TDataConnection;
begin
  if not Assigned(FInstance) then
    FInstance := TDataConnection.Create;
  Result := FInstance;
end;

class procedure TDataConnection.ReleaseInstance;
begin
  if Assigned(FInstance) then
  begin
    FreeAndNil(FInstance);
  end;
end;

procedure TDataConnection.ConfigureConnection;
var
  DatabasePath: string;
begin
  // Define o caminho do banco de dados
  DatabasePath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'maternidade.db');

  // Configura os parâmetros da conexão
  FConnection.Params.Clear;
  FConnection.Params.Add('Database=' + DatabasePath);
  FConnection.Params.Add('DriverID=SQLite');
  FConnection.Params.Add('LockingMode=Normal');
  FConnection.Params.Add('Synchronous=Normal');
  FConnection.Params.Add('JournalMode=WAL');
  FConnection.Params.Add('ForeignKeys=True');

  // Configura o driver
  FConnection.LoginPrompt := False;
end;

procedure TDataConnection.CreateDatabase;
begin
  try
    if not FConnection.Connected then
      FConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao conectar com o banco de dados: ' + E.Message);
  end;
end;

procedure TDataConnection.CreateTables;
var
  SQLScript: TStringList;
begin
  SQLScript := TStringList.Create;
  try
    // Tabela de Gestantes
    SQLScript.Add('CREATE TABLE IF NOT EXISTS gestantes (');
    SQLScript.Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
    SQLScript.Add('  nome VARCHAR(100) NOT NULL,');
    SQLScript.Add('  cpf VARCHAR(14) UNIQUE NOT NULL,');
    SQLScript.Add('  rg VARCHAR(20),');
    SQLScript.Add('  data_nascimento DATE NOT NULL,');
    SQLScript.Add('  telefone VARCHAR(20),');
    SQLScript.Add('  celular VARCHAR(20),');
    SQLScript.Add('  email VARCHAR(100),');
    SQLScript.Add('  endereco TEXT,');
    SQLScript.Add('  cep VARCHAR(10),');
    SQLScript.Add('  cidade VARCHAR(50),');
    SQLScript.Add('  estado VARCHAR(2),');
    SQLScript.Add('  data_ultima_menstruacao DATE,');
    SQLScript.Add('  data_provavel_parto DATE,');
    SQLScript.Add('  tipo_sanguineo VARCHAR(5),');
    SQLScript.Add('  peso_inicial DECIMAL(5,2),');
    SQLScript.Add('  altura DECIMAL(3,2),');
    SQLScript.Add('  observacoes TEXT,');
    SQLScript.Add('  ativo BOOLEAN DEFAULT 1,');
    SQLScript.Add('  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,');
    SQLScript.Add('  data_alteracao DATETIME DEFAULT CURRENT_TIMESTAMP');
    SQLScript.Add(');');
    SQLScript.Add('');

    // Tabela de Consultas
    SQLScript.Add('CREATE TABLE IF NOT EXISTS consultas (');
    SQLScript.Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
    SQLScript.Add('  gestante_id INTEGER NOT NULL,');
    SQLScript.Add('  data_consulta DATETIME NOT NULL,');
    SQLScript.Add('  peso_atual DECIMAL(5,2),');
    SQLScript.Add('  pressao_arterial VARCHAR(10),');
    SQLScript.Add('  altura_uterina DECIMAL(4,1),');
    SQLScript.Add('  batimentos_fetais INTEGER,');
    SQLScript.Add('  idade_gestacional VARCHAR(10),');
    SQLScript.Add('  observacoes TEXT,');
    SQLScript.Add('  medico_responsavel VARCHAR(100),');
    SQLScript.Add('  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,');
    SQLScript.Add('  FOREIGN KEY (gestante_id) REFERENCES gestantes(id) ON DELETE CASCADE');
    SQLScript.Add(');');
    SQLScript.Add('');

    // Tabela de Exames
    SQLScript.Add('CREATE TABLE IF NOT EXISTS exames (');
    SQLScript.Add('  id INTEGER PRIMARY KEY AUTOINCREMENT,');
    SQLScript.Add('  gestante_id INTEGER NOT NULL,');
    SQLScript.Add('  tipo_exame VARCHAR(50) NOT NULL,');
    SQLScript.Add('  data_exame DATE NOT NULL,');
    SQLScript.Add('  resultado TEXT,');
    SQLScript.Add('  observacoes TEXT,');
    SQLScript.Add('  medico_solicitante VARCHAR(100),');
    SQLScript.Add('  laboratorio VARCHAR(100),');
    SQLScript.Add('  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,');
    SQLScript.Add('  FOREIGN KEY (gestante_id) REFERENCES gestantes(id) ON DELETE CASCADE');
    SQLScript.Add(');');
    SQLScript.Add('');

    // Índices para melhor performance
    SQLScript.Add('CREATE INDEX IF NOT EXISTS idx_gestantes_cpf ON gestantes(cpf);');
    SQLScript.Add('CREATE INDEX IF NOT EXISTS idx_consultas_gestante ON consultas(gestante_id);');
    SQLScript.Add('CREATE INDEX IF NOT EXISTS idx_consultas_data ON consultas(data_consulta);');
    SQLScript.Add('CREATE INDEX IF NOT EXISTS idx_exames_gestante ON exames(gestante_id);');
    SQLScript.Add('CREATE INDEX IF NOT EXISTS idx_exames_data ON exames(data_exame);');

    // Executa o script
    FConnection.ExecSQL(SQLScript.Text);
  finally
    SQLScript.Free;
  end;
end;

function TDataConnection.GetConnection: TFDConnection;
begin
  if not FConnection.Connected then
    FConnection.Connected := True;
  Result := FConnection;
end;

function TDataConnection.TestConnection: Boolean;
begin
  try
    Result := FConnection.Connected or FConnection.Ping;
  except
    Result := False;
  end;
end;

procedure TDataConnection.StartTransaction;
begin
  if not InTransaction then
    FConnection.StartTransaction;
end;

procedure TDataConnection.Commit;
begin
  if InTransaction then
    FConnection.Commit;
end;

procedure TDataConnection.Rollback;
begin
  if InTransaction then
    FConnection.Rollback;
end;

function TDataConnection.InTransaction: Boolean;
begin
  Result := FConnection.InTransaction;
end;

initialization

finalization
  TDataConnection.ReleaseInstance;

end.

