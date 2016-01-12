object frmImportacao: TfrmImportacao
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Importa'#231#245'es'
  ClientHeight = 476
  ClientWidth = 729
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imFundo: TImage
    Left = 0
    Top = 0
    Width = 729
    Height = 476
    Align = alClient
    Center = True
    Stretch = True
    ExplicitLeft = 24
    ExplicitTop = 128
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object pnPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 729
    Height = 476
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object GridPanel1: TGridPanel
      Left = 1
      Top = 1
      Width = 727
      Height = 474
      Align = alClient
      Color = clWhite
      ColumnCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = pnImportacaoProduto
          Row = 0
        end
        item
          Column = 1
          Control = pnImportaAlmoxarifados
          Row = 0
        end
        item
          Column = 0
          Control = pnImportaFornecedor
          Row = 1
        end
        item
          Column = 1
          Control = pnImportaProdutoFornecedor
          Row = 1
        end>
      RowCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      TabOrder = 0
      object pnImportacaoProduto: TPanel
        Left = 1
        Top = 1
        Width = 362
        Height = 236
        Align = alClient
        Color = clWhite
        TabOrder = 0
        object pbImportaProdutos: TProgressBar
          Left = 1
          Top = 203
          Width = 360
          Height = 32
          Align = alBottom
          ParentShowHint = False
          ShowHint = False
          TabOrder = 2
        end
        object mnImportaProdutos: TMemo
          Left = 1
          Top = 50
          Width = 360
          Height = 153
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
        end
        object pnCabProdutos: TPanel
          Left = 1
          Top = 1
          Width = 360
          Height = 49
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          DesignSize = (
            360
            49)
          object Label1: TLabel
            Left = 5
            Top = 0
            Width = 171
            Height = 19
            Caption = 'Importa'#231#227'o de Produtos'
          end
          object btImportarProdutos: TButton
            Left = 283
            Top = 20
            Width = 75
            Height = 27
            Anchors = [akTop, akRight]
            Caption = 'Importar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnClick = btImportarProdutosClick
          end
          object edBuscaArquivoProdutos: TButtonedEdit
            Left = 5
            Top = 20
            Width = 275
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            Images = ImageList1
            ParentFont = False
            RightButton.ImageIndex = 1
            RightButton.Visible = True
            TabOrder = 0
            TextHint = 'Selecione o Arquivo...'
            OnRightButtonClick = edBuscaArquivoProdutosRightButtonClick
          end
        end
      end
      object pnImportaAlmoxarifados: TPanel
        Left = 363
        Top = 1
        Width = 363
        Height = 236
        Align = alClient
        Color = clWhite
        TabOrder = 1
        object pnCabAlmoxarifado: TPanel
          Left = 1
          Top = 1
          Width = 361
          Height = 49
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 0
          DesignSize = (
            361
            49)
          object Label2: TLabel
            Left = 4
            Top = 0
            Width = 210
            Height = 19
            Caption = 'Importa'#231#227'o de Almoxarifados'
          end
          object btImportaAlmoxarifado: TButton
            Left = 283
            Top = 20
            Width = 75
            Height = 27
            Anchors = [akTop, akRight]
            Caption = 'Importar'
            TabOrder = 1
            OnClick = btImportaAlmoxarifadoClick
          end
          object edBuscaArquivoAlmoxarifado: TButtonedEdit
            Left = 4
            Top = 20
            Width = 277
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            Images = ImageList1
            ParentFont = False
            RightButton.ImageIndex = 1
            RightButton.Visible = True
            TabOrder = 0
            TextHint = 'Selecione o Arquivo...'
            OnRightButtonClick = edBuscaArquivoAlmoxarifadoRightButtonClick
          end
        end
        object mnImportaAlmoxarifado: TMemo
          Left = 1
          Top = 50
          Width = 361
          Height = 153
          Align = alClient
          ReadOnly = True
          TabOrder = 1
        end
        object pbImportaAlmoxarifado: TProgressBar
          Left = 1
          Top = 203
          Width = 361
          Height = 32
          Align = alBottom
          ParentShowHint = False
          ShowHint = False
          TabOrder = 2
        end
      end
      object pnImportaFornecedor: TPanel
        Left = 1
        Top = 237
        Width = 362
        Height = 236
        Align = alClient
        Color = clWhite
        TabOrder = 2
        object mnImportaFornecedor: TMemo
          Left = 1
          Top = 49
          Width = 360
          Height = 154
          Align = alClient
          ReadOnly = True
          TabOrder = 1
        end
        object pbImportaFornecedor: TProgressBar
          Left = 1
          Top = 203
          Width = 360
          Height = 32
          Align = alBottom
          ParentShowHint = False
          ShowHint = False
          TabOrder = 2
        end
        object pnCabImportaFornecedor: TPanel
          Left = 1
          Top = 1
          Width = 360
          Height = 48
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 0
          DesignSize = (
            360
            48)
          object Label3: TLabel
            Left = 5
            Top = 0
            Width = 202
            Height = 19
            Caption = 'Importa'#231#227'o de Fornecedores'
          end
          object btImportarFornecedor: TButton
            Left = 283
            Top = 19
            Width = 75
            Height = 27
            Anchors = [akTop, akRight]
            Caption = 'Importar'
            TabOrder = 1
            OnClick = btImportarFornecedorClick
          end
          object edBuscaArquivoFornecedor: TButtonedEdit
            Left = 5
            Top = 19
            Width = 275
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            Images = ImageList1
            ParentFont = False
            RightButton.ImageIndex = 1
            RightButton.Visible = True
            TabOrder = 0
            TextHint = 'Selecione o Arquivo...'
            OnRightButtonClick = edBuscaArquivoFornecedorRightButtonClick
          end
        end
      end
      object pnImportaProdutoFornecedor: TPanel
        Left = 363
        Top = 237
        Width = 363
        Height = 236
        Align = alClient
        Color = clWhite
        TabOrder = 3
        object pnCabImportaProdutoFornecedor: TPanel
          Left = 1
          Top = 1
          Width = 361
          Height = 48
          Align = alTop
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 0
          DesignSize = (
            361
            48)
          object Label4: TLabel
            Left = 4
            Top = 0
            Width = 385
            Height = 19
            Caption = 'Importa'#231#227'o de C'#243'digo dos Produtos dos Fornecedores'
          end
          object btImportarProdutoFornecedor: TButton
            Left = 283
            Top = 19
            Width = 75
            Height = 27
            Anchors = [akTop, akRight]
            Caption = 'Importar'
            TabOrder = 1
            OnClick = btImportarProdutoFornecedorClick
          end
          object edBuscaArquivoProdutoFornecedor: TButtonedEdit
            Left = 4
            Top = 19
            Width = 277
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            Images = ImageList1
            ParentFont = False
            RightButton.ImageIndex = 1
            RightButton.Visible = True
            TabOrder = 0
            TextHint = 'Selecione o Arquivo...'
            OnRightButtonClick = edBuscaArquivoProdutoFornecedorRightButtonClick
          end
        end
        object mnImportaProdutoFornecedor: TMemo
          Left = 1
          Top = 49
          Width = 361
          Height = 154
          Align = alClient
          ReadOnly = True
          TabOrder = 1
        end
        object pbImportaProdutoFornecedor: TProgressBar
          Left = 1
          Top = 203
          Width = 361
          Height = 32
          Align = alBottom
          ParentShowHint = False
          ShowHint = False
          TabOrder = 2
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 249
    Top = 81
  end
  object ImageList1: TImageList
    Left = 201
    Top = 105
    Bitmap = {
      494C0101020008005C0010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FEFEFE00F3F3F300CACA
      CA00A4A4A4005E5E5E0026262600EEEEEE00FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC9C9
      C900A3A3A3005D5D5D0024242400FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000ECECEC00DFDFDF00CDCDCD00CACACA00DEDE
      DE00ECECEC002B292900000000007D7D7D00FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDEDEDE00CCCCCC00C9C9C900DDDD
      DD00FFFFFFFF2B292900000000007B7B7B000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008D8D8D00000000008F8F9000FBFBFB00FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF8C8C8C00000000008F8F9000FFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000002B29
      2900000000006D6D6D00FBFBFB0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2B29
      2900000000006B6B6B00FFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008E8E8E000000
      00008F8F9000FBFBFB000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8D8D8D000000
      00008F8F9000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000B9B3B1004A4443007777
      7700FDFDFD00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB7B1AF00484241007676
      7600FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FDFDFD009A9A
      990099999800999998009B9B9B00F6F6F600E9E9E900342D2C00DFDCDB00FDFD
      FD0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF9898
      9700979797009797960099999900FFFFFFFFFFFFFFFF322B2A00DDD9D900FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008B8B8900BFBEBB00C2C2
      C000C2C2C100C1C1C000C3C2C000C0C0BF008D8C8C00E1E1E000000000000000
      000000000000000000000000000000000000FFFFFFFF89898700BFBEBB00C2C2
      C000C2C2C100C1C1C000C3C2C000C0C0BF008B8A8A00DFDFDE00FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000B6B6B400BDBDBA00BABA
      B700B8B7B500B7B7B400B9B9B600BCBCB900B8B8B500F6F6F600000000000000
      000000000000000000000000000000000000FFFFFFFFB6B6B400BDBDBA00BABA
      B700B8B7B500B7B7B400B9B9B600BCBCB900B8B8B500FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000009A9A9A00A8A8A500A7A7A400A7A7
      A400A7A7A400A8A8A400A8A8A500A8A8A500A8A8A50092929100000000000000
      00000000000000000000000000000000000098989800A8A8A500A7A7A400A7A7
      A400A7A7A400A8A8A400A8A8A500A8A8A500A8A8A50090908F00FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008F8F8E00A2A29F00A2A39F00A3A3
      A000A3A3A000A3A3A000A3A4A000A4A4A100A4A4A1008B8B8A00F9F9F9000000
      0000000000000000000000000000000000008D8D8C00A2A29F00A2A39F00A3A3
      A000A3A3A000A3A3A000A3A4A000A4A4A100A4A4A10089898800FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008F8F8E009D9E9C009E9F9D00A1A1
      9E00A2A29F00A2A3A000A2A3A000A1A29F00A1A19F0087878600F9F9F9000000
      0000000000000000000000000000000000008D8D8C009D9E9C009E9F9D00A1A1
      9E00A2A29F00A2A3A000A2A3A000A1A29F00A1A19F0085858400FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000999A9900ABACAB00ABACAB00ACAD
      AB00ACADAB00ACADAB00ADADAB00ADADAB00ADADAB008B8B8B00000000000000
      00000000000000000000000000000000000097989700ABACAB00ABACAB00ACAD
      AB00ACADAB00ACADAB00ADADAB00ADADAB00ADADAB0089898900FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A4A5A300CBCBCA00CBCB
      CB00CBCBCB00CBCBCB00CBCBCB00CBCCCB00B2B2B000F7F7F700000000000000
      000000000000000000000000000000000000FFFFFFFFA4A5A300CBCBCA00CBCB
      CB00CBCBCB00CBCBCB00CBCBCB00CBCCCB00B2B2B000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000085858400A9AAA800E1E1
      E100E1E1E100E1E1E100E1E1E100B9B9B8008586850000000000000000000000
      000000000000000000000000000000000000FFFFFFFF83838200A9AAA800E1E1
      E100E1E1E100E1E1E100E1E1E100B9B9B80083848300FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009394
      9300858685008586850090908F00FBFBFB000000000000000000000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF9192
      910083848300848484008E8E8D00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FF80000000000000FE00000000000000
      FFF0000000000000FFE1000000000000FFC3000000000000FF87000000000000
      C00F000000000000803F000000000000803F000000000000003F000000000000
      001F000000000000001F000000000000003F000000000000803F000000000000
      807F000000000000E0FF00000000000000000000000000000000000000000000
      000000000000}
  end
end
