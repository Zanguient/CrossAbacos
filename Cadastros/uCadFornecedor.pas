unit uCadFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, Vcl.ImgList,
  FireDAC.Comp.Client;

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
    ImageList: TImageList;
    csPesquisaCNPJ: TStringField;
    csPesquisaID_ALMOXARIFADO: TIntegerField;
    csPesquisaNOMEALMOXARIFADO: TStringField;
    edPrazoEntrega: TEdit;
    Label1: TLabel;
    csPesquisaPRAZO_ENTREGA: TIntegerField;
    edAlmoxarifado: TButtonedEdit;
    Label5: TLabel;
    lbAlmoxarifado: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btPesquisarClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure gdPesquisaDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure edAlmoxarifadoChange(Sender: TObject);
    procedure edAlmoxarifadoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edAlmoxarifadoRightButtonClick(Sender: TObject);
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
  uMensagem,
  uBeanAlmoxarifado,
  uDMUtil;

{$R *.dfm}

procedure TfrmCadFornecedor.AtualizarEdits(Limpar: Boolean);
begin
  if Limpar then begin
    edNome.Clear;
    edEstoqueMinimo.Clear;
    edEstoqueMaximo.Clear;
    edPrazoEntrega.Clear;
    edAlmoxarifado.Text := '0';
    lbAlmoxarifado.Caption  := 'Geral';
    cbAtivo.Checked := True;
    btGravar.Tag    := 0;
  end else begin
    edNome.Text                 := csPesquisaNOME.Value;
    cbAtivo.Checked             := csPesquisaSTATUS.Value;
    edEstoqueMinimo.Text        := csPesquisaESTOQUEMINIMO.AsString;
    edEstoqueMaximo.Text        := csPesquisaESTOQUEMAXIMO.AsString;
    edPrazoEntrega.Text         := csPesquisaPRAZO_ENTREGA.AsString;
    edAlmoxarifado.Text         := csPesquisaID_ALMOXARIFADO.AsString;
    lbAlmoxarifado.Caption      := csPesquisaNOMEALMOXARIFADO.AsString;
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

      F.STATUS.Value          := cbAtivo.Checked;
      F.ESTOQUEMINIMO.Value   := StrToIntDef(edEstoqueMinimo.Text, 0);
      F.ESTOQUEMAXIMO.Value   := StrToIntDef(edEstoqueMaximo.Text, 0);
      F.PRAZO_ENTREGA.Value   := StrToIntDef(edPrazoEntrega.Text, 0);
      F.ID_ALMOXARIFADO.Value := StrToIntDef(edAlmoxarifado.Text, 0);

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
  SQL : TFDQuery;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    SQL := TFDQuery.Create(nil);
    try

      csPesquisa.EmptyDataSet;

      //SQL BUSCA FORNECEDORES
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	F.ID AS IDFORNECEDOR,');
      SQL.SQL.Add('	F.NOME AS NOMEFORNECEDOR,');
      SQL.SQL.Add('	F.CNPJ AS CNPJFORNECEDOR,');
      SQL.SQL.Add('	F.STATUS AS STATUSFORNECEDOR,');
      SQL.SQL.Add('	F.ESTOQUEMINIMO AS ESTOQUEMINIMO,');
      SQL.SQL.Add('	F.ESTOQUEMAXIMO AS ESTOQUEMAXIMO,');
      SQL.SQL.Add('	F.PRAZO_ENTREGA AS PRAZO_ENTREGA,');
      SQL.SQL.Add('	F.ID_ALMOXARIFADO,');
      SQL.SQL.Add('	A.NOME AS NOMEALMOXARIFADO');
      SQL.SQL.Add('FROM FORNECEDOR F');
      SQL.SQL.Add('INNER JOIN ALMOXARIFADO A ON (A.ID = F.ID_ALMOXARIFADO)');
      SQL.SQL.Add('WHERE 1 = 1');

      SQL.Connection  := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open;
      SQL.FetchAll;

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          csPesquisa.Append;
          csPesquisaCODIGO.Value            := SQL.FieldByName('IDFORNECEDOR').Value;
          csPesquisaNOME.Value              := SQL.FieldByName('NOMEFORNECEDOR').Value;
          csPesquisaCNPJ.Value              := FormataCNPJ(SQL.FieldByName('CNPJFORNECEDOR').Value);
          csPesquisaSTATUS.Value            := SQL.FieldByName('STATUSFORNECEDOR').Value;
          csPesquisaESTOQUEMINIMO.Value     := SQL.FieldByName('ESTOQUEMINIMO').Value;
          csPesquisaESTOQUEMAXIMO.Value     := SQL.FieldByName('ESTOQUEMAXIMO').Value;
          csPesquisaPRAZO_ENTREGA.Value     := SQL.FieldByName('PRAZO_ENTREGA').Value;
          csPesquisaID_ALMOXARIFADO.Value   := SQL.FieldByName('ID_ALMOXARIFADO').Value;
          csPesquisaNOMEALMOXARIFADO.Value  := SQL.FieldByName('NOMEALMOXARIFADO').Value;
          csPesquisa.Post;
          SQL.Next;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(SQL);
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

procedure TfrmCadFornecedor.edAlmoxarifadoChange(Sender: TObject);
begin
  lbAlmoxarifado.Caption  := EmptyStr;
end;

procedure TfrmCadFornecedor.edAlmoxarifadoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    edAlmoxarifadoRightButtonClick(nil);
end;

procedure TfrmCadFornecedor.edAlmoxarifadoRightButtonClick(Sender: TObject);
var
  ALM : TALMOXARIFADO;
  CON : TFWConnection;
begin
  CON := TFWConnection.Create;
  ALM := TALMOXARIFADO.Create(CON);

  lbAlmoxarifado.Caption := EmptyStr;

  try
    edAlmoxarifado.Text   := IntToStr(DMUtil.Selecionar(ALM, edAlmoxarifado.Text));

    ALM.SelectList('ID = ' + edAlmoxarifado.Text);

    if ALM.Count > 0 then
      lbAlmoxarifado.Caption := TALMOXARIFADO(ALM.Itens[0]).NOME.asString;
  finally
    FreeAndNil(ALM);
    FreeAndNil(CON);
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
      if edPesquisa.Focused then begin
        if not csPesquisa.IsEmpty then begin
          if csPesquisa.RecNo > 1 then
            csPesquisa.Prior;
        end;
      end;
    end;
    VK_DOWN : begin
      if edPesquisa.Focused then begin
        if not csPesquisa.IsEmpty then begin
          if csPesquisa.RecNo < csPesquisa.RecordCount then
            csPesquisa.Next;
        end;
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

procedure TfrmCadFornecedor.gdPesquisaDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if csPesquisa.IsEmpty then Exit;

  if (gdSelected in State) or (gdFocused in State) then begin
    gdPesquisa.Canvas.Font.Color   := clWhite;
    gdPesquisa.Canvas.Brush.Color  := clBlue;
    gdPesquisa.Canvas.Font.Style   := [];
  end;

  gdPesquisa.DefaultDrawDataCell( Rect, gdPesquisa.Columns[DataCol].Field, State);

  if Column.FieldName = csPesquisaSTATUS.FieldName then begin
    gdPesquisa.Canvas.FillRect(Rect);
    if csPesquisaSTATUS.Value then // Cadastro está ativo
      ImageList.Draw(gdPesquisa.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, 1)
    else
      ImageList.Draw(gdPesquisa.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, 0);
  end;

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
