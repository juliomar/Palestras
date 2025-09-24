unit uProductRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  uIProductRepository,
  uProductEntity;

type
  TProductRepository = class(TInterfacedObject, IProductRepository)
  private
    FConnection: TFDConnection;
    function CreateProductFromDataSet(ADataSet: TFDQuery): TProductEntity;
  public
    constructor Create(AConnection: TFDConnection);

    function GetAll: TObjectList<TProductEntity>;
    function GetById(AId: Integer): TProductEntity;
    function GetByCode(const ACode: string): TProductEntity;
    function Search(const ASearchTerm: string): TObjectList<TProductEntity>;
    function Save(AProduct: TProductEntity): Boolean;
    function Update(AProduct: TProductEntity): Boolean;
    function Delete(AId: Integer): Boolean;
    function Exists(AId: Integer): Boolean;
    function ExistsByCode(const ACode: string): Boolean;
    function UpdateStock(AProductId: Integer; ANewQuantity: Integer): Boolean;
  end;

implementation

constructor TProductRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TProductRepository.CreateProductFromDataSet(ADataSet: TFDQuery): TProductEntity;
begin
  Result := TProductEntity.Create;
  Result.Id := ADataSet.FieldByName('id').AsInteger;
  Result.Code := ADataSet.FieldByName('code').AsString;
  Result.Name := ADataSet.FieldByName('name').AsString;
  Result.Description := ADataSet.FieldByName('description').AsString;
  Result.Price := ADataSet.FieldByName('price').AsCurrency;
  Result.StockQuantity := ADataSet.FieldByName('stock_quantity').AsInteger;
  Result.NCM := ADataSet.FieldByName('ncm').AsString;
  Result.CFOP := ADataSet.FieldByName('cfop').AsString;
  Result.&Unit := ADataSet.FieldByName('unit').AsString;
end;

function TProductRepository.Delete(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'DELETE FROM products WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao excluir produto: ' + E.Message);
  end;
  Query.Free;
end;

function TProductRepository.Exists(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM products WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;
    Result := Query.FieldByName('total').AsInteger > 0;
  finally
    Query.Free;
  end;
end;

function TProductRepository.ExistsByCode(const ACode: string): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM products WHERE code = :code';
    Query.ParamByName('code').AsString := ACode;
    Query.Open;
    Result := Query.FieldByName('total').AsInteger > 0;
  finally
    Query.Free;
  end;
end;

function TProductRepository.GetAll: TObjectList<TProductEntity>;
var
  Query: TFDQuery;
  Product: TProductEntity;
begin
  Result := TObjectList<TProductEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM products ORDER BY name';
    Query.Open;

    while not Query.Eof do
    begin
      Product := CreateProductFromDataSet(Query);
      Result.Add(Product);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TProductRepository.GetByCode(const ACode: string): TProductEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM products WHERE code = :code';
    Query.ParamByName('code').AsString := ACode;
    Query.Open;

    if not Query.IsEmpty then
      Result := CreateProductFromDataSet(Query);
  finally
    Query.Free;
  end;
end;

function TProductRepository.GetById(AId: Integer): TProductEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM products WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := CreateProductFromDataSet(Query);
  finally
    Query.Free;
  end;
end;

function TProductRepository.Save(AProduct: TProductEntity): Boolean;
var
  Query: TFDQuery;
begin
  if not AProduct.IsValid then
    raise Exception.Create('Produto inválido para salvar');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'INSERT INTO products (code, name, description, price, stock_quantity, ncm, cfop, unit) ' +
      'VALUES (:code, :name, :description, :price, :stock_quantity, :ncm, :cfop, :unit)';

    Query.ParamByName('code').AsString := AProduct.Code;
    Query.ParamByName('name').AsString := AProduct.Name;
    Query.ParamByName('description').AsString := AProduct.Description;
    Query.ParamByName('price').AsCurrency := AProduct.Price;
    Query.ParamByName('stock_quantity').AsInteger := AProduct.StockQuantity;
    Query.ParamByName('ncm').AsString := AProduct.NCM;
    Query.ParamByName('cfop').AsString := AProduct.CFOP;
    Query.ParamByName('unit').AsString := AProduct.&Unit;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;

    if Result then
    begin
      Query.SQL.Text := 'SELECT last_insert_rowid() as id';
      Query.Open;
      AProduct.Id := Query.FieldByName('id').AsInteger;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao salvar produto: ' + E.Message);
  end;
  Query.Free;
end;

function TProductRepository.Search(const ASearchTerm: string): TObjectList<TProductEntity>;
var
  Query: TFDQuery;
  Product: TProductEntity;
begin
  Result := TObjectList<TProductEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'SELECT * FROM products ' +
      'WHERE name LIKE :search OR code LIKE :search OR description LIKE :search ' +
      'ORDER BY name';
    Query.ParamByName('search').AsString := '%' + ASearchTerm + '%';
    Query.Open;

    while not Query.Eof do
    begin
      Product := CreateProductFromDataSet(Query);
      Result.Add(Product);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TProductRepository.Update(AProduct: TProductEntity): Boolean;
var
  Query: TFDQuery;
begin
  if not AProduct.IsValid then
    raise Exception.Create('Produto inválido para atualizar');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'UPDATE products SET ' +
      'code = :code, name = :name, description = :description, price = :price, ' +
      'stock_quantity = :stock_quantity, ncm = :ncm, cfop = :cfop, unit = :unit ' +
      'WHERE id = :id';

    Query.ParamByName('id').AsInteger := AProduct.Id;
    Query.ParamByName('code').AsString := AProduct.Code;
    Query.ParamByName('name').AsString := AProduct.Name;
    Query.ParamByName('description').AsString := AProduct.Description;
    Query.ParamByName('price').AsCurrency := AProduct.Price;
    Query.ParamByName('stock_quantity').AsInteger := AProduct.StockQuantity;
    Query.ParamByName('ncm').AsString := AProduct.NCM;
    Query.ParamByName('cfop').AsString := AProduct.CFOP;
    Query.ParamByName('unit').AsString := AProduct.&Unit;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar produto: ' + E.Message);
  end;
  Query.Free;
end;

function TProductRepository.UpdateStock(AProductId, ANewQuantity: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'UPDATE products SET stock_quantity = :quantity WHERE id = :id';
    Query.ParamByName('id').AsInteger := AProductId;
    Query.ParamByName('quantity').AsInteger := ANewQuantity;
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar estoque: ' + E.Message);
  end;
  Query.Free;
end;

end.

