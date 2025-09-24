unit uCustomerRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  uICustomerRepository,
  uCustomerEntity;

type
  TCustomerRepository = class(TInterfacedObject, ICustomerRepository)
  private
    FConnection: TFDConnection;
    function CreateCustomerFromDataSet(ADataSet: TFDQuery): TCustomerEntity;
  public
    constructor Create(AConnection: TFDConnection);

    function GetAll: TObjectList<TCustomerEntity>;
    function GetById(AId: Integer): TCustomerEntity;
    function GetByDocument(const ADocument: string): TCustomerEntity;
    function Save(ACustomer: TCustomerEntity): Boolean;
    function Update(ACustomer: TCustomerEntity): Boolean;
    function Delete(AId: Integer): Boolean;
    function Exists(AId: Integer): Boolean;
    function ExistsByDocument(const ADocument: string): Boolean;
  end;

implementation

constructor TCustomerRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TCustomerRepository.CreateCustomerFromDataSet(ADataSet: TFDQuery): TCustomerEntity;
begin
  Result := TCustomerEntity.Create;
  Result.Id := ADataSet.FieldByName('id').AsInteger;
  Result.Name := ADataSet.FieldByName('name').AsString;
  Result.Document := ADataSet.FieldByName('document').AsString;
  Result.Email := ADataSet.FieldByName('email').AsString;
  Result.Phone := ADataSet.FieldByName('phone').AsString;
  Result.Address := ADataSet.FieldByName('address').AsString;
  Result.City := ADataSet.FieldByName('city').AsString;
  Result.State := ADataSet.FieldByName('state').AsString;
  Result.ZipCode := ADataSet.FieldByName('zipcode').AsString;
end;

function TCustomerRepository.Delete(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'DELETE FROM customers WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao excluir cliente: ' + E.Message);
  end;
  Query.Free;
end;

function TCustomerRepository.Exists(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM customers WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;
    Result := Query.FieldByName('total').AsInteger > 0;
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.ExistsByDocument(const ADocument: string): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT COUNT(*) as total FROM customers WHERE document = :document';
    Query.ParamByName('document').AsString := ADocument;
    Query.Open;
    Result := Query.FieldByName('total').AsInteger > 0;
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.GetAll: TObjectList<TCustomerEntity>;
var
  Query: TFDQuery;
  Customer: TCustomerEntity;
begin
  Result := TObjectList<TCustomerEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM customers ORDER BY name';
    Query.Open;

    while not Query.Eof do
    begin
      Customer := CreateCustomerFromDataSet(Query);
      Result.Add(Customer);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.GetByDocument(const ADocument: string): TCustomerEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM customers WHERE document = :document';
    Query.ParamByName('document').AsString := ADocument;
    Query.Open;

    if not Query.IsEmpty then
      Result := CreateCustomerFromDataSet(Query);
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.GetById(AId: Integer): TCustomerEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM customers WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := CreateCustomerFromDataSet(Query);
  finally
    Query.Free;
  end;
end;

function TCustomerRepository.Save(ACustomer: TCustomerEntity): Boolean;
var
  Query: TFDQuery;
begin
  if not ACustomer.IsValid then
    raise Exception.Create('Cliente inválido para salvar');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'INSERT INTO customers (name, document, email, phone, address, city, state, zipcode) ' +
      'VALUES (:name, :document, :email, :phone, :address, :city, :state, :zipcode)';

    Query.ParamByName('name').AsString := ACustomer.Name;
    Query.ParamByName('document').AsString := ACustomer.Document;
    Query.ParamByName('email').AsString := ACustomer.Email;
    Query.ParamByName('phone').AsString := ACustomer.Phone;
    Query.ParamByName('address').AsString := ACustomer.Address;
    Query.ParamByName('city').AsString := ACustomer.City;
    Query.ParamByName('state').AsString := ACustomer.State;
    Query.ParamByName('zipcode').AsString := ACustomer.ZipCode;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;

    if Result then
    begin
      Query.SQL.Text := 'SELECT last_insert_rowid() as id';
      Query.Open;
      ACustomer.Id := Query.FieldByName('id').AsInteger;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao salvar cliente: ' + E.Message);
  end;
  Query.Free;
end;

function TCustomerRepository.Update(ACustomer: TCustomerEntity): Boolean;
var
  Query: TFDQuery;
begin
  if not ACustomer.IsValid then
    raise Exception.Create('Cliente inválido para atualizar');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'UPDATE customers SET ' +
      'name = :name, document = :document, email = :email, phone = :phone, ' +
      'address = :address, city = :city, state = :state, zipcode = :zipcode ' +
      'WHERE id = :id';

    Query.ParamByName('id').AsInteger := ACustomer.Id;
    Query.ParamByName('name').AsString := ACustomer.Name;
    Query.ParamByName('document').AsString := ACustomer.Document;
    Query.ParamByName('email').AsString := ACustomer.Email;
    Query.ParamByName('phone').AsString := ACustomer.Phone;
    Query.ParamByName('address').AsString := ACustomer.Address;
    Query.ParamByName('city').AsString := ACustomer.City;
    Query.ParamByName('state').AsString := ACustomer.State;
    Query.ParamByName('zipcode').AsString := ACustomer.ZipCode;

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar cliente: ' + E.Message);
  end;
  Query.Free;
end;

end.

