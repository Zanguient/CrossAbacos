unit uInativaProdutoFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.ImgList, Data.DB, Datasnap.DBClient,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

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
    csProdutosFORNECEDOR: TIntegerField;
    csProdutosFORNECEDORNOME: TStringField;
    csProdutosSKU: TStringField;
    ImageList2: TImageList;
    csProdutosSELECIONAR: TBooleanField;
    csProdutosSTATUS: TBooleanField;
    csProdutosPRODUTOFORNECEDOR: TIntegerField;
    cbStatus: TComboBox;
    Label4: TLabel;
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
  private
    { Private declarations }
    procedure selecionaFornecedor;
    procedure selecionaProduto;
    procedure pesquisar;
    procedure ativar(Status : Boolean);
    procedure filtrar;
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
begin
  csProdutos.DisableControls;
  CON                     := TFWConnection.Create;
  PF                      := TPRODUTOFORNECEDOR.Create(CON);
  DisplayMsg(MSG_WAIT, 'Atualizando produtos!');
  try
    CON.StartTransaction;

    csProdutos.First;
    while not csProdutos.Eof do begin
      if csProdutosSELECIONAR.Value then begin
        PF.SelectList('id = ' + csProdutosPRODUTOFORNECEDOR.AsString);
        if PF.Count > 0 then begin
          PF.ID.Value     := csProdutosPRODUTOFORNECEDOR.Value;
          PF.STATUS.Value := Status;

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

procedure TfrmInativaProdutoFornecedor.btAtivarClick(Sender: TObject);
begin
  ativar(True);
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
begin
  if cbStatus.ItemIndex = 1 then
    Accept   := csProdutosSTATUS.Value
  else
    Accept   := not csProdutosSTATUS.Value;
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
  if (gdSelected in State) or (gdFocused in State) then begin
    dgProdutos.Canvas.Font.Color   := clWhite;
    dgProdutos.Canvas.Brush.Color  := clBlue;
    dgProdutos.Canvas.Font.Style   := [];
  end;

  dgProdutos.DefaultDrawDataCell( Rect, dgProdutos.Columns[DataCol].Field, State);

  if Column.FieldName = csProdutosSTATUS.FieldName then begin
    dgProdutos.Canvas.FillRect(Rect);
    ImageList2.Draw(dgProdutos.Canvas, Rect.Left + 2, Rect.Top + 2, 0);

    if csProdutosSTATUS.Value then // Cadastro está ativo
      ImageList2.Draw(dgProdutos.Canvas, Rect.Left + 2, Rect.Top + 2, 1);
  end;
  if Column.FieldName = csProdutosSELECIONAR.FieldName then begin
    DrawRect   :=Rect;
    InflateRect(DrawRect,-1,-1);
    dgProdutos.Canvas.FillRect(Rect);
    DrawFrameControl(dgProdutos.Canvas.Handle, DrawRect, DFC_BUTTON, ISChecked[Column.Field.AsBoolean]);
  end;
end;

procedure TfrmInativaProdutoFornecedor.dsProdutosDataChange(Sender: TObject;
  Field: TField);
begin
  edRegistroAtual.Text   := IntToStr(csProdutos.RecNo);
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
  csProdutos.Filtered      := cbStatus.ItemIndex > 0;

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
end;

procedure TfrmInativaProdutoFornecedor.pesquisar;
var
  CON      : TFWConnection;
  P        : TPRODUTO;
  F        : TFORNECEDOR;
  PF       : TPRODUTOFORNECEDOR;
  Filtro   : String;
  I        : Integer;
begin
  csProdutos.EmptyDataSet;
  csProdutos.DisableControls;

  edRegistroAtual.Text := '0';
  edTotalRegistros.Text:= '0';

  CON                  := TFWConnection.Create;
  PF                   := TPRODUTOFORNECEDOR.Create(CON);
  P                    := TPRODUTO.Create(CON);
  F                    := TFORNECEDOR.Create(CON);
  DisplayMsg(MSG_WAIT, 'Buscando dados no banco de dados!');
  try
    Filtro             := '';
    if (edFornecedor.Text <> '') and (edNomeFornecedor.Text <> '') then
      Filtro           := 'id_fornecedor = ' + edFornecedor.Text;

    if (edProduto.Text <> '') and (edNomeProduto.Text <> '') then begin
      if Filtro <> '' then
        Filtro         := Filtro + ' and id_produto = ' + edProduto.Text
      else
      Filtro           := Filtro + 'id_produto = ' + edProduto.Text;
    end;

    PF.SelectList(Filtro);

    if PF.Count > 0 then begin
      for I := 0 to Pred(PF.Count) do begin
        P.SelectList('id = ' + TPRODUTOFORNECEDOR(PF.Itens[I]).ID_PRODUTO.asString);
        F.SelectList('id = ' + TPRODUTOFORNECEDOR(PF.Itens[I]).ID_FORNECEDOR.asString);

        csProdutos.Append;
        csProdutosPRODUTO.Value          := TPRODUTOFORNECEDOR(PF.Itens[I]).ID_PRODUTO.Value;
        csProdutosSKU.Value              := TPRODUTO(P.Itens[0]).SKU.Value;
        csProdutosPRODUTONOME.Value      := TPRODUTO(P.Itens[0]).NOME.Value;
        csProdutosCODIGO.Value           := TPRODUTOFORNECEDOR(PF.Itens[I]).COD_PROD_FORNECEDOR.Value;
        csProdutosFORNECEDOR.Value       := TFORNECEDOR(F.Itens[0]).ID.Value;
        csProdutosFORNECEDORNOME.Value   := TFORNECEDOR(F.Itens[0]).NOME.Value;
        csProdutosSTATUS.Value           := TPRODUTOFORNECEDOR(PF.Itens[I]).STATUS.Value;
        csProdutosPRODUTOFORNECEDOR.Value:= TPRODUTOFORNECEDOR(PF.Itens[I]).ID.Value;
        csProdutos.Post;
      end;
    end;

  finally
    DisplayMsgFinaliza;
    FreeAndNil(P);
    FreeAndNil(F);
    FreeAndNil(PF);
    FreeAndNil(CON);
    csProdutos.EnableControls;
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
