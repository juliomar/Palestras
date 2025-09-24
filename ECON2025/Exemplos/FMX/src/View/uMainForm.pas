unit uMainForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.TabControl,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Edit,
  FMX.Grid.Style,
  FMX.Grid,
  FMX.ScrollBox,
  FMX.Memo,
  System.Generics.Collections,
  System.Rtti,
  System.Bindings.Outputs,
  Fmx.Bind.Editors,
  Data.Bind.Components,
  uNFCeEntity,
  uProductEntity,
  uCustomerEntity,
  uNFCeService,
  uProductRepository,
  uCustomerRepository,
  uNFCeBuilder,
  uDIContainer,
  FMX.Memo.Types;

type
  TMainForm = class(TForm)
    TabControl1: TTabControl;
    TabItemNFCe: TTabItem;
    TabItemProducts: TTabItem;
    TabItemCustomers: TTabItem;
    TabItemReports: TTabItem;
    LayoutMain: TLayout;
    LayoutHeader: TLayout;
    LabelTitle: TLabel;
    LayoutNFCe: TLayout;
    LayoutNFCeHeader: TLayout;
    ButtonNewNFCe: TButton;
    ButtonIssueNFCe: TButton;
    ButtonGeneratePDF: TButton;
    LayoutNFCeContent: TLayout;
    LayoutCustomer: TLayout;
    LabelCustomer: TLabel;
    ComboBoxCustomers: TComboBox;
    LayoutItems: TLayout;
    LabelItems: TLabel;
    GridItems: TGrid;
    LayoutAddItem: TLayout;
    ComboBoxProducts: TComboBox;
    EditQuantity: TEdit;
    ButtonAddItem: TButton;
    LayoutTotal: TLayout;
    LabelTotal: TLabel;
    LabelTotalValue: TLabel;
    LayoutProducts: TLayout;
    LayoutProductsHeader: TLayout;
    ButtonNewProduct: TButton;
    GridProducts: TGrid;
    LayoutCustomers: TLayout;
    LayoutCustomersHeader: TLayout;
    ButtonNewCustomer: TButton;
    GridCustomers: TGrid;
    LayoutReports: TLayout;
    GridNFCeList: TGrid;
    ButtonRefreshReports: TButton;
    MemoNFCeInfo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonNewNFCeClick(Sender: TObject);
    procedure ButtonAddItemClick(Sender: TObject);
    procedure ButtonIssueNFCeClick(Sender: TObject);
    procedure ButtonGeneratePDFClick(Sender: TObject);
    procedure ButtonRefreshReportsClick(Sender: TObject);
    procedure GridNFCeListCellClick(const Column: TColumn; const Row: Integer);
    procedure GridNFCeListGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridItemsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure ComboBoxCustomersChange(Sender: TObject);
  private
    FCurrentNFCe: TNFCeEntity;
    FNFCeService: TNFCeService;
    FProductRepository: TProductRepository;
    FCustomerRepository: TCustomerRepository;
    FProducts: TObjectList<TProductEntity>;
    FCustomers: TObjectList<TCustomerEntity>;
    FNFCeList: TObjectList<TNFCeEntity>;

    procedure InitializeDependencies;
    procedure LoadProducts;
    procedure LoadCustomers;
    procedure LoadNFCeList;
    procedure UpdateItemsGrid;
    procedure UpdateTotal;
    procedure ClearCurrentNFCe;
    procedure ShowMessage(const AMessage: string);
    procedure ShowError(const AError: string);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  FMX.DialogService;

{$R *.fmx}

procedure TMainForm.ButtonAddItemClick(Sender: TObject);
var
  Product: TProductEntity;
  Quantity: Double;
  ItemIndex: Integer;
begin
  if not Assigned(FCurrentNFCe) then
  begin
    ShowError('Crie uma nova NFCe primeiro');
    Exit;
  end;

  ItemIndex := ComboBoxProducts.ItemIndex;
  if ItemIndex < 0 then
  begin
    ShowError('Selecione um produto');
    Exit;
  end;

  if not TryStrToFloat(EditQuantity.Text, Quantity) or (Quantity <= 0) then
  begin
    ShowError('Informe uma quantidade válida');
    Exit;
  end;

  try
    Product := FProducts[ItemIndex];
    if FNFCeService.AddItemToNFCe(FCurrentNFCe, Product, Quantity) then
    begin
      UpdateItemsGrid;
      UpdateTotal;
      EditQuantity.Text := '1';
      ComboBoxProducts.ItemIndex := -1;
    end;
  except
    on E: Exception do
      ShowError('Erro ao adicionar item: ' + E.Message);
  end;
end;

procedure TMainForm.ButtonGeneratePDFClick(Sender: TObject);
var
  PDFPath: string;
begin
  if not Assigned(FCurrentNFCe) then
  begin
    ShowError('Selecione uma NFCe');
    Exit;
  end;

  if FCurrentNFCe.Status <> nsIssued then
  begin
    ShowError('Apenas NFCe emitidas podem gerar PDF');
    Exit;
  end;

  try
    PDFPath := FNFCeService.GeneratePDF(FCurrentNFCe);
    ShowMessage('PDF gerado com sucesso: ' + PDFPath);
  except
    on E: Exception do
      ShowError('Erro ao gerar PDF: ' + E.Message);
  end;
end;

procedure TMainForm.ButtonIssueNFCeClick(Sender: TObject);
begin
  if not Assigned(FCurrentNFCe) then
  begin
    ShowError('Crie uma nova NFCe primeiro');
    Exit;
  end;

  if not FCurrentNFCe.HasItems then
  begin
    ShowError('Adicione pelo menos um item à NFCe');
    Exit;
  end;

  try
    if FNFCeService.IssueNFCe(FCurrentNFCe) then
    begin
      ShowMessage('NFCe emitida com sucesso!');
      LoadNFCeList;
      ClearCurrentNFCe;
    end;
  except
    on E: Exception do
      ShowError('Erro ao emitir NFCe: ' + E.Message);
  end;
end;

procedure TMainForm.ButtonNewNFCeClick(Sender: TObject);
begin
  try
    ClearCurrentNFCe;
    FCurrentNFCe := FNFCeService.CreateNFCe;
    UpdateItemsGrid;
    UpdateTotal;
    ShowMessage('Nova NFCe criada');
  except
    on E: Exception do
      ShowError('Erro ao criar NFCe: ' + E.Message);
  end;
end;

procedure TMainForm.ButtonRefreshReportsClick(Sender: TObject);
begin
  LoadNFCeList;
end;

procedure TMainForm.ClearCurrentNFCe;
begin
  if Assigned(FCurrentNFCe) then
  begin
    FCurrentNFCe.Free;
    FCurrentNFCe := nil;
  end;
  ComboBoxCustomers.ItemIndex := -1;
  UpdateItemsGrid;
  UpdateTotal;
end;

procedure TMainForm.ComboBoxCustomersChange(Sender: TObject);
var
  CustomerIndex: Integer;
begin
  if not Assigned(FCurrentNFCe) then
    Exit;

  CustomerIndex := ComboBoxCustomers.ItemIndex;
  if CustomerIndex >= 0 then
    FCurrentNFCe.Customer := FCustomers[CustomerIndex]
  else
    FCurrentNFCe.Customer := nil;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FCurrentNFCe := nil;
  FProducts := TObjectList<TProductEntity>.Create(False);
  FCustomers := TObjectList<TCustomerEntity>.Create(False);
  FNFCeList := TObjectList<TNFCeEntity>.Create(False);

  InitializeDependencies;
  LoadProducts;
  LoadCustomers;
  LoadNFCeList;

  EditQuantity.Text := '1';
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ClearCurrentNFCe;
  FProducts.Free;
  FCustomers.Free;
  FNFCeList.Free;
end;

procedure TMainForm.GridNFCeListCellClick(const Column: TColumn; const Row: Integer);
var
  NFCe: TNFCeEntity;
begin
  if (Row >= 0) and (Row < FNFCeList.Count) then
  begin
    NFCe := FNFCeList[Row];
    MemoNFCeInfo.Lines.Clear;
    MemoNFCeInfo.Lines.Add('NFCe #' + IntToStr(NFCe.Number));
    MemoNFCeInfo.Lines.Add('Série: ' + IntToStr(NFCe.Series));
    MemoNFCeInfo.Lines.Add('Data: ' + DateTimeToStr(NFCe.IssueDate));
    MemoNFCeInfo.Lines.Add('Status: ' + NFCe.GetStatusDescription);
    MemoNFCeInfo.Lines.Add('Total: ' + NFCe.GetFormattedTotal);

    if Assigned(NFCe.Customer) then
      MemoNFCeInfo.Lines.Add('Cliente: ' + NFCe.Customer.Name)
    else
      MemoNFCeInfo.Lines.Add('Cliente: Consumidor Final');

    MemoNFCeInfo.Lines.Add('');
    MemoNFCeInfo.Lines.Add('Itens:');

    var Item: TNFCeItemEntity;
    for Item in NFCe.Items do
    begin
      MemoNFCeInfo.Lines.Add(Format('- %s (%.3f x %s = %s)',
          [Item.Product.Name, Item.Quantity,
            FormatCurr('R$ #,##0.00', Item.UnitPrice),
            FormatCurr('R$ #,##0.00', Item.TotalPrice)]));
    end;
  end;
end;

procedure TMainForm.InitializeDependencies;
begin
  try
    FNFCeService := TDIContainer.Resolve<TNFCeService>;
    FProductRepository := TDIContainer.Resolve<TProductRepository>;
    FCustomerRepository := TDIContainer.Resolve<TCustomerRepository>;
  except
    on E: Exception do
      ShowError('Erro ao inicializar dependências: ' + E.Message);
  end;
end;

procedure TMainForm.LoadCustomers;
var
  Customers: TObjectList<TCustomerEntity>;
  Customer: TCustomerEntity;
begin
  try
    FCustomers.Clear;
    ComboBoxCustomers.Items.Clear;

    Customers := FCustomerRepository.GetAll;
    try
      ComboBoxCustomers.Items.Add('Consumidor Final');

      for Customer in Customers do
      begin
        FCustomers.Add(Customer);
        ComboBoxCustomers.Items.Add(Customer.Name);
      end;
    finally
      Customers.Free;
    end;
  except
    on E: Exception do
      ShowError('Erro ao carregar clientes: ' + E.Message);
  end;
end;

procedure TMainForm.LoadNFCeList;
var
  NFCeList: TObjectList<TNFCeEntity>;
  NFCe: TNFCeEntity;
  I: Integer;
begin
  try
    FNFCeList.Clear;
    GridNFCeList.RowCount := 0;

    NFCeList := FNFCeService.GetNFCeList;
    try
      GridNFCeList.RowCount := NFCeList.Count;

      for I := 0 to NFCeList.Count - 1 do
      begin
        NFCe := NFCeList[I];
        FNFCeList.Add(NFCe);

        // Grid será populado via eventos OnGetValue
      end;
    finally
      NFCeList.Free;
    end;
  except
    on E: Exception do
      ShowError('Erro ao carregar lista de NFCe: ' + E.Message);
  end;
end;

procedure TMainForm.LoadProducts;
var
  Products: TObjectList<TProductEntity>;
  Product: TProductEntity;
begin
  try
    FProducts.Clear;
    ComboBoxProducts.Items.Clear;

    Products := FProductRepository.GetAll;
    try
      for Product in Products do
      begin
        FProducts.Add(Product);
        ComboBoxProducts.Items.Add(Format('%s - %s (%s)',
            [Product.Code, Product.Name, Product.GetFormattedPrice]));
      end;
    finally
      Products.Free;
    end;
  except
    on E: Exception do
      ShowError('Erro ao carregar produtos: ' + E.Message);
  end;
end;

procedure TMainForm.ShowError(const AError: string);
begin
  TDialogService.ShowMessage('Erro: ' + AError);
end;

procedure TMainForm.ShowMessage(const AMessage: string);
begin
  TDialogService.ShowMessage(AMessage);
end;

procedure TMainForm.UpdateItemsGrid;
var
  I: Integer;
  Item: TNFCeItemEntity;
begin
  GridItems.RowCount := 0;

  if not Assigned(FCurrentNFCe) then
    Exit;

  GridItems.RowCount := FCurrentNFCe.Items.Count;

  for I := 0 to FCurrentNFCe.Items.Count - 1 do
  begin
    Item := FCurrentNFCe.Items[I];
    // Grid será populado via eventos OnGetValue
  end;
end;

procedure TMainForm.UpdateTotal;
begin
  if Assigned(FCurrentNFCe) then
  begin
    FCurrentNFCe.CalculateTotal;
    LabelTotalValue.Text := FCurrentNFCe.GetFormattedTotal;
  end;
end;

procedure TMainForm.GridNFCeListGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var
  NFCe: TNFCeEntity;
begin
  if (ARow >= 0) and (ARow < FNFCeList.Count) then
  begin
    NFCe := FNFCeList[ARow];
    case ACol of
      0:
        Value := IntToStr(NFCe.Number);
      1:
        Value := IntToStr(NFCe.Series);
      2:
        Value := DateTimeToStr(NFCe.IssueDate);
      3:
        Value := NFCe.GetStatusDescription;
      4:
        Value := NFCe.GetFormattedTotal;
    end;
  end;
end;

procedure TMainForm.GridItemsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var
  Item: TNFCeItemEntity;
begin
  if Assigned(FCurrentNFCe) and (ARow >= 0) and (ARow < FCurrentNFCe.Items.Count) then
  begin
    Item := FCurrentNFCe.Items[ARow];
    case ACol of
      0:
        Value := Item.Product.Code;
      1:
        Value := Item.Product.Name;
      2:
        Value := FormatFloat('#,##0.000', Item.Quantity);
      3:
        Value := FormatCurr('R$ #,##0.00', Item.UnitPrice);
      4:
        Value := FormatCurr('R$ #,##0.00', Item.TotalPrice);
    end;
  end;
end;

end.

