unit uCadFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient;

type
  TfrmCadFornecedor = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnBotoesVisualizacao: TPanel;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    pnEdicao: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    GridPanel1: TGridPanel;
    pnUsuarioEsquerda: TPanel;
    Label2: TLabel;
    edNome: TEdit;
    pnUsuarioDireita: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    edEstoqueMaximo: TEdit;
    edEstoqueMinimo: TEdit;
    csPesquisa: TClientDataSet;
    csPesquisaCODIGO: TIntegerField;
    csPesquisaNOME: TStringField;
    dsPesquisa: TDataSource;
    csPesquisaSTATUS: TBooleanField;
    csPesquisaESTOQUEMINIMO: TIntegerField;
    csPesquisaESTOQUEMAXIMO: TIntegerField;
    cbAtivo: TCheckBox;
    gpBotoesEdicao: TGridPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    btGravar: TSpeedButton;
    btCancelar: TSpeedButton;
    GridPanel2: TGridPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    btFechar: TSpeedButton;
    btAlterar: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btPesquisarClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    procedure Cancelar;
    procedure InvertePaineis;
    procedure Filtrar;
    procedure CarregaDados;
    procedure AtualizarEdits(Limpar : Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadFornecedor: TfrmCadFornecedor;

implementation

uses
  uFuncoes,
  uFWConnection,
  uBeanFornecedor,
  uMensagem;

{$R *.dfm}

procedure TfrmCadFornecedor.AtualizarEdits(Limpar: Boolean);
begin
  if Limpar then begin
    edNome.Clear;
    edEstoqueMinimo.Clear;
    edEstoqueMaximo.Clear;
    cbAtivo.Checked := True;
    btGravar.Tag    := 0;
  end else begin
    edNome.Text                 := csPesquisaNOME.Value;
    cbAtivo.Checked             := csPesquisaSTATUS.Value;
    edEstoqueMinimo.Text        := csPesquisaESTOQUEMINIMO.AsString;
    edEstoqueMaximo.Text        := csPesquisaESTOQUEMAXIMO.AsString;
    btGravar.Tag                := csPesquisaCODIGO.Value;
  end;

end;

procedure TfrmCadFornecedor.btAlterarClick(Sender: TObject);
begin
  if not csPesquisa.IsEmpty then begin
    AtualizarEdits(False);
    InvertePaineis;
  end;
end;

procedure TfrmCadFornecedor.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmCadFornecedor.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadFornecedor.btGravarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  F   : TFORNECEDOR;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  F   := TFORNECEDOR.Create(FWC);

  try
    try

      if StrToIntDef(edEstoqueMinimo.Text, -1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Estoque Mínimo Inválido, Verifique!');
        if edEstoqueMinimo.CanFocus then
          edEstoqueMinimo.SetFocus;
        Exit;
      end;

      if StrToIntDef(edEstoqueMaximo.Text, -1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Estoque Máximo Inválido, Verifique!');
        if edEstoqueMaximo.CanFocus then
          edEstoqueMaximo.SetFocus;
        Exit;
      end;

      F.STATUS.Value        := cbAtivo.Checked;
      F.ESTOQUEMINIMO.Value := StrToIntDef(edEstoqueMinimo.Text, 0);
      F.ESTOQUEMAXIMO.Value := StrToIntDef(edEstoqueMaximo.Text, 0);

      if (Sender as TSpeedButton).Tag > 0 then begin
        F.ID.Value                    := (Sender as TSpeedButton).Tag;
        F.Update;
      end;

      FWC.Commit;

      InvertePaineis;

      CarregaDados;
    except
      On E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_WAR, 'Erro ao Salvar Fornecedor!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(F);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmCadFornecedor.btPesquisarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TfrmCadFornecedor.Cancelar;
begin
  InvertePaineis;
end;

procedure TfrmCadFornecedor.CarregaDados;
Var
  FWC : TFWConnection;
  F   : TFORNECEDOR;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    F   := TFORNECEDOR.Create(FWC);
    try

      csPesquisa.EmptyDataSet;

      F.SelectList();
      if F.Count > 0 then begin
        for I := 0 to F.Count -1 do begin
          csPesquisa.Append;
          csPesquisaCODIGO.Value        := TFORNECEDOR(F.Itens[I]).ID.Value;
          csPesquisaNOME.Value          := TFORNECEDOR(F.Itens[I]).NOME.Value;
          csPesquisaSTATUS.Value        := TFORNECEDOR(F.Itens[I]).STATUS.Value;
          csPesquisaESTOQUEMINIMO.Value := TFORNECEDOR(F.Itens[I]).ESTOQUEMINIMO.Value;
          csPesquisaESTOQUEMAXIMO.Value := TFORNECEDOR(F.Itens[I]).ESTOQUEMAXIMO.Value;
          csPesquisa.Post;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(F);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmCadFornecedor.csPesquisaFilterRecord(DataSet: TDataSet;
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

procedure TfrmCadFornecedor.Filtrar;
begin
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TfrmCadFornecedor.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmCadFornecedor.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfrmCadFornecedor.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TfrmCadFornecedor.InvertePaineis;
begin
  pnVisualizacao.Visible        := not pnVisualizacao.Visible;
  pnBotoesVisualizacao.Visible  := pnVisualizacao.Visible;
  pnEdicao.Visible              := not pnEdicao.Visible;
  gpBotoesEdicao.Visible        := pnEdicao.Visible;
  if pnEdicao.Visible then begin
    if edEstoqueMinimo.CanFocus then
      edEstoqueMinimo.SetFocus;
  end;
end;

end.
