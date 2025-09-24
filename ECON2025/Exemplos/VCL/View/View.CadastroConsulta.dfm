object frmCadastroConsulta: TfrmCadastroConsulta
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  Caption = 'Cadastro de Consultas'
  ClientHeight = 875
  ClientWidth = 1503
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 1503
    Height = 875
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    Color = 15987699
    ParentBackground = False
    TabOrder = 0
    object pnlHeader: TPanel
      Left = 0
      Top = 0
      Width = 1503
      Height = 100
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblTitulo: TLabel
        Left = 30
        Top = 20
        Width = 209
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Cadastro de Consultas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3355443
        Font.Height = -20
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSubtitulo: TLabel
        Left = 30
        Top = 56
        Width = 258
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Gerenciamento de consultas pr'#233'-natais'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6710886
        Font.Height = -15
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlContent: TPanel
      Left = 0
      Top = 100
      Width = 1503
      Height = 700
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      BevelOuter = bvNone
      Color = 15987699
      ParentBackground = False
      TabOrder = 1
      object pnlBusca: TPanel
        Left = 30
        Top = 20
        Width = 1440
        Height = 225
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblBusca: TLabel
          Left = 20
          Top = 20
          Width = 128
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Buscar Consultas'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 3355443
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtBusca: TEdit
          Left = 20
          Top = 50
          Width = 250
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 0
        end
        object btnBuscar: TButton
          Left = 280
          Top = 50
          Width = 94
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Buscar'
          TabOrder = 1
          OnClick = btnBuscarClick
        end
        object lvConsultas: TListView
          Left = 20
          Top = 90
          Width = 1400
          Height = 115
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Columns = <>
          ReadOnly = True
          RowSelect = True
          TabOrder = 2
          ViewStyle = vsReport
          OnSelectItem = lvConsultasSelectItem
        end
      end
      object pnlDadosConsulta: TPanel
        Left = 30
        Top = 265
        Width = 1440
        Height = 400
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object lblDadosConsulta: TLabel
          Left = 20
          Top = 20
          Width = 142
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Dados da Consulta'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 3355443
          Font.Height = -16
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblGestante: TLabel
          Left = 20
          Top = 60
          Width = 58
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Gestante'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblDataConsulta: TLabel
          Left = 420
          Top = 60
          Width = 93
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Data Consulta'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblPesoAtual: TLabel
          Left = 620
          Top = 60
          Width = 69
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Peso Atual'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblPressaoArterial: TLabel
          Left = 770
          Top = 60
          Width = 103
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Press'#227'o Arterial'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblAlturaUterina: TLabel
          Left = 20
          Top = 120
          Width = 92
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Altura Uterina'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblBatimentosFetais: TLabel
          Left = 220
          Top = 120
          Width = 117
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Batimentos Fetais'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblIdadeGestacional: TLabel
          Left = 420
          Top = 120
          Width = 119
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Idade Gestacional'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblMedicoResponsavel: TLabel
          Left = 620
          Top = 120
          Width = 136
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'M'#233'dico Respons'#225'vel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblObservacoes: TLabel
          Left = 20
          Top = 180
          Width = 84
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Observa'#231#245'es'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object cmbGestante: TComboBox
          Left = 20
          Top = 84
          Width = 375
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = csDropDownList
          TabOrder = 0
          OnChange = cmbGestanteChange
        end
        object dtpDataConsulta: TDateTimePicker
          Left = 420
          Top = 84
          Width = 175
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Date = 45292.000000000000000000
          Time = 0.708333333335758700
          TabOrder = 1
        end
        object edtPesoAtual: TEdit
          Left = 620
          Top = 84
          Width = 125
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 2
        end
        object edtPressaoArterial: TEdit
          Left = 770
          Top = 84
          Width = 125
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 3
        end
        object edtAlturaUterina: TEdit
          Left = 20
          Top = 144
          Width = 175
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 4
        end
        object edtBatimentosFetais: TEdit
          Left = 220
          Top = 144
          Width = 175
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 5
        end
        object edtIdadeGestacional: TEdit
          Left = 420
          Top = 144
          Width = 175
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ReadOnly = True
          TabOrder = 6
        end
        object edtMedicoResponsavel: TEdit
          Left = 620
          Top = 144
          Width = 275
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 7
        end
        object memoObservacoes: TMemo
          Left = 20
          Top = 204
          Width = 1400
          Height = 175
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 8
        end
      end
    end
    object pnlFooter: TPanel
      Left = 0
      Top = 800
      Width = 1503
      Height = 75
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object btnSalvar: TButton
        Left = 30
        Top = 20
        Width = 125
        Height = 44
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Salvar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnSalvarClick
      end
      object btnCancelar: TButton
        Left = 170
        Top = 20
        Width = 125
        Height = 44
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Cancelar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = btnCancelarClick
      end
      object btnNovo: TButton
        Left = 310
        Top = 20
        Width = 125
        Height = 44
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Novo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnNovoClick
      end
      object btnExcluir: TButton
        Left = 450
        Top = 20
        Width = 125
        Height = 44
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Excluir'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = btnExcluirClick
      end
    end
  end
end
