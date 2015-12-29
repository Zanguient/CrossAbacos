unit uCadastroUsuario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB,
  Datasnap.DBClient, Vcl.ImgList;

type
  TFrmCadastroUsuario = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnEdicao: TPanel;
    dsPesquisa: TDataSource;
    csPesquisa: TClientDataSet;
    csPesquisaCODIGO: TIntegerField;
    csPesquisaNOME: TStringField;
    pnBotoesVisualizacao: TPanel;
    pnBotoesEdicao: TPanel;
    Panel1: TPanel;
    pnAjusteBotoes1: TPanel;
    pnPequisa: TPanel;
    edPesquisa: TEdit;
    csPesquisaEMAIL: TStringField;
    edNome: TEdit;
    edSenha: TEdit;
    edEmail: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    edConfirmarSenha: TEdit;
    btGravar: TSpeedButton;
    btCancelar: TSpeedButton;
    pnAjusteBotoes2: TPanel;
    btFechar: TSpeedButton;
    btExcluir: TSpeedButton;
    btAlterar: TSpeedButton;
    btNovo: TSpeedButton;
    csPesquisaSENHA: TStringField;
    btPesquisar: TSpeedButton;
    Panel2: TPanel;
    Panel3: TPanel;
    cbAcessoCadUsuario: TCheckBox;
    csPesquisaPERMITIRCADUSUARIO: TBooleanField;
    procedure sbFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btBuscarClick(Sender: TObject);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btNovoClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btPesquisarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CarregaDados;
    procedure InvertePaineis;
    procedure Cancelar;
    procedure Filtrar;
    procedure AtualizarEdits(Limpar : Boolean);
    { Public declarations }
  end;

var
  FrmCadastroUsuario: TFrmCadastroUsuario;

implementation

uses
  uFWConnection,
  uMensagem,
  uBeanUsuario,
  uFuncoes;

{$R *.dfm}

procedure TFrmCadastroUsuario.AtualizarEdits(Limpar: Boolean);
begin
  if Limpar then begin
    edNome.Clear;
    edEmail.Clear;
    btGravar.Tag  := 0;
  end else begin
    edNome.Text                 := csPesquisaNOME.Value;
    edEmail.Text                := csPesquisaEMAIL.Value;
    edSenha.Text                := Criptografa(csPesquisaSENHA.Value, 'D');
    edConfirmarSenha.Text       := Criptografa(csPesquisaSENHA.Value, 'D');
    cbAcessoCadUsuario.Checked  := csPesquisaPERMITIRCADUSUARIO.Value;
    btGravar.Tag                := csPesquisaCODIGO.Value;
  end;
end;

procedure TFrmCadastroUsuario.btAlterarClick(Sender: TObject);
begin
  if not csPesquisa.IsEmpty then begin
    AtualizarEdits(False);
    InvertePaineis;
  end;
end;

procedure TFrmCadastroUsuario.btBuscarClick(Sender: TObject);
begin
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroUsuario.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TFrmCadastroUsuario.btExcluirClick(Sender: TObject);
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
begin
  if not csPesquisa.IsEmpty then begin

    DisplayMsg(MSG_CONF, 'Excluir o Usuário Selecionado?');

    if ResultMsgModal = mrYes then begin

      try

        FWC := TFWConnection.Create;
        USU := TUSUARIO.Create(FWC);
        try

          USU.ID.Value := csPesquisaCODIGO.Value;
          USU.Delete;

          FWC.Commit;

          csPesquisa.Delete;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao Excluir Usuário, Verifique!', '', E.Message);
          end;
        end;
      finally
        FreeAndNil(USU);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmCadastroUsuario.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroUsuario.btGravarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
begin

  try
    FWC := TFWConnection.Create;
    USU := TUSUARIO.Create(FWC);
    try

      if Length(Trim(edNome.Text)) = 0 then begin
        DisplayMsg(MSG_WAR, 'Nome não informado, Verifique!');
        if edNome.CanFocus then
          edNome.SetFocus;
        Exit;
      end;

      if Length(Trim(edEmail.Text)) = 0 then begin
        DisplayMsg(MSG_WAR, 'Usuário/Email não informado, Verifique!');
        if edEmail.CanFocus then
          edEmail.SetFocus;
        Exit;
      end;

      if edSenha.Text <> edConfirmarSenha.Text then begin
        DisplayMsg(MSG_WAR, 'Senha de Confirmação não confere, Verifique!');
        if edConfirmarSenha.CanFocus then
          edConfirmarSenha.SetFocus;
        Exit;
      end;

      USU.NOME.Value                  := edNome.Text;
      USU.EMAIL.Value                 := edEmail.Text;
      USU.PERMITIR_CAD_USUARIO.Value  := cbAcessoCadUsuario.Checked;

      if (Sender as TSpeedButton).Tag > 0 then begin
        USU.ID.Value      := (Sender as TSpeedButton).Tag;
        USU.SENHA.Value   := Criptografa(edSenha.Text, 'E');
        USU.Update;
      end else begin
        USU.SENHA.Value   := Criptografa(edSenha.Text, 'E');
        USU.Insert;
      end;

      FWC.Commit;

      InvertePaineis;

      CarregaDados;
    except
      On E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_WAR, 'Erro ao Gravar Usuário!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(USU);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroUsuario.btNovoClick(Sender: TObject);
begin
  AtualizarEdits(True);
  InvertePaineis;
end;

procedure TFrmCadastroUsuario.btPesquisarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TFrmCadastroUsuario.Cancelar;
begin
  InvertePaineis;
end;

procedure TFrmCadastroUsuario.CarregaDados;
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    USU := TUSUARIO.Create(FWC);
    try

      csPesquisa.EmptyDataSet;

      USU.SelectList();
      if USU.Count > 0 then begin
        for I := 0 to USU.Count -1 do begin
          csPesquisa.Append;
          csPesquisaCODIGO.Value              := TUSUARIO(USU.Itens[I]).ID.Value;
          csPesquisaNOME.Value                := TUSUARIO(USU.Itens[I]).NOME.Value;
          csPesquisaEMAIL.Value               := TUSUARIO(USU.Itens[I]).EMAIL.Value;
          csPesquisaSENHA.Value               := TUSUARIO(USU.Itens[I]).SENHA.Value;
          csPesquisaPERMITIRCADUSUARIO.Value  := TUSUARIO(USU.Itens[I]).PERMITIR_CAD_USUARIO.Value;
          csPesquisa.Post;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(USU);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroUsuario.csPesquisaFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
Var
  I : Integer;
begin
  Accept := False;
  for I := 0 to DataSet.Fields.Count - 1 do begin
    if not DataSet.Fields[I].IsNull then begin
      if Pos(AnsiLowerCase(edPesquisa.Text),AnsiLowerCase(DataSet.Fields[I].AsVariant)) > 0 then begin
        Accept := True;
        Break;
      end;
    end;
  end;
end;

procedure TFrmCadastroUsuario.Filtrar;
begin
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroUsuario.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmCadastroUsuario.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  case Key of
    VK_ESCAPE : begin
      if pnVisualizacao.Visible then
        Close
      else
        Cancelar;
    end;
    VK_RETURN : begin
      if edPesquisa.Focused then begin
        Filtrar;
      end else begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
          edPesquisa.SelectAll;
        end;
      end;
    end;
    VK_UP : begin
      if not csPesquisa.IsEmpty then begin
        if csPesquisa.RecNo > 1 then
          csPesquisa.Prior;
      end;
    end;
    VK_DOWN : begin
      if not csPesquisa.IsEmpty then begin
        if csPesquisa.RecNo < csPesquisa.RecordCount then
          csPesquisa.Next;
      end;
    end else begin
      if not edPesquisa.Focused then begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
        end;
      end;
    end;
  end;
end;

procedure TFrmCadastroUsuario.FormResize(Sender: TObject);
begin
  pnAjusteBotoes1.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - (btExcluir.Left - btNovo.Left));
  pnAjusteBotoes2.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - btGravar.Width) - 3;
end;

procedure TFrmCadastroUsuario.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TFrmCadastroUsuario.InvertePaineis;
begin
  pnVisualizacao.Visible        := not pnVisualizacao.Visible;
  pnBotoesVisualizacao.Visible  := pnVisualizacao.Visible;
  pnEdicao.Visible              := not pnEdicao.Visible;
  pnBotoesEdicao.Visible        := pnEdicao.Visible;
  if pnEdicao.Visible then begin
    if edNome.CanFocus then
      edNome.SetFocus;
  end;
end;

procedure TFrmCadastroUsuario.sbFecharClick(Sender: TObject);
begin
  Close;
end;

end.
