unit uImportacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ImgList,
  Vcl.StdCtrls, comObj, TypInfo, uDomains, Vcl.Imaging.jpeg;
type
  TfrmImportacao = class(TForm)
    GridPanel1: TGridPanel;
    pnImportacaoProduto: TPanel;
    pnImportaAlmoxarifados: TPanel;
    pnImportaFornecedor: TPanel;
    pnImportaProdutoFornecedor: TPanel;
    pbImportaProdutos: TProgressBar;
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
    pbImportaAlmoxarifado: TProgressBar;
    mnImportaFornecedor: TMemo;
    pbImportaFornecedor: TProgressBar;
    pnCabImportaFornecedor: TPanel;
    Label3: TLabel;
    btImportarFornecedor: TButton;
    edBuscaArquivoFornecedor: TButtonedEdit;
    pnCabImportaProdutoFornecedor: TPanel;
    Label4: TLabel;
    btImportarProdutoFornecedor: TButton;
    edBuscaArquivoProdutoFornecedor: TButtonedEdit;
    mnImportaProdutoFornecedor: TMemo;
    pbImportaProdutoFornecedor: TProgressBar;
    imFundo: TImage;
    pnPrincipal: TPanel;
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
begin
  if not FileExists(edBuscaArquivoAlmoxarifado.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado n�o existe! Verifique!');
    Exit;
  end;
  // Cria Excel- OLE Object
  XLSAplicacao                                        := CreateOleObject('Excel.Application');
  edBuscaArquivoAlmoxarifado.Enabled                  := False;
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
    pbImportaAlmoxarifado.Max                         := vrow;
    //COLLUM
    CON                                               := TFWConnection.Create;
    ALM                                               := TALMOXARIFADO.Create(CON);
    try
      ALM.CODIGO_E10.excelTitulo                      := 'ID';
      ALM.NOME.excelTitulo                            := 'Nome';

      ALM.buscaIndicesExcel(edBuscaArquivoAlmoxarifado.Text, XLSAplicacao);

      Count                                           := GetPropList(ALM.ClassInfo, tkProperties, @List, False);

      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          ALM.CODIGO_E10.Value    := 0;
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
              mnImportaAlmoxarifado.Lines.Add('C�digo: ' + ALM.CODIGO_E10.asString + ' - alterado com sucesso!');
            end else begin
              ALM.Insert;
              mnImportaAlmoxarifado.Lines.Add('C�digo: ' + ALM.CODIGO_E10.asString + ' - inserido com sucesso!');
            end;
          end;

          pbImportaAlmoxarifado.Position              := I;
          Application.ProcessMessages;
        end;
        CON.Commit;
        mnImportaAlmoxarifado.Lines.Add('Total de almoxarifados importados: ' + IntToStr(I));
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
begin
  if not FileExists(edBuscaArquivoFornecedor.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado n�o existe! Verifique!');
    Exit;
  end;
  // Cria Excel- OLE Object
  XLSAplicacao                                                                 := CreateOleObject('Excel.Application');
  btImportarFornecedor.Enabled                                                 := False;
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
    pbImportaFornecedor.Max                                                    := vrow;
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

      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          FORN.CNPJ.Value                                                      := '';
          for J := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelIndice > 0) then begin
              Valor                                                            := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelIndice]);
              if Valor <> '' then
                TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).asVariant := Valor;
            end;
          end;
          if FORN.CNPJ.Value = '' then begin
            mnImportaFornecedor.Lines.Add('Linha vazia!');
            pbImportaFornecedor.Position                                       := pbImportaFornecedor.Max;
            Break;
          end else begin
            ALM.SelectList('codigo_e10 = ' + FORN.ID_ALMOXARIFADO.asSQL);
            if ALM.Count > 0 then begin
              FORN.ID_ALMOXARIFADO.Value                                       := TALMOXARIFADO(ALM.Itens[0]).ID.Value;

              FORN.SelectList('cnpj = ' + FORN.CNPJ.asSQL);
              if FORN.Count > 0 then begin
                FORN.ID.Value                                                  := TFORNECEDOR(FORN.Itens[0]).ID.Value;
                FORN.Update;
                mnImportaFornecedor.Lines.Add('C�digo: ' + FORN.CNPJ.asString + ' - alterado com sucesso!');
              end else begin
                FORN.Insert;
                mnImportaFornecedor.Lines.Add('C�digo: ' + FORN.CNPJ.asString + ' - inserido com sucesso!');
              end;
            end else begin
              mnImportaFornecedor.Lines.Add('Almoxarifado n�o encontrado! ' + FORN.ID_ALMOXARIFADO.asString);
            end;
          end;
          pbImportaFornecedor.Position                                         := I;
          Application.ProcessMessages;
        end;
        CON.Commit;
        mnImportaFornecedor.Lines.Add('Total de Fornecedores importados: ' + IntToStr(I));
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
begin
  if not FileExists(edBuscaArquivoProdutoFornecedor.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado n�o existe! Verifique!');
    Exit;
  end;
  // Cria Excel- OLE Object
  XLSAplicacao                                                                 := CreateOleObject('Excel.Application');
  btImportarProdutoFornecedor.Enabled                                          := False;
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
    pbImportaProdutoFornecedor.Max                                             := vrow;
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

      CON.StartTransaction;
      try
        for I := 2 to vrow do begin
          for J := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).excelIndice > 0) then begin
              Valor                                                            := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).excelIndice]);
              if Valor <> '' then begin
                if List[J]^.Name = 'ID_PRODUTO' then begin
                  PROD.SelectList('sku = ' + QuotedStr(Valor));
                  if PROD.Count > 0 then
                    FORPROD.ID_PRODUTO.Value                                   := TPRODUTO(PROD.Itens[0]).ID.Value
                  else begin
                    mnImportaProdutoFornecedor.Lines.Add('Produto n�o encontrado! ' + Valor);
                    Break;
                  end;

                end else if List[J]^.Name = 'ID_FORNECEDOR' then begin
                  FORN.SelectList('cnpj = ' + QuotedStr(Valor));
                  if FORN.Count > 0 then
                    FORPROD.ID_FORNECEDOR.Value                                := TFORNECEDOR(FORN.Itens[0]).ID.Value
                  else begin
                    CON.Rollback;
                    mnImportaAlmoxarifado.Lines.Add('Fornecedor n�o encontrado! ' + Valor);
                    Exit;
                  end;
                end else
                  TFieldTypeDomain(GetObjectProp(FORPROD, List[J]^.Name)).asVariant := Valor;
              end;
            end;
          end;

          FORPROD.SelectList('id_produto = ' + FORPROD.ID_PRODUTO.asSQL + ' and id_fornecedor = ' + FORPROD.ID_FORNECEDOR.asSQL);
          if FORPROD.Count > 0 then begin
            FORPROD.ID.Value                                                   := TPRODUTOFORNECEDOR(FORPROD.Itens[0]).ID.Value;
            FORPROD.Update;
            mnImportaProdutoFornecedor.Lines.Add('C�digo: ' + FORPROD.COD_PROD_FORNECEDOR.asString + ' - alterado com sucesso!');
          end else begin
            FORPROD.Insert;
            mnImportaProdutoFornecedor.Lines.Add('C�digo: ' + FORPROD.COD_PROD_FORNECEDOR.asString + ' - inserido com sucesso!');
          end;

          pbImportaProdutoFornecedor.Position                                  := I;
          Application.ProcessMessages;
        end;
        CON.Commit;
        mnImportaProdutoFornecedor.Lines.Add('Total de c�digos de produtos por fornecedor importados: ' + IntToStr(I));
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
  CON  : TFWConnection;
  PROD : TPRODUTO;
  List: TPropList;
  Valor,
  arrData : Variant;
begin
  if not FileExists(edBuscaArquivoProdutos.Text) then begin
    DisplayMsg(MSG_WAR, 'Arquivo selecionado n�o existe! Verifique!');
    Exit;
  end;
   // Cria Excel- OLE Object
   XLSAplicacao                                                                := CreateOleObject('Excel.Application');
   btImportarProdutos.Enabled                                                  := False;
   try
     mnImportaProdutos.Clear;
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
     pbImportaProdutos.Max                                                     := vrow;
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
       PROD.FAMILIA.excelTitulo                                                := 'Fam�lia';
       PROD.CLASSE.excelTitulo                                                 := 'Classe';
       PROD.UNIDADE_MEDIDA.excelTitulo                                         := 'Unidade de medida';
       PROD.GRUPO.excelTitulo                                                  := 'Grupo';
       PROD.SUB_GRUPO.excelTitulo                                              := 'Sub-grupo';
       PROD.PRECO_VENDA.excelTitulo                                            := 'Pre�o de venda';
       PROD.PROMOCAO_IPI.excelTitulo                                           := 'Promo��o + IPI';
       PROD.PESO.excelTitulo                                                   := 'Peso';
       PROD.NCM.excelTitulo                                                    := 'Clas Fisc';
       PROD.ESTOQUE_MAXIMO.excelTitulo                                         := 'Estoque m�ximo';
       PROD.PRAZO_ENTREGA.excelTitulo                                          := 'Prazo de entrega';
       PROD.QUANTIDADE_EMBALAGEM.excelTitulo                                   := 'Qtde. por embalagem';
       PROD.C.excelTitulo                                                      := 'C';
       PROD.L.excelTitulo                                                      := 'L';
       PROD.E.excelTitulo                                                      := 'E';
       PROD.DIAS_GARANTIA.excelTitulo                                          := 'Dias de garantia';
       PROD.ORIGEM_MERCADORIA.excelTitulo                                      := 'Origem da mercadoria';

       PROD.buscaIndicesExcel(edBuscaArquivoProdutos.Text, XLSAplicacao);
       PROD.ID.excelIndice                                                     := -1;

       Count                                                                   := GetPropList(PROD.ClassInfo, tkProperties, @List, False);

       CON.StartTransaction;
       try
         for I := 2 to vrow do begin
           PROD.SKU.Value                                                      := '';
           for J := 0 to Pred(Count) do begin
             if (TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).excelIndice > 0) then begin
               Valor := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).excelIndice]);
               if Valor <> '' then
                 TFieldTypeDomain(GetObjectProp(PROD, List[J]^.Name)).asVariant:= Valor;
             end;
           end;
           if PROD.SKU.Value <> '' then begin
             PROD.SelectList('sku = ' + PROD.SKU.asSQL);
             if PROD.Count > 0 then begin
               PROD.ID.Value                                                    := TPRODUTO(PROD.Itens[0]).ID.Value;
               PROD.Update;
               mnImportaProdutos.Lines.Add('SKU: ' + PROD.SKU.Value + ' - alterado com sucesso!');
             end else begin
               PROD.CUSTOANTERIOR.Value                                           := 0.00;
               PROD.CUSTO.Value                                                   := 0.00;
               PROD.ID_FORNECEDORANTERIOR.Value                                   := 0;
               PROD.ID_FORNECEDORNOVO.Value                                       := 0;
               PROD.ID_ULTIMOLOTE.Value                                           := 0;
               PROD.Insert;
               mnImportaProdutos.Lines.Add('SKU: ' + PROD.SKU.Value + ' - inserido com sucesso!');
             end;
           end;
           pbImportaProdutos.Position                                          := I;
           Application.ProcessMessages;
         end;
         CON.Commit;
         mnImportaProdutos.Lines.Add('Total de produtos importados: ' + IntToStr(I));
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
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabe�alho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabe�alho form principal
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
