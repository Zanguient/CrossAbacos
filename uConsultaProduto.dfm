object frmConsultaProdutos: TfrmConsultaProdutos
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Consulta de Produtos'
  ClientHeight = 469
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 469
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object pnTopo: TPanel
      Left = 0
      Top = 0
      Width = 688
      Height = 49
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 3
        Top = 2
        Width = 81
        Height = 16
        Caption = 'Digite o Filtro:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object edFiltro: TEdit
        AlignWithMargins = True
        Left = 3
        Top = 19
        Width = 682
        Height = 27
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnKeyDown = edFiltroKeyDown
      end
    end
    object dgConsulta: TDBGrid
      Left = 0
      Top = 49
      Width = 688
      Height = 420
      Align = alClient
      Color = clMoneyGreen
      DataSource = dsConsulta
      DrawingStyle = gdsGradient
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
      OnDrawColumnCell = dgConsultaDrawColumnCell
      OnTitleClick = dgConsultaTitleClick
      Columns = <
        item
          Expanded = False
          FieldName = 'SKU'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ID_PAI'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NOMEPRODUTO'
          Width = 255
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MARCA'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CATEGORIA'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MENORCUSTO'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'FORNECEDOR'
          Width = 300
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DATAULTIMAATUA'
          Visible = True
        end>
    end
  end
  object csConsulta: TClientDataSet
    Aggregates = <>
    Params = <>
    OnFilterRecord = csConsultaFilterRecord
    Left = 104
    Top = 176
    object csConsultaSKU: TStringField
      FieldName = 'SKU'
      Size = 60
    end
    object csConsultaNOMEPRODUTO: TStringField
      DisplayLabel = 'Nome Produto'
      FieldName = 'NOMEPRODUTO'
      Size = 255
    end
    object csConsultaMARCA: TStringField
      DisplayLabel = 'Marca'
      FieldName = 'MARCA'
      Size = 100
    end
    object csConsultaCATEGORIA: TStringField
      DisplayLabel = 'Categoria'
      FieldName = 'CATEGORIA'
      Size = 100
    end
    object csConsultaMENORCUSTO: TCurrencyField
      DisplayLabel = 'Menor Custo'
      FieldName = 'MENORCUSTO'
    end
    object csConsultaFORNECEDOR: TStringField
      DisplayLabel = 'Fornecedor'
      FieldName = 'FORNECEDOR'
      Size = 120
    end
    object csConsultaDATAULTIMAATUA: TDateTimeField
      DisplayLabel = 'Dt '#218'ltima Atualiza'#231#227'o'
      FieldName = 'DATAULTIMAATUA'
    end
    object csConsultaID_PAI: TStringField
      DisplayLabel = 'SKU Pai'
      FieldName = 'ID_PAI'
      Size = 100
    end
  end
  object dsConsulta: TDataSource
    DataSet = csConsulta
    Left = 264
    Top = 280
  end
end
