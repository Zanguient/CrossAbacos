program CrossAbacos;

uses
  Vcl.Forms,
  Vcl.Controls,
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
  uMatch in 'uMatch.pas' {frmMatch},
  uBeanLoteImportacao in 'Beans\uBeanLoteImportacao.pas',
  uImportacao in 'uImportacao.pas' {frmImportacao},
  uBeanAlmoxarifado in 'Beans\uBeanAlmoxarifado.pas',
  uBeanProdutoFornecedor in 'Beans\uBeanProdutoFornecedor.pas',
  uImportacaoArquivoFornecedor in 'uImportacaoArquivoFornecedor.pas' {frmImportacaoArquivoFornecedor},
  uSeleciona in 'uSeleciona.pas' {frmSeleciona},
  uBeanImportacao in 'Beans\uBeanImportacao.pas',
  uBeanImportacao_Itens in 'Beans\uBeanImportacao_Itens.pas';

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
