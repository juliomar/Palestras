unit uDMConnection;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI;

type
  TDMConnection = class
  private
    FConnection: TFDConnection;
    FWaitCursor: TFDGUIxWaitCursor;
    FDriverLink: TFDPhysSQLiteDriverLink;
    procedure CreateTables;
    class var
      FInstance: TDMConnection;
  public
    constructor Create;
    destructor Destroy; override;
    class destructor Destroy;

    class function GetInstance: TDMConnection;
    property Connection: TFDConnection read FConnection;
  end;

implementation

{ TDMConnection }

constructor TDMConnection.Create;
begin
  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'SQLite';
  FConnection.Params.Add('Database=' + ExtractFilePath(ParamStr(0)) + 'nfce.db');
  FConnection.Params.Add('DriverID=SQLite');
  FConnection.Params.Add('LockingMode=Normal');
  FConnection.Params.Add('Synchronous=Normal');
  FConnection.Params.Add('JournalMode=WAL');
  FConnection.Params.Add('ForeignKeys=True');
  FConnection.Connected := True;

  // Create tables
  CreateTables;
end;

procedure TDMConnection.CreateTables;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // Tabela de Clientes
    Query.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS customers (' +
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  name VARCHAR(100) NOT NULL,' +
      '  document VARCHAR(20),' +
      '  email VARCHAR(100),' +
      '  phone VARCHAR(20),' +
      '  address VARCHAR(200),' +
      '  city VARCHAR(50),' +
      '  state VARCHAR(2),' +
      '  zipcode VARCHAR(10),' +
      '  created_at DATETIME DEFAULT CURRENT_TIMESTAMP' +
      ')';
    Query.ExecSQL;

    // Tabela de Produtos
    Query.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS products (' +
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  code VARCHAR(20) UNIQUE NOT NULL,' +
      '  name VARCHAR(100) NOT NULL,' +
      '  description TEXT,' +
      '  price DECIMAL(10,2) NOT NULL,' +
      '  stock_quantity INTEGER DEFAULT 0,' +
      '  ncm VARCHAR(10),' +
      '  cfop VARCHAR(4) DEFAULT "5102",' +
      '  unit VARCHAR(10) DEFAULT "UN",' +
      '  created_at DATETIME DEFAULT CURRENT_TIMESTAMP' +
      ')';
    Query.ExecSQL;

    // Tabela de NFCe
    Query.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS nfce (' +
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  number INTEGER NOT NULL,' +
      '  series INTEGER DEFAULT 1,' +
      '  customer_id INTEGER,' +
      '  issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,' +
      '  total_value DECIMAL(10,2) NOT NULL,' +
      '  xml_content TEXT,' +
      '  pdf_path VARCHAR(500),' +
      '  status VARCHAR(20) DEFAULT "PENDING",' +
      '  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,' +
      '  FOREIGN KEY (customer_id) REFERENCES customers(id)' +
      ')';
    Query.ExecSQL;

    // Tabela de Itens da NFCe
    Query.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS nfce_items (' +
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  nfce_id INTEGER NOT NULL,' +
      '  product_id INTEGER NOT NULL,' +
      '  quantity DECIMAL(10,3) NOT NULL,' +
      '  unit_price DECIMAL(10,2) NOT NULL,' +
      '  total_price DECIMAL(10,2) NOT NULL,' +
      '  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,' +
      '  FOREIGN KEY (nfce_id) REFERENCES nfce(id),' +
      '  FOREIGN KEY (product_id) REFERENCES products(id)' +
      ')';
    Query.ExecSQL;

    // Inserir alguns dados de exemplo
    Query.SQL.Text :=
      'INSERT OR IGNORE INTO products (code, name, price, ncm, cfop) VALUES ' +
      '("001", "Produto Teste 1", 10.50, "12345678", "5102"), ' +
      '("002", "Produto Teste 2", 25.00, "87654321", "5102")';
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

destructor TDMConnection.Destroy;
begin
  if Assigned(FConnection) then
    FConnection.Free;
  if Assigned(FWaitCursor) then
    FWaitCursor.Free;
  if Assigned(FDriverLink) then
    FDriverLink.Free;
  inherited;
end;

class destructor TDMConnection.Destroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TDMConnection.GetInstance: TDMConnection;
begin
  if not Assigned(FInstance) then
    FInstance := TDMConnection.Create;
  Result := FInstance;
end;

end.

