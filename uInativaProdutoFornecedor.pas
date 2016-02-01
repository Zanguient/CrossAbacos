unit uInativaProdutoFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ImgList, Data.DB, Datasnap.DBClient,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Samples.Gauges, System.StrUtils;

type
  TfrmInativaProdutoFornecedor = class(TForm)
    gbSelecionaFornecedor: TGroupBox;
    lbFornecedor: TLabel;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    gbSelecionaProdutos: TGroupBox;
    Label1: TLabel;
    edProduto: TButtonedEdit;
    edNomeProduto: TEdit;
    gbImportar: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    btPesquisar: TBitBtn;
    edTotalRegistros: TEdit;
    edRegistroAtual: TEdit;
    dgProdutos: TDBGrid;
    btAtivar: TSpeedButton;
    btInativar: TSpeedButton;
    pnPrincipal: TPanel;
    ImageList1: TImageList;
    csProdutos: TClientDataSet;
    dsProdutos: TDataSource;
    csProdutosPRODUTO: TIntegerField;
    csProdutosPRODUTONOME: TStringField;
    csProdutosCODIGO: TStringField;
    csProdutosFORNECEDORNOME: TStringField;
    csProdutosSKU: TStringField;
    ImageList2: TImageList;
    csProdutosSELECIONAR: TBooleanField;
    csProdutosSTATUS: TBooleanField;
    csProdutosPRODUTOFORNECEDOR: TIntegerField;
    cbStatus: TComboBox;
    Label4: TLabel;
    pnFiltro: TPanel;
    btFiltrar: TSpeedButton;
    edFiltro: TEdit;
    pbBusca: TGauge;
    csProdutosMOTIVO: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btSairClick(Sender: TObject);
    procedure edProdutoRightButtonClick(Sender: TObject);
    procedure edProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btPesquisarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dgProdutosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dgProdutosCellClick(Column: TColumn);
    procedure btAtivarClick(Sender: TObject);
    procedure btInativarClick(Sender: TObject);
    procedure cbStatusChange(Sender: TObject);
    procedure csProdutosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dsProdutosDataChange(Sender: TObject; Field: TField);
    procedure csProdutosAfterPost(DataSet: TDataSet);
    procedure csProdutosAfterDelete(DataSet: TDataSet);
    procedure edFiltroKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btFiltrarClick(Sender: TObject);
    procedure edFornecedorExit(Sender: TObject);
    procedure edProdutoExit(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure edProdutoChange(Sender: TObject);
    procedure dgProdutosTitleClick(Column: TColumn);
  private
    { Private declarations }
    procedure selecionaFornecedor;
    procedure selecionaProduto;
    procedure pesquisar;
    procedure ativar(Status : Boolean);
    procedure filtrar;
    procedure AtivarInativarTodos;
  public
    { Public declarations }
  end;

var
  frmInativaProdutoFornecedor: TfrmInativaProdutoFornecedor;

implementation
uses uFuncoes, uBeanProduto, uBeanFornecedor, uBeanProdutoFornecedor, uDMUtil,
     uFWConnection, uMensagem;
{$R *.dfm}

procedure TfrmInativaProdutoFornecedor.ativar(Status : Boolean);
var
  CON      : TFWConnection;
  PF       : TPRODUTOFORNECEDOR;
  Motivo   : String;
begin
  csProdutos.DisableControls;
  CON                     := TFWConnection.Create;
  PF                      := TPRODUTOFORNECEDOR.Create(CON);
  DisplayMsg(MSG_WAIT, 'Atualizando produtos!');
  try
    if not Status then begin
      DisplayMsg(MSG_INPUT_TEXT, 'Digite o motivo para inativar o produto!');
      Motivo := ResultMsgInputText;
      if Motivo = '' then begin
        DisplayMsg(MSG_INF, 'O procedimento será cancelado pelo não preenchimento do motivo!');
        Exit;
      end;
    end;

    CON.StartTransaction;

    csProdutos.First;
    while not csProdutos.Eof do begin
      if csProdutosSELECIONAR.Value then begin
        PF.SelectList('id = ' + csProdutosPRODUTOFORNECEDOR.AsString);
        if PF.Count > 0 then begin
          PF.ID.Value           := csProdutosPRODUTOFORNECEDOR.Value;
          PF.STATUS.Value       := Status;
          PF.MOTIVO.Value       := '';
          if not Status then
            PF.MOTIVO.Value     := Motivo;

          PF.Update;
        end;
      end;
      csProdutos.Next;
    end;
    CON.Commit;

    pesquisar;
  finally
    DisplayMsgFinaliza;
    FreeAndNil(PF);
    FreeAndNil(CON);
    csProdutos.EnableControls;
  end;
end;

procedure TfrmInativaProdutoFornecedor.AtivarInativarTodos;
Var
  Aux : Boolean;
begin
  if not csProdutos.IsEmpty then begin

    Aux := not csProdutosSELECIONAR.Value;

    DisplayMsg(MSG_WAIT, IfThen(Aux, 'Marcando Itens!', 'Desmarcando Itens!'));

    csProdutos.DisableControls;

    try
      csProdutos.First;
      while not csProdutos.Eof do begin
        csProdutos.Edit;
        csProdutosSELECIONAR.Value  := Aux;
        csProdutos.Post;
        csProdutos.Next;
      end;
    finally
      csProdutos.EnableControls;
      DisplayMsgFinaliza
    end;
  end;
end;

procedure TfrmInativaProdutoFornecedor.btAtivarClick(Sender: TObject);
begin
  ativar(True);
end;

procedure TfrmInativaProdutoFornecedor.btFiltrarClick(Sender: TObject);
begin
  filtrar;
end;

procedure TfrmInativaProdutoFornecedor.btInativarClick(Sender: TObject);
begin
  ativar(False);
end;

procedure TfrmInativaProdutoFornecedor.btPesquisarClick(Sender: TObject);
begin
  pesquisar;
end;

procedure TfrmInativaProdutoFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmInativaProdutoFornecedor.cbStatusChange(Sender: TObject);
begin
  Filtrar;
end;

procedure TfrmInativaProdutoFornecedor.csProdutosAfterDelete(DataSet: TDataSet);
begin
  edTotalRegistros.Text    := IntToStr(csProdutos.RecordCount);
end;

procedure TfrmInativaProdutoFornecedor.csProdutosAfterPost(DataSet: TDataSet);
begin
  edTotalRegistros.Text    := IntToStr(csProdutos.RecordCount);
end;

procedure TfrmInativaProdutoFornecedor.csProdutosFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  case cbStatus.ItemIndex of
    0 : Accept     := True;
    1 : Accept     := csProdutosSTATUS.Value;
    2 : Accept     := not csProdutosSTATUS.Value;
  end;

  if (Accept) and (edFiltro.Text <> '') then begin
    for I := 0 to Pred(csProdutos.FieldCount) do begin
      Accept    := Pos(AnsiUpperCase(edFiltro.Text), AnsiUpperCase(csProdutos.Fields[I].AsString)) > 0;
      if Accept then Break;
    end;
  end;
    
end;

procedure TfrmInativaProdutoFornecedor.dgProdutosCellClick(Column: TColumn);
begin
  csProdutos.Edit;
  csProdutosSELECIONAR.Value := not csProdutosSELECIONAR.Value;
  csProdutos.Post;
end;

procedure TfrmInativaProdutoFornecedor.dgProdutosDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  IsChecked : array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  DrawRect: TRect;
begin
  if csProdutos.IsEmpty then Exit;
  
  if (gdSelected in State) or (gdFocused in State) then begin
    dgProdutos.Canvas.Font.Color   := clWhite;
    dgProdutos.Canvas.Brush.Color  := clBlue;
    dgProdutos.Canvas.Font.Style   := [];
  end;

  dgProdutos.DefaultDrawDataCell( Rect, dgProdutos.Columns[DataCol].Field, State);

  if Column.FieldName = csProdutosSTATUS.FieldName then begin
    dgProdutos.Canvas.FillRect(Rect);
    if csProdutosSTATUS.Value then // Cadastro está ativo
      ImageList2.Draw(dgProdutos.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, 1)
    else
      ImageList2.Draw(dgProdutos.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, 0);
  end;
  if Column.FieldName = csProdutosSELECIONAR.FieldName then begin
    DrawRect   := Rect;
    InflateRect(DrawRect,-1,-1);
    dgProdutos.Canvas.FillRect(Rect);
    DrawFrameControl(dgProdutos.Canvas.Handle, DrawRect, DFC_BUTTON, ISChecked[Column.Field.AsBoolean]);
  end;
end;

procedure TfrmInativaProdutoFornecedor.dgProdutosTitleClick(Column: TColumn);
begin
  if UpperCase(Column.FieldName) = 'SELECIONAR' then
    AtivarInativarTodos;
end;

procedure TfrmInativaProdutoFornecedor.dsProdutosDataChange(Sender: TObject;
  Field: TField);
begin
  edRegistroAtual.Text   := IntToStr(csProdutos.RecNo);
end;

procedure TfrmInativaProdutoFornecedor.edFiltroKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    filtrar;
end;

procedure TfrmInativaProdutoFornecedor.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmInativaProdutoFornecedor.edFornecedorExit(Sender: TObject);
begin
  if (edFornecedor.Text = '') or (edFornecedor.Text = '0') then
    edNomeFornecedor.Text := '';
end;

procedure TfrmInativaProdutoFornecedor.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    selecionaFornecedor;
end;

procedure TfrmInativaProdutoFornecedor.edFornecedorRightButtonClick(
  Sender: TObject);
begin
  selecionaFornecedor;
end;

procedure TfrmInativaProdutoFornecedor.edProdutoChange(Sender: TObject);
begin
  edNomeProduto.Clear;
end;

procedure TfrmInativaProdutoFornecedor.edProdutoExit(Sender: TObject);
begin
  if (edProduto.Text = '') or (edProduto.Text = '0') then
    edProduto.Text := '';
end;

procedure TfrmInativaProdutoFornecedor.edProdutoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
   selecionaProduto;
end;

procedure TfrmInativaProdutoFornecedor.edProdutoRightButtonClick(
  Sender: TObject);
begin
  selecionaProduto;
end;

procedure TfrmInativaProdutoFornecedor.filtrar;
begin
  csProdutos.Filtered      := False;
  csProdutos.Filtered      := (cbStatus.ItemIndex > 0) or (edFiltro.Text <> '');

  edTotalRegistros.Text    := IntToStr(csProdutos.RecordCount);
  edRegistroAtual.Text     := IntToStr(csProdutos.RecNo);
end;

procedure TfrmInativaProdutoFornecedor.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmInativaProdutoFornecedor.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmInativaProdutoFornecedor.FormShow(Sender: TObject);
begin
  csProdutos.CreateDataSet;
  csProdutos.Open;

  AutoSizeDBGrid(dgProdutos);
end;

procedure TfrmInativaProdutoFornecedor.pesquisar;
var
  CON      : TFWConnection;
  SQL      : TFDQuery;
  Filtro   : String;
  I        : Integer;
begin
  csProdutos.EmptyDataSet;
  csProdutos.DisableControls;

  edRegistroAtual.Text := '0';
  edTotalRegistros.Text:= '0';

  CON                  := TFWConnection.Create;
  SQL                  := TFDQuery.Create(nil);
  DisplayMsg(MSG_WAIT, 'Buscando dados no banco de dados!');
  pbBusca.Progress     := 0;
  try
    SQL.Connection     := CON.FDConnection;
    Filtro             := '';
    if (edFornecedor.Text <> '') and (edNomeFornecedor.Text <> '') then
      Filtro           := 'pf.id_fornecedor = ' + edFornecedor.Text;

    if (edProduto.Text <> '') and (edNomeProduto.Text <> '') then begin
      if Filtro <> '' then
        Filtro         := Filtro + ' and pf.id_produto = ' + edProduto.Text
      else
      Filtro           := Filtro + 'pf.id_produto = ' + edProduto.Text;
    end;

    SQL.SQL.Add('select');
    SQL.SQL.Add('	pf.id,');
    SQL.SQL.Add('	p.id as produto,');
    SQL.SQL.Add('	p.sku,');
    SQL.SQL.Add('	p.nome as produtonome,');
    SQL.SQL.Add('	f.id as fornecedor,');
    SQL.SQL.Add('	f.nome as fornecedornome,');
    SQL.SQL.Add('	pf.cod_prod_fornecedor,');
    SQL.SQL.Add('	pf.status,');
    SQL.SQL.Add('coalesce(pf.motivo,'''') as motivo');
    SQL.SQL.Add('from produtofornecedor pf');
    SQL.SQL.Add('inner join produto p on pf.id_produto = p.id');
    SQL.SQL.Add('inner join fornecedor f on pf.id_fornecedor = f.id');
    if Filtro <> '' then
      SQL.SQL.Add('where ' + Filtro);
    SQL.Open();

    if not SQL.IsEmpty then begin
      DisplayMsg(MSG_WAIT, 'Adicionando dados a tela!');
      pbBusca.MaxValue   := SQL.RecordCount;

      while not SQL.Eof do begin
        csProdutos.Append;
        csProdutosPRODUTO.Value          := SQL.FieldByName('produto').Value;
        csProdutosSKU.Value              := SQL.FieldByName('sku').Value;
        csProdutosPRODUTONOME.Value      := SQL.FieldByName('produtonome').Value;
        csProdutosCODIGO.Value           := SQL.FieldByName('cod_prod_fornecedor').Value;
        csProdutosFORNECEDORNOME.Value   := SQL.FieldByName('fornecedor').AsString + ' - ' + SQL.FieldByName('fornecedornome').AsString;
        csProdutosSTATUS.Value           := SQL.FieldByName('status').Value;
        csProdutosPRODUTOFORNECEDOR.Value:= SQL.FieldByName('id').Value;
        csProdutosMOTIVO.Value           := SQL.FieldByName('motivo').Value;
        csProdutos.Post;

        pbBusca.Progress                 := SQL.RecNo;
        SQL.Next;
      end;
    end;

  finally
    DisplayMsgFinaliza;
    FreeAndNil(SQL);
    FreeAndNil(CON);
    csProdutos.EnableControls;
    pbBusca.Progress                    := 0;
  end;
end;

procedure TfrmInativaProdutoFornecedor.selecionaFornecedor;
var
  CON : TFWConnection;
  F   : TFORNECEDOR;
begin
  CON                       := TFWConnection.Create;
  F                         := TFORNECEDOR.Create(CON);
  edNomeFornecedor.Text     := '';
  try
    edFornecedor.Text       := IntToStr(DMUtil.Selecionar(F, edFornecedor.Text));
    F.SelectList('id = ' + edFornecedor.Text);
    if F.Count > 0 then
      edNomeFornecedor.Text := TFORNECEDOR(F.Itens[0]).NOME.asString;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;
end;

procedure TfrmInativaProdutoFornecedor.selecionaProduto;
var
  CON : TFWConnection;
  P   : TPRODUTO;
begin
  CON                       := TFWConnection.Create;
  P                         := TPRODUTO.Create(CON);
  edNomeProduto.Text        := '';
  try
    edProduto.Text          := IntToStr(DMUtil.Selecionar(P, edProduto.Text));
    P.SelectList('id = ' + edProduto.Text);
    if P.Count > 0 then
      edNomeProduto.Text    := TPRODUTO(P.Itens[0]).NOME.asString;
  finally
    FreeAndNil(P);
    FreeAndNil(CON);
  end;
end;

end.
