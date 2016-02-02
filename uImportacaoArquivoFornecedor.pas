unit uImportacaoArquivoFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ImgList, Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, comObj, TypInfo,
  Vcl.ComCtrls, Vcl.Imaging.jpeg, Vcl.Samples.Gauges, TlHelp32;

type
  TExcelColluns = record
    index : Integer;
    nome  : String;
  end;
  TfrmImportacaoArquivoFornecedor = class(TForm)
    pnPrincipal: TPanel;
    pnBotton: TPanel;
    GridPanel1: TGridPanel;
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
    Panel1: TPanel;
    Panel2: TPanel;
    btSalvar: TBitBtn;
    btSair: TBitBtn;
    btExport: TSpeedButton;
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
    procedure btExportClick(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure dgProdutosTitleClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure carregaLotes;
    procedure limpaCampos;
    procedure atualizaTotal;
    procedure bloqueioSalvar(Status : Integer = 0);//0 - Bloqueio Botao Salvar 1 - Bloqueio Tudo 2 - Bloqueio Importar
    procedure buscaProdutosFornecedor(CodFornecedor : Integer);
    procedure exportaprodutos;
    procedure filtrar;
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

procedure TfrmImportacaoArquivoFornecedor.btExportClick(Sender: TObject);
begin
  if btExport.Tag = 0 then begin
    btExport.Tag := 1;
    try
      exportaprodutos;
    finally
      btExport.Tag := 0;
    end;
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.btImportarClick(Sender: TObject);
const
  xlCellTypeLastCell = $0000000B;
var
  Excel         : OleVariant;
  arrData       : Variant;
  vrow,
  vcol,
  i,
  j,
  k             : Integer;
  ExcelColluns  : array of TExcelColluns;
  Valor         : Variant;
  FORN          : TFORNECEDOR;
  CON           : TFWConnection;
begin
  csProdutos.EmptyDataSet;
  csProdutos.Filtered                               := False;
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
  btImportar.Tag                                    := 0;
  try
    buscaProdutosFornecedor(StrToIntDef(edFornecedor.Text,0));

    Excel                                           := CreateOleObject('Excel.Application');

    csProdutos.DisableControls;
    pgProdutos.Progress                             := 0;

    try
      Excel.Visible                                 := False;
      // Abre o Workbook
      Excel.Workbooks.Open(edArquivo.Text);

      Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
      //ROW
      vrow                                          := Excel.ActiveCell.Row;
      vcol                                          := Excel.ActiveCell.Column;

      arrData                                       := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

      pgProdutos.MaxValue                           := vRow;
      SetLength(ExcelColluns, 0);
      for I := 1 to vcol do begin
        if arrData[1, I] = 'Cód. do Fornecedor' then begin
          SetLength(ExcelColluns, Length(ExcelColluns) + 1);
          ExcelColluns[High(ExcelColluns)].index    := I;
          ExcelColluns[High(ExcelColluns)].nome     := csProdutosCODIGO.FieldName;
        end else if arrData[1, I] = 'Estoque' then begin
          SetLength(ExcelColluns, Length(ExcelColluns) + 1);
          ExcelColluns[High(ExcelColluns)].index    := I;
          ExcelColluns[High(ExcelColluns)].nome     := csProdutosDISPONIVEL.FieldName;
        end else if arrData[1, I] = 'Custo Final C/ IPI+ST+Desc' then begin
          SetLength(ExcelColluns, Length(ExcelColluns) + 1);
          ExcelColluns[High(ExcelColluns)].index    := I;
          ExcelColluns[High(ExcelColluns)].nome     := csProdutosCUSTO.FieldName;
        end;
      end;

      if Length(ExcelColluns) < 3 then begin
        DisplayMsg(MSG_WAR, 'Estrutura do arquivo inválida!', '', 'Colunas: Cód. do Fornecedor, Estoque, Custo Final C/ IPI+ST+Desc');
        Exit;
      end;

      for I := 2 to vrow do begin
        for J := 0 to High(ExcelColluns) do begin
          if csProdutos.FieldByName(ExcelColluns[J].nome).FieldName = csProdutosCODIGO.FieldName then begin
            Valor                                   := Trim(arrData[I, ExcelColluns[J].index]);
            if Valor <> '' then begin
              if csProdutos.Locate(csProdutosCODIGO.FieldName, Valor, []) then
                csProdutos.Edit
              else
                csProdutos.Append;
              for k := 0 to High(ExcelColluns) do begin
                if ExcelColluns[K].nome <> csProdutosCODIGO.FieldName then begin
                  Valor                               := Trim(arrData[I, ExcelColluns[K].index]);
                  if Valor <> '' then
                    csProdutos.FieldByName(ExcelColluns[k].nome).Value := Valor;
                end;
              end;
              csProdutosSTATUS.Value                := 1;
              if ((csProdutosCODIGO.IsNull) or (csProdutosCODIGO.Value = '')) then
                csProdutos.Cancel
              else begin
                if csProdutosSKU.Value = '' then
                  btImportar.Tag                    := 1;
                if (csProdutosCUSTO.Value = 0) or (csProdutosDISPONIVEL.Value = 0) then begin
                  csProdutosDISPONIVEL.Value        := 0;
                  csProdutosCUSTO.Value             := 0;
                end;
                csProdutos.Post;
              end;
              Break;
            end;
          end;
        end;
        pgProdutos.Progress                         := I;
      end;

      CON   := TFWConnection.Create;
      FORN  := TFORNECEDOR.Create(CON);
      pgProdutos.Progress                     := 0;
      pgProdutos.MaxValue                     := csProdutos.RecordCount;
      try

        FORN.SelectList('id = ' + edFornecedor.Text);

        csProdutos.First;
        while not csProdutos.Eof do begin
          if (csProdutosSTATUS.Value = 1) and (csProdutosDISPONIVEL.Value > 0) then begin
            if csProdutosDISPONIVEL.Value < TFORNECEDOR(FORN.Itens[0]).ESTOQUEMINIMO.Value then begin
              csProdutos.Edit;
              csProdutosDISPONIVEL.Value     := 0;
              csProdutosCUSTO.Value          := 0;
              csProdutos.Post;
            end else if csProdutosDISPONIVEL.Value > TFORNECEDOR(FORN.Itens[0]).ESTOQUEMAXIMO.Value then begin
              csProdutos.Edit;
              csProdutosDISPONIVEL.Value     := TFORNECEDOR(FORN.Itens[0]).ESTOQUEMAXIMO.Value;
              csProdutos.Post;
            end;
          end;
          pgProdutos.Progress                := csProdutos.RecNo;
          csProdutos.Next;
        end;
      finally
        FreeAndNil(FORN);
        FreeAndNil(CON);
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
      cbFiltro.ItemIndex                            := 3;
      cbFiltroChange(nil);
      Exit;
    end;
    DisplayMsg(MSG_OK, 'Importacao Realizada com sucesso!');
  finally
    arrData                                         := Unassigned;
     // Fecha o Microsoft Excel
    if not VarIsEmpty(Excel) then begin
      Excel.Quit;
      Excel                                         := Unassigned;
    end;
    filtrar;
    csProdutos.EnableControls;
    pgProdutos.Progress                             := 0;
    Application.ProcessMessages;
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.btLimparClick(Sender: TObject);
begin
  limpaCampos;
  bloqueioSalvar(0);
end;

procedure TfrmImportacaoArquivoFornecedor.btSairClick(Sender: TObject);
begin
  if not csProdutos.IsEmpty then begin
    DisplayMsg(MSG_CONF, 'Tem certeza que deseja sair?');
    if not (ResultMsgModal in [mrOk, mrYes]) then Exit;
  end;
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
  pgProdutos.MaxValue                := csProdutos.RecordCount;
  pgProdutos.Progress                := 0;
  csProdutos.DisableControls;
  csProdutos.Filtered                := False;

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
        pgProdutos.Progress            := csProdutos.RecNo;
        csProdutos.Next;
      end;
      CON.Commit;
      bloqueioSalvar(0);
      pgProdutos.Progress              := 0;
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
    filtrar;
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
  csProdutos.DisableControls;
  try
    PRODFOR.SelectList('id_fornecedor = ' + edFornecedor.Text + ' AND STATUS = True');
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
      Application.ProcessMessages;
    end;

    pgProdutos.Progress                             := 0;

  finally
    csProdutos.EnableControls;
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
  filtrar;
end;

procedure TfrmImportacaoArquivoFornecedor.csProdutosAfterPost(
  DataSet: TDataSet);
begin
  atualizaTotal;
end;

procedure TfrmImportacaoArquivoFornecedor.csProdutosFilterRecord(
  DataSet: TDataSet; var Accept: Boolean);
begin
  case cbFiltro.ItemIndex of
    1 : Accept   := csProdutosSTATUS.Value = 1;
    2 : Accept   := csProdutosSTATUS.Value = 0;
    3 : Accept   := csProdutosSKU.Value  = '';
  end;
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

procedure TfrmImportacaoArquivoFornecedor.dgProdutosTitleClick(Column: TColumn);
begin
   csProdutos.IndexFieldNames := Column.FieldName;
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

procedure TfrmImportacaoArquivoFornecedor.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
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

procedure TfrmImportacaoArquivoFornecedor.exportaprodutos;
var
  XLSAplicacao,
  AbaXLS,
  RangeTitulos,
  RangeDados,
  arrTitulos,
  arrData      : Variant;
  I            : Integer;
  DirArquivo   : String;
begin
  if csProdutos.IsEmpty then begin
    DisplayMsg(MSG_WAR, 'Não existem dados para exportar');
    Exit;
  end;

  DirArquivo := DirArquivosExcel + FormatDateTime('yyyymmdd', Date);

  if not DirectoryExists(DirArquivo) then begin
    if not ForceDirectories(DirArquivo) then begin
      DisplayMsg(MSG_WAR, 'Não foi possível criar o diretório,' + sLineBreak + DirArquivo + sLineBreak + 'Verifique!');
      Exit;
    end;
  end;

  DirArquivo    := DirArquivo + '\' + edNomeFornecedor.Text + '.xlsx';

  if FileExists(DirArquivo) then begin
    DisplayMsg(MSG_CONF, 'Já existe um arquivo em,' + sLineBreak + DirArquivo + sLineBreak +
                          'Deseja Sobreescrever?');
    if ResultMsgModal <> mrYes then
      Exit;

    DeleteFile(DirArquivo);
  end;

  DisplayMsg(MSG_WAIT, 'Carregando dados para o Arquivo!');

  XLSAplicacao := CreateOleObject('Excel.Application');
  csProdutos.DisableControls;
  try
    XLSAplicacao.Caption := 'IMPORTACAO ' + edNomeFornecedor.Text;
    XLSAplicacao.Visible := False;
    XLSAplicacao.WorkBooks.add(1);
    XLSAplicacao.Workbooks[1].WorkSheets[1].Name := edNomeFornecedor.Text;
    AbaXLS                  := XLSAplicacao.Workbooks[1].WorkSheets[edNomeFornecedor.Text];

    arrTitulos              := VarArrayCreate([1, 1, 1, csProdutos.FieldCount], varVariant);
    for I := 0 to Pred(csProdutos.FieldCount) do
      arrTitulos[1, I + 1]  := csProdutos.Fields[I].DisplayLabel;
    RangeTitulos            := AbaXLS.Range[AbaXLS.cells[1,1].Address, AbaXLS.Cells[1, csProdutos.FieldCount].Address];
    RangeTitulos.Font.Bold  := True;
    RangeTitulos.Font.Color := clBlue;
    RangeTitulos.Value      := arrTitulos;

    arrData                 := VarArrayCreate([1, csProdutos.RecordCount + 1, 1 , csProdutos.FieldCount], varVariant);

    csProdutos.First;
    while not csProdutos.Eof do begin
      for I := 0 to Pred(csProdutos.FieldCount) do
        arrData[csProdutos.RecNo, I + 1] := csProdutos.Fields[I].Value;
      csProdutos.Next;
    end;

    RangeDados              := AbaXLS.Range[AbaXLS.cells[2,1].Address, AbaXLS.Cells[csProdutos.RecordCount + 1, csProdutos.FieldCount].Address];
    RangeDados.numberFormat := '@';
    RangeDados.Value        := arrData;

    AbaXLS.Columns.AutoFit;
    XLSAplicacao.WorkBooks[1].Sheets[1].SaveAs(DirArquivo);
    DisplayMsg(MSG_OK, 'Arquivo gerado com sucesso!','', DirArquivo);
  finally
    csProdutos.EnableControls;

    if not VarIsEmpty(XLSAplicacao) then begin
      AbaXLS                := Unassigned;
      RangeTitulos          := Unassigned;
      RangeDados            := Unassigned;
      arrTitulos            := Unassigned;
      arrData               := Unassigned;

      XLSAplicacao.Quit;
      XLSAplicacao          := Unassigned;
    end;
  end;
end;

procedure TfrmImportacaoArquivoFornecedor.filtrar;
begin
  csProdutos.Filtered        := False;
  if cbFiltro.ItemIndex <> 0 then
    csProdutos.Filtered      := True;
  atualizaTotal;
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
