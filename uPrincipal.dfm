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
  OnKeyDown = FormKeyDown
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
      object Fornecedor1: TMenuItem
        Caption = 'Fornecedor'
        OnClick = Fornecedor1Click
      end
      object Famlia1: TMenuItem
        Caption = 'Fam'#237'lia'
        OnClick = Famlia1Click
      end
      object Margem1: TMenuItem
        Caption = 'Margem'
        OnClick = Margem1Click
      end
      object ConfiguraodeProdutos1: TMenuItem
        Caption = 'Configura'#231#227'o de Produtos'
        OnClick = ConfiguraodeProdutos1Click
      end
      object ConsultadeProdutos1: TMenuItem
        Caption = 'Consulta de Produtos'
        OnClick = ConsultadeProdutos1Click
      end
    end
    object Importaes1: TMenuItem
      Caption = 'Importa'#231#245'es'
      object GerarLote1: TMenuItem
        Caption = 'Gerar Lote'
        OnClick = GerarLote1Click
      end
      object Importacoes2: TMenuItem
        Caption = 'Importa'#231#245'es'
        OnClick = Importacoes2Click
      end
      object ImportaodeArquivosdeFornecedores1: TMenuItem
        Caption = 'Importa'#231#227'o de Arquivos de Fornecedores'
        OnClick = ImportaodeArquivosdeFornecedores1Click
      end
    end
    object Movimentaes1: TMenuItem
      Caption = 'Movimenta'#231#245'es'
      object GerarMatch1: TMenuItem
        Caption = 'Gerar Match'
        OnClick = GerarMatch1Click
      end
      object ConsultaMatch1: TMenuItem
        Caption = 'Consultar Match'
        OnClick = ConsultaMatch1Click
      end
      object GerarPrecificao1: TMenuItem
        Caption = 'Gerar Precifica'#231#227'o'
        OnClick = GerarPrecificao1Click
      end
      object ConsultarMatch1: TMenuItem
        Caption = 'Consultar Precificacao'
        OnClick = ConsultarMatch1Click
      end
    end
    object Relatrios1: TMenuItem
      Caption = 'Relat'#243'rios'
      object Cross1: TMenuItem
        Caption = 'Cross'
        object ItensdoFornecedor1: TMenuItem
          Caption = 'Itens do Fornecedor'
          OnClick = ItensdoFornecedor1Click
        end
        object ListagemdeProdutos1: TMenuItem
          Caption = 'Listagem de Produtos'
          OnClick = ListagemdeProdutos1Click
        end
        object ListagemdeFornecedores1: TMenuItem
          Caption = 'Listagem de Fornecedores'
          OnClick = ListagemdeFornecedores1Click
        end
        object ListagemdeAtualizaoporFornecedor1: TMenuItem
          Caption = 'Listagem de Atualiza'#231#227'o por Fornecedor'
          OnClick = ListagemdeAtualizaoporFornecedor1Click
        end
        object HistricodeAtualizaoporSKU1: TMenuItem
          Caption = 'Hist'#243'rico por SKU'
          OnClick = HistricodeAtualizaoporSKU1Click
        end
        object ListagemSimplesdeFornecedor1: TMenuItem
          Caption = 'Listagem Simples de Fornecedores'
          OnClick = ListagemSimplesdeFornecedor1Click
        end
        object ListagemdeAlmoxarifados1: TMenuItem
          Caption = 'Listagem Simples de Almoxarifados'
          OnClick = ListagemdeAlmoxarifados1Click
        end
        object ListagemdeLotes1: TMenuItem
          Caption = 'Listagem de Lotes'
          OnClick = ListagemdeLotes1Click
        end
        object RatingporFornecedor1: TMenuItem
          Caption = 'Rating por Fornecedor'
          OnClick = RatingporFornecedor1Click
        end
        object HistricodeCustoporSKU1: TMenuItem
          Caption = 'Hist'#243'rico de Custo por SKU'
          OnClick = HistricodeCustoporSKU1Click
        end
        object ResponsvelMatch1: TMenuItem
          Caption = 'Respons'#225'vel Match'
          OnClick = Match1Click
        end
        object SKUxSubGrupoAbacosxSubGrupoCross1: TMenuItem
          Caption = 'SKU x SubGrupo Abacos x SubGrupo Cross'
          OnClick = SKUxSubGrupoAbacosxSubGrupoCross1Click
        end
        object RatingDetalhadoPorFornecedor1: TMenuItem
          Caption = 'Rating Detalhado Por Fornecedor'
          OnClick = RatingDetalhadoPorFornecedor1Click
        end
        object AlteraodeCusto1: TMenuItem
          Caption = 'Altera'#231#227'o de Custo'
          OnClick = AlteraodeCusto1Click
        end
        object ProdutosPorFornecedor1: TMenuItem
          Caption = 'Produtos Por Fornecedor'
          OnClick = ProdutosPorFornecedor1Click
        end
      end
      object Precificao1: TMenuItem
        Caption = 'Precifica'#231#227'o'
        object HistricodePreoeMargem1: TMenuItem
          Caption = 'Hist'#243'rico de Pre'#231'o e Margem'
          OnClick = HistricodePreoeMargem1Click
        end
        object CustoPreoeMargemporDepartamentoMarca1: TMenuItem
          Caption = 'Custo, Pre'#231'o e Margem por Departamento/Marca'
          OnClick = CustoPreoeMargemporDepartamentoMarca1Click
        end
      end
    end
    object Arquivo1: TMenuItem
      Caption = 'Arquivo'
      object Produtos1: TMenuItem
        Caption = 'Produtos'
        OnClick = Produtos1Click
      end
      object ProdutosBaseFornecedor1: TMenuItem
        Caption = 'Produtos Base Fornecedor'
        OnClick = ProdutosBaseFornecedor1Click
      end
      object ProdutosDetalhado1: TMenuItem
        Caption = 'Produtos Detalhado'
        OnClick = ProdutosDetalhado1Click
      end
      object Matchs1: TMenuItem
        Caption = 'Matchs'
        OnClick = Matchs1Click
      end
    end
    object Configuraes1: TMenuItem
      Caption = 'Configura'#231#245'es'
      object ConfigGerais1: TMenuItem
        Caption = 'Configura'#231#245'es do Sistema'
        OnClick = ConfigGerais1Click
      end
      object RedefinirSenha: TMenuItem
        Caption = 'Redefinir Senha'
        OnClick = RedefinirSenhaClick
      end
      object BackupdoBancodeDados1: TMenuItem
        Caption = 'Backup do Banco de Dados'
        OnClick = BackupdoBancodeDados1Click
      end
    end
    object miSair: TMenuItem
      Caption = 'Sair'
      ShortCut = 27
      OnClick = miSairClick
    end
  end
end
