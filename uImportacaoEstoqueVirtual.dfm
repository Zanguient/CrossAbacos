object frmImportacaodeEstoqueVirtual: TfrmImportacaodeEstoqueVirtual
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Importa'#231#227'o de Estoque Virtual'
  ClientHeight = 486
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 689
    Height = 486
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object gbBuscaArquivo: TGroupBox
      Left = 0
      Top = 0
      Width = 689
      Height = 57
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      DesignSize = (
        689
        57)
      object lbNomeArquivo: TLabel
        Left = 453
        Top = 24
        Width = 6
        Height = 24
        Anchors = [akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object sbBuscaArquivo: TSpeedButton
        Left = 366
        Top = 20
        Width = 81
        Height = 34
        Anchors = [akTop, akRight]
        Caption = '...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = sbBuscaArquivoClick
      end
      object Label1: TLabel
        Left = 3
        Top = 2
        Width = 85
        Height = 19
        Caption = 'Fornecedor:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 366
        Top = 2
        Width = 62
        Height = 19
        Anchors = [akTop, akRight]
        Caption = 'Arquivo:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object cbFornecedores: TComboBox
        Left = 3
        Top = 21
        Width = 209
        Height = 32
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object gbCampos: TGroupBox
      Left = 0
      Top = 57
      Width = 689
      Height = 208
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object pnSelecionaCampos: TPanel
        Left = 2
        Top = 15
        Width = 685
        Height = 55
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        ExplicitLeft = 3
        DesignSize = (
          685
          55)
        object Label3: TLabel
          Left = 1
          Top = 2
          Width = 147
          Height = 19
          Caption = 'Campos do Arquivo:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label4: TLabel
          Left = 364
          Top = 2
          Width = 204
          Height = 19
          Anchors = [akTop, akRight]
          Caption = 'Campos do Banco de Dados:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object sbAdicionarRelacaoCampos: TSpeedButton
          Left = 603
          Top = 21
          Width = 40
          Height = 34
          Anchors = [akTop, akRight]
          Caption = '+'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = sbAdicionarRelacaoCamposClick
        end
        object sbRemoverRelacaoCampos: TSpeedButton
          Left = 645
          Top = 21
          Width = 40
          Height = 34
          Anchors = [akTop, akRight]
          Caption = '-'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          OnClick = sbRemoverRelacaoCamposClick
        end
        object cbCamposExcel: TComboBox
          Left = 1
          Top = 21
          Width = 209
          Height = 32
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object cbCamposBancodeDados: TComboBox
          Left = 364
          Top = 21
          Width = 209
          Height = 32
          Style = csDropDownList
          Anchors = [akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -20
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
      object DBGrid1: TDBGrid
        Left = 2
        Top = 70
        Width = 685
        Height = 136
        Align = alClient
        DataSource = dsCamposRelacionados
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ParentFont = False
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -20
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'EXCEL'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'BANCODADOS'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            Visible = True
          end>
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 280
    Top = 80
  end
  object csCamposRelacionados: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 224
    Top = 248
    object csCamposRelacionadosEXCEL: TStringField
      DisplayLabel = 'Excel'
      FieldName = 'EXCEL'
      Size = 100
    end
    object csCamposRelacionadosBANCODADOS: TStringField
      DisplayLabel = 'Banco de Dados'
      FieldName = 'BANCODADOS'
      Size = 100
    end
    object csCamposRelacionadosINDICEEXCEL: TIntegerField
      FieldName = 'INDICEEXCEL'
    end
  end
  object dsCamposRelacionados: TDataSource
    DataSet = csCamposRelacionados
    Left = 448
    Top = 256
  end
end
