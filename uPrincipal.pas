unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Vcl.ExtCtrls, Math;

type
  TFrmPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Cadastros1: TMenuItem;
    Importaes1: TMenuItem;
    Relatrios1: TMenuItem;
    Configuraes1: TMenuItem;
    Usuario1: TMenuItem;
    Margem1: TMenuItem;
    ConfigGerais1: TMenuItem;
    miSair: TMenuItem;
    IMFundo: TImage;
    RedefinirSenha: TMenuItem;
    Familia1: TMenuItem;
    Importacoes2: TMenuItem;
    Movimentaes1: TMenuItem;
    Match1: TMenuItem;
    GerarLote1: TMenuItem;
    procedure Usuario1Click(Sender: TObject);
    procedure miSairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RedefinirSenhaClick(Sender: TObject);
    procedure Margem1Click(Sender: TObject);
    procedure Familia1Click(Sender: TObject);
    procedure Importacoes2Click(Sender: TObject);
    procedure GerarLote1Click(Sender: TObject);
    procedure Match1Click(Sender: TObject);
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
  uCadastroMargem,
  uImportacaoEstoqueVirtual,
  uCadastroFamilia,
  uImportacao,
  uMatch;
{$R *.dfm}

procedure TFrmPrincipal.DefinirPermissoes;
begin
  Usuario1.Visible        := USUARIO.PERMITIRCADUSUARIO;
  RedefinirSenha.Visible  := USUARIO.CODIGO > 0; //Usuário 0 é Administrador e não tem Cadastro
end;

procedure TFrmPrincipal.Familia1Click(Sender: TObject);
begin
  try
    if FrmCadastroFamilia = nil then
      FrmCadastroFamilia := TFrmCadastroFamilia.Create(Self);
    FrmCadastroFamilia.ShowModal;
  finally
    FreeAndNil(FrmCadastroFamilia);
  end;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');

  DefinirPermissoes;

  CriarComandoSequenciaMenu(MainMenu1);

  Caption := 'Sistema CrossAbacos - Usuário: ' + IntToStr(USUARIO.CODIGO) + ' - ' + USUARIO.NOME;
end;

procedure TFrmPrincipal.GerarLote1Click(Sender: TObject);
begin
  GerarLoteImportacao;
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

procedure TFrmPrincipal.Margem1Click(Sender: TObject);
begin
  try
    if FrmCadastroMargem = nil then
      FrmCadastroMargem := TFrmCadastroMargem.Create(Self);
    FrmCadastroMargem.ShowModal;
  finally
    FreeAndNil(FrmCadastroMargem);
  end;
end;

procedure TFrmPrincipal.Match1Click(Sender: TObject);
begin
  try
    if frmMatch = nil then
      frmMatch := TfrmMatch.Create(Self);
    frmMatch.ShowModal;
  finally
    FreeAndNil(frmMatch);
  end;
end;

procedure TFrmPrincipal.miSairClick(Sender: TObject);
begin
  DisplayMsg(MSG_CONF, 'Deseja realmente sair do sistema?', 'Sair do Sistema');

  if (ResultMsgModal = mrYes) then
    Close;
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

procedure TFrmPrincipal.Usuario1Click(Sender: TObject);
begin
  try
    if FrmCadastroUsuario = nil then
      FrmCadastroUsuario := TFrmCadastroUsuario.Create(Self);
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
