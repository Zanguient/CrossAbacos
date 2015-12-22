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
  uBeanProdutoAbacos in 'Beans\uBeanProdutoAbacos.pas',
  uRedefinirSenha in 'uRedefinirSenha.pas' {FrmRedefinirSenha},
  uCadastroMargem in 'Cadastros\uCadastroMargem.pas' {FrmCadastroMargem},
  uBeanMargem in 'Beans\uBeanMargem.pas',
  uBeanGrupo in 'Beans\uBeanGrupo.pas',
  uImportacaoEstoqueVirtual in 'uImportacaoEstoqueVirtual.pas' {frmImportacaodeEstoqueVirtual},
  uCadastroFamilia in 'Cadastros\uCadastroFamilia.pas' {FrmCadastroFamilia},
  uBeanFamilia in 'Beans\uBeanFamilia.pas',
  uMatch in 'uMatch.pas' {frmMatch},
  uBeanLoteImportacao in 'Beans\uBeanLoteImportacao.pas';

{$R *.res}

begin

  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TDMUtil, DMUtil);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TfrmMatch, frmMatch);
  if FrmLogin.ShowModal = mrOk then begin

    FreeAndNil(FrmLogin);
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);
    Application.Run;

  end else
    Application.Terminate; //Encerra a aplicação

end.
