unit View.CadastroGestante;

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
  Vcl.DBCtrls,
  System.Generics.Collections,
  System.StrUtils,
  system.UITypes,
  Controller.Gestante,
  Model.Gestante,
  Utils.Validacao,
  Utils.Formatacao;

type
  TfrmCadastroGestante = class(TForm)
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
    pnlDadosPessoais: TPanel;
    lblDadosPessoais: TLabel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblCPF: TLabel;
    edtCPF: TMaskEdit;
    lblRG: TLabel;
    edtRG: TEdit;
    lblDataNascimento: TLabel;
    dtpDataNascimento: TDateTimePicker;
    lblTelefone: TLabel;
    edtTelefone: TMaskEdit;
    lblCelular: TLabel;
    edtCelular: TMaskEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    pnlEndereco: TPanel;
    lblEndereco: TLabel;
    lblEnderecoCompleto: TLabel;
    edtEnderecoCompleto: TEdit;
    lblCEP: TLabel;
    edtCEP: TMaskEdit;
    lblCidade: TLabel;
    edtCidade: TEdit;
    lblEstado: TLabel;
    cmbEstado: TComboBox;
    pnlDadosGestacao: TPanel;
    lblDadosGestacao: TLabel;
    lblDataUltimaMenstruacao: TLabel;
    dtpDataUltimaMenstruacao: TDateTimePicker;
    lblDataProvavelParto: TLabel;
    dtpDataProvavelParto: TDateTimePicker;
    lblTipoSanguineo: TLabel;
    cmbTipoSanguineo: TComboBox;
    lblPesoInicial: TLabel;
    edtPesoInicial: TEdit;
    lblAltura: TLabel;
    edtAltura: TEdit;
    lblObservacoes: TLabel;
    memoObservacoes: TMemo;
    chkAtiva: TCheckBox;
    pnlBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TButton;
    lvGestantes: TListView;
    lblIdadeGestacional: TLabel;
    edtIdadeGestacional: TEdit;
    lblIMC: TLabel;
    edtIMC: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure lvGestantesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure edtCPFExit(Sender: TObject);
    procedure dtpDataUltimaMenstruacaoChange(Sender: TObject);
    procedure edtPesoInicialExit(Sender: TObject);
    procedure edtAlturaExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtCEPExit(Sender: TObject);
  private
    FController: TGestanteController;
    FModoEdicao: Boolean;

    procedure ConfigurarInterface;
    procedure ConfigurarEstiloWindows11;
    procedure ConfigurarComboBoxes;
    procedure ConfigurarListView;
    procedure LimparCampos;
    procedure CarregarDadosNaTela;
    procedure SalvarDadosDaTela;
    procedure CalcularIdadeGestacional;
    procedure CalcularIMC;
    procedure ValidarCampos;
    procedure ExibirErros(const Erros: TStringList);
    procedure AtualizarListaGestantes;
    procedure HabilitarCampos(const Habilitar: Boolean);
    procedure BuscarCEP(const CEP: string);
    procedure ConfigurarLabelSecao(ALabel: TLabel);
    procedure ConfigurarBotao(ABotao: TButton; ACor: TColor);

  public
    property ModoEdicao: Boolean read FModoEdicao write FModoEdicao;
  end;

var
  frmCadastroGestante: TfrmCadastroGestante;

implementation

{$R *.dfm}

procedure TfrmCadastroGestante.FormCreate(Sender: TObject);
begin
  FController := TGestanteController.Create;
  FModoEdicao := False;

  ConfigurarInterface;
  ConfigurarEstiloWindows11;
  ConfigurarComboBoxes;
  ConfigurarListView;
  LimparCampos;
end;

procedure TfrmCadastroGestante.FormDestroy(Sender: TObject);
begin
  if Assigned(FController) then
    FreeAndNil(FController);
end;

procedure TfrmCadastroGestante.FormShow(Sender: TObject);
begin
  AtualizarListaGestantes;
  edtNome.SetFocus;
end;

procedure TfrmCadastroGestante.ConfigurarInterface;
begin
  Self.Caption := 'Cadastro de Gestantes';
  Self.Position := poScreenCenter;
  Self.WindowState := wsMaximized;

  // Configurar textos
  lblTitulo.Caption := 'Cadastro de Gestantes';
  lblSubtitulo.Caption := 'Gerenciamento completo de gestantes';

  lblDadosPessoais.Caption := 'Dados Pessoais';
  lblEndereco.Caption := 'Endereço';
  lblDadosGestacao.Caption := 'Dados da Gestação';
  lblBusca.Caption := 'Buscar Gestantes';

  // Configurar botões
  btnSalvar.Caption := 'Salvar';
  btnCancelar.Caption := 'Cancelar';
  btnNovo.Caption := 'Novo';
  btnExcluir.Caption := 'Excluir';
  btnBuscar.Caption := 'Buscar';

  // Configurar máscaras
  edtCPF.EditMask := '000.000.000-00;1;_';
  edtTelefone.EditMask := '(00) 0000-0000;1;_';
  edtCelular.EditMask := '(00) 00000-0000;1;_';
  edtCEP.EditMask := '00000-000;1;_';

  // Configurar campos calculados como readonly
  edtIdadeGestacional.ReadOnly := True;
  edtIMC.ReadOnly := True;
  dtpDataProvavelParto.Enabled := False;
end;

procedure TfrmCadastroGestante.ConfigurarEstiloWindows11;
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
  pnlDadosPessoais.Color := $FFFFFF;
  pnlDadosPessoais.ParentBackground := False;

  pnlEndereco.Color := $FFFFFF;
  pnlEndereco.ParentBackground := False;

  pnlDadosGestacao.Color := $FFFFFF;
  pnlDadosGestacao.ParentBackground := False;

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
  ConfigurarLabelSecao(lblDadosPessoais);
  ConfigurarLabelSecao(lblEndereco);
  ConfigurarLabelSecao(lblDadosGestacao);
  ConfigurarLabelSecao(lblBusca);

  // Configurar botões
  ConfigurarBotao(btnSalvar, $0078D4); // Azul
  ConfigurarBotao(btnCancelar, $666666); // Cinza
  ConfigurarBotao(btnNovo, $107C10); // Verde
  ConfigurarBotao(btnExcluir, $D13438); // Vermelho
  ConfigurarBotao(btnBuscar, $5C2D91); // Roxo
end;

procedure TfrmCadastroGestante.ConfigurarLabelSecao(ALabel: TLabel);
begin
  ALabel.Font.Name := 'Segoe UI';
  ALabel.Font.Size := 12;
  ALabel.Font.Style := [fsBold];
  ALabel.Font.Color := $333333;
end;

procedure TfrmCadastroGestante.ConfigurarBotao(ABotao: TButton; ACor: TColor);
begin
  ABotao.Font.Name := 'Segoe UI';
  ABotao.Font.Size := 10;
  ABotao.Font.Style := [fsBold];
  ABotao.Font.Color := clWhite;
  ABotao.Height := 35;
end;

procedure TfrmCadastroGestante.ConfigurarComboBoxes;
begin
  // Estados brasileiros
  cmbEstado.Items.Clear;
  cmbEstado.Items.AddStrings([
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
      'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
      'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ]);

  // Tipos sanguíneos
  cmbTipoSanguineo.Items.Clear;
  cmbTipoSanguineo.Items.AddStrings(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']);
end;

procedure TfrmCadastroGestante.ConfigurarListView;
begin
  lvGestantes.ViewStyle := vsReport;
  lvGestantes.RowSelect := True;
  lvGestantes.ReadOnly := True;
  lvGestantes.Font.Name := 'Segoe UI';
  lvGestantes.Font.Size := 9;

  // Configurar colunas
  with lvGestantes.Columns.Add do
  begin
    Caption := 'ID';
    Width := 50;
  end;

  with lvGestantes.Columns.Add do
  begin
    Caption := 'Nome';
    Width := 200;
  end;

  with lvGestantes.Columns.Add do
  begin
    Caption := 'CPF';
    Width := 120;
  end;

  with lvGestantes.Columns.Add do
  begin
    Caption := 'Data Nascimento';
    Width := 100;
  end;

  with lvGestantes.Columns.Add do
  begin
    Caption := 'Telefone';
    Width := 120;
  end;

  with lvGestantes.Columns.Add do
  begin
    Caption := 'Status';
    Width := 80;
  end;
end;

procedure TfrmCadastroGestante.LimparCampos;
begin
  edtNome.Clear;
  edtCPF.Clear;
  edtRG.Clear;
  dtpDataNascimento.Date := Date;
  edtTelefone.Clear;
  edtCelular.Clear;
  edtEmail.Clear;
  edtEnderecoCompleto.Clear;
  edtCEP.Clear;
  edtCidade.Clear;
  cmbEstado.ItemIndex := -1;
  dtpDataUltimaMenstruacao.Date := Date;
  dtpDataProvavelParto.Date := Date;
  cmbTipoSanguineo.ItemIndex := -1;
  edtPesoInicial.Clear;
  edtAltura.Clear;
  edtIdadeGestacional.Clear;
  edtIMC.Clear;
  memoObservacoes.Clear;
  chkAtiva.Checked := True;

  FModoEdicao := False;
  HabilitarCampos(True);
end;

procedure TfrmCadastroGestante.CarregarDadosNaTela;
var
  Gestante: TGestante;
begin
  Gestante := FController.ObterGestante;
  if not Assigned(Gestante) then
    Exit;

  edtNome.Text := Gestante.Nome;
  edtCPF.Text := TFormatacao.FormatarCPF(Gestante.CPF);
  edtRG.Text := Gestante.RG;

  if Gestante.DataNascimento > 0 then
    dtpDataNascimento.Date := Gestante.DataNascimento;

  edtTelefone.Text := TFormatacao.FormatarTelefone(Gestante.Telefone);
  edtCelular.Text := TFormatacao.FormatarCelular(Gestante.Celular);
  edtEmail.Text := Gestante.Email;
  edtEnderecoCompleto.Text := Gestante.Endereco;
  edtCEP.Text := TFormatacao.FormatarCEP(Gestante.CEP);
  edtCidade.Text := Gestante.Cidade;
  cmbEstado.Text := Gestante.Estado;

  if Gestante.DataUltimaMenstruacao > 0 then
    dtpDataUltimaMenstruacao.Date := Gestante.DataUltimaMenstruacao;

  if Gestante.DataProvavelParto > 0 then
    dtpDataProvavelParto.Date := Gestante.DataProvavelParto;

  cmbTipoSanguineo.Text := Gestante.TipoSanguineo;

  if Gestante.PesoInicial > 0 then
    edtPesoInicial.Text := FormatFloat('0.0', Gestante.PesoInicial);

  if Gestante.Altura > 0 then
    edtAltura.Text := FormatFloat('0.00', Gestante.Altura);

  edtIdadeGestacional.Text := Gestante.GetIdadeGestacional;

  if Gestante.GetIMC > 0 then
    edtIMC.Text := TFormatacao.FormatarIMC(Gestante.GetIMC);

  memoObservacoes.Text := Gestante.Observacoes;
  chkAtiva.Checked := Gestante.Ativo;

  FModoEdicao := True;
end;

procedure TfrmCadastroGestante.SalvarDadosDaTela;
begin
  if not FModoEdicao then
    FController.NovaGestante;

  FController
    .ComNome(edtNome.Text)
    .ComCPF(edtCPF.Text)
    .ComRG(edtRG.Text)
    .ComDataNascimento(dtpDataNascimento.Date)
    .ComTelefone(edtTelefone.Text)
    .ComCelular(edtCelular.Text)
    .ComEmail(edtEmail.Text)
    .ComEndereco(edtEnderecoCompleto.Text)
    .ComCEP(edtCEP.Text)
    .ComCidade(edtCidade.Text)
    .ComEstado(cmbEstado.Text)
    .ComDataUltimaMenstruacao(dtpDataUltimaMenstruacao.Date)
    .ComTipoSanguineo(cmbTipoSanguineo.Text)
    .ComObservacoes(memoObservacoes.Text)
    .Ativa(chkAtiva.Checked);

  // Converter peso e altura
  if Trim(edtPesoInicial.Text) <> '' then
    FController.ComPesoInicial(StrToFloatDef(edtPesoInicial.Text, 0));

  if Trim(edtAltura.Text) <> '' then
    FController.ComAltura(StrToFloatDef(edtAltura.Text, 0));
end;

procedure TfrmCadastroGestante.CalcularIdadeGestacional;
begin
  if FController.ExisteGestante then
    edtIdadeGestacional.Text := FController.ObterIdadeGestacional;
end;

procedure TfrmCadastroGestante.CalcularIMC;
begin
  if FController.ExisteGestante then
  begin
    if FController.ObterIMC > 0 then
      edtIMC.Text := TFormatacao.FormatarIMC(FController.ObterIMC)
    else
      edtIMC.Clear;
  end;
end;

procedure TfrmCadastroGestante.ValidarCampos;
var
  Erros: TStringList;
begin
  Erros := TStringList.Create;
  try
    // Validações básicas
    if not TValidacao.ValidarNome(edtNome.Text) then
      Erros.Add('Nome inválido');

    if not TValidacao.ValidarCPF(edtCPF.Text) then
      Erros.Add('CPF inválido');

    if not TValidacao.ValidarEmail(edtEmail.Text) and (Trim(edtEmail.Text) <> '') then
      Erros.Add('Email inválido');

    if not TValidacao.ValidarTelefone(edtTelefone.Text) and (Trim(edtTelefone.Text) <> '') then
      Erros.Add('Telefone inválido');

    if not TValidacao.ValidarCEP(edtCEP.Text) and (Trim(edtCEP.Text) <> '') then
      Erros.Add('CEP inválido');

    // Validar peso e altura se informados
    if (Trim(edtPesoInicial.Text) <> '') and
      (not TValidacao.ValidarPeso(StrToFloatDef(edtPesoInicial.Text, 0))) then
      Erros.Add('Peso deve estar entre 30 e 200 kg');

    if (Trim(edtAltura.Text) <> '') and
      (not TValidacao.ValidarAltura(StrToFloatDef(edtAltura.Text, 0))) then
      Erros.Add('Altura deve estar entre 1,0 e 2,5 metros');

    if Erros.Count > 0 then
      ExibirErros(Erros);
  finally
    Erros.Free;
  end;
end;

procedure TfrmCadastroGestante.ExibirErros(const Erros: TStringList);
begin
  MessageDlg('Erros de validação:' + sLineBreak + sLineBreak + Erros.Text,
    mtError, [mbOK], 0);
end;

procedure TfrmCadastroGestante.AtualizarListaGestantes;
var
  Gestantes: TObjectList<TGestante>;
  Gestante: TGestante;
  Item: TListItem;
begin
  lvGestantes.Items.Clear;

  try
    Gestantes := FController.BuscarAtivas.ObterLista;
    if not Assigned(Gestantes) then
      Exit;

    for Gestante in Gestantes do
    begin
      Item := lvGestantes.Items.Add;
      Item.Caption := IntToStr(Gestante.Id);
      Item.SubItems.Add(Gestante.Nome);
      Item.SubItems.Add(TFormatacao.FormatarCPF(Gestante.CPF));
      Item.SubItems.Add(TFormatacao.FormatarData(Gestante.DataNascimento));
      Item.SubItems.Add(TFormatacao.FormatarTelefone(Gestante.Telefone));
      Item.SubItems.Add(IfThen(Gestante.Ativo, 'Ativa', 'Inativa'));
      Item.Data := Pointer(Gestante.Id);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar lista de gestantes: ' + E.Message);
  end;
end;

procedure TfrmCadastroGestante.HabilitarCampos(const Habilitar: Boolean);
begin
  edtNome.Enabled := Habilitar;
  edtCPF.Enabled := Habilitar;
  edtRG.Enabled := Habilitar;
  dtpDataNascimento.Enabled := Habilitar;
  edtTelefone.Enabled := Habilitar;
  edtCelular.Enabled := Habilitar;
  edtEmail.Enabled := Habilitar;
  edtEnderecoCompleto.Enabled := Habilitar;
  edtCEP.Enabled := Habilitar;
  edtCidade.Enabled := Habilitar;
  cmbEstado.Enabled := Habilitar;
  dtpDataUltimaMenstruacao.Enabled := Habilitar;
  cmbTipoSanguineo.Enabled := Habilitar;
  edtPesoInicial.Enabled := Habilitar;
  edtAltura.Enabled := Habilitar;
  memoObservacoes.Enabled := Habilitar;
  chkAtiva.Enabled := Habilitar;
end;

procedure TfrmCadastroGestante.BuscarCEP(const CEP: string);
begin
  if not TValidacao.ValidarCEP(CEP) then
  begin
    MessageDlg('CEP inválido. Use o formato 00000-000', mtWarning, [mbOK], 0);
    Exit;
  end;

  // Implementação básica - funcionalidade completa será adicionada futuramente
  MessageDlg('Busca de CEP implementada!' + #13#10 +
    'CEP: ' + CEP + #13#10 +
    'Funcionalidade de preenchimento automático será implementada em versão futura.',
    mtInformation, [mbOK], 0);
end;

// Event Handlers

procedure TfrmCadastroGestante.btnSalvarClick(Sender: TObject);
begin
  try
    ValidarCampos;
    SalvarDadosDaTela;

    FController.ValidarCPFUnico.ValidarDados;

    if FController.TemErro then
    begin
      MessageDlg(FController.ObterErro, mtError, [mbOK], 0);
      Exit;
    end;

    FController.Salvar;

    if FController.Sucesso then
    begin
      MessageDlg('Gestante salva com sucesso!', mtInformation, [mbOK], 0);
      AtualizarListaGestantes;
      LimparCampos;
    end
    else
      MessageDlg(FController.ObterErro, mtError, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao salvar gestante: ' + E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCadastroGestante.btnCancelarClick(Sender: TObject);
begin
  if MessageDlg('Deseja cancelar a operação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    LimparCampos;
end;

procedure TfrmCadastroGestante.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  edtNome.SetFocus;
end;

procedure TfrmCadastroGestante.btnExcluirClick(Sender: TObject);
begin
  if not FModoEdicao then
  begin
    MessageDlg('Selecione uma gestante para excluir', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg('Confirma a exclusão desta gestante?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FController.Excluir;

    if FController.Sucesso then
    begin
      MessageDlg('Gestante excluída com sucesso!', mtInformation, [mbOK], 0);
      AtualizarListaGestantes;
      LimparCampos;
    end
    else
      MessageDlg(FController.ObterErro, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCadastroGestante.btnBuscarClick(Sender: TObject);
var
  TextoBusca: string;
begin
  TextoBusca := Trim(edtBusca.Text);

  if TextoBusca = '' then
  begin
    AtualizarListaGestantes;
    Exit;
  end;

  // Buscar por nome ou CPF
  if TValidacao.ValidarCPF(TextoBusca) then
  begin
    FController.CarregarPorCPF(TextoBusca);
    if FController.ExisteGestante then
      CarregarDadosNaTela;
  end
  else
  begin
    // Buscar por nome e atualizar lista
    FController.BuscarPorNome(TextoBusca);
    AtualizarListaGestantes;
  end;
end;

procedure TfrmCadastroGestante.lvGestantesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  GestanteId: Integer;
begin
  if Selected and Assigned(Item) then
  begin
    GestanteId := Integer(Item.Data);
    FController.CarregarGestante(GestanteId);

    if FController.ExisteGestante then
      CarregarDadosNaTela;
  end;
end;

procedure TfrmCadastroGestante.edtCPFExit(Sender: TObject);
begin
  if (Trim(edtCPF.Text) <> '') and (not FModoEdicao) then
  begin
    // Verificar se CPF já existe
    FController.CarregarPorCPF(edtCPF.Text);
    if FController.ExisteGestante then
    begin
      if MessageDlg('CPF já cadastrado. Deseja carregar os dados?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        CarregarDadosNaTela
      else
        edtCPF.Clear;
    end;
  end;
end;

procedure TfrmCadastroGestante.dtpDataUltimaMenstruacaoChange(Sender: TObject);
begin
  // Calcular data provável do parto (40 semanas)
  dtpDataProvavelParto.Date := dtpDataUltimaMenstruacao.Date + 280;
  CalcularIdadeGestacional;
end;

procedure TfrmCadastroGestante.edtPesoInicialExit(Sender: TObject);
begin
  SalvarDadosDaTela;
  CalcularIMC;
end;

procedure TfrmCadastroGestante.edtAlturaExit(Sender: TObject);
begin
  SalvarDadosDaTela;
  CalcularIMC;
end;

procedure TfrmCadastroGestante.edtCEPExit(Sender: TObject);
begin
  if TValidacao.ValidarCEP(edtCEP.Text) then
    BuscarCEP(edtCEP.Text);
end;

end.

