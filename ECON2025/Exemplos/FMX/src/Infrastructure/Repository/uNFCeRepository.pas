unit uNFCeRepository;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Data.DB,
  uINFCeRepository,
  uNFCeEntity,
  uCustomerEntity,
  uProductEntity,
  system.Variants;

type
  TNFCeRepository = class(TInterfacedObject, INFCeRepository)
  private
    FConnection: TFDConnection;
    function CreateNFCeFromDataSet(ADataSet: TFDQuery): TNFCeEntity;
    function LoadNFCeItems(ANFCeId: Integer): TObjectList<TNFCeItemEntity>;
    function LoadCustomer(ACustomerId: Integer): TCustomerEntity;
    function LoadProduct(AProductId: Integer): TProductEntity;
    function SaveNFCeItems(ANFCe: TNFCeEntity): Boolean;
    function StatusToString(AStatus: TNFCeStatus): string;
    function StringToStatus(const AStatus: string): TNFCeStatus;
  public
    constructor Create(AConnection: TFDConnection);

    function GetAll: TObjectList<TNFCeEntity>;
    function GetById(AId: Integer): TNFCeEntity;
    function GetByNumber(ANumber: Integer; ASeries: Integer = 1): TNFCeEntity;
    function GetByDateRange(AStartDate, AEndDate: TDateTime): TObjectList<TNFCeEntity>;
    function GetByStatus(AStatus: TNFCeStatus): TObjectList<TNFCeEntity>;
    function Save(ANFCe: TNFCeEntity): Boolean;
    function Update(ANFCe: TNFCeEntity): Boolean;
    function Delete(AId: Integer): Boolean;
    function GetNextNumber(ASeries: Integer = 1): Integer;
    function SaveWithItems(ANFCe: TNFCeEntity): Boolean;
    function UpdateStatus(AId: Integer; AStatus: TNFCeStatus): Boolean;
  end;

implementation

constructor TNFCeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TNFCeRepository.CreateNFCeFromDataSet(ADataSet: TFDQuery): TNFCeEntity;
begin
  Result := TNFCeEntity.Create;
  Result.Id := ADataSet.FieldByName('id').AsInteger;
  Result.Number := ADataSet.FieldByName('number').AsInteger;
  Result.Series := ADataSet.FieldByName('series').AsInteger;
  Result.IssueDate := ADataSet.FieldByName('issue_date').AsDateTime;
  Result.TotalValue := ADataSet.FieldByName('total_value').AsCurrency;
  Result.XMLContent := ADataSet.FieldByName('xml_content').AsString;
  Result.PDFPath := ADataSet.FieldByName('pdf_path').AsString;
  Result.Status := StringToStatus(ADataSet.FieldByName('status').AsString);

  // Carregar cliente se existir
  if not ADataSet.FieldByName('customer_id').IsNull then
    Result.Customer := LoadCustomer(ADataSet.FieldByName('customer_id').AsInteger);

  // Carregar itens da NFCe
  Result.Items.Clear;
  Result.Items.AddRange(LoadNFCeItems(Result.Id));
end;

function TNFCeRepository.Delete(AId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  FConnection.StartTransaction;
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConnection;

      // Excluir itens primeiro
      Query.SQL.Text := 'DELETE FROM nfce_items WHERE nfce_id = :nfce_id';
      Query.ParamByName('nfce_id').AsInteger := AId;
      Query.ExecSQL;

      // Excluir NFCe
      Query.SQL.Text := 'DELETE FROM nfce WHERE id = :id';
      Query.ParamByName('id').AsInteger := AId;
      Query.ExecSQL;

      Result := Query.RowsAffected > 0;
      FConnection.Commit;
    finally
      Query.Free;
    end;
  except
    FConnection.Rollback;
    raise;
  end;
end;

function TNFCeRepository.GetAll: TObjectList<TNFCeEntity>;
var
  Query: TFDQuery;
  NFCe: TNFCeEntity;
begin
  Result := TObjectList<TNFCeEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM nfce ORDER BY issue_date DESC';
    Query.Open;

    while not Query.Eof do
    begin
      NFCe := CreateNFCeFromDataSet(Query);
      Result.Add(NFCe);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.GetByDateRange(AStartDate, AEndDate: TDateTime): TObjectList<TNFCeEntity>;
var
  Query: TFDQuery;
  NFCe: TNFCeEntity;
begin
  Result := TObjectList<TNFCeEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'SELECT * FROM nfce ' +
      'WHERE DATE(issue_date) BETWEEN DATE(:start_date) AND DATE(:end_date) ' +
      'ORDER BY issue_date DESC';
    Query.ParamByName('start_date').AsDateTime := AStartDate;
    Query.ParamByName('end_date').AsDateTime := AEndDate;
    Query.Open;

    while not Query.Eof do
    begin
      NFCe := CreateNFCeFromDataSet(Query);
      Result.Add(NFCe);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.GetById(AId: Integer): TNFCeEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM nfce WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
      Result := CreateNFCeFromDataSet(Query);
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.GetByNumber(ANumber, ASeries: Integer): TNFCeEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM nfce WHERE number = :number AND series = :series';
    Query.ParamByName('number').AsInteger := ANumber;
    Query.ParamByName('series').AsInteger := ASeries;
    Query.Open;

    if not Query.IsEmpty then
      Result := CreateNFCeFromDataSet(Query);
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.GetByStatus(AStatus: TNFCeStatus): TObjectList<TNFCeEntity>;
var
  Query: TFDQuery;
  NFCe: TNFCeEntity;
begin
  Result := TObjectList<TNFCeEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM nfce WHERE status = :status ORDER BY issue_date DESC';
    Query.ParamByName('status').AsString := StatusToString(AStatus);
    Query.Open;

    while not Query.Eof do
    begin
      NFCe := CreateNFCeFromDataSet(Query);
      Result.Add(NFCe);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.GetNextNumber(ASeries: Integer): Integer;
var
  Query: TFDQuery;
begin
  Result := 1;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT MAX(number) as max_number FROM nfce WHERE series = :series';
    Query.ParamByName('series').AsInteger := ASeries;
    Query.Open;

    if not Query.FieldByName('max_number').IsNull then
      Result := Query.FieldByName('max_number').AsInteger + 1;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.LoadCustomer(ACustomerId: Integer): TCustomerEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM customers WHERE id = :id';
    Query.ParamByName('id').AsInteger := ACustomerId;
    Query.Open;

    if not Query.IsEmpty then
    begin
      Result := TCustomerEntity.Create;
      Result.Id := Query.FieldByName('id').AsInteger;
      Result.Name := Query.FieldByName('name').AsString;
      Result.Document := Query.FieldByName('document').AsString;
      Result.Email := Query.FieldByName('email').AsString;
      Result.Phone := Query.FieldByName('phone').AsString;
      Result.Address := Query.FieldByName('address').AsString;
      Result.City := Query.FieldByName('city').AsString;
      Result.State := Query.FieldByName('state').AsString;
      Result.ZipCode := Query.FieldByName('zipcode').AsString;
    end;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.LoadNFCeItems(ANFCeId: Integer): TObjectList<TNFCeItemEntity>;
var
  Query: TFDQuery;
  Item: TNFCeItemEntity;
begin
  Result := TObjectList<TNFCeItemEntity>.Create(True);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM nfce_items WHERE nfce_id = :nfce_id ORDER BY id';
    Query.ParamByName('nfce_id').AsInteger := ANFCeId;
    Query.Open;

    while not Query.Eof do
    begin
      Item := TNFCeItemEntity.Create;
      Item.Id := Query.FieldByName('id').AsInteger;
      Item.NFCeId := Query.FieldByName('nfce_id').AsInteger;
      Item.Product := LoadProduct(Query.FieldByName('product_id').AsInteger);
      Item.Quantity := Query.FieldByName('quantity').AsFloat;
      Item.UnitPrice := Query.FieldByName('unit_price').AsCurrency;
      Item.TotalPrice := Query.FieldByName('total_price').AsCurrency;

      Result.Add(Item);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.LoadProduct(AProductId: Integer): TProductEntity;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM products WHERE id = :id';
    Query.ParamByName('id').AsInteger := AProductId;
    Query.Open;

    if not Query.IsEmpty then
    begin
      Result := TProductEntity.Create;
      Result.Id := Query.FieldByName('id').AsInteger;
      Result.Code := Query.FieldByName('code').AsString;
      Result.Name := Query.FieldByName('name').AsString;
      Result.Description := Query.FieldByName('description').AsString;
      Result.Price := Query.FieldByName('price').AsCurrency;
      Result.StockQuantity := Query.FieldByName('stock_quantity').AsInteger;
      Result.NCM := Query.FieldByName('ncm').AsString;
      Result.CFOP := Query.FieldByName('cfop').AsString;
      Result.&Unit := Query.FieldByName('unit').AsString;
    end;
  finally
    Query.Free;
  end;
end;

function TNFCeRepository.Save(ANFCe: TNFCeEntity): Boolean;
var
  Query: TFDQuery;
  CustomerId: Variant;
begin
  if not ANFCe.IsValid then
    raise Exception.Create('NFCe inválida para salvar');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    if Assigned(ANFCe.Customer) then
      CustomerId := ANFCe.Customer.Id
    else
      CustomerId := Null;

    Query.SQL.Text :=
      'INSERT INTO nfce (number, series, customer_id, issue_date, total_value, xml_content, pdf_path, status) ' +
      'VALUES (:number, :series, :customer_id, :issue_date, :total_value, :xml_content, :pdf_path, :status)';

    Query.ParamByName('number').AsInteger := ANFCe.Number;
    Query.ParamByName('series').AsInteger := ANFCe.Series;
    Query.ParamByName('customer_id').Value := CustomerId;
    Query.ParamByName('issue_date').AsDateTime := ANFCe.IssueDate;
    Query.ParamByName('total_value').AsCurrency := ANFCe.TotalValue;
    Query.ParamByName('xml_content').AsString := ANFCe.XMLContent;
    Query.ParamByName('pdf_path').AsString := ANFCe.PDFPath;
    Query.ParamByName('status').AsString := StatusToString(ANFCe.Status);

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;

    if Result then
    begin
      Query.SQL.Text := 'SELECT last_insert_rowid() as id';
      Query.Open;
      ANFCe.Id := Query.FieldByName('id').AsInteger;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao salvar NFCe: ' + E.Message);
  end;
  Query.Free;
end;

function TNFCeRepository.SaveNFCeItems(ANFCe: TNFCeEntity): Boolean;
var
  Query: TFDQuery;
  Item: TNFCeItemEntity;
begin
  Result := True;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    for Item in ANFCe.Items do
    begin
      Query.SQL.Text :=
        'INSERT INTO nfce_items (nfce_id, product_id, quantity, unit_price, total_price) ' +
        'VALUES (:nfce_id, :product_id, :quantity, :unit_price, :total_price)';

      Query.ParamByName('nfce_id').AsInteger := ANFCe.Id;
      Query.ParamByName('product_id').AsInteger := Item.Product.Id;
      Query.ParamByName('quantity').AsFloat := Item.Quantity;
      Query.ParamByName('unit_price').AsCurrency := Item.UnitPrice;
      Query.ParamByName('total_price').AsCurrency := Item.TotalPrice;

      Query.ExecSQL;

      if Query.RowsAffected = 0 then
      begin
        Result := False;
        Break;
      end;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro ao salvar itens da NFCe: ' + E.Message);
    end;
  end;
  Query.Free;
end;

function TNFCeRepository.SaveWithItems(ANFCe: TNFCeEntity): Boolean;
begin
  Result := False;
  FConnection.StartTransaction;
  try
    if Save(ANFCe) then
    begin
      if SaveNFCeItems(ANFCe) then
      begin
        FConnection.Commit;
        Result := True;
      end
      else
        FConnection.Rollback;
    end
    else
      FConnection.Rollback;
  except
    FConnection.Rollback;
    raise;
  end;
end;

function TNFCeRepository.StatusToString(AStatus: TNFCeStatus): string;
begin
  case AStatus of
    nsNone:
      Result := 'NONE';
    nsPending:
      Result := 'PENDING';
    nsIssued:
      Result := 'ISSUED';
    nsCanceled:
      Result := 'CANCELED';
    nsError:
      Result := 'ERROR';
  else
    Result := 'UNKNOWN';
  end;
end;

function TNFCeRepository.StringToStatus(const AStatus: string): TNFCeStatus;
begin
  if AStatus = 'PENDING' then
    Result := nsPending
  else if AStatus = 'ISSUED' then
    Result := nsIssued
  else if AStatus = 'CANCELED' then
    Result := nsCanceled
  else if AStatus = 'ERROR' then
    Result := nsError
  else
    Result := nsNone;
end;

function TNFCeRepository.Update(ANFCe: TNFCeEntity): Boolean;
var
  Query: TFDQuery;
  CustomerId: Variant;
begin
  if not ANFCe.IsValid then
    raise Exception.Create('NFCe inválida para atualizar');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    if Assigned(ANFCe.Customer) then
      CustomerId := ANFCe.Customer.Id
    else
      CustomerId := Null;

    Query.SQL.Text :=
      'UPDATE nfce SET ' +
      'number = :number, series = :series, customer_id = :customer_id, ' +
      'issue_date = :issue_date, total_value = :total_value, xml_content = :xml_content, ' +
      'pdf_path = :pdf_path, status = :status ' +
      'WHERE id = :id';

    Query.ParamByName('id').AsInteger := ANFCe.Id;
    Query.ParamByName('number').AsInteger := ANFCe.Number;
    Query.ParamByName('series').AsInteger := ANFCe.Series;
    Query.ParamByName('customer_id').Value := CustomerId;
    Query.ParamByName('issue_date').AsDateTime := ANFCe.IssueDate;
    Query.ParamByName('total_value').AsCurrency := ANFCe.TotalValue;
    Query.ParamByName('xml_content').AsString := ANFCe.XMLContent;
    Query.ParamByName('pdf_path').AsString := ANFCe.PDFPath;
    Query.ParamByName('status').AsString := StatusToString(ANFCe.Status);

    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar NFCe: ' + E.Message);
  end;
  Query.Free;
end;

function TNFCeRepository.UpdateStatus(AId: Integer; AStatus: TNFCeStatus): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'UPDATE nfce SET status = :status WHERE id = :id';
    Query.ParamByName('id').AsInteger := AId;
    Query.ParamByName('status').AsString := StatusToString(AStatus);
    Query.ExecSQL;
    Result := Query.RowsAffected > 0;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar status da NFCe: ' + E.Message);
  end;
  Query.Free;
end;

end.

