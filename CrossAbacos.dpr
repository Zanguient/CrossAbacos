program CrossAbacos;

uses
  Vcl.Forms,
  Vcl.Controls,
  MidasLib,
  System.SysUtils,
  uPrincipal in 'uPrincipal.pas' {FrmPrincipal},
  uLogin in 'uLogin.pas' {FrmLogin},
  uConstantes in 'Units\uConstantes.pas',
  uFuncoes in 'Units\uFuncoes.pas',
  uMensagem in 'Diversos\uMensagem.pas' {frmMensagem},
  uDMUtil in 'Diversos\uDMUtil.pas' {DMUtil: TDataModule},
  uFWConnection in 'uFWConnection.pas',
  uDomains in 'Diversos\uDomains.pas',
  uFWPersistence in 'Diversos\uFWPersistence.pas',
  uBeanUsuario in 'Beans\uBeanUsuario.pas',
  uCadPadrao in 'Cadastros\uCadPadrao.pas' {frmCadPadrao},
  uCadastroUsuario in 'Cadastros\uCadastroUsuario.pas' {FrmCadastroUsuario},
  uBeanFornecedor in 'Beans\uBeanFornecedor.pas',
  uBeanProduto in 'Beans\uBeanProduto.pas',
  uRedefinirSenha in 'uRedefinirSenha.pas' {FrmRedefinirSenha},
  uCadastroMargem in 'Cadastros\uCadastroMargem.pas' {FrmCadastroMargem},
  uBeanMargem in 'Beans\uBeanMargem.pas',
  uBeanGrupo in 'Beans\uBeanGrupo.pas',
  uCadastroFamilia in 'Cadastros\uCadastroFamilia.pas' {FrmCadastroFamilia},
  uBeanFamilia in 'Beans\uBeanFamilia.pas',
  uConsultaMatch in 'uConsultaMatch.pas' {frmConsultaMatch},
  uBeanLoteImportacao in 'Beans\uBeanLoteImportacao.pas',
  uImportacao in 'uImportacao.pas' {frmImportacao},
  uBeanAlmoxarifado in 'Beans\uBeanAlmoxarifado.pas',
  uBeanProdutoFornecedor in 'Beans\uBeanProdutoFornecedor.pas',
  uImportacaoArquivoFornecedor in 'uImportacaoArquivoFornecedor.pas' {frmImportacaoArquivoFornecedor},
  uSeleciona in 'uSeleciona.pas' {frmSeleciona},
  uBeanImportacao in 'Beans\uBeanImportacao.pas',
  uBeanImportacao_Itens in 'Beans\uBeanImportacao_Itens.pas',
  uBeanMatch in 'Beans\uBeanMatch.pas',
  uBeanMatch_Itens in 'Beans\uBeanMatch_Itens.pas',
  uGeraMatch in 'uGeraMatch.pas' {frmGeraMatch},
  uBeanUsuario_Permissao in 'Beans\uBeanUsuario_Permissao.pas',
  uInativaProdutoFornecedor in 'uInativaProdutoFornecedor.pas' {frmInativaProdutoFornecedor},
  uRelItensdoFornecedor in 'uRelItensdoFornecedor.pas' {frmRelItensdoFornecedor},
  uRelListagemProdutos in 'uRelListagemProdutos.pas' {frmRelListagemProdutos},
  uRelListagemFornecedor in 'uRelListagemFornecedor.pas' {frmRelListagemFornecedor},
  uConfiguracoesSistema in 'uConfiguracoesSistema.pas' {frmConfiguracoesSistema},
  uRelListagemAtualizacaoporFornecedor in 'uRelListagemAtualizacaoporFornecedor.pas' {frmRelListagemAtualizacaoporFornecedor},
  uRelRatingporFornecedor in 'uRelRatingporFornecedor.pas' {frmRatingporFornecedor},
  uRelatorios in 'Units\uRelatorios.pas',
  uRelHistoricodeCustoporSKU in 'uRelHistoricodeCustoporSKU.pas' {frmRelHistoricodeCustoporSKU},
  uRelHistoricoporSKU in 'uRelHistoricoporSKU.pas' {frmRelHistoricoporSKU},
  uRelResponsavelMatch in 'uRelResponsavelMatch.pas' {frmRelResponsavelMatch},
  uRelListagemdeLotes in 'uRelListagemdeLotes.pas' {frmRelListagemdeLotes},
  uCadFornecedor in 'Cadastros\uCadFornecedor.pas' {frmCadFornecedor},
  uRelRatingDetalhadoporFornecedor in 'uRelRatingDetalhadoporFornecedor.pas' {frmRelRatingDetalhadoporFornecedor},
  uConsultaProduto in 'uConsultaProduto.pas' {frmConsultaProdutos},
  uArquivoProdutos in 'uArquivoProdutos.pas' {FrmArquivoProdutos},
  uRelAlteracaoCusto in 'uRelAlteracaoCusto.pas' {frmRelAlteracaoCusto},
  uBeanPrecificacao in 'Beans\uBeanPrecificacao.pas',
  uBeanPrecificacao_itens in 'Beans\uBeanPrecificacao_itens.pas',
  uGeraPrecificacao in 'uGeraPrecificacao.pas' {frmGeraPrecificacao};

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TDMUtil, DMUtil);
  Application.CreateForm(TFrmLogin, FrmLogin);
  if FrmLogin.ShowModal = mrOk then begin

    FreeAndNil(FrmLogin);
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);
    Application.Run;

  end else
    Application.Terminate; //Encerra a aplicação

end.
