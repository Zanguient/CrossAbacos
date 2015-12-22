object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  ClientHeight = 467
  ClientWidth = 1035
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  WindowState = wsMaximized
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object IMFundo: TImage
    Left = 0
    Top = 0
    Width = 1035
    Height = 467
    Align = alClient
    Stretch = True
    ExplicitLeft = 448
    ExplicitTop = 128
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object MainMenu1: TMainMenu
    Left = 320
    Top = 128
    object Cadastros1: TMenuItem
      Caption = 'Cadastros'
      object Usuario1: TMenuItem
        Caption = 'Usu'#225'rio'
        OnClick = Usuario1Click
      end
      object Margem1: TMenuItem
        Caption = 'Margem'
        OnClick = Margem1Click
      end
      object Familia1: TMenuItem
        Caption = 'Familia'
        OnClick = Familia1Click
      end
    end
    object Lanamentos1: TMenuItem
      Caption = 'Lan'#231'amentos'
      object Precificao1: TMenuItem
        Caption = 'Precifica'#231#227'o'
      end
      object CrossEstoque1: TMenuItem
        Caption = 'Cross - Estoque'
      end
      object CrossFornec1: TMenuItem
        Caption = 'Cross - Fornec.'
      end
      object CrossMatch1: TMenuItem
        Caption = 'Cross - Match'
      end
    end
    object Importaes1: TMenuItem
      Caption = 'Importa'#231#245'es'
      object Estoques1: TMenuItem
        Caption = 'Estoques'
      end
      object ProdutosERP1: TMenuItem
        Caption = 'Produtos ERP'
      end
    end
    object Relatrios1: TMenuItem
      Caption = 'Relat'#243'rios'
    end
    object Configuraes1: TMenuItem
      Caption = 'Configura'#231#245'es'
      object ConfigGerais1: TMenuItem
        Caption = 'Config. Gerais'
      end
      object RedefinirSenha: TMenuItem
        Caption = 'Redefinir Senha'
        OnClick = RedefinirSenhaClick
      end
    end
    object miSair: TMenuItem
      Caption = 'Sair'
      ShortCut = 27
      OnClick = miSairClick
    end
  end
end
