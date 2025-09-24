unit View.Principal;

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
  Vcl.Imaging.pngimage,
  System.ImageList,
  Vcl.ImgList,
  Controller.Gestante,
  Controller.Consulta,
  Controller.Exame,
  system.UITypes,
  Model.Gestante,
  Model.Consulta,
  Model.Exame,
  System.Generics.Collections;

type
  TfrmPrincipal = class(TForm)
    pnlMain: TPanel;
    pnlSidebar: TPanel;
    pnlContent: TPanel;
    pnlHeader: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    imgLogo: TImage;
    pnlMenuButtons: TPanel;
    btnGestantes: TSpeedButton;
    btnConsultas: TSpeedButton;
    btnExames: TSpeedButton;
    btnRelatorios: TSpeedButton;
    btnConfiguracoes: TSpeedButton;
    pnlFooter: TPanel;
    lblVersao: TLabel;
    lblStatus: TLabel;
    pnlDashboard: TPanel;
    lblDashboardTitle: TLabel;
    pnlCards: TPanel;
    pnlCardGestantes: TPanel;
    lblCardGestantesTitle: TLabel;
    lblCardGestantesValue: TLabel;
    lblCardGestantesDesc: TLabel;
    pnlCardConsultas: TPanel;
    lblCardConsultasTitle: TLabel;
    lblCardConsultasValue: TLabel;
    lblCardConsultasDesc: TLabel;
    pnlCardExames: TPanel;
    lblCardExamesTitle: TLabel;
    lblCardExamesValue: TLabel;
    lblCardExamesDesc: TLabel;
    pnlRecentActivity: TPanel;
    lblRecentTitle: TLabel;
    lvRecentActivity: TListView;
    ImageList: TImageList;
    tmrUpdate: TTimer;
    pnlQuickActions: TPanel;
    lblQuickActionsTitle: TLabel;
    btnNovaGestante: TButton;
    btnNovaConsulta: TButton;
    btnNovoExame: TButton;
    btnBuscarGestante: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnGestantesClick(Sender: TObject);
    procedure btnConsultasClick(Sender: TObject);
    procedure btnExamesClick(Sender: TObject);
    procedure btnRelatoriosClick(Sender: TObject);
    procedure btnConfiguracoesClick(Sender: TObject);
    procedure btnNovaGestanteClick(Sender: TObject);
    procedure btnNovaConsultaClick(Sender: TObject);
    procedure btnNovoExameClick(Sender: TObject);
    procedure btnBuscarGestanteClick(Sender: TObject);
    procedure tmrUpdateTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FGestanteController: TGestanteController;
    FConsultaController: TConsultaController;
    FExameController: TExameController;
    procedure ConfigurarInterface;
    procedure ConfigurarEstiloWindows11;
    procedure AtualizarDashboard;
    procedure AtualizarAtividadeRecente;
    procedure SelecionarBotaoMenu(Botao: TSpeedButton);
    procedure MostrarPainel(const NomePainel: string);
    procedure ConfigurarCards;
    procedure ConfigurarListaAtividades;
    procedure ConfigurarBotaoMenu(Botao: TSpeedButton);
    procedure ConfigurarBotaoAcao(Botao: TButton; Cor: TColor);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  Data.Connection,
  View.CadastroGestante,
  View.CadastroConsulta,
  View.CadastroExame;

{$R *.dfm}

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FGestanteController := TGestanteController.Create;
  FConsultaController := TConsultaController.Create;
  FExameController := TExameController.Create;
  ConfigurarInterface;
  ConfigurarEstiloWindows11;
  ConfigurarCards;
  ConfigurarListaAtividades;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  if Assigned(FGestanteController) then
    FreeAndNil(FGestanteController);
  if Assigned(FConsultaController) then
    FreeAndNil(FConsultaController);
  if Assigned(FExameController) then
    FreeAndNil(FExameController);
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  AtualizarDashboard;
  AtualizarAtividadeRecente;
  SelecionarBotaoMenu(btnGestantes);
end;

procedure TfrmPrincipal.ConfigurarInterface;
begin
  // Configurações gerais do formulário
  Self.Caption := 'Sistema de Controle de Maternidade';
  Self.WindowState := wsMaximized;
  Self.Position := poScreenCenter;

  // Configurar textos
  lblTitulo.Caption := 'Controle de Maternidade';
  lblSubtitulo.Caption := 'Sistema de Gestão Hospitalar';
  lblVersao.Caption := 'Versão 1.0.0';
  lblStatus.Caption := 'Sistema Online';

  // Configurar dashboard
  lblDashboardTitle.Caption := 'Dashboard - Visão Geral';
  lblQuickActionsTitle.Caption := 'Ações Rápidas';
  lblRecentTitle.Caption := 'Atividade Recente';

  // Configurar botões do menu
  btnGestantes.Caption := 'Gestantes';
  btnConsultas.Caption := 'Consultas';
  btnExames.Caption := 'Exames';
  btnRelatorios.Caption := 'Relatórios';
  btnConfiguracoes.Caption := 'Configurações';

  // Configurar botões de ação rápida
  btnNovaGestante.Caption := 'Nova Gestante';
  btnNovaConsulta.Caption := 'Nova Consulta';
  btnNovoExame.Caption := 'Novo Exame';
  btnBuscarGestante.Caption := 'Buscar Gestante';
end;

procedure TfrmPrincipal.ConfigurarEstiloWindows11;
begin
  // Cores do Windows 11
  Self.Color := $F3F3F3; // Cinza claro

  // Sidebar
  pnlSidebar.Color := $FFFFFF; // Branco
  pnlSidebar.ParentBackground := False;

  // Header
  pnlHeader.Color := $FFFFFF;
  pnlHeader.ParentBackground := False;

  // Content
  pnlContent.Color := $F3F3F3;
  pnlContent.ParentBackground := False;

  // Footer
  pnlFooter.Color := $E5E5E5;
  pnlFooter.ParentBackground := False;

  // Dashboard
  pnlDashboard.Color := $F3F3F3;
  pnlDashboard.ParentBackground := False;

  // Configurar fontes
  lblTitulo.Font.Name := 'Segoe UI';
  lblTitulo.Font.Size := 16;
  lblTitulo.Font.Style := [fsBold];
  lblTitulo.Font.Color := $333333;

  lblSubtitulo.Font.Name := 'Segoe UI';
  lblSubtitulo.Font.Size := 10;
  lblSubtitulo.Font.Color := $666666;

  lblDashboardTitle.Font.Name := 'Segoe UI';
  lblDashboardTitle.Font.Size := 14;
  lblDashboardTitle.Font.Style := [fsBold];
  lblDashboardTitle.Font.Color := $333333;

  // Configurar botões do menu com estilo Windows 11
  ConfigurarBotaoMenu(btnGestantes);
  ConfigurarBotaoMenu(btnConsultas);
  ConfigurarBotaoMenu(btnExames);
  ConfigurarBotaoMenu(btnRelatorios);
  ConfigurarBotaoMenu(btnConfiguracoes);

  // Configurar botões de ação rápida
  ConfigurarBotaoAcao(btnNovaGestante, $0078D4); // Azul Windows
  ConfigurarBotaoAcao(btnNovaConsulta, $107C10); // Verde
  ConfigurarBotaoAcao(btnNovoExame, $FF8C00); // Laranja
  ConfigurarBotaoAcao(btnBuscarGestante, $5C2D91); // Roxo
end;

procedure TfrmPrincipal.ConfigurarBotaoMenu(Botao: TSpeedButton);
begin
  Botao.Flat := True;
  Botao.Font.Name := 'Segoe UI';
  Botao.Font.Size := 10;
  Botao.Font.Color := $333333;
  Botao.Height := 40;
end;

procedure TfrmPrincipal.ConfigurarBotaoAcao(Botao: TButton; Cor: TColor);
begin
  Botao.Font.Name := 'Segoe UI';
  Botao.Font.Size := 10;
  Botao.Font.Color := clWhite;
  Botao.Font.Style := [fsBold];
  Botao.Height := 35;
end;

procedure TfrmPrincipal.ConfigurarCards;
begin
  // Card Gestantes
  pnlCardGestantes.Color := $FFFFFF;
  pnlCardGestantes.ParentBackground := False;
  pnlCardGestantes.BevelOuter := bvNone;
  lblCardGestantesTitle.Caption := 'Gestantes Ativas';
  lblCardGestantesTitle.Font.Name := 'Segoe UI';
  lblCardGestantesTitle.Font.Size := 12;
  lblCardGestantesTitle.Font.Style := [fsBold];
  lblCardGestantesTitle.Font.Color := $333333;

  lblCardGestantesValue.Font.Name := 'Segoe UI';
  lblCardGestantesValue.Font.Size := 24;
  lblCardGestantesValue.Font.Style := [fsBold];
  lblCardGestantesValue.Font.Color := $0078D4;

  lblCardGestantesDesc.Caption := 'Total de gestantes cadastradas';
  lblCardGestantesDesc.Font.Name := 'Segoe UI';
  lblCardGestantesDesc.Font.Size := 9;
  lblCardGestantesDesc.Font.Color := $666666;

  // Card Consultas
  pnlCardConsultas.Color := $FFFFFF;
  pnlCardConsultas.ParentBackground := False;
  pnlCardConsultas.BevelOuter := bvNone;
  lblCardConsultasTitle.Caption := 'Consultas Hoje';
  lblCardConsultasTitle.Font.Name := 'Segoe UI';
  lblCardConsultasTitle.Font.Size := 12;
  lblCardConsultasTitle.Font.Style := [fsBold];
  lblCardConsultasTitle.Font.Color := $333333;

  lblCardConsultasValue.Font.Name := 'Segoe UI';
  lblCardConsultasValue.Font.Size := 24;
  lblCardConsultasValue.Font.Style := [fsBold];
  lblCardConsultasValue.Font.Color := $107C10;

  lblCardConsultasDesc.Caption := 'Consultas agendadas para hoje';
  lblCardConsultasDesc.Font.Name := 'Segoe UI';
  lblCardConsultasDesc.Font.Size := 9;
  lblCardConsultasDesc.Font.Color := $666666;

  // Card Exames
  pnlCardExames.Color := $FFFFFF;
  pnlCardExames.ParentBackground := False;
  pnlCardExames.BevelOuter := bvNone;
  lblCardExamesTitle.Caption := 'Exames Pendentes';
  lblCardExamesTitle.Font.Name := 'Segoe UI';
  lblCardExamesTitle.Font.Size := 12;
  lblCardExamesTitle.Font.Style := [fsBold];
  lblCardExamesTitle.Font.Color := $333333;

  lblCardExamesValue.Font.Name := 'Segoe UI';
  lblCardExamesValue.Font.Size := 24;
  lblCardExamesValue.Font.Style := [fsBold];
  lblCardExamesValue.Font.Color := $FF8C00;

  lblCardExamesDesc.Caption := 'Exames aguardando resultado';
  lblCardExamesDesc.Font.Name := 'Segoe UI';
  lblCardExamesDesc.Font.Size := 9;
  lblCardExamesDesc.Font.Color := $666666;
end;

procedure TfrmPrincipal.ConfigurarListaAtividades;
begin
  lvRecentActivity.ViewStyle := vsReport;
  lvRecentActivity.RowSelect := True;
  lvRecentActivity.ReadOnly := True;
  lvRecentActivity.Font.Name := 'Segoe UI';
  lvRecentActivity.Font.Size := 9;

  // Configurar colunas
  with lvRecentActivity.Columns.Add do
  begin
    Caption := 'Hora';
    Width := 80;
  end;

  with lvRecentActivity.Columns.Add do
  begin
    Caption := 'Atividade';
    Width := 200;
  end;

  with lvRecentActivity.Columns.Add do
  begin
    Caption := 'Detalhes';
    Width := 250;
  end;
end;

procedure TfrmPrincipal.AtualizarDashboard;
var
  TotalGestantes, TotalConsultas, TotalExames: Integer;
  GestantesAtivas: TObjectList<TGestante>;
  ConsultasHoje: TObjectList<TConsulta>;
  ExamesPendentes: TObjectList<TExame>;
begin
  try
    // Atualizar card de gestantes
    GestantesAtivas := FGestanteController.BuscarAtivas.ObterLista;
    if Assigned(GestantesAtivas) then
    begin
      TotalGestantes := GestantesAtivas.Count;
      lblCardGestantesValue.Caption := IntToStr(TotalGestantes);
    end
    else
    begin
      TotalGestantes := 0;
      lblCardGestantesValue.Caption := '0';
    end;

    // Atualizar card de consultas (consultas de hoje)
    ConsultasHoje := FConsultaController.BuscarPorPeriodo(Date, Date).ObterLista;
    if Assigned(ConsultasHoje) then
    begin
      TotalConsultas := ConsultasHoje.Count;
      lblCardConsultasValue.Caption := IntToStr(TotalConsultas);
    end
    else
    begin
      TotalConsultas := 0;
      lblCardConsultasValue.Caption := '0';
    end;

    // Atualizar card de exames (exames pendentes)
    ExamesPendentes := FExameController.BuscarTodos.ObterLista;
    if Assigned(ExamesPendentes) then
    begin
      TotalExames := ExamesPendentes.Count;
      lblCardExamesValue.Caption := IntToStr(TotalExames);
    end
    else
    begin
      TotalExames := 0;
      lblCardExamesValue.Caption := '0';
    end;

    // Atualizar status
    lblStatus.Caption := Format('Sistema Online - %d gestantes, %d consultas hoje, %d exames',
      [TotalGestantes, TotalConsultas, TotalExames]);
  except
    on E: Exception do
    begin
      lblStatus.Caption := 'Erro ao carregar dados: ' + E.Message;
      lblCardGestantesValue.Caption := '?';
      lblCardConsultasValue.Caption := '?';
      lblCardExamesValue.Caption := '?';
    end;
  end;
end;

procedure TfrmPrincipal.AtualizarAtividadeRecente;
var
  Item: TListItem;
begin
  lvRecentActivity.Items.Clear;

  // Adicionar atividades de exemplo (implementar com dados reais)
  Item := lvRecentActivity.Items.Add;
  Item.Caption := FormatDateTime('hh:nn', Now);
  Item.SubItems.Add('Sistema Iniciado');
  Item.SubItems.Add('Sistema de controle de maternidade iniciado com sucesso');

  Item := lvRecentActivity.Items.Add;
  Item.Caption := FormatDateTime('hh:nn', Now - (1 / 24));
  Item.SubItems.Add('Conexão BD');
  Item.SubItems.Add('Conexão com banco de dados SQLite estabelecida');
end;

procedure TfrmPrincipal.SelecionarBotaoMenu(Botao: TSpeedButton);
begin
  // Resetar todos os botões
  btnGestantes.Down := False;
  btnConsultas.Down := False;
  btnExames.Down := False;
  btnRelatorios.Down := False;
  btnConfiguracoes.Down := False;

  // Selecionar o botão atual
  Botao.Down := True;
end;

procedure TfrmPrincipal.MostrarPainel(const NomePainel: string);
begin
  // Ocultar todos os painéis
  pnlDashboard.Visible := False;

  // Mostrar o painel solicitado
  if NomePainel = 'Dashboard' then
    pnlDashboard.Visible := True;
  // Adicionar outros painéis conforme necessário
end;

// Event Handlers

procedure TfrmPrincipal.btnGestantesClick(Sender: TObject);
var
  frmCadastroGestante: TfrmCadastroGestante;
begin
  SelecionarBotaoMenu(btnGestantes);
  MostrarPainel('Dashboard');

  frmCadastroGestante := TfrmCadastroGestante.Create(Self);
  try
    frmCadastroGestante.ShowModal;
    AtualizarDashboard; // Atualiza o dashboard após fechar o formulário
  finally
    frmCadastroGestante.Free;
  end;
end;

procedure TfrmPrincipal.btnConsultasClick(Sender: TObject);
var
  frmCadastroConsulta: TfrmCadastroConsulta;
begin
  SelecionarBotaoMenu(btnConsultas);

  frmCadastroConsulta := TfrmCadastroConsulta.Create(Self);
  try
    frmCadastroConsulta.ShowModal;
    AtualizarDashboard; // Atualiza o dashboard após fechar o formulário
  finally
    frmCadastroConsulta.Free;
  end;
end;

procedure TfrmPrincipal.btnExamesClick(Sender: TObject);
var
  frmCadastroExame: TfrmCadastroExame;
begin
  SelecionarBotaoMenu(btnExames);

  frmCadastroExame := TfrmCadastroExame.Create(Self);
  try
    frmCadastroExame.ShowModal;
    AtualizarDashboard; // Atualiza o dashboard após fechar o formulário
  finally
    frmCadastroExame.Free;
  end;
end;

procedure TfrmPrincipal.btnRelatoriosClick(Sender: TObject);
begin
  SelecionarBotaoMenu(btnRelatorios);
  // Implementação básica de relatórios
  MessageDlg('Módulo de Relatórios' + #13#10 +
    '• Relatório de Gestantes' + #13#10 +
    '• Relatório de Consultas' + #13#10 +
    '• Relatório de Exames' + #13#10 +
    '• Estatísticas Gerais' + #13#10#13#10 +
    'Funcionalidade será implementada em versão futura.',
    mtInformation, [mbOK], 0);
end;

procedure TfrmPrincipal.btnConfiguracoesClick(Sender: TObject);
begin
  SelecionarBotaoMenu(btnConfiguracoes);
  // Implementação básica de configurações
  MessageDlg('Configurações do Sistema' + #13#10 +
    '• Configurações de Banco de Dados' + #13#10 +
    '• Configurações de Backup' + #13#10 +
    '• Configurações de Usuário' + #13#10 +
    '• Configurações de Impressão' + #13#10 +
    '• Sobre o Sistema' + #13#10#13#10 +
    'Funcionalidade será implementada em versão futura.',
    mtInformation, [mbOK], 0);
end;

procedure TfrmPrincipal.btnNovaGestanteClick(Sender: TObject);
var
  frmCadastroGestante: TfrmCadastroGestante;
begin
  frmCadastroGestante := TfrmCadastroGestante.Create(Self);
  try
    frmCadastroGestante.ShowModal;
    AtualizarDashboard; // Atualiza o dashboard após fechar o formulário
  finally
    frmCadastroGestante.Free;
  end;
end;

procedure TfrmPrincipal.btnNovaConsultaClick(Sender: TObject);
var
  frmCadastroConsulta: TfrmCadastroConsulta;
begin
  frmCadastroConsulta := TfrmCadastroConsulta.Create(Self);
  try
    frmCadastroConsulta.ShowModal;
    AtualizarDashboard; // Atualiza o dashboard após fechar o formulário
  finally
    frmCadastroConsulta.Free;
  end;
end;

procedure TfrmPrincipal.btnNovoExameClick(Sender: TObject);
var
  frmCadastroExame: TfrmCadastroExame;
begin
  frmCadastroExame := TfrmCadastroExame.Create(Self);
  try
    frmCadastroExame.ShowModal;
    AtualizarDashboard; // Atualiza o dashboard após fechar o formulário
  finally
    frmCadastroExame.Free;
  end;
end;

procedure TfrmPrincipal.btnBuscarGestanteClick(Sender: TObject);
var
  frmCadastroGestante: TfrmCadastroGestante;
begin
  frmCadastroGestante := TfrmCadastroGestante.Create(Self);
  try
    frmCadastroGestante.ShowModal;
  finally
    frmCadastroGestante.Free;
  end;
end;

procedure TfrmPrincipal.tmrUpdateTimer(Sender: TObject);
begin
  AtualizarDashboard;
  AtualizarAtividadeRecente;
end;

end.

