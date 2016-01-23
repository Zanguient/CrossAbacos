unit uImportacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ImgList,
  Vcl.StdCtrls, comObj, TypInfo, uDomains, Vcl.Imaging.jpeg, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Samples.Gauges;
type
  TfrmImportacao = class(TForm)
    GridPanel1: TGridPanel;
    pnImportacaoProduto: TPanel;
    pnImportaAlmoxarifados: TPanel;
    pnImportaFornecedor: TPanel;
    pnImportaProdutoFornecedor: TPanel;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    mnImportaProdutos: TMemo;
    pnCabProdutos: TPanel;
    btImportarProdutos: TButton;
    edBuscaArquivoProdutos: TButtonedEdit;
    Label1: TLabel;
    pnCabAlmoxarifado: TPanel;
    Label2: TLabel;
    btImportaAlmoxarifado: TButton;
    edBuscaArquivoAlmoxarifado: TButtonedEdit;
    mnImportaAlmoxarifado: TMemo;
    mnImportaFornecedor: TMemo;
    pnCabImportaFornecedor: TPanel;
    Label3: TLabel;
    btImportarFornecedor: TButton;
    edBuscaArquivoFornecedor: TButtonedEdit;
    pnCabImportaProdutoFornecedor: TPanel;
    Label4: TLabel;
    btImportarProdutoFornecedor: TButton;
    edBuscaArquivoProdutoFornecedor: TButtonedEdit;
    mnImportaProdutoFornecedor: TMemo;
    imFundo: TImage;
    pnPrincipal: TPanel;
    pbImportaProdutos: TGauge;
    pbImportaAlmoxarifado: TGauge;
    pbImportaFornecedor: TGauge;
    pbImportaProdutoFornecedor: TGauge;
    procedure edBuscaArquivoProdutosRightButtonClick(Sender: TObject);
    procedure btImportarProdutosClick(Sender: TObject);
    procedure btImportaAlmoxarifadoClick(Sender: TObject);
    procedure edBuscaArquivoAlmoxarifadoRightButtonClick(Sender: TObject);
    procedure edBuscaArquivoFornecedorRightButtonClick(Sender: TObject);
    procedure btImportarFornecedorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edBuscaArquivoProdutoFornecedorRightButtonClick(Sender: TObject);
    procedure btImportarProdutoFornecedorClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImportacao: TfrmImportacao;

implementation
uses uBeanProduto, uFWConnection, uMensagem, uBeanAlmoxarifado,
     uBeanProdutoFornecedor, uBeanFornecedor, uConstantes;

{$R *.dfm}

procedure TfrmImportacao.btImportaAlmoxarifadoClick(Sender: TObject);
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
  Count         : Integer;
  CON           : TFWConnection;
  ALM           : TALMOXARIFADO;
  List          : TPropList;
  Valor,
  arrData       : Variant;
  arrInsert,
  arrUpdate     : array of Integer;
begin
  if not FileExists(edBuscaArquivoAlmoxarifado.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
    Exit;
  end;
  // Cria Excel- OLE Object
  XLSAplicacao                                        := CreateOleObject('Excel.Application');
  edBuscaArquivoAlmoxarifado.Enabled                  := False;
  btImportaAlmoxarifado.Enabled                       := False;

  SetLength(arrInsert, 0);
  SetLength(arrUpdate, 0);
  try
    mnImportaAlmoxarifado.Clear;
    // Esconde Excel
    XLSAplicacao.Visible                              := False;
    // Abre o Workbook
    XLSAplicacao.Workbooks.Open(edBuscaArquivoAlmoxarifado.Text);

    AbaXLS                                            := XLSAplicacao.Workbooks[ExtractFileName(edBuscaArquivoAlmoxarifado.Text)].WorkSheets[1];
    AbaXLS.select;

    XLSAplicacao.ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
    //ROW
    vrow                                              := XLSAplicacao.ActiveCell.Row;
    vcol                                              := XLSAplicacao.ActiveCell.Column;
    arrData                                           := VarArrayCreate([1, vrow, 1, vcol], varVariant);
    Range                                             := XLSAplicacao.WorkSheets[1].Range[XLSAplicacao.WorkSheets[1].Cells[1, 1], XLSAplicacao.WorkSheets[1].Cells[vrow, vcol]];
    arrData                                           := Range.value;
    pbImportaAlmoxarifado.MaxValue                    := vrow;
    //COLLUM
    CON                                               := TFWConnection.Create;
    ALM                                               := TALMOXARIFADO.Create(CON);
    try
      ALM.CODIGO_E10.excelTitulo                      := 'ID';
      ALM.NOME.excelTitulo                            := 'Nome';

      ALM.buscaIndicesExcel(edBuscaArquivoAlmoxarifado.Text, XLSAplicacao);

      Count                                           := GetPropList(ALM.ClassInfo, tkProperties, @List, False);

      for J := 0 to Pred(Count) do begin
        if (TFieldTypeDomain(GetObjectProp(ALM, List[J]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(ALM, List[J]^.Name)).excelIndice <= 0) then begin
          DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'ID, Nome.');
          Exit;
        end;
      end;
      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          ALM.ClearFields;
          for J := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(ALM, List[J]^.Name)).excelIndice > 0) then begin
              Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(ALM, List[J]^.Name)).excelIndice]);
              if Valor <> '' then
                TFieldTypeDomain(GetObjectProp(ALM, List[J]^.Name)).asVariant := Valor;
            end;
          end;

          if ALM.CODIGO_E10.Value > 0 then begin
            ALM.SelectList('codigo_e10 = ' + ALM.CODIGO_E10.asSQL);
            if ALM.Count > 0 then begin
              ALM.ID.Value                            := TALMOXARIFADO(ALM.Itens[0]).ID.Value;
              ALM.Update;

              SetLength(arrUpdate, Length(arrUpdate) + 1);
              arrUpdate[High(arrUpdate)]              := ALM.ID.Value;

              mnImportaAlmoxarifado.Lines.Add('Código: ' + ALM.CODIGO_E10.asString + ' - alterado com sucesso!');
            end else begin
              ALM.Insert;

              SetLength(arrInsert, Length(arrInsert) + 1);
              arrInsert[High(arrInsert)]              := ALM.ID.Value;

              mnImportaAlmoxarifado.Lines.Add('Código: ' + ALM.CODIGO_E10.asString + ' - inserido com sucesso!');
            end;
          end;

          pbImportaAlmoxarifado.Progress              := I;
          Application.ProcessMessages;
        end;
        CON.Commit;

        if Length(arrInsert) > 0 then
          mnImportaAlmoxarifado.Lines.Add('Total de almoxarifados inseridos: ' + IntToStr(Length(arrInsert)));
        if Length(arrUpdate) > 0 then
          mnImportaAlmoxarifado.Lines.Add('Total de almoxarifados alterados: ' + IntToStr(Length(arrUpdate)));

        DisplayMsg(MSG_OK, 'Importação realizada com sucesso!');
        pbImportaAlmoxarifado.Progress                := 0;
      except
        on E : Exception do begin
          CON.Rollback;
          DisplayMsg(MSG_WAR, 'Erro ao importar os almoxarifados!', '', E.Message);
          Exit;
        end;
      end;
    finally
      FreeAndNil(ALM);
      FreeAndNil(CON);
    end;

  finally
    edBuscaArquivoAlmoxarifado.Enabled                                         := True;
    btImportaAlmoxarifado.Enabled                                              := True;
    // Fecha o Microsoft Excel
    if not VarIsEmpty(XLSAplicacao) then begin
      XLSAplicacao.Quit;
      XLSAplicacao := Unassigned;
      AbaXLS := Unassigned;
    end;
  end;
end;

procedure TfrmImportacao.btImportarFornecedorClick(Sender: TObject);
const
  xlCellTypeLastCell = $0000000B;
var
  XLSAplicacao,
  AbaXLS,
  Range          : OLEVariant;
  vrow,
  vcol,
  i,
  j,
  Count          : Integer;
  CON            : TFWConnection;
  FORN           : TFORNECEDOR;
  ALM            : TALMOXARIFADO;
  List           : TPropList;
  Valor,
  arrData        : Variant;
  arrInsert,
  arrUpdate      : array of Integer;
begin
  if not FileExists(edBuscaArquivoFornecedor.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
    Exit;
  end;
  // Cria Excel- OLE Object
  XLSAplicacao                                                                 := CreateOleObject('Excel.Application');
  btImportarFornecedor.Enabled                                                 := False;

  SetLength(arrInsert, 0);
  SetLength(arrUpdate, 0);
  try
    mnImportaFornecedor.Clear;
    // Esconde Excel
    XLSAplicacao.Visible                                                       := False;
    // Abre o Workbook
    XLSAplicacao.Workbooks.Open(edBuscaArquivoFornecedor.Text);

    AbaXLS                                                                     := XLSAplicacao.Workbooks[ExtractFileName(edBuscaArquivoFornecedor.Text)].WorkSheets[1];
    AbaXLS.select;

    XLSAplicacao.ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
    //ROW
    vrow                                                                       := XLSAplicacao.ActiveCell.Row;
    vcol                                                                       := XLSAplicacao.ActiveCell.Column;
    arrData                                                                    := VarArrayCreate([1, vrow, 1, vcol], varVariant);
    Range                                                                      := XLSAplicacao.WorkSheets[1].Range[XLSAplicacao.WorkSheets[1].Cells[1, 1], XLSAplicacao.WorkSheets[1].Cells[vrow, vcol]];
    arrData                                                                    := Range.value;
    pbImportaFornecedor.MaxValue                                               := vrow;
    //COLLUM
    CON                                                                        := TFWConnection.Create;
    FORN                                                                       := TFORNECEDOR.Create(CON);
    ALM                                                                        := TALMOXARIFADO.Create(CON);
    try
      FORN.CNPJ.excelTitulo                                                    := 'ID_Forn';
      FORN.NOME.excelTitulo                                                    := 'Nome';
      FORN.ID_ALMOXARIFADO.excelTitulo                                         := 'ID_Almoxerifado';

      FORN.buscaIndicesExcel(edBuscaArquivoFornecedor.Text, XLSAplicacao);

      Count                                                                    := GetPropList(FORN.ClassInfo, tkProperties, @List, False);

      for J := 0 to Pred(Count) do begin
        if (TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelIndice <= 0) then begin
          DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas:' + sLineBreak + 'ID_Forn, ' + sLineBreak + 'Nome,' + sLineBreak + 'ID_Almoxerifado');
          Exit;
        end;
      end;

      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          FORN.ClearFields;
          for J := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelIndice > 0) then begin
              Valor                                                            := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelIndice]);
              if Valor <> '' then
                TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).asVariant := Valor;
            end;
          end;
          if FORN.CNPJ.isNull then begin
            mnImportaFornecedor.Lines.Add('Linha vazia!');
            pbImportaFornecedor.Progress                                       := pbImportaFornecedor.MaxValue;
            Break;
          end else begin
            ALM.SelectList('codigo_e10 = ' + FORN.ID_ALMOXARIFADO.asSQL);
            if ALM.Count > 0 then begin
              FORN.ID_ALMOXARIFADO.Value                                       := TALMOXARIFADO(ALM.Itens[0]).ID.Value;

              FORN.SelectList('cnpj = ' + FORN.CNPJ.asSQL);
              if FORN.Count > 0 then begin
                FORN.ID.Value                                                  := TFORNECEDOR(FORN.Itens[0]).ID.Value;
                FORN.Update;

                SetLength(arrUpdate, Length(arrUpdate) + 1);
                arrUpdate[High(arrUpdate)]                                     := ALM.ID.Value;

                mnImportaFornecedor.Lines.Add('Código: ' + FORN.CNPJ.asString + ' - alterado com sucesso!');
              end else begin
                FORN.Insert;

                SetLength(arrInsert, Length(arrInsert) + 1);
                arrInsert[High(arrInsert)]                                     := FORN.ID.Value;

                mnImportaFornecedor.Lines.Add('Código: ' + FORN.CNPJ.asString + ' - inserido com sucesso!');
              end;
            end else begin
              mnImportaFornecedor.Lines.Add('Almoxarifado não encontrado! ' + FORN.ID_ALMOXARIFADO.asString);
            end;
          end;
          pbImportaFornecedor.Progress                                         := I;
          Application.ProcessMessages;
        end;
        CON.Commit;

        if Length(arrInsert) > 0 then
          mnImportaFornecedor.Lines.Add('Total de Fornecedores inseridos: ' + IntToStr(Length(arrInsert)));
        if Length(arrUpdate) > 0 then
          mnImportaFornecedor.Lines.Add('Total de Fornecedores alterados: ' + IntToStr(Length(arrUpdate)));

        DisplayMsg(MSG_OK, 'Importação realizada com sucesso!');
        pbImportaFornecedor.Progress                                           := 0;

      except
        on E : Exception do begin
          CON.Rollback;
          DisplayMsg(MSG_WAR, 'Erro ao importar os Fornecedores!', '', E.Message);
          Exit;
        end;
      end;
    finally
      FreeAndNil(FORN);
      FreeAndNil(ALM);
      FreeAndNil(CON);
    end;

  finally
    btImportarFornecedor.Enabled                                               := True;
    // Fecha o Microsoft Excel
    if not VarIsEmpty(XLSAplicacao) then begin
      XLSAplicacao.Quit;
      XLSAplicacao := Unassigned;
      AbaXLS := Unassigned;
    end;
  end;
end;

procedure TfrmImportacao.btImportarProdutoFornecedorClick(Sender: TObject);
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
  Count         : Integer;
  CON           : TFWConnection;
  FORN          : TFORNECEDOR;
  PROD          : TPRODUTO;
  FORPROD       : TPRODUTOFORNECEDOR;
  List          : TPropList;
  Valor,
  arrData       : Variant;
  arrInsert,
  arrUpdate     : array of Integer;
begin
  if not FileExists(edBuscaArquivoProdutoFornecedor.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
    Exit;
  end;
  // Cria Excel- OLE Object
  XLSAplicacao                                                                 := CreateOleObject('Excel.Application');
  btImportarProdutoFornecedor.Enabled                                          := False;

  SetLength(arrInsert, 0);
  SetLength(arrUpdate, 0);
  try
    mnImportaProdutoFornecedor.Clear;
    // Esconde Excel
    XLSAplicacao.Visible                                                       := False;
    // Abre o Workbook
    XLSAplicacao.Workbooks.Open(edBuscaArquivoProdutoFornecedor.Text);

    AbaXLS                                                                     := XLSAplicacao.Workbooks[ExtractFileName(edBuscaArquivoProdutoFornecedor.Text)].WorkSheets[1];
    AbaXLS.select;

    XLSAplicacao.ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
    //ROW
    vrow                                                                       := XLSAplicacao.ActiveCell.Row;
    vcol                                                                       := XLSAplicacao.ActiveCell.Column;
    arrData                                                                    := VarArrayCreate([1, vrow, 1, vcol], varVariant);
    Range                                                                      := XLSAplicacao.WorkSheets[1].Range[XLSAplicacao.WorkSheets[1].Cells[1, 1], XLSAplicacao.WorkSheets[1].Cells[vrow, vcol]];
    arrData                                                                    := Range.value;
    pbImportaProdutoFornecedor.MaxValue                                        := vrow;
    //COLLUM
    CON                                                                        := TFWConnection.Create;
    PROD                                                                       := TPRODUTO.Create(CON);
    FORN                                                                       := TFORNECEDOR.Create(CON);
    FORPROD                                                                    := TPRODUTOFORNECEDOR.Create(CON);
    try
      FORPROD.ID_PRODUTO.excelTitulo                                           := 'SKU';
      FORPROD.ID_FORNECEDOR.excelTitulo                                        := 'CNPJ Fornecedor';
      FORPROD.COD_PROD_FORNECEDOR.excelTitulo                                  := 'Cod.Forn';

      FORPROD.buscaIndicesExcel(edBuscaArquivoProdutoFornecedor.Text, XLSAplicacao);

      Count                                                                    := GetPropList(FORPROD.ClassInfo, tkProperties, @List, False);

      for J := 0 to Pred(Count) do begin
        if (TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).excelIndice <= 0) then begin
          DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'SKU, ' + sLineBreak + 'CNPJ Fornecedor,' + sLineBreak + 'Cod.Forn');
          Exit;
        end;
      end;

      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          FORPROD.ClearFields;
          for J := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).excelIndice > 0) then begin
              Valor                                                            := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).excelIndice]);
              if Valor <> '' then begin
                if List[J]^.Name = 'ID_PRODUTO' then begin
                  PROD.SelectList('upper(sku) = ' + QuotedStr(AnsiUpperCase(Valor)));
                  if PROD.Count > 0 then
                    FORPROD.ID_PRODUTO.Value                                   := TPRODUTO(PROD.Itens[0]).ID.Value
                  else begin
                    mnImportaProdutoFornecedor.Lines.Add('Produto não encontrado! ' + Valor);
                    Break;
                  end;

                end else if List[J]^.Name = 'ID_FORNECEDOR' then begin
                  FORN.SelectList('cnpj = ' + QuotedStr(Valor));
                  if FORN.Count > 0 then
                    FORPROD.ID_FORNECEDOR.Value                                := TFORNECEDOR(FORN.Itens[0]).ID.Value
                  else begin
                    CON.Rollback;
                    mnImportaAlmoxarifado.Lines.Add('Fornecedor não encontrado! ' + Valor);
                    Exit;
                  end;
                end else
                  TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).asVariant := Valor;
              end;
            end;
          end;

          FORPROD.SelectList('id_produto = ' + FORPROD.ID_PRODUTO.asString + ' and id_fornecedor = ' + FORPROD.ID_FORNECEDOR.asString);
          if FORPROD.Count > 0 then begin
            FORPROD.ID.Value                                                   := TPRODUTOFORNECEDOR(FORPROD.Itens[0]).ID.Value;
            FORPROD.Update;

            SetLength(arrUpdate, Length(arrUpdate) + 1);
            arrUpdate[High(arrUpdate)]                                         := FORPROD.ID.Value;

            mnImportaProdutoFornecedor.Lines.Add('Código: ' + FORPROD.COD_PROD_FORNECEDOR.asString + ' - alterado com sucesso!');
          end else begin
            FORPROD.ID_ULTIMOLOTE.Value                                        := 0;
            FORPROD.CUSTO.Value                                                := 0.00;
            FORPROD.QUANTIDADE.Value                                           := 0;

            FORPROD.Insert;

            SetLength(arrInsert, Length(arrInsert) + 1);
            arrInsert[High(arrInsert)]                                         := FORPROD.ID.Value;

            mnImportaProdutoFornecedor.Lines.Add('Código: ' + FORPROD.COD_PROD_FORNECEDOR.asString + ' - inserido com sucesso!');
          end;

          pbImportaProdutoFornecedor.Progress                                  := I;
          Application.ProcessMessages;
        end;
        CON.Commit;

        if Length(arrInsert) > 0 then
          mnImportaProdutoFornecedor.Lines.Add('Total de Códigos de Produtos de Fornecedores inseridos: ' + IntToStr(Length(arrInsert)));
        if Length(arrUpdate) > 0 then
          mnImportaProdutoFornecedor.Lines.Add('Total de Códigos de Produtos de Fornecedores alterados: ' + IntToStr(Length(arrUpdate)));

        DisplayMsg(MSG_OK, 'Importação realizada com sucesso!');
        pbImportaProdutoFornecedor.Progress                                    := 0;

      except
        on E : Exception do begin
          CON.Rollback;
          DisplayMsg(MSG_WAR, 'Erro ao importar os Produtos de fornecedores!', '', E.Message);
          Exit;
        end;
      end;
    finally
      FreeAndNil(PROD);
      FreeAndNil(FORN);
      FreeAndNil(FORPROD);
      FreeAndNil(CON);
    end;
  finally
    btImportarProdutoFornecedor.Enabled                                        := True;
    // Fecha o Microsoft Excel
    if not VarIsEmpty(XLSAplicacao) then begin
      XLSAplicacao.Quit;
      XLSAplicacao := Unassigned;
      AbaXLS := Unassigned;
    end;
  end;
end;

procedure TfrmImportacao.btImportarProdutosClick(Sender: TObject);
const
  xlCellTypeLastCell = $0000000B;
var
  XLSAplicacao, AbaXLS, Range: OLEVariant;
  vrow, vcol, i, j, Count: Integer;
  CON                 : TFWConnection;
  PROD                : TPRODUTO;
  List                : TPropList;
  Valor,
  arrData             : Variant;
  arrInsert,
  arrUpdate           : array of Integer;
  SQL                 : TFDQuery;
  ListaProdutosInsert : String;
begin
  if not FileExists(edBuscaArquivoProdutos.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
    Exit;
  end;
   // Cria Excel- OLE Object
  XLSAplicacao                                                                := CreateOleObject('Excel.Application');
  btImportarProdutos.Enabled                                                  := False;

  SetLength(arrInsert, 0);
  SetLength(arrUpdate, 0);
  try
    mnImportaProdutos.Clear;
    mnImportaProdutos.Lines.Add('Carregando dados, Aguarde!');
    // Esconde Excel
    XLSAplicacao.Visible                                                      := False;
    // Abre o Workbook
    XLSAplicacao.Workbooks.Open(edBuscaArquivoProdutos.Text);

    AbaXLS                                                                    := XLSAplicacao.Workbooks[ExtractFileName(edBuscaArquivoProdutos.Text)].WorkSheets[1];
    AbaXLS.select;

    XLSAplicacao.ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
    //ROW
    vrow                                                                      := XLSAplicacao.ActiveCell.Row;
    vcol                                                                      := XLSAplicacao.ActiveCell.Column;
    arrData                                                                   := VarArrayCreate([1, vrow, 1, vcol], varVariant);
    Range                                                                     := XLSAplicacao.WorkSheets[1].Range[XLSAplicacao.WorkSheets[1].Cells[1, 1], XLSAplicacao.WorkSheets[1].Cells[vrow, vcol]];
    arrData                                                                   := Range.value;
    pbImportaProdutos.MaxValue                                                := vrow;
    //COLLUM
    CON                                                                       := TFWConnection.Create;
    PROD                                                                      := TPRODUTO.Create(CON);
    try
      PROD.SKU.excelTitulo                                                    := 'SKU';
      PROD.CODIGO_BARRAS.excelTitulo                                          := 'CODIGO DE BARRAS';
      PROD.NOME.excelTitulo                                                   := 'NOME';
      PROD.SALDO.excelTitulo                                                  := 'SALDO';
      PROD.DISPONIVEL.excelTitulo                                             := 'DISP';
      PROD.ICMS.excelTitulo                                                   := 'ICMS';
      PROD.CF.excelTitulo                                                     := 'CF';
      PROD.PRODUTO_PAI.excelTitulo                                            := 'PRODUTO PAI';
      PROD.MARCA.excelTitulo                                                  := 'MARCA';
      PROD.FAMILIA.excelTitulo                                                := 'Família';
      PROD.CLASSE.excelTitulo                                                 := 'Classe';
      PROD.UNIDADE_MEDIDA.excelTitulo                                         := 'Unidade de medida';
      PROD.GRUPO.excelTitulo                                                  := 'Grupo';
      PROD.SUB_GRUPO.excelTitulo                                              := 'Sub-grupo';
      PROD.PRECO_VENDA.excelTitulo                                            := 'Preço de venda';
      PROD.PROMOCAO_IPI.excelTitulo                                           := 'Promoção + IPI';
      PROD.PESO.excelTitulo                                                   := 'Peso';
      PROD.NCM.excelTitulo                                                    := 'Clas Fisc';
      PROD.ESTOQUE_MAXIMO.excelTitulo                                         := 'Estoque máximo';
      PROD.PRAZO_ENTREGA.excelTitulo                                          := 'Prazo de entrega';
      PROD.QUANTIDADE_EMBALAGEM.excelTitulo                                   := 'Qtde. por embalagem';
      PROD.C.excelTitulo                                                      := 'C';
      PROD.L.excelTitulo                                                      := 'L';
      PROD.E.excelTitulo                                                      := 'E';
      PROD.DIAS_GARANTIA.excelTitulo                                          := 'Dias de garantia';
      PROD.ORIGEM_MERCADORIA.excelTitulo                                      := 'Origem da mercadoria';
      PROD.UN.excelTitulo                                                     := 'UN';
      PROD.CODIGO_CF.excelTitulo                                              := 'Código Classificacao Fical';
      PROD.ESTOQUE_MINIMO.excelTitulo                                         := 'Em';

      PROD.buscaIndicesExcel(edBuscaArquivoProdutos.Text, XLSAplicacao);
      PROD.ID.excelIndice                                                     := -1;

      Count                                                                   := GetPropList(PROD.ClassInfo, tkProperties, @List, False);
      for J := 0 to Pred(Count) do begin
        if (TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).excelIndice <= 0) and (TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).isNotNull) then begin
          DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'SKU, ' + sLineBreak +
                                                                               'CODIGO DE BARRAS, ' + sLineBreak +
                                                                               'NOME, ' + sLineBreak +
                                                                               'SALDO, ' + sLineBreak +
                                                                               'DISP, ' + sLineBreak +
                                                                               'ICMS, ' + sLineBreak +
                                                                               'CF, ' + sLineBreak +
                                                                               'PRODUTO PAI, ' + sLineBreak +
                                                                               'MARCA, ' + sLineBreak +
                                                                               'Família, ' + sLineBreak +
                                                                               'Classe, ' + sLineBreak +
                                                                               'Unidade de medida, ' + sLineBreak +
                                                                               'Grupo, ' + sLineBreak +
                                                                               'Sub-grupo, ' + sLineBreak +
                                                                               'Preço de venda, ' + sLineBreak +
                                                                               'Promoção + IPI, ' + sLineBreak +
                                                                               'Código Classificacao Fical, ' + sLineBreak +
                                                                               'UN, ' + sLineBreak +
                                                                               'Peso, ' + sLineBreak +
                                                                               'Clas Fisc, ' + sLineBreak +
                                                                               'Estoque máximo, ' + sLineBreak +
                                                                               'Prazo de entrega, ' + sLineBreak +
                                                                               'Qtde. por embalagem, ' + sLineBreak +
                                                                               'C, ' + sLineBreak +
                                                                               'L, ' + sLineBreak +
                                                                               'E, ' + sLineBreak +
                                                                               'Dias de garantia, ' + sLineBreak +
                                                                               'Origem da mercadoria');
          Exit;
        end;
      end;

      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          PROD.ClearFields;
          for J := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).excelIndice > 0) then begin
              Valor := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).excelIndice]);
              if Valor <> '' then
                TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).asVariant   := Valor;
            end;
          end;
          if (PROD.SKU.Value <> '') and (Copy(PROD.SKU.Value, 1, 4) <> '345.') then begin
            PROD.SelectList('upper(sku) = ' + QuotedStr(AnsiUpperCase(PROD.SKU.asString)));
            if PROD.Count > 0 then begin
              PROD.ID.Value                                                      := TPRODUTO(PROD.Itens[0]).ID.Value;
              PROD.Update;

              SetLength(arrUpdate, Length(arrUpdate) + 1);
              arrUpdate[High(arrUpdate)]                                         := PROD.ID.Value;

              mnImportaProdutos.Lines.Add('SKU: ' + PROD.SKU.Value + ' - alterado com sucesso!');
            end else begin
              PROD.CUSTOANTERIOR.Value                                           := 0.00;
              PROD.CUSTO.Value                                                   := 0.00;
              PROD.ID_FORNECEDORANTERIOR.Value                                   := 0;
              PROD.ID_FORNECEDORNOVO.Value                                       := 0;
              PROD.ID_ULTIMOLOTE.Value                                           := 0;
              PROD.Insert;

              SetLength(arrInsert, Length(arrInsert) + 1);
              arrInsert[High(arrInsert)]                                         := PROD.ID.Value;

              mnImportaProdutos.Lines.Add('SKU: ' + PROD.SKU.Value + ' - inserido com sucesso!');
            end;
          end;
          pbImportaProdutos.Progress                                             := I;
          Application.ProcessMessages;
        end;
        if Length(arrInsert) > 0 then begin
          ListaProdutosInsert                                                    := '';
          for I := 0 to High(arrInsert) do begin
            if I = 0 then
              ListaProdutosInsert                                                := IntToStr(arrInsert[I])
            else
              ListaProdutosInsert                                                := ListaProdutosInsert + ', ' + IntToStr(arrInsert[I])
          end;

          SQL                                                                    := TFDQuery.Create(nil);
          try
            SQL.Connection                                                       := CON.FDConnection;

            SQL.ExecSQL('UPDATE PRODUTO SET ID_FORNECEDORNOVO = COALESCE((SELECT F.ID FROM FORNECEDOR F WHERE UPPER(F.NOME) = UPPER(SUB_GRUPO)),0) WHERE ID IN (' + ListaProdutosInsert + ')')

          finally
            FreeAndNil(SQL);
          end;
        end;
        CON.Commit;

        if Length(arrInsert) > 0 then
          mnImportaProdutos.Lines.Add('Total de produtos inseridos: ' + IntToStr(Length(arrInsert)));
        if Length(arrUpdate) > 0 then
          mnImportaProdutos.Lines.Add('Total de produtos alterados: ' + IntToStr(Length(arrUpdate)));

        DisplayMsg(MSG_OK, 'Importação realizada com sucesso!');
        pbImportaProdutos.Progress                                               := 0;

      except
        on E : Exception do begin
          CON.Rollback;
          btImportarProdutos.Enabled                                          := True;
          DisplayMsg(MSG_WAR, 'Erro ao importar os produtos!', '', E.Message);
          Exit;
        end;
      end;
    finally
      FreeAndNil(PROD);
      FreeAndNil(CON);
    end;

  finally
    // Fecha o Microsoft Excel
    btImportarProdutos.Enabled     := True;
    if not VarIsEmpty(XLSAplicacao) then begin
      XLSAplicacao.Quit;
      XLSAplicacao := Unassigned;
      AbaXLS := Unassigned;
    end;
  end;
end;

procedure TfrmImportacao.edBuscaArquivoAlmoxarifadoRightButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if Pos('xls',ExtractFileExt(OpenDialog1.FileName)) > 0 then begin
      edBuscaArquivoAlmoxarifado.Text := OpenDialog1.FileName;
    end;
  end;
end;

procedure TfrmImportacao.edBuscaArquivoFornecedorRightButtonClick(
  Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if Pos('xls',ExtractFileExt(OpenDialog1.FileName)) > 0 then begin
      edBuscaArquivoFornecedor.Text := OpenDialog1.FileName;
    end;
  end;
end;

procedure TfrmImportacao.edBuscaArquivoProdutoFornecedorRightButtonClick(
  Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if Pos('xls',ExtractFileExt(OpenDialog1.FileName)) > 0 then begin
      edBuscaArquivoProdutoFornecedor.Text := OpenDialog1.FileName;
    end;
  end;
end;

procedure TfrmImportacao.edBuscaArquivoProdutosRightButtonClick(
  Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    if Pos('xls',ExtractFileExt(OpenDialog1.FileName)) > 0 then begin
      edBuscaArquivoProdutos.Text := OpenDialog1.FileName;
    end;
  end;
end;

procedure TfrmImportacao.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure TfrmImportacao.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmImportacao.FormShow(Sender: TObject);
begin
  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');
end;

end.
