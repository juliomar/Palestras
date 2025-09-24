unit View.CadastroConsulta;

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
  System.DateUtils,
  Model.Consulta,
  Model.Gestante,
  Controller.Gestante,
  Controller.Consulta,
  Utils.Validacao,
  Utils.Formatacao;

type
  TfrmCadastroConsulta = class(TForm)
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
    pnlDadosConsulta: TPanel;
    lblDadosConsulta: TLabel;
    lblGestante: TLabel;
    cmbGestante: TComboBox;
    lblDataConsulta: TLabel;
    dtpDataConsulta: TDateTimePicker;
    lblPesoAtual: TLabel;
    edtPesoAtual: TEdit;
    lblPressaoArterial: TLabel;
    edtPressaoArterial: TEdit;
    lblAlturaUterina: TLabel;
    edtAlturaUterina: TEdit;
    lblBatimentosFetais: TLabel;
    edtBatimentosFetais: TEdit;
    lblIdadeGestacional: TLabel;
    edtIdadeGestacional: TEdit;
    lblMedicoResponsavel: TLabel;
    edtMedicoResponsavel: TEdit;
    lblObservacoes: TLabel;
    memoObservacoes: TMemo;
    pnlBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TButton;
    lvConsultas: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure lvConsultasSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure cmbGestanteChange(Sender: TObject);
  private
    FGestanteController: TGestanteController;
    FConsultaController: TConsultaController;
    FModoEdicao: Boolean;

    procedure ConfigurarInterface;
    procedure ConfigurarEstiloWindows11;
    procedure ConfigurarListView;
    procedure LimparCampos;
    procedure CarregarGestantes;
    procedure CarregarDadosNaTela;
    procedure SalvarDadosDaTela;
    procedure ValidarCampos;
    procedure ExibirErros(const Erros: TStringList);
    procedure AtualizarListaConsultas;
    procedure HabilitarCampos(const Habilitar: Boolean);
    procedure ConfigurarLabelSecao(ALabel: TLabel);
    procedure ConfigurarBotao(ABotao: TButton; ACor: TColor);

  public
    property ModoEdicao: Boolean read FModoEdicao write FModoEdicao;
  end;

var
  frmCadastroConsulta: TfrmCadastroConsulta;

implementation

{$R *.dfm}

procedure TfrmCadastroConsulta.FormCreate(Sender: TObject);
begin
  FGestanteController := TGestanteController.Create;
  FConsultaController := TConsultaController.Create;
  FModoEdicao := False;

  ConfigurarInterface;
  ConfigurarEstiloWindows11;
  ConfigurarListView;
  CarregarGestantes;
  LimparCampos;
end;

procedure TfrmCadastroConsulta.FormDestroy(Sender: TObject);
begin
  if Assigned(FGestanteController) then
    FreeAndNil(FGestanteController);
  if Assigned(FConsultaController) then
    FreeAndNil(FConsultaController);
end;

procedure TfrmCadastroConsulta.FormShow(Sender: TObject);
begin
  AtualizarListaConsultas;
  cmbGestante.SetFocus;
end;

procedure TfrmCadastroConsulta.ConfigurarInterface;
begin
  Self.Caption := 'Cadastro de Consultas';
  Self.Position := poScreenCenter;
  Self.WindowState := wsMaximized;

  // Configurar textos
  lblTitulo.Caption := 'Cadastro de Consultas';
  lblSubtitulo.Caption := 'Gerenciamento de consultas pré-natais';

  lblDadosConsulta.Caption := 'Dados da Consulta';
  lblBusca.Caption := 'Buscar Consultas';

  // Configurar botões
  btnSalvar.Caption := 'Salvar';
  btnCancelar.Caption := 'Cancelar';
  btnNovo.Caption := 'Novo';
  btnExcluir.Caption := 'Excluir';
  btnBuscar.Caption := 'Buscar';

  // Configurar campos calculados como readonly
  edtIdadeGestacional.ReadOnly := True;
end;

procedure TfrmCadastroConsulta.ConfigurarEstiloWindows11;
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
  pnlDadosConsulta.Color := $FFFFFF;
  pnlDadosConsulta.ParentBackground := False;

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
  ConfigurarLabelSecao(lblDadosConsulta);
  ConfigurarLabelSecao(lblBusca);

  // Configurar botões
  ConfigurarBotao(btnSalvar, $0078D4); // Azul
  ConfigurarBotao(btnCancelar, $666666); // Cinza
  ConfigurarBotao(btnNovo, $107C10); // Verde
  ConfigurarBotao(btnExcluir, $D13438); // Vermelho
  ConfigurarBotao(btnBuscar, $5C2D91); // Roxo
end;

procedure TfrmCadastroConsulta.ConfigurarLabelSecao(ALabel: TLabel);
begin
  ALabel.Font.Name := 'Segoe UI';
  ALabel.Font.Size := 12;
  ALabel.Font.Style := [fsBold];
  ALabel.Font.Color := $333333;
end;

procedure TfrmCadastroConsulta.ConfigurarBotao(ABotao: TButton; ACor: TColor);
begin
  ABotao.Font.Name := 'Segoe UI';
  ABotao.Font.Size := 10;
  ABotao.Font.Style := [fsBold];
  ABotao.Font.Color := clWhite;
  ABotao.Height := 35;
end;

procedure TfrmCadastroConsulta.ConfigurarListView;
begin
  lvConsultas.ViewStyle := vsReport;
  lvConsultas.RowSelect := True;
  lvConsultas.ReadOnly := True;
  lvConsultas.Font.Name := 'Segoe UI';
  lvConsultas.Font.Size := 9;

  // Configurar colunas
  with lvConsultas.Columns.Add do
  begin
    Caption := 'ID';
    Width := 50;
  end;

  with lvConsultas.Columns.Add do
  begin
    Caption := 'Gestante';
    Width := 200;
  end;

  with lvConsultas.Columns.Add do
  begin
    Caption := 'Data Consulta';
    Width := 120;
  end;

  with lvConsultas.Columns.Add do
  begin
    Caption := 'Peso';
    Width := 80;
  end;

  with lvConsultas.Columns.Add do
  begin
    Caption := 'Pressão';
    Width := 100;
  end;

  with lvConsultas.Columns.Add do
  begin
    Caption := 'Médico';
    Width := 150;
  end;
end;

procedure TfrmCadastroConsulta.LimparCampos;
begin
  cmbGestante.ItemIndex := -1;
  dtpDataConsulta.Date := Date;
  edtPesoAtual.Clear;
  edtPressaoArterial.Clear;
  edtAlturaUterina.Clear;
  edtBatimentosFetais.Clear;
  edtIdadeGestacional.Clear;
  edtMedicoResponsavel.Clear;
  memoObservacoes.Clear;

  FModoEdicao := False;
  HabilitarCampos(True);
end;

procedure TfrmCadastroConsulta.CarregarGestantes;
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

procedure TfrmCadastroConsulta.CarregarDadosNaTela;
var
  Consulta: TConsulta;
begin
  if not FConsultaController.ExisteConsulta then
    Exit;

  Consulta := FConsultaController.ObterConsulta;
  if not Assigned(Consulta) then
    Exit;

  // Selecionar gestante no combo
  var I: Integer;
  for I := 0 to cmbGestante.Items.Count - 1 do
  begin
    if Integer(cmbGestante.Items.Objects[I]) = Consulta.GestanteId then
    begin
      cmbGestante.ItemIndex := I;
      Break;
    end;
  end;

  if Consulta.DataConsulta > 0 then
    dtpDataConsulta.Date := Consulta.DataConsulta;

  if Consulta.PesoAtual > 0 then
    edtPesoAtual.Text := FormatFloat('0.0', Consulta.PesoAtual);

  edtPressaoArterial.Text := Consulta.PressaoArterial;

  if Consulta.AlturaUterina > 0 then
    edtAlturaUterina.Text := FormatFloat('0.0', Consulta.AlturaUterina);

  if Consulta.BatimentosFetais > 0 then
    edtBatimentosFetais.Text := IntToStr(Consulta.BatimentosFetais);

  edtIdadeGestacional.Text := Consulta.IdadeGestacional;
  edtMedicoResponsavel.Text := Consulta.MedicoResponsavel;
  memoObservacoes.Text := Consulta.Observacoes;

  FModoEdicao := True;
end;

procedure TfrmCadastroConsulta.SalvarDadosDaTela;
begin
  if not FModoEdicao then
    FConsultaController.NovaConsulta;

  if cmbGestante.ItemIndex >= 0 then
    FConsultaController.ComGestante(Integer(cmbGestante.Items.Objects[cmbGestante.ItemIndex]));

  FConsultaController
    .ComDataConsulta(dtpDataConsulta.Date)
    .ComPressaoArterial(edtPressaoArterial.Text)
    .ComIdadeGestacional(edtIdadeGestacional.Text)
    .ComMedicoResponsavel(edtMedicoResponsavel.Text)
    .ComObservacoes(memoObservacoes.Text);

  // Converter valores numéricos
  if Trim(edtPesoAtual.Text) <> '' then
    FConsultaController.ComPesoAtual(StrToFloatDef(edtPesoAtual.Text, 0));

  if Trim(edtAlturaUterina.Text) <> '' then
    FConsultaController.ComAlturaUterina(StrToFloatDef(edtAlturaUterina.Text, 0));

  if Trim(edtBatimentosFetais.Text) <> '' then
    FConsultaController.ComBatimentosFetais(StrToIntDef(edtBatimentosFetais.Text, 0));
end;

procedure TfrmCadastroConsulta.ValidarCampos;
var
  Erros: TStringList;
begin
  Erros := TStringList.Create;
  try
    // Validações básicas
    if cmbGestante.ItemIndex < 0 then
      Erros.Add('Gestante é obrigatória');

    if Trim(edtMedicoResponsavel.Text) = '' then
      Erros.Add('Médico responsável é obrigatório');

    // Validar pressão arterial se informada
    if (Trim(edtPressaoArterial.Text) <> '') and
      (not TValidacao.ValidarPressaoArterial(edtPressaoArterial.Text)) then
      Erros.Add('Pressão arterial deve estar no formato 120x80');

    // Validar batimentos fetais se informados
    if (Trim(edtBatimentosFetais.Text) <> '') and
      (not TValidacao.ValidarBatimentosFetais(StrToIntDef(edtBatimentosFetais.Text, 0))) then
      Erros.Add('Batimentos fetais devem estar entre 110 e 180 bpm');

    // Validar peso se informado
    if (Trim(edtPesoAtual.Text) <> '') and
      (not TValidacao.ValidarPeso(StrToFloatDef(edtPesoAtual.Text, 0))) then
      Erros.Add('Peso deve estar entre 30 e 200 kg');

    if Erros.Count > 0 then
      ExibirErros(Erros);
  finally
    Erros.Free;
  end;
end;

procedure TfrmCadastroConsulta.ExibirErros(const Erros: TStringList);
begin
  MessageDlg('Erros de validação:' + sLineBreak + sLineBreak + Erros.Text,
    mtError, [mbOK], 0);
end;

procedure TfrmCadastroConsulta.AtualizarListaConsultas;
var
  Consultas: TObjectList<TConsulta>;
  Consulta: TConsulta;
  Item: TListItem;
  Gestante: TGestante;
begin
  lvConsultas.Items.Clear;

  try
    Consultas := FConsultaController.BuscarTodas.ObterLista;
    if not Assigned(Consultas) then
      Exit;

    for Consulta in Consultas do
    begin
      Item := lvConsultas.Items.Add;
      Item.Caption := IntToStr(Consulta.Id);

      // Buscar nome da gestante
      FGestanteController.CarregarGestante(Consulta.GestanteId);
      if FGestanteController.ExisteGestante then
      begin
        Gestante := FGestanteController.ObterGestante;
        Item.SubItems.Add(Gestante.Nome);
      end
      else
        Item.SubItems.Add('Gestante não encontrada');

      Item.SubItems.Add(TFormatacao.FormatarData(Consulta.DataConsulta));

      if Consulta.PesoAtual > 0 then
        Item.SubItems.Add(FormatFloat('0.0 kg', Consulta.PesoAtual))
      else
        Item.SubItems.Add('-');

      Item.SubItems.Add(Consulta.PressaoArterial);
      Item.SubItems.Add(Consulta.MedicoResponsavel);
      Item.Data := Pointer(Consulta.Id);
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar lista de consultas: ' + E.Message);
  end;
end;

procedure TfrmCadastroConsulta.HabilitarCampos(const Habilitar: Boolean);
begin
  cmbGestante.Enabled := Habilitar;
  dtpDataConsulta.Enabled := Habilitar;
  edtPesoAtual.Enabled := Habilitar;
  edtPressaoArterial.Enabled := Habilitar;
  edtAlturaUterina.Enabled := Habilitar;
  edtBatimentosFetais.Enabled := Habilitar;
  edtMedicoResponsavel.Enabled := Habilitar;
  memoObservacoes.Enabled := Habilitar;
end;

// Event Handlers

procedure TfrmCadastroConsulta.btnSalvarClick(Sender: TObject);
begin
  try
    ValidarCampos;
    SalvarDadosDaTela;

    FConsultaController.ValidarDados.Salvar;

    if FConsultaController.TemErro then
    begin
      MessageDlg(FConsultaController.ObterErro, mtError, [mbOK], 0);
      Exit;
    end;

    if FConsultaController.Sucesso then
    begin
      MessageDlg('Consulta salva com sucesso!', mtInformation, [mbOK], 0);
      AtualizarListaConsultas;
      LimparCampos;
    end
    else
      MessageDlg(FConsultaController.ObterErro, mtError, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao salvar consulta: ' + E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCadastroConsulta.btnCancelarClick(Sender: TObject);
begin
  if MessageDlg('Deseja cancelar a operação?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    LimparCampos;
end;

procedure TfrmCadastroConsulta.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  cmbGestante.SetFocus;
end;

procedure TfrmCadastroConsulta.btnExcluirClick(Sender: TObject);
var
  ConsultaId: Integer;
begin
  if not FModoEdicao then
  begin
    MessageDlg('Selecione uma consulta para excluir', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg('Confirma a exclusão desta consulta?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      // Obter ID da consulta selecionada
      if Assigned(lvConsultas.Selected) and Assigned(lvConsultas.Selected.Data) then
      begin
        ConsultaId := Integer(lvConsultas.Selected.Data);
        FConsultaController.CarregarConsulta(ConsultaId).Excluir;

        if FConsultaController.Sucesso then
        begin
          MessageDlg('Consulta excluída com sucesso!', mtInformation, [mbOK], 0);
          AtualizarListaConsultas;
          LimparCampos;
          FModoEdicao := False;
        end
        else
          MessageDlg('Erro ao excluir consulta: ' + FConsultaController.ObterErro, mtError, [mbOK], 0);
      end
      else
        MessageDlg('Erro: Consulta não identificada', mtError, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg('Erro ao excluir consulta: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmCadastroConsulta.btnBuscarClick(Sender: TObject);
var
  TermoBusca: string;
  Consultas: TObjectList<TConsulta>;
  Consulta: TConsulta;
  Item: TListItem;
  Gestante: TGestante;
begin
  TermoBusca := Trim(edtBusca.Text);

  if TermoBusca = '' then
  begin
    AtualizarListaConsultas;
    Exit;
  end;

  try
    lvConsultas.Items.Clear;

    // Buscar por médico responsável
    Consultas := FConsultaController.BuscarPorMedico(TermoBusca).ObterLista;

    if Assigned(Consultas) then
    begin
      for Consulta in Consultas do
      begin
        Item := lvConsultas.Items.Add;
        Item.Data := Pointer(Consulta.Id);

        // Buscar dados da gestante
        Gestante := FGestanteController.CarregarGestante(Consulta.GestanteId).ObterGestante;
        if Assigned(Gestante) then
          Item.Caption := Gestante.Nome
        else
          Item.Caption := 'Gestante não encontrada';

        Item.SubItems.Add(FormatDateTime('dd/mm/yyyy', Consulta.DataConsulta));
        Item.SubItems.Add(Consulta.MedicoResponsavel);

        if Consulta.PesoAtual > 0 then
          Item.SubItems.Add(FormatFloat('0.0 kg', Consulta.PesoAtual))
        else
          Item.SubItems.Add('-');

        Item.SubItems.Add(Consulta.PressaoArterial);
      end;
    end;

    if lvConsultas.Items.Count = 0 then
      MessageDlg('Nenhuma consulta encontrada para: ' + TermoBusca, mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao buscar consultas: ' + E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCadastroConsulta.lvConsultasSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  ConsultaId: Integer;
begin
  if Selected and Assigned(Item) and Assigned(Item.Data) then
  begin
    try
      ConsultaId := Integer(Item.Data);
      FConsultaController.CarregarConsulta(ConsultaId);

      if FConsultaController.ExisteConsulta then
      begin
        CarregarDadosNaTela;
        FModoEdicao := True;
        HabilitarCampos(True);
      end
      else
        MessageDlg('Erro ao carregar consulta selecionada', mtError, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg('Erro ao carregar consulta: ' + E.Message, mtError, [mbOK], 0);
    end;
  end
  else
  begin
    FModoEdicao := False;
    LimparCampos;
  end;
end;

procedure TfrmCadastroConsulta.cmbGestanteChange(Sender: TObject);
var
  GestanteId: Integer;
  Gestante: TGestante;
  IdadeGestacional: string;
  DiasGestacao: Integer;
  Semanas, Dias: Integer;
begin
  if cmbGestante.ItemIndex >= 0 then
  begin
    try
      GestanteId := Integer(cmbGestante.Items.Objects[cmbGestante.ItemIndex]);
      Gestante := FGestanteController.CarregarGestante(GestanteId).ObterGestante;

      if Assigned(Gestante) and (Gestante.DataUltimaMenstruacao > 0) then
      begin
        // Calcular idade gestacional baseada na DUM
        DiasGestacao := DaysBetween(Now, Gestante.DataUltimaMenstruacao);

        if DiasGestacao > 0 then
        begin
          Semanas := DiasGestacao div 7;
          Dias := DiasGestacao mod 7;

          if Dias > 0 then
            IdadeGestacional := Format('%d semanas e %d dias', [Semanas, Dias])
          else
            IdadeGestacional := Format('%d semanas', [Semanas]);

          edtIdadeGestacional.Text := IdadeGestacional;
        end
        else
          edtIdadeGestacional.Text := 'Não calculável';
      end
      else
        edtIdadeGestacional.Text := 'DUM não informada';
    except
      on E: Exception do
      begin
        edtIdadeGestacional.Text := 'Erro no cálculo';
        // Log do erro se necessário
      end;
    end;
  end
  else
    edtIdadeGestacional.Text := '';
end;

end.

