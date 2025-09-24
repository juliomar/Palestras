unit View.CadastroExame;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.Mask,
  System.Generics.Collections,
  System.StrUtils,
  system.UITypes,
  Model.Exame,
  Model.Gestante,
  Controller.Gestante,
  Controller.Exame,
  Utils.Validacao,
  Utils.Formatacao;

type
  TfrmCadastroExame = class(TForm)
    pnlMain: TPanel;
    pnlHeader: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlContent: TPanel;
    pnlFooter: TPanel;
    btnSalvar: TButton;
    btnCancelar: TButton;
    btnNovo: TButton;
    btnExcluir: TButton;
    pnlDadosExame: TPanel;
    lblDadosExame: TLabel;
    lblGestante: TLabel;
    cmbGestante: TComboBox;
    lblTipoExame: TLabel;
    cmbTipoExame: TComboBox;
    lblDataExame: TLabel;
    dtpDataExame: TDateTimePicker;
    lblMedicoSolicitante: TLabel;
    edtMedicoSolicitante: TEdit;
    lblLaboratorio: TLabel;
    edtLaboratorio: TEdit;
    lblResultado: TLabel;
    memoResultado: TMemo;
    lblObservacoes: TLabel;
    memoObservacoes: TMemo;
    pnlBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TButton;
    lvExames: TListView;
    btnTiposComuns: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure lvExamesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnTiposComunsClick(Sender: TObject);
  private
    FGestanteController: TGestanteController;
    FExameController: TExameController;
    FModoEdicao: Boolean;

    procedure ConfigurarInterface;
    procedure ConfigurarEstiloWindows11;
    procedure ConfigurarListView;
    procedure LimparCampos;
    procedure CarregarGestantes;
    procedure CarregarTiposExame;
    procedure CarregarDadosNaTela;
    procedure SalvarDadosDaTela;
    procedure ValidarCampos;
    procedure ExibirErros(const Erros: TStringList);
    procedure AtualizarListaExames;
    procedure HabilitarCampos(const Habilitar: Boolean);
    procedure ConfigurarLabelSecao(ALabel: TLabel);
    procedure ConfigurarBotao(ABotao: TButton; ACor: TColor);

  public
    property ModoEdicao: Boolean read FModoEdicao write FModoEdicao;
  end;

var
  frmCadastroExame: TfrmCadastroExame;

implementation

{$R *.dfm}

procedure TfrmCadastroExame.FormCreate(Sender: TObject);
begin
  FGestanteController := TGestanteController.Create;
  FExameController := TExameController.Create;
  FModoEdicao := False;

  ConfigurarInterface;
  ConfigurarEstiloWindows11;
  ConfigurarListView;
  CarregarGestantes;
  CarregarTiposExame;
  LimparCampos;
end;

procedure TfrmCadastroExame.FormDestroy(Sender: TObject);
begin
  if Assigned(FGestanteController) then
    FreeAndNil(FGestanteController);
  if Assigned(FExameController) then
    FreeAndNil(FExameController);
end;

procedure TfrmCadastroExame.FormShow(Sender: TObject);
begin
  AtualizarListaExames;
  cmbGestante.SetFocus;
end;

procedure TfrmCadastroExame.ConfigurarInterface;
begin
  Self.Caption := 'Cadastro de Exames';
  Self.Position := poScreenCenter;
  Self.WindowState := wsMaximized;

  // Configurar textos
  lblTitulo.Caption := 'Cadastro de Exames';
  lblSubtitulo.Caption := 'Gerenciamento de exames laboratoriais e de imagem';

  lblDadosExame.Caption := 'Dados do Exame';
  lblBusca.Caption := 'Buscar Exames';

  // Configurar botões
  btnSalvar.Caption := 'Salvar';
  btnCancelar.Caption := 'Cancelar';
  btnNovo.Caption := 'Novo';
  btnExcluir.Caption := 'Excluir';
  btnBuscar.Caption := 'Buscar';
  btnTiposComuns.Caption := 'Tipos Comuns';
end;

procedure TfrmCadastroExame.ConfigurarEstiloWindows11;
begin
  // Cores do Windows 11
  Self.Color := $F3F3F3;

  // Painéis
  pnlMain.Color := $F3F3F3;
  pnlMain.ParentBackground := False;

  pnlHeader.Color := $FFFFFF;
  pnlHeader.ParentBackground := False;

  pnlContent.Color := $F3F3F3;
  pnlContent.ParentBackground := False;

  pnlFooter.Color := $FFFFFF;
  pnlFooter.ParentBackground := False;

  // Painéis de seção
  pnlDadosExame.Color := $FFFFFF;
  pnlDadosExame.ParentBackground := False;

  pnlBusca.Color := $FFFFFF;
  pnlBusca.ParentBackground := False;

  // Configurar fontes
  lblTitulo.Font.Name := 'Segoe UI';
  lblTitulo.Font.Size := 16;
  lblTitulo.Font.Style := [fsBold];
  lblTitulo.Font.Color := $333333;

  lblSubtitulo.Font.Name := 'Segoe UI';
  lblSubtitulo.Font.Size := 10;
  lblSubtitulo.Font.Color := $666666;

  // Labels de seção
  ConfigurarLabelSecao(lblDadosExame);
  ConfigurarLabelSecao(lblBusca);

  // Configurar botões
  ConfigurarBotao(btnSalvar, $0078D4); // Azul
  ConfigurarBotao(btnCancelar, $666666); // Cinza
  ConfigurarBotao(btnNovo, $107C10); // Verde
  ConfigurarBotao(btnExcluir, $D13438); // Vermelho
  ConfigurarBotao(btnBuscar, $5C2D91); // Roxo
  ConfigurarBotao(btnTiposComuns, $FF8C00); // Laranja
end;

procedure TfrmCadastroExame.ConfigurarLabelSecao(ALabel: TLabel);
begin
  ALabel.Font.Name := 'Segoe UI';
  ALabel.Font.Size := 12;
  ALabel.Font.Style := [fsBold];
  ALabel.Font.Color := $333333;
end;

procedure TfrmCadastroExame.ConfigurarBotao(ABotao: TButton; ACor: TColor);
begin
  ABotao.Font.Name := 'Segoe UI';
  ABotao.Font.Size := 10;
  ABotao.Font.Style := [fsBold];
  ABotao.Font.Color := clWhite;
  ABotao.Height := 35;
end;

procedure TfrmCadastroExame.ConfigurarListView;
begin
  lvExames.ViewStyle := vsReport;
  lvExames.RowSelect := True;
  lvExames.ReadOnly := True;
  lvExames.Font.Name := 'Segoe UI';
  lvExames.Font.Size := 9;

  // Configurar colunas
  with lvExames.Columns.Add do
  begin
    Caption := 'ID';
    Width := 50;
  end;

  with lvExames.Columns.Add do
  begin
    Caption := 'Gestante';
    Width := 200;
  end;

  with lvExames.Columns.Add do
  begin
    Caption := 'Tipo Exame';
    Width := 180;
  end;

  with lvExames.Columns.Add do
  begin
    Caption := 'Data Exame';
    Width := 100;
  end;

  with lvExames.Columns.Add do
  begin
    Caption := 'Laboratório';
    Width := 150;
  end;

  with lvExames.Columns.Add do
  begin
    Caption := 'Status';
    Width := 100;
  end;
end;

procedure TfrmCadastroExame.LimparCampos;
begin
  cmbGestante.ItemIndex := -1;
  cmbTipoExame.ItemIndex := -1;
  dtpDataExame.Date := Date;
  edtMedicoSolicitante.Clear;
  edtLaboratorio.Clear;
  memoResultado.Clear;
  memoObservacoes.Clear;

  FModoEdicao := False;
  HabilitarCampos(True);
end;

procedure TfrmCadastroExame.CarregarGestantes;
var
  Gestantes: TObjectList<TGestante>;
  Gestante: TGestante;
begin
  cmbGestante.Items.Clear;

  Gestantes := FGestanteController.BuscarAtivas.ObterLista;
  if not Assigned(Gestantes) then
    Exit;

  for Gestante in Gestantes do
  begin
    cmbGestante.Items.AddObject(Gestante.Nome, TObject(Gestante.Id));
  end;
end;

procedure TfrmCadastroExame.CarregarTiposExame;
var
  ExameTemp: TExame;
  TiposComuns: TStringList;
  I: Integer;
begin
  cmbTipoExame.Items.Clear;

  ExameTemp := TExame.Create;
  try
    TiposComuns := ExameTemp.GetTiposExameComuns;
    try
      for I := 0 to TiposComuns.Count - 1 do
        cmbTipoExame.Items.Add(TiposComuns[I]);
    finally
      TiposComuns.Free;
    end;
  finally
    ExameTemp.Free;
  end;
end;

procedure TfrmCadastroExame.CarregarDadosNaTela;
var
  Exame: TExame;
begin
  if not FExameController.ExisteExame then
    Exit;

  Exame := FExameController.ObterExame;
  if not Assigned(Exame) then
    Exit;

  // Selecionar gestante no combo
  var I: Integer;
  for I := 0 to cmbGestante.Items.Count - 1 do
  begin
    if Integer(cmbGestante.Items.Objects[I]) = Exame.GestanteId then
    begin
      cmbGestante.ItemIndex := I;
      Break;
    end;
  end;

  cmbTipoExame.Text := Exame.TipoExame;

  if Exame.DataExame > 0 then
    dtpDataExame.Date := Exame.DataExame;

  edtMedicoSolicitante.Text := Exame.MedicoSolicitante;
  edtLaboratorio.Text := Exame.Laboratorio;
  memoResultado.Text := Exame.Resultado;
  memoObservacoes.Text := Exame.Observacoes;

  FModoEdicao := True;
end;

procedure TfrmCadastroExame.SalvarDadosDaTela;
begin
  if not FModoEdicao then
    FExameController.NovoExame;

  if cmbGestante.ItemIndex >= 0 then
    FExameController.ComGestante(Integer(cmbGestante.Items.Objects[cmbGestante.ItemIndex]));

  FExameController
    .ComTipoExame(cmbTipoExame.Text)
    .ComDataExame(dtpDataExame.Date)
    .ComMedicoSolicitante(edtMedicoSolicitante.Text)
    .ComLaboratorio(edtLaboratorio.Text)
    .ComResultado(memoResultado.Text)
    .ComObservacoes(memoObservacoes.Text);
end;



// Event Handlers

procedure TfrmCadastroExame.btnSalvarClick(Sender: TObject);
begin
  try
    ValidarCampos;
    SalvarDadosDaTela;

    FExameController.ValidarDados.Salvar;

    if FExameController.TemErro then
    begin
      MessageDlg(FExameController.ObterErro, mtError, [mbOK], 0);
      Exit;
    end;

    if FExameController.Sucesso then
    begin
      MessageDlg('Exame salvo com sucesso!', mtInformation, [mbOK], 0);
      AtualizarListaExames;
      LimparCampos;
    end
    else
      MessageDlg(FExameController.ObterErro, mtError, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao salvar exame: ' + E.Message, mtError, [mbOK], 0);
  end;
end;



// Event Handlers

procedure TfrmCadastroExame.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  FModoEdicao := False;
end;

procedure TfrmCadastroExame.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  FModoEdicao := False;
  cmbGestante.SetFocus;
end;

procedure TfrmCadastroExame.btnExcluirClick(Sender: TObject);
begin
  if not FExameController.ExisteExame then
  begin
    MessageDlg('Nenhum exame selecionado para exclusão.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg('Confirma a exclusão do exame selecionado?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FExameController.Excluir;

      if FExameController.Sucesso then
      begin
        MessageDlg('Exame excluído com sucesso!', mtInformation, [mbOK], 0);
        AtualizarListaExames;
        LimparCampos;
      end
      else
        MessageDlg(FExameController.ObterErro, mtError, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg('Erro ao excluir exame: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmCadastroExame.btnBuscarClick(Sender: TObject);
begin
  AtualizarListaExames;
end;

procedure TfrmCadastroExame.lvExamesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and Assigned(Item) then
  begin
    FExameController.CarregarExame(Integer(Item.Data));
    if FExameController.ExisteExame then
      CarregarDadosNaTela;
  end;
end;

procedure TfrmCadastroExame.btnTiposComunsClick(Sender: TObject);
begin
  // Implementar menu de tipos comuns se necessário
  ShowMessage('Funcionalidade de tipos comuns em desenvolvimento');
end;

procedure TfrmCadastroExame.ValidarCampos;
var
  Erros: TStringList;
begin
  Erros := TStringList.Create;
  try
    // Validações básicas
    if cmbGestante.ItemIndex < 0 then
      Erros.Add('Gestante é obrigatória');

    if Trim(cmbTipoExame.Text) = '' then
      Erros.Add('Tipo de exame é obrigatório');

    if Trim(edtMedicoSolicitante.Text) = '' then
      Erros.Add('Médico solicitante é obrigatório');

    if dtpDataExame.Date > Now then
      Erros.Add('Data do exame não pode ser futura');

    if Erros.Count > 0 then
      ExibirErros(Erros);
  finally
    Erros.Free;
  end;
end;

procedure TfrmCadastroExame.ExibirErros(const Erros: TStringList);
begin
  MessageDlg('Erros de validação:' + sLineBreak + sLineBreak + Erros.Text,
    mtError, [mbOK], 0);
end;

procedure TfrmCadastroExame.HabilitarCampos(const Habilitar: Boolean);
begin
  cmbGestante.Enabled := Habilitar;
  cmbTipoExame.Enabled := Habilitar;
  dtpDataExame.Enabled := Habilitar;
  edtMedicoSolicitante.Enabled := Habilitar;
  edtLaboratorio.Enabled := Habilitar;
  memoResultado.Enabled := Habilitar;
  memoObservacoes.Enabled := Habilitar;
end;

procedure TfrmCadastroExame.AtualizarListaExames;
var
  Exames: TObjectList<TExame>;
  Exame: TExame;
  Item: TListItem;
  Gestante: TGestante;
begin
  lvExames.Items.Clear;

  try
    Exames := FExameController.BuscarTodos.ObterLista;
    if not Assigned(Exames) then
      Exit;

    for Exame in Exames do
    begin
      Item := lvExames.Items.Add;
      Item.Caption := IntToStr(Exame.Id);

      // Buscar nome da gestante
      FGestanteController.CarregarGestante(Exame.GestanteId);
      if FGestanteController.ExisteGestante then
      begin
        Gestante := FGestanteController.ObterGestante;
        Item.SubItems.Add(Gestante.Nome);
      end
      else
        Item.SubItems.Add('Gestante não encontrada');

      Item.SubItems.Add(Exame.TipoExame);
      Item.SubItems.Add(TFormatacao.FormatarData(Exame.DataExame));
      Item.SubItems.Add(Exame.MedicoSolicitante);
      Item.SubItems.Add(Exame.Laboratorio);

      if Trim(Exame.Resultado) <> '' then
        Item.SubItems.Add('Concluído')
      else
        Item.SubItems.Add('Pendente');

      Item.Data := Pointer(Exame.Id);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar lista de exames: ' + E.Message);
  end;
end;

end.

