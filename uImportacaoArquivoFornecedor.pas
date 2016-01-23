unit uImportacaoArquivoFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ImgList, Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, comObj, TypInfo,
  Vcl.ComCtrls, Vcl.Imaging.jpeg, Vcl.Samples.Gauges;

type
  TExcelColluns = record
    index : Integer;
    nome  : String;
  end;
  TfrmImportacaoArquivoFornecedor = class(TForm)
    pnPrincipal: TPanel;
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
    csProdutosSTATUS: TIntegerField;
    cbFiltro: TComboBox;
    Label3: TLabel;
    IMFundo: TImage;
    pgProdutos: TGauge;
    btLimpar: TSpeedButton;
    csProdutosID_PRODUTO: TIntegerField;
    gbSelecionaLote: TGroupBox;
    cbLote: TComboBox;
    csProdutosID_PRODUTOFORNECEDOR: TIntegerField;
    csProdutosDISPONIVEL: TIntegerField;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
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
    procedure btSalvarClick(Sender: TObject);
    procedure dgProdutosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure cbFiltroChange(Sender: TObject);
    procedure csProdutosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btLimparClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure carregaLotes;
    procedure limpaCampos;
    procedure atualizaTotal;
    procedure bloqueioSalvar(Status : Integer = 0);//0 - Bloqueio Botao Salvar 1 - Bloqueio Tudo 2 - Bloqueio Importar
    procedure buscaProdutosFornecedor(CodFornecedor : Integer);
  end;

var
  frmImportacaoArquivoFornecedor: TfrmImportacaoArquivoFornecedor;

implementation
uses uDMUtil, uBeanLoteImportacao, uFWConnection, uMensagem, uBeanFornecedor,
     uBeanProduto, uBeanProdutoFornecedor, uBeanImportacao, uBeanImportacao_Itens,
     uConstantes, uFuncoes;
{$R *.dfm}

procedure TfrmImportacaoArquivoFornecedor.atualizaTotal;
begin
  edTotalRegistros.Text     := IntToStr(csProdutos.RecordCount);
end;

procedure TfrmImportacaoArquivoFornecedor.bloqueioSalvar(Status : Integer = 0);
//0 - Bloqueio Botao Salvar 1 - Bloqueio Tudo 2 - Bloqueio Importar
begin
  edFornecedor.Enabled := Status in [0];
  edArquivo.Enabled    := Status in [0];
  btImportar.Enabled   := Status in [0];
  btSalvar.Enabled     := Status in [2];;
end;

procedure TfrmImportacaoArquivoFornecedor.btImportarClick(Sender: TObject);
const
  xlCellTypeLastCell = $0000000B;
var
  XLSAplicacao,
  AbaXLS,
  Range         : OLEVariant;
  vrow,
  vcol,
  i,
  j,
  k,
  Count         : Integer;
  ExcelColluns  : array of TExcelColluns;
  Valor         : Variant;
  FORN          : TFORNECEDOR;
  CON           : TFWConnection;
  arrData       : Variant;

begin
  csProdutos.EmptyDataSet;
  if StrToIntDef(edFornecedor.Text, 0) <> 0 then begin
    CON                                             := TFWConnection.Create;
    FORN                                            := TFORNECEDOR.Create(CON);
    try
      FORN.SelectList('id = ' + edFornecedor.Text);
      if FORN.Count = 0 then begin
        DisplayMsg(MSG_WAR, 'Fornecedor não encontrado!');
        if edFornecedor.CanFocus then edFornecedor.SetFocus;
        Exit;
      end;
    finally
      FreeAndNil(FORN);
      FreeAndNil(CON);
    end;
  end else begin
    DisplayMsg(MSG_WAR, 'Fornecedor não encontrado!');
    if edFornecedor.CanFocus then edFornecedor.SetFocus;
    Exit;
  end;

  if not FileExists(edArquivo.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo não encontrado!');
    if edArquivo.CanFocus then edArquivo.SetFocus;
    Exit;
  end;

  bloqueioSalvar(1);
  btImportar.Tag                       := 0;
  try
    buscaProdutosFornecedor(StrToIntDef(edFornecedor.Text,0));

    XLSAplicacao := CreateOleObject('Excel.Application');

    csProdutos.DisableControls;
    pgProdutos.Progress                             := 0;

    try
      XLSAplicacao.Visible                          := False;
      // Abre o Workbook
      XLSAplicacao.Workbooks.Open(edArquivo.Text);

      AbaXLS                                        := XLSAplicacao.Workbooks[ExtractFileName(edArquivo.Text)].WorkSheets[1];

      XLSAplicacao.ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
      //ROW
      vrow                                          := XLSAplicacao.ActiveCell.Row;
      vcol                                          := XLSAplicacao.ActiveCell.Column;

      arrData                                       := VarArrayCreate([1, vrow, 1, vcol], varVariant);

      Range                                         := XLSAplicacao.WorkSheets[1].Range[XLSAplicacao.WorkSheets[1].Cells[1, 1], XLSAplicacao.WorkSheets[1].Cells[vrow, vcol]];

      arrData                                       := Range.value;

      pgProdutos.MaxValue                           := vRow;
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
        for J := 0 to High(ExcelColluns) do begin
          if csProdutos.FieldByName(ExcelColluns[J].nome).FieldName = csProdutosCODIGO.FieldName then begin
            Valor                                   := Trim(arrData[I, ExcelColluns[J].index]);
//            Valor                                   := Trim(AbaXLS.Cells.Item[I, ExcelColluns[J].index].Value);
            if Valor <> '' then begin
              if csProdutos.Locate(csProdutosCODIGO.FieldName, Valor, []) then
                csProdutos.Edit
              else
                csProdutos.Append;
              for k := 0 to High(ExcelColluns) do begin
                Valor                               := Trim(AbaXLS.Cells.Item[I, ExcelColluns[k].index].Value);
                if Valor <> '' then
                  csProdutos.FieldByName(ExcelColluns[k].nome).Value := Valor;
              end;
              csProdutosSTATUS.Value                := 1;
              if ((csProdutosCODIGO.IsNull) or (csProdutosCODIGO.Value = '')) then
                csProdutos.Cancel
              else begin
                if csProdutosSKU.Value = '' then
                  btImportar.Tag                    := 1;
                if csProdutosCUSTO.Value = 0 then
                  csProdutosDISPONIVEL.Value        := 0;
                csProdutos.Post;
              end;
              Break;
            end;
          end;
        end;
        pgProdutos.Progress                         := I;
      end;
      bloqueioSalvar(2);
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'houve algum erro ao importar os produtos!', '', E.Message);
        bloqueioSalvar(0);
        Exit;
      end;
    end;
    if btImportar.Tag <> 0 then begin
      DisplayMsg(MSG_WAR, 'Existem produtos não cadastrados no arquivo!');
      bloqueioSalvar(0);
      cbFiltro.ItemIndex                            := 2;
      cbFiltroChange(nil);
      Exit;
    end;
    DisplayMsg(MSG_INF, 'Importacao Realizada com sucesso!');
  finally
     // Fecha o Microsoft Excel
    if not VarIsEmpty(XLSAplicacao) then begin
      XLSAplicacao.Quit;
      XLSAplicacao                                := Unassigned;
    end;
    csProdutos.EnableControls;
    pgProdutos.Progress                           := 0;
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.btLimparClick(Sender: TObject);
begin
  limpaCampos;
  bloqueioSalvar(0);
end;

procedure TfrmImportacaoArquivoFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmImportacaoArquivoFornecedor.btSalvarClick(Sender: TObject);
var
  IMPORTACAO : TIMPORTACAO;
  ITENS      : TIMPORTACAO_ITENS;
  CON        : TFWConnection;
  PROD       : TPRODUTO;
  PRODFOR    : TPRODUTOFORNECEDOR;
  I,
  idLote     : Integer;
begin

  idLote := StrToIntDef(Copy(cbLote.Items[cbLote.ItemIndex], 1, (Pos(' - ', cbLote.Items[cbLote.ItemIndex]) -1)),-1);

  if idLote = -1 then begin
    DisplayMsg(MSG_WAR, 'Não há Lote Selecionado, Verifique!');
    Exit;
  end;

  CON                                := TFWConnection.Create;
  IMPORTACAO                         := TIMPORTACAO.Create(CON);
  ITENS                              := TIMPORTACAO_ITENS.Create(CON);
  PROD                               := TPRODUTO.Create(CON);
  PRODFOR                            := TPRODUTOFORNECEDOR.Create(CON);
  csProdutos.DisableControls;

  DisplayMsg(MSG_WAIT, 'Gravando dados no banco de dados!');

  try
    CON.StartTransaction;
    try
      IMPORTACAO.DATA_HORA.Value       := Now;
      IMPORTACAO.ID_FORNECEDOR.Value   := StrToInt(edFornecedor.Text);
      IMPORTACAO.ID_LOTE.Value         := idLote;
      IMPORTACAO.ID_USUARIO.Value      := USUARIO.CODIGO;
      IMPORTACAO.Insert;

      csProdutos.First;
      while not csProdutos.Eof do begin
        if csProdutosSKU.Value <> '' then begin
          ITENS.ID_IMPORTACAO.Value    := IMPORTACAO.ID.Value;
          ITENS.ID_PRODUTO.Value       := csProdutosID_PRODUTO.Value;
          ITENS.CUSTO.Value            := csProdutosCUSTO.Value;
          ITENS.QUANTIDADE.Value       := csProdutosDISPONIVEL.Value;
          ITENS.STATUS.Value           := csProdutosSTATUS.Value;

          ITENS.Insert;

          PRODFOR.ID.Value             := csProdutosID_PRODUTOFORNECEDOR.Value;
          PRODFOR.ID_ULTIMOLOTE.Value  := idLote;
          PRODFOR.CUSTO.Value          := csProdutosCUSTO.Value;
          PRODFOR.QUANTIDADE.Value     := csProdutosDISPONIVEL.Value;
          PRODFOR.Update;
        end;
        csProdutos.Next;
      end;
      CON.Commit;
      bloqueioSalvar(0);
      limpaCampos;
      DisplayMsg(MSG_OK, 'Dados gravados com sucesso!');
    except
      on E : Exception do begin
        CON.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao incluir produtos!', '', E.Message);
        Exit;
      end;
    end;
  finally
    csProdutos.EnableControls;
    FreeAndNil(IMPORTACAO);
    FreeAndNil(ITENS);
    FreeAndNil(PROD);
    FreeAndNil(PRODFOR);
    FreeAndNil(CON);
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.buscaProdutosFornecedor(
  CodFornecedor: Integer);
var
  CON           : TFWConnection;
  PRODFOR       : TPRODUTOFORNECEDOR;
  PROD          : TPRODUTO;
  I             : Integer;
begin
  CON                                               := TFWConnection.Create;
  PRODFOR                                           := TPRODUTOFORNECEDOR.Create(CON);
  PROD                                              := TPRODUTO.Create(CON);
  try
    PRODFOR.SelectList('id_fornecedor = ' + edFornecedor.Text);
    pgProdutos.MaxValue                             := PRODFOR.Count;
    pgProdutos.Progress                             := 0;
    for I := 0 to Pred(PRODFOR.Count) do begin
      csProdutos.Append;
      csProdutosCODIGO.Value                        := TPRODUTOFORNECEDOR(PRODFOR.Itens[I]).COD_PROD_FORNECEDOR.Value;
      csProdutosID_PRODUTO.Value                    := TPRODUTOFORNECEDOR(PRODFOR.Itens[I]).ID_PRODUTO.Value;
      csProdutosID_PRODUTOFORNECEDOR.Value          := TPRODUTOFORNECEDOR(PRODFOR.Itens[I]).ID.Value;
      PROD.SelectList('id = ' + csProdutosID_PRODUTO.asString);
      if PROD.Count > 0 then begin
        csProdutosSKU.Value                         := TPRODUTO(PROD.Itens[0]).SKU.Value;
        csProdutosNOME.Value                        := TPRODUTO(PROD.Itens[0]).NOME.Value;
      end;
      csProdutosSTATUS.Value                        := 0;
      csProdutosCUSTO.Value                         := 0;
      csProdutosDISPONIVEL.Value                    := 0;
      csProdutos.Post;
      pgProdutos.Progress                           := I;
    end;

    pgProdutos.Progress                             := 0;

  finally
    FreeAndNil(PRODFOR);
    FreeAndNil(PROD);
    FreeAndNil(CON);
  end;

end;

procedure TfrmImportacaoArquivoFornecedor.carregaLotes;
var
  CON  : TFWConnection;
  LOTE : TLOTE;
  I    : Integer;
begin
  CON                 := TFWConnection.Create;
  LOTE                := TLOTE.Create(CON);
  try
    LOTE.SelectList('ID > 0','ID DESC LIMIT 5');
    cbLote.Clear;
    for I := 0 to Pred(LOTE.Count) do
      cbLote.Items.Add(TLOTE(LOTE.Itens[I]).ID.asString + ' - ' + FormatDateTime('dd/mm/yyyy', TLOTE(LOTE.Itens[I]).DATA_HORA.Value));
    cbLote.ItemIndex  := 0;
  finally
    FreeAndNil(LOTE);
    FreeAndNil(CON);
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.cbFiltroChange(Sender: TObject);
begin
  csProdutos.Filtered        := False;
  if cbFiltro.ItemIndex <> 0 then
    csProdutos.Filtered      := True;
  atualizaTotal;
end;

procedure TfrmImportacaoArquivoFornecedor.csProdutosAfterPost(
  DataSet: TDataSet);
begin
  atualizaTotal;
end;

procedure TfrmImportacaoArquivoFornecedor.csProdutosFilterRecord(
  DataSet: TDataSet; var Accept: Boolean);
begin
  if cbFiltro.ItemIndex = 1 then
    Accept   := csProdutosSTATUS.Value = 0
  else
    Accept   := csProdutosSKU.Value = '';
end;

procedure TfrmImportacaoArquivoFornecedor.dgProdutosDrawColumnCell(
  Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if csProdutosSTATUS.Value = 1 then
    dgProdutos.Canvas.Font.Color := clDefault
  else
    dgProdutos.Canvas.Font.Color := clRed;
  dgProdutos.DefaultDrawDataCell(Rect, dgProdutos.Columns[DataCol].Field, State);
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
  AjustaForm(Self);
end;

procedure TfrmImportacaoArquivoFornecedor.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmImportacaoArquivoFornecedor.FormShow(Sender: TObject);
begin
  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');
  AutoSizeDBGrid(dgProdutos);

  carregaLotes;

  csProdutos.CreateDataSet;
  csProdutos.Open;

  bloqueioSalvar(0);
end;

procedure TfrmImportacaoArquivoFornecedor.limpaCampos;
begin
  edFornecedor.Enabled                          := True;
  edArquivo.Enabled                             := True;
  csProdutos.EmptyDataSet;
  edTotalRegistros.Text                         := '0';
  edRegistroAtual.Text                          := '0';
  pgProdutos.Progress                           := 0;
  edFornecedor.Text                             := '';
  edNomeFornecedor.Text                         := '';
  edArquivo.Text                                := '';
  if cbLote.CanFocus then
    cbLote.SetFocus;
end;

end.
