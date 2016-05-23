unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Vcl.ExtCtrls, Math,
  FireDAC.Comp.Client, ShellAPI;

type
  TFrmPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Cadastros1: TMenuItem;
    Importaes1: TMenuItem;
    Relatrios1: TMenuItem;
    Configuraes1: TMenuItem;
    Usuario1: TMenuItem;
    ConfigGerais1: TMenuItem;
    miSair: TMenuItem;
    IMFundo: TImage;
    RedefinirSenha: TMenuItem;
    Importacoes2: TMenuItem;
    Movimentaes1: TMenuItem;
    ConsultaMatch1: TMenuItem;
    GerarLote1: TMenuItem;
    ImportaodeArquivosdeFornecedores1: TMenuItem;
    GerarMatch1: TMenuItem;
    ConfiguraodeProdutos1: TMenuItem;
    ItensdoFornecedor1: TMenuItem;
    Cross1: TMenuItem;
    ListagemdeProdutos1: TMenuItem;
    ListagemdeFornecedores1: TMenuItem;
    ListagemdeAtualizaoporFornecedor1: TMenuItem;
    HistricodeAtualizaoporSKU1: TMenuItem;
    ListagemSimplesdeFornecedor1: TMenuItem;
    ListagemdeAlmoxarifados1: TMenuItem;
    ListagemdeLotes1: TMenuItem;
    RatingporFornecedor1: TMenuItem;
    HistricodeCustoporSKU1: TMenuItem;
    SKUxSubGrupoAbacosxSubGrupoCross1: TMenuItem;
    Fornecedor1: TMenuItem;
    RatingDetalhadoPorFornecedor1: TMenuItem;
    ConsultadeProdutos1: TMenuItem;
    Arquivo1: TMenuItem;
    Produtos1: TMenuItem;
    BackupdoBancodeDados1: TMenuItem;
    Famlia1: TMenuItem;
    Margem1: TMenuItem;
    AlteraodeCusto1: TMenuItem;
    ResponsvelMatch1: TMenuItem;
    procedure Usuario1Click(Sender: TObject);
    procedure miSairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RedefinirSenhaClick(Sender: TObject);
    procedure Importacoes2Click(Sender: TObject);
    procedure GerarLote1Click(Sender: TObject);
    procedure ConsultaMatch1Click(Sender: TObject);
    procedure ImportaodeArquivosdeFornecedores1Click(Sender: TObject);
    procedure GerarMatch1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ConfiguraodeProdutos1Click(Sender: TObject);
    procedure ItensdoFornecedor1Click(Sender: TObject);
    procedure ListagemdeProdutos1Click(Sender: TObject);
    procedure ListagemdeFornecedores1Click(Sender: TObject);
    procedure ConfigGerais1Click(Sender: TObject);
    procedure ListagemdeAtualizaoporFornecedor1Click(Sender: TObject);
    procedure HistricodeAtualizaoporSKU1Click(Sender: TObject);
    procedure ListagemSimplesdeFornecedor1Click(Sender: TObject);
    procedure ListagemdeAlmoxarifados1Click(Sender: TObject);
    procedure ListagemdeLotes1Click(Sender: TObject);
    procedure RatingporFornecedor1Click(Sender: TObject);
    procedure HistricodeCustoporSKU1Click(Sender: TObject);
    procedure Match1Click(Sender: TObject);
    procedure SKUxSubGrupoAbacosxSubGrupoCross1Click(Sender: TObject);
    procedure Fornecedor1Click(Sender: TObject);
    procedure RatingDetalhadoPorFornecedor1Click(Sender: TObject);
    procedure ConsultadeProdutos1Click(Sender: TObject);
    procedure Produtos1Click(Sender: TObject);
    procedure BackupdoBancodeDados1Click(Sender: TObject);
    procedure Famlia1Click(Sender: TObject);
    procedure Margem1Click(Sender: TObject);
    procedure AlteraodeCusto1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CriarComandoSequenciaMenu(Menu: TMainMenu);
    procedure DefinirPermissoes;
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  uConstantes,
  uFuncoes,
  uMensagem,
  uCadastroUsuario,
  uBeanUsuario,
  uRedefinirSenha,
  uImportacao,
  uConsultaMatch,
  uImportacaoArquivoFornecedor,
  uGeraMatch,
  uInativaProdutoFornecedor,
  uFWConnection, uDMUtil,
  uRelItensdoFornecedor,
  uRelListagemProdutos,
  uRelListagemFornecedor,
  uConfiguracoesSistema,
  uRelListagemAtualizacaoporFornecedor,
  uRelHistoricoporSKU,
  uRelatorios,
  uRelListagemdeLotes,
  uRelRatingporFornecedor,
  uRelHistoricodeCustoporSKU,
  uRelResponsavelMatch,
  uCadFornecedor,
  uRelRatingDetalhadoporFornecedor,
  uConsultaProduto,
  uArquivoProdutos,
  uCadastroFamilia,
  uCadastroMargem,
  uRelAlteracaoCusto;
{$R *.dfm}

procedure TFrmPrincipal.DefinirPermissoes;
begin
  RedefinirSenha.Visible  := False; //Usuário 0 é Administrador e não tem Cadastro
  if USUARIO.CODIGO > 0 then begin
    DefinePermissaoMenu(MainMenu1);
    miSair.Visible          := True;
  end;
end;

procedure TFrmPrincipal.Famlia1Click(Sender: TObject);
begin
  if FrmCadastroFamilia = nil then
    FrmCadastroFamilia := TFrmCadastroFamilia.Create(nil);
  try
    FrmCadastroFamilia.ShowModal;
  finally
    FreeAndNil(FrmCadastroFamilia);
  end;
end;

procedure TFrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = VK_F11) then begin
    DESIGNREL       := not DESIGNREL;
    if DESIGNREL then
      DisplayMsg(MSG_INF, 'Design de Relatórios Ativado!')
    else
      DisplayMsg(MSG_INF, 'Design de Relatórios Desativado!');
  end;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');

  CarregaArrayMenus(MainMenu1);

  DefinirPermissoes;

  CriarComandoSequenciaMenu(MainMenu1);

  Caption := 'Sistema CrossAbacos - Usuário: ' + IntToStr(USUARIO.CODIGO) + ' - ' + USUARIO.NOME;
end;

procedure TFrmPrincipal.Fornecedor1Click(Sender: TObject);
begin
  if frmCadFornecedor = nil then
    frmCadFornecedor := TfrmCadFornecedor.Create(nil);
  try
    frmCadFornecedor.ShowModal;
  finally
    FreeAndNil(frmCadFornecedor);
  end;
end;

procedure TFrmPrincipal.GerarLote1Click(Sender: TObject);
begin
  GerarLoteImportacao;
end;

procedure TFrmPrincipal.GerarMatch1Click(Sender: TObject);
begin
  if frmGeraMatch = nil then
    frmGeraMatch := TfrmGeraMatch.Create(nil);
  try
    frmGeraMatch.ShowModal;
  finally
    FreeAndNil(frmGeraMatch);
  end;

end;

procedure TFrmPrincipal.HistricodeAtualizaoporSKU1Click(Sender: TObject);
begin
  if frmRelHistoricoporSKU = nil then
    frmRelHistoricoporSKU   := TfrmRelHistoricoporSKU.Create(nil);
  try
    frmRelHistoricoporSKU.ShowModal;
  finally
    FreeAndNil(frmRelHistoricoporSKU);
  end;
end;

procedure TFrmPrincipal.HistricodeCustoporSKU1Click(Sender: TObject);
begin
  if frmRelHistoricodeCustoporSKU = nil then
    frmRelHistoricodeCustoporSKU   := TfrmRelHistoricodeCustoporSKU.Create(nil);
  try
    frmRelHistoricodeCustoporSKU.ShowModal;
  finally
    FreeAndNil(frmRelHistoricodeCustoporSKU);
  end;
end;

procedure TFrmPrincipal.Importacoes2Click(Sender: TObject);
begin
  if frmImportacao = nil then
    frmImportacao   := TfrmImportacao.Create(nil);
  try
    frmImportacao.ShowModal;
  finally
    FreeAndNil(frmImportacao);
  end;
end;

procedure TFrmPrincipal.ImportaodeArquivosdeFornecedores1Click(Sender: TObject);
begin
  if frmImportacaoArquivoFornecedor = nil then
    frmImportacaoArquivoFornecedor   := TfrmImportacaoArquivoFornecedor.Create(nil);
  frmImportacaoArquivoFornecedor.ShowModal;
end;

procedure TFrmPrincipal.ItensdoFornecedor1Click(Sender: TObject);
begin
  if not Assigned(frmRelItensdoFornecedor) then
    frmRelItensdoFornecedor   := TfrmRelItensdoFornecedor.Create(nil);
  try
    frmRelItensdoFornecedor.ShowModal;
  finally
    FreeAndNil(frmRelItensdoFornecedor);
  end;
end;

procedure TFrmPrincipal.ListagemdeAlmoxarifados1Click(Sender: TObject);
begin
  RelatorioListagemAlmoxarifados;
end;

procedure TFrmPrincipal.ListagemdeAtualizaoporFornecedor1Click(Sender: TObject);
begin
  try
    if frmRelListagemAtualizacaoporFornecedor = nil then
      frmRelListagemAtualizacaoporFornecedor := TfrmRelListagemAtualizacaoporFornecedor.Create(Self);
    frmRelListagemAtualizacaoporFornecedor.ShowModal;
  finally
    FreeAndNil(frmRelListagemAtualizacaoporFornecedor);
  end;
end;

procedure TFrmPrincipal.ListagemdeFornecedores1Click(Sender: TObject);
begin
  if not Assigned(frmRelListagemFornecedor) then
    frmRelListagemFornecedor := TfrmRelListagemFornecedor.Create(nil);
  try
    frmRelListagemFornecedor.ShowModal;
  finally
    FreeAndNil(frmRelListagemFornecedor);
  end;
end;

procedure TFrmPrincipal.ListagemdeLotes1Click(Sender: TObject);
begin
  try
    if frmRelListagemdeLotes = nil then
      frmRelListagemdeLotes := TfrmRelListagemdeLotes.Create(Self);
    frmRelListagemdeLotes.ShowModal;
  finally
    FreeAndNil(frmRelListagemdeLotes);
  end;
end;

procedure TFrmPrincipal.ListagemdeProdutos1Click(Sender: TObject);
begin
  if not Assigned(frmRelListagemProdutos) then
    frmRelListagemProdutos := TfrmRelListagemProdutos.Create(nil);
  try
    frmRelListagemProdutos.ShowModal;
  finally
    FreeAndNil(frmRelListagemProdutos);
  end;
end;

procedure TFrmPrincipal.ListagemSimplesdeFornecedor1Click(Sender: TObject);
begin
  RelatorioListagemFornecedores;
end;

procedure TFrmPrincipal.Margem1Click(Sender: TObject);
begin
  if FrmCadastroMargem = nil then
    FrmCadastroMargem := TFrmCadastroMargem.Create(nil);
  try
    FrmCadastroMargem.ShowModal;
  finally
    FreeAndNil(FrmCadastroMargem);
  end;
end;

procedure TFrmPrincipal.Match1Click(Sender: TObject);
begin
  try
    if frmRelResponsavelMatch = nil then
      frmRelResponsavelMatch := TfrmRelResponsavelMatch.Create(Self);
    frmRelResponsavelMatch.ShowModal;
  finally
    FreeAndNil(frmRelResponsavelMatch);
  end;
end;

procedure TFrmPrincipal.AlteraodeCusto1Click(Sender: TObject);
begin
  try
    if frmRelAlteracaoCusto = nil then
      frmRelAlteracaoCusto := TfrmRelAlteracaoCusto.Create(Self);
    frmRelAlteracaoCusto.ShowModal;
  finally
    FreeAndNil(frmRelAlteracaoCusto);
  end;
end;

procedure TFrmPrincipal.BackupdoBancodeDados1Click(Sender: TObject);
var
  DirBkp : String;
begin
  DisplayMsg(MSG_WAIT, 'Realizando Backup');

  DirBkp := ExtractFilePath(Application.ExeName) +  'backups\';

 if not DirectoryExists(DirBkp) then
   CreateDir(DirBkp);

 if not FileExists(ExtractFilePath(Application.ExeName) + 'pg_dump.exe') then begin
   DisplayMsg(MSG_INF, 'Executavel do Backup (PG_Dump.exe) não encontrado na pasta do executável!' + sLineBreak + 'Para continuar o executável é necessário!');
   Exit;
 end;

 ShellExecute(0, 'OPEN', pchar( ExtractFilePath(Application.ExeName) + 'pg_dump.exe'), pchar(' --host ' + CONEXAO.Server + ' --port 5432 --username ' + CONEXAO.User_Name + ' --format custom --file "' + CONEXAO.Database + '_' + FormatDateTime('yyyymmdd_hhmm', Now) + '.backup" ' + CONEXAO.Database), pchar(DirBkp), SW_SHOWNORMAL);

 DisplayMsgFinaliza;
end;

procedure TFrmPrincipal.ConfigGerais1Click(Sender: TObject);
begin
  try
    if frmConfiguracoesSistema = nil then
      frmConfiguracoesSistema := TfrmConfiguracoesSistema.Create(Self);
    frmConfiguracoesSistema.ShowModal;
  finally
    FreeAndNil(frmConfiguracoesSistema);
  end;
end;

procedure TFrmPrincipal.ConfiguraodeProdutos1Click(Sender: TObject);
begin
  if frmInativaProdutoFornecedor = nil then
    frmInativaProdutoFornecedor := TfrmInativaProdutoFornecedor.Create(nil);
  try
    frmInativaProdutoFornecedor.ShowModal;
  finally
    FreeAndNil(frmInativaProdutoFornecedor);
  end;
end;

procedure TFrmPrincipal.ConsultadeProdutos1Click(Sender: TObject);
begin
  if frmConsultaProdutos = nil then
    frmConsultaProdutos   := TfrmConsultaProdutos.Create(nil);
  try
    frmConsultaProdutos.ShowModal;
  finally
    FreeAndNil(frmConsultaProdutos);
  end;
end;

procedure TFrmPrincipal.ConsultaMatch1Click(Sender: TObject);
begin
  try
    if frmConsultaMatch = nil then
      frmConsultaMatch := TfrmConsultaMatch.Create(Self);
    frmConsultaMatch.ShowModal;
  finally
    FreeAndNil(frmConsultaMatch);
  end;
end;

procedure TFrmPrincipal.miSairClick(Sender: TObject);
begin
  DisplayMsg(MSG_CONF, 'Deseja realmente sair do sistema?', 'Sair do Sistema');

  if (ResultMsgModal = mrYes) then
    Close;
end;

procedure TFrmPrincipal.Produtos1Click(Sender: TObject);
begin
  try
    if FrmArquivoProdutos = nil then
      FrmArquivoProdutos := TFrmArquivoProdutos.Create(Self);
    FrmArquivoProdutos.ShowModal;
  finally
    FreeAndNil(FrmArquivoProdutos);
  end;
end;

procedure TFrmPrincipal.RatingDetalhadoPorFornecedor1Click(Sender: TObject);
begin
  if not Assigned(frmRelRatingDetalhadoporFornecedor) then
    frmRelRatingDetalhadoporFornecedor := TfrmRelRatingDetalhadoporFornecedor.Create(nil);
  try
    frmRelRatingDetalhadoporFornecedor.ShowModal;
  finally
    FreeAndNil(frmRelRatingDetalhadoporFornecedor);
  end;
end;

procedure TFrmPrincipal.RatingporFornecedor1Click(Sender: TObject);
begin
  try
    if frmRatingporFornecedor = nil then
      frmRatingporFornecedor := TfrmRatingporFornecedor.Create(Self);
    frmRatingporFornecedor.ShowModal;
  finally
    FreeAndNil(frmRatingporFornecedor);
  end;
end;

procedure TFrmPrincipal.RedefinirSenhaClick(Sender: TObject);
begin
  try
    if FrmRedefinirSenha = nil then
      FrmRedefinirSenha := TFrmRedefinirSenha.Create(Self);
    FrmRedefinirSenha.ShowModal;
  finally
    FreeAndNil(FrmRedefinirSenha);
  end;
end;

procedure TFrmPrincipal.SKUxSubGrupoAbacosxSubGrupoCross1Click(Sender: TObject);
begin
  DivergenciaSubGrupoAbacosCross;
end;

procedure TFrmPrincipal.Usuario1Click(Sender: TObject);
begin
  try
    if FrmCadastroUsuario = nil then
      FrmCadastroUsuario     := TFrmCadastroUsuario.Create(Self);
    FrmCadastroUsuario.ShowModal;
  finally
    FreeAndNil(FrmCadastroUsuario);
  end;
end;

procedure TFrmPrincipal.CriarComandoSequenciaMenu(Menu: TMainMenu);
Var
  I, J, K,
  PosMenu1,
  PosMenu2,
  PosMenu3 : Integer;
Const
  Alfabeto : String = 'ABCDEFGHIJKLMNOPQRSTUVXYWZ';
begin
  if Menu is TMainMenu then begin
    PosMenu1 := 1;
    for I := 0 to Menu.Items.Count - 1 do begin
      if ((Menu.Items[I].Visible) and (Menu.Items[I].Enabled)) then begin
        Menu.Items[I].Caption := '&' + Alfabeto[PosMenu1] + ' - ' + Trim(Menu.Items[I].Caption);
        Inc(PosMenu1);
        PosMenu2 := 1;
        for J := 0 to Menu.Items[I].Count - 1 do begin
          if ((Menu.Items[I].Items[J].Visible) and (Menu.Items[I].Items[J].Enabled)) then begin
            if Pos('&', Menu.Items[I].Items[J].Caption) = 0 then begin
              Menu.Items[I].Items[J].Caption := '&' + Alfabeto[PosMenu2] + ' - ' + Trim(Menu.Items[I].Items[J].Caption);
              Inc(PosMenu2);
              PosMenu3 := 1;
              for K := 0 to Menu.Items[I].Items[J].Count - 1 do begin
                if ((Menu.Items[I].Items[J].Items[K].Visible) and (Menu.Items[I].Items[J].Items[K].Enabled)) then begin
                  if Pos('&', Menu.Items[I].Items[J].Items[K].Caption) = 0 then begin
                    Menu.Items[I].Items[J].Items[K].Caption := '&' + Alfabeto[PosMenu3] + ' - ' + Trim(Menu.Items[I].Items[J].Items[K].Caption);
                    Inc(PosMenu3);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end else begin
    DisplayMsg(MSG_WAR, 'Menu não Específicado, Verifique!');
    Exit;
  end;
end;

end.
