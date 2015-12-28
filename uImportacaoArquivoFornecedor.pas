unit uImportacaoArquivoFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ImgList, Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, comObj, TypInfo,
  Vcl.ComCtrls;

type
  TExcelColluns = record
    index : Integer;
    nome  : String;
  end;
  TfrmImportacaoArquivoFornecedor = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaLote: TGroupBox;
    cbLote: TComboBox;
    btNovoLote: TBitBtn;
    pnBotton: TPanel;
    GridPanel1: TGridPanel;
    btSalvar: TBitBtn;
    btSair: TBitBtn;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    ImageList1: TImageList;
    lbFornecedor: TLabel;
    edNomeFornecedor: TEdit;
    gbSelecionaArquivo: TGroupBox;
    edArquivo: TButtonedEdit;
    OpenDialog1: TOpenDialog;
    gbImportar: TGroupBox;
    btImportar: TBitBtn;
    dgProdutos: TDBGrid;
    csProdutos: TClientDataSet;
    dsProdutos: TDataSource;
    csProdutosSKU: TStringField;
    csProdutosCODIGO: TStringField;
    csProdutosCUSTO: TCurrencyField;
    csProdutosNOME: TStringField;
    edTotalRegistros: TEdit;
    edRegistroAtual: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    csProdutosDISPONIVEL: TFloatField;
    pgProdutos: TProgressBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btNovoLoteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edArquivoRightButtonClick(Sender: TObject);
    procedure btImportarClick(Sender: TObject);
    procedure dsProdutosDataChange(Sender: TObject; Field: TField);
    procedure csProdutosAfterPost(DataSet: TDataSet);
    procedure edArquivoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure carregaLotes;
  end;

var
  frmImportacaoArquivoFornecedor: TfrmImportacaoArquivoFornecedor;

implementation
uses uDMUtil, uBeanLoteImportacao, uFWConnection, uMensagem, uBeanFornecedor, uBeanProdutoAbacos, uBeanProdutoFornecedor;
{$R *.dfm}

procedure TfrmImportacaoArquivoFornecedor.btImportarClick(Sender: TObject);
const
  xlCellTypeLastCell = $0000000B;
var
  XLSAplicacao,
  AbaXLS        : OLEVariant;
  vrow,
  vcol,
  i,
  j,
  Count         : Integer;
  CON           : TFWConnection;
  PRODFOR       : TPRODUTOFORNECEDOR;
  PROD          : TPRODUTO;
  FORN          : TFORNECEDOR;
  ExcelColluns  : array of TExcelColluns;
begin
  csProdutos.EmptyDataSet;
  XLSAplicacao := CreateOleObject('Excel.Application');
  csProdutos.DisableControls;
  pgProdutos.Position                               := 0;
  try
    CON                                             := TFWConnection.Create;
    PROD                                            := TPRODUTO.Create(CON);
    FORN                                            := TFORNECEDOR.Create(CON);
    PRODFOR                                         := TPRODUTOFORNECEDOR.Create(CON);
    try
      XLSAplicacao.Visible                          := False;
      // Abre o Workbook
      XLSAplicacao.Workbooks.Open(edArquivo.Text);

      AbaXLS                                        := XLSAplicacao.Workbooks[ExtractFileName(edArquivo.Text)].WorkSheets[1];

      XLSAplicacao.ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
      //ROW
      vrow                                          := XLSAplicacao.ActiveCell.Row;
      vcol                                          := XLSAplicacao.ActiveCell.Column;

      pgProdutos.Max                                := vRow;

      SetLength(ExcelColluns, 0);
      for I := 1 to vcol do begin
        if AbaXLS.Cells.Item[1, I].Value = 'Cód. do Fornecedor' then begin
          SetLength(ExcelColluns, Length(ExcelColluns) + 1);
          ExcelColluns[High(ExcelColluns)].index    := I;
          ExcelColluns[High(ExcelColluns)].nome     := csProdutosCODIGO.FieldName;
        end else if AbaXLS.Cells.Item[1, I].Value = 'Estoque' then begin
          SetLength(ExcelColluns, Length(ExcelColluns) + 1);
          ExcelColluns[High(ExcelColluns)].index    := I;
          ExcelColluns[High(ExcelColluns)].nome     := csProdutosDISPONIVEL.FieldName;
        end else if AbaXLS.Cells.Item[1, I].Value = 'Custo Final C/ IPI+ST+Desc' then begin
          SetLength(ExcelColluns, Length(ExcelColluns) + 1);
          ExcelColluns[High(ExcelColluns)].index    := I;
          ExcelColluns[High(ExcelColluns)].nome     := csProdutosCUSTO.FieldName;
        end;
      end;
      for I := 2 to vrow do begin
        csProdutos.Append;
        for J := 0 to High(ExcelColluns) do
          csProdutos.FieldByName(ExcelColluns[J].nome).Value   := AbaXLS.Cells.Item[I, ExcelColluns[J].index].Value;
        if not (csProdutosCODIGO.IsNull) then begin
          PRODFOR.SelectList('cod_prod_fornecedor = ' + QuotedStr(csProdutosCODIGO.AsString) + ' and id_fornecedor = ' + edFornecedor.Text);
          if PRODFOR.Count > 0 then begin
            PROD.SelectList('id = ' + TPRODUTOFORNECEDOR(PRODFOR.Itens[0]).ID_PRODUTO.asSQL);
            if PROD.Count > 0 then begin
              csProdutosSKU.Value                   := TPRODUTO(PROD.Itens[0]).SKU.Value;
              csProdutosNOME.Value                  := TPRODUTO(PROD.Itens[0]).NOME.Value;
            end;
          end;
        end;
      end;
      csProdutos.Post;
      pgProdutos.Position                           := I;
      Application.ProcessMessages;
    finally
      FreeAndNil(PROD);
      FreeAndNil(FORN);
      FreeAndNil(PRODFOR);
      FreeAndNil(CON);
    end;
  finally
     // Fecha o Microsoft Excel
    if not VarIsEmpty(XLSAplicacao) then begin
      XLSAplicacao.Quit;
      XLSAplicacao := Unassigned;
    end;
    csProdutos.EnableControls;
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.btNovoLoteClick(Sender: TObject);
var
  CON  : TFWConnection;
  LOTE : TLOTEIMPORTACAO;
begin
  CON                     := TFWConnection.Create;
  LOTE                    := TLOTEIMPORTACAO.Create(CON);
  try
    try
      DisplayMsg(MSG_WAIT, 'Gravando lote...');
      CON.StartTransaction;
      LOTE.DATA_HORA.Value := Now;
      LOTE.Insert;
      CON.Commit;
      DisplayMsg(MSG_OK, 'Lote Incluído com sucesso!');
      carregaLotes;
    except
      on E : Exception do begin
        CON.Rollback;
        DisplayMsg(MSG_WAR, 'Erro ao incluir lote!', '', E.Message);
        Exit;
      end;
    end;

  finally
    FreeAndNil(LOTE);
    FreeAndNil(CON);
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmImportacaoArquivoFornecedor.carregaLotes;
var
  CON  : TFWConnection;
  LOTE : TLOTEIMPORTACAO;
  Total,
  I    : Integer;
begin
  CON                 := TFWConnection.Create;
  LOTE                := TLOTEIMPORTACAO.Create(CON);
  try
    LOTE.SelectList('','id desc');
    Total             := 5;
    if LOTE.Count < Total then
      Total           := LOTE.Count;
    cbLote.Clear;
    for I := 0 to Pred(Total) do
      cbLote.Items.Add(TLOTEIMPORTACAO(LOTE.Itens[I]).ID.asString +'-'+ FormatDateTime('dd/mm/yyyy hh:MM:ss', TLOTEIMPORTACAO(LOTE.Itens[I]).DATA_HORA.Value));
    cbLote.ItemIndex  := 0;
  finally
    FreeAndNil(LOTE);
    FreeAndNil(CON);
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.csProdutosAfterPost(
  DataSet: TDataSet);
begin
  edTotalRegistros.Text     := IntToStr(csProdutos.RecordCount);
end;

procedure TfrmImportacaoArquivoFornecedor.dsProdutosDataChange(Sender: TObject;
  Field: TField);
begin
  edRegistroAtual.Text     := IntToStr(csProdutos.RecNo);
end;

procedure TfrmImportacaoArquivoFornecedor.edArquivoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    edArquivoRightButtonClick(nil);
end;

procedure TfrmImportacaoArquivoFornecedor.edArquivoRightButtonClick(
  Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if Pos('xls',ExtractFileExt(OpenDialog1.FileName)) > 0 then begin
      edArquivo.Text := OpenDialog1.FileName;
    end;
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    edFornecedorRightButtonClick(nil);
end;

procedure TfrmImportacaoArquivoFornecedor.edFornecedorRightButtonClick(
  Sender: TObject);
var
  FORNECEDOR : TFORNECEDOR;
  CON        : TFWConnection;
begin
  CON                       := TFWConnection.Create;
  FORNECEDOR                := TFORNECEDOR.Create(CON);
  edNomeFornecedor.Text     := '';
  try
    edFornecedor.Text       := IntToStr(DMUtil.Selecionar(FORNECEDOR, edFornecedor.Text));
    FORNECEDOR.SelectList('id = ' + edFornecedor.Text);
    if FORNECEDOR.Count > 0 then
      edNomeFornecedor.Text := TFORNECEDOR(FORNECEDOR.Itens[0]).NOME.asString;
  finally
    FreeAndNil(FORNECEDOR);
    FreeAndNil(CON);
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmImportacaoArquivoFornecedor := nil;
  Action                         := caFree;
end;

procedure TfrmImportacaoArquivoFornecedor.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure TfrmImportacaoArquivoFornecedor.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmImportacaoArquivoFornecedor.FormShow(Sender: TObject);
begin
  carregaLotes;
  csProdutos.CreateDataSet;
  csProdutos.Open;
end;

end.
