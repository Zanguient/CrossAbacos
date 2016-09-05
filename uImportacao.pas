unit uImportacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ImgList,
  Vcl.StdCtrls, comObj, TypInfo, uDomains, Vcl.Imaging.jpeg, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Samples.Gauges,
  System.StrUtils;
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
    procedure AtualizarProdutos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImportacao: TfrmImportacao;

implementation
uses
  uBeanProduto,
  uFWConnection,
  uMensagem,
  uBeanAlmoxarifado,
  uBeanProdutoFornecedor,
  uBeanFornecedor,
  uConstantes,
  uFuncoes,
  uBeanFamilia;

{$R *.dfm}

procedure TfrmImportacao.AtualizarProdutos;
type
  TArrayFamilias = record
    ID          : Integer;
    DESCRICAO   : string;
  end;

type
  TArrayListaProdutos = record
    ID  : Integer;
    SKU : string;
    CUSTO_EST_FISICO_ANT : Currency;
  end;

type
  TArrayProdutos = record
    ID_PRODUTO : Integer;
    CODIGO : string;
    NOME : string;
    MARCA : string;
    DEPARTAMENTO : string;
    SETOR : string;
    FAMILIA : string;
    SUBFAMILIA : string;
    PRAZO_FABRICACAO : Integer;
    ID_FAMILIA : Integer;
    CUSTO_EST_FISICO_ANT : Currency;
    CUSTO_ESTOQUE_FISICO : Currency;
  end;

const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  F       : TFAMILIA;
  P       : TPRODUTO;
  Arquivo,
  Aux     : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  I,
  J       : Integer;
  ArqValido,
  AchouColuna   : Boolean;
  arProdutos    : array of TArrayProdutos;
  arFamilias    : array of TArrayFamilias;
  ListaProdutos : array of TArrayListaProdutos;
  Colunas       : array of String;
  arrInsert,
  arrUpdate     : array of Integer;
  SQL                 : TFDQuery;
  ListaProdutosInsert : String;
begin

  SetLength(arProdutos, 0);
  SetLength(arFamilias, 0);
  SetLength(arrInsert, 0);
  SetLength(arrUpdate, 0);
  SetLength(ListaProdutos, 0);

  Arquivo := edBuscaArquivoProdutos.Text;

  if Pos(ExtractFileExt(Arquivo), '|.xls|.xlsx|') > 0 then begin

    if not FileExists(Arquivo) then begin
      DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
      Exit;
    end;

    // Cria Excel- OLE Object
    Excel                     := CreateOleObject('Excel.Application');
    FWC                       := TFWConnection.Create;
    F                         := TFAMILIA.Create(FWC);
    P                         := TPRODUTO.Create(FWC);

    try
      FWC.StartTransaction;
      try
        mnImportaProdutos.Clear;
        mnImportaProdutos.Lines.Add('Carregando dados, Aguarde!');
        // Esconde Excel
        Excel.Visible  := False;
        // Abre o Workbook
        Excel.Workbooks.Open(Arquivo);

        Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
        vrow                                  := Excel.ActiveCell.Row;
        vcol                                  := Excel.ActiveCell.Column;
        pbImportaProdutos.MaxValue            := vrow;
        arrData                               := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

        mnImportaProdutos.Lines.Add('Validando arquivo!');

        SetLength(Colunas, 8);
        Colunas[0]     := 'ID_ITEM';
        Colunas[1]     := 'ITEM_NOME';
        Colunas[2]     := 'NM_MARCA';
        Colunas[3]     := 'NM_DEPARTAMENTO';
        Colunas[4]     := 'NM_SETOR';
        Colunas[5]     := 'NM_FAMILIA';
        Colunas[6]     := 'NM_SUBFAMILIA';
        Colunas[7]     := 'PRAZO_FABRICACAO';


        ArqValido := True;
        for I := Low(Colunas) to High(Colunas) do begin
          AchouColuna := False;
          for J := 1 to vcol do begin
            if AnsiUpperCase(Colunas[I]) = AnsiUpperCase(arrData[1, J]) then begin
              AchouColuna := True;
              Break;
            end;
          end;
          if not AchouColuna then begin
            ArqValido := False;
            Break;
          end;
        end;

        if not ArqValido then begin
          Aux := 'Colunas.:';
          for I := Low(Colunas) to High(Colunas) do begin
            if Colunas[I] <> EmptyStr then
              Aux := Aux + sLineBreak + Colunas[I];
          end;

          DisplayMsg(MSG_WAR, 'Arquivo Inválido, Verifique as Colunas!', '', Aux);
          Exit;
        end;

        pbImportaProdutos.Progress  := 0;
        pbImportaProdutos.MaxValue  := vrow;

        mnImportaProdutos.Lines.Add('Capturando Produtos do arquivo!');

        for I := 2 to vrow do begin
          SetLength(arProdutos, Length(arProdutos) + 1);
          arProdutos[High(arProdutos)].ID_PRODUTO := 0;
          for J := 1 to vcol do begin
            if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('ID_ITEM') then
              arProdutos[High(arProdutos)].CODIGO  := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('ITEM_NOME') then
              arProdutos[High(arProdutos)].NOME := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('NM_MARCA') then
              arProdutos[High(arProdutos)].MARCA := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('NM_DEPARTAMENTO') then
              arProdutos[High(arProdutos)].DEPARTAMENTO := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('NM_SETOR') then
              arProdutos[High(arProdutos)].SETOR := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('NM_FAMILIA') then
              arProdutos[High(arProdutos)].FAMILIA := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('NM_SUBFAMILIA') then
              arProdutos[High(arProdutos)].SUBFAMILIA := arrData[I, J]
            else if AnsiUpperCase(arrData[1, J]) = AnsiUpperCase('PRAZO_FABRICACAO') then
              arProdutos[High(arProdutos)].PRAZO_FABRICACAO := arrData[I, J];
          end;
          Application.ProcessMessages;
          pbImportaProdutos.Progress  := I;
        end;

        Aux := EmptyStr;

        if Length(arProdutos) > 0 then begin

          mnImportaProdutos.Lines.Add('Carregando Array de Famílias!');
          //Alimenta o Array para identificação
          F.SelectList('ID > 0');
          if F.Count > 0 then begin
            for I := 0 to F.Count - 1 do begin
              SetLength(arFamilias, Length(arFamilias) + 1);
              arFamilias[High(arFamilias)].ID         := TFAMILIA(F.Itens[I]).ID.Value;
              arFamilias[High(arFamilias)].DESCRICAO  := TFAMILIA(F.Itens[I]).DESCRICAO.Value;
            end;
          end;

          mnImportaProdutos.Lines.Add('Carregando Array de Produtos!');

          SQL := TFDQuery.Create(nil);
          try
            SQL.Connection  := FWC.FDConnection;
            SQL.SQL.Clear;
            SQL.SQL.Add('SELECT ID, SKU, COALESCE(CUSTO_ESTOQUE_FISICO,0) FROM PRODUTO');
            SQL.Open;
            SQL.FetchAll;
            if not SQL.IsEmpty then begin
              SQL.First;
              while not SQL.Eof do begin
                SetLength(ListaProdutos, Length(ListaProdutos) + 1);
                ListaProdutos[High(ListaProdutos)].ID                     := SQL.Fields[0].AsInteger;
                ListaProdutos[High(ListaProdutos)].SKU                    := SQL.Fields[1].AsString;
                ListaProdutos[High(ListaProdutos)].CUSTO_EST_FISICO_ANT   := SQL.Fields[2].AsCurrency;
                SQL.Next;
              end;
            end;
          finally
            FreeAndNil(SQL);
          end;

          mnImportaProdutos.Lines.Add('Identificando Produtos e Famílias!');

          //Identificando Produtos e Famílias
          pbImportaProdutos.Progress  := 0;
          pbImportaProdutos.MaxValue  := High(arProdutos);

          for I := Low(arProdutos) to High(arProdutos) do begin
            if arProdutos[I].CODIGO <> EmptyStr then begin
              if (LeftStr(arProdutos[I].CODIGO,4) <> '345.') then begin
                //Identificando Famílias
                for J := Low(arFamilias) to High(arFamilias) do begin
                  if AnsiUpperCase(arProdutos[I].FAMILIA) = AnsiUpperCase(arFamilias[J].DESCRICAO) then begin
                    arProdutos[I].ID_FAMILIA := arFamilias[J].ID;
                    Break;
                  end;
                end;

                if arProdutos[I].ID_FAMILIA = 0 then begin
                  if Aux = EmptyStr then
                    Aux := 'Família.: ' + arProdutos[I].FAMILIA
                  else
                    Aux := Aux + sLineBreak + 'Família.: ' + arProdutos[I].FAMILIA;
                end;

                //Identificando Produtos
                for J := Low(ListaProdutos) to High(ListaProdutos) do begin
                  if AnsiUpperCase(ListaProdutos[J].SKU) = AnsiUpperCase(arProdutos[I].CODIGO) then begin
                    arProdutos[I].ID_PRODUTO            := ListaProdutos[J].ID;
                    arProdutos[I].CUSTO_EST_FISICO_ANT  := ListaProdutos[J].CUSTO_EST_FISICO_ANT;
                    Break;
                  end;
                end;
              end;
            end;
            pbImportaProdutos.Progress := I;
            Application.ProcessMessages;
          end;
        end;

        if Aux = EmptyStr then begin

          mnImportaProdutos.Lines.Add('Gravando Produtos no Banco de Dados!');

          pbImportaProdutos.Progress  := 0;
          pbImportaProdutos.MaxValue  := High(arProdutos);

          //Começa a Gravação dos Dados no BD
          for I := Low(arProdutos) to High(arProdutos) do begin
            if arProdutos[I].CODIGO <> EmptyStr then begin
              if (LeftStr(arProdutos[I].CODIGO,4) <> '345.') then begin
                P.ClearFields;
                P.SKU.Value                       := arProdutos[I].CODIGO;
                P.NOME.Value                      := arProdutos[I].NOME;
                P.CUSTO_ESTOQUE_FISICO.Value      := arProdutos[I].CUSTO_ESTOQUE_FISICO;
                P.ID_FAMILIA.Value                := arProdutos[I].ID_FAMILIA;
                P.MARCA.Value                     := arProdutos[I].MARCA;
                P.CLASSE.Value                    := arProdutos[I].DEPARTAMENTO;
                P.GRUPO.Value                     := arProdutos[I].SETOR;
                P.SUB_GRUPO.Value                 := arProdutos[I].SUBFAMILIA;
                P.NCM.Value                       := '00';
                P.QUANTIDADE_ESTOQUE_FISICO.Value := 0;
                P.CUSTO_ESTOQUE_FISICO.Value      := 0;
                P.MEDIA_ALTERACAO.Value           := 0;

                if arProdutos[I].ID_PRODUTO = 0 then begin
                  P.ID.isNotNull                  := True;
                  P.SKU.Value                     := arProdutos[I].CODIGO;
                  P.CUSTOANTERIOR.Value           := 0.00;
                  P.CUSTO.Value                   := 0.00;
                  P.ID_FORNECEDORANTERIOR.Value   := 0;
                  P.ID_FORNECEDORNOVO.Value       := 0;
                  P.ID_ULTIMOLOTE.Value           := 0;
                  P.CUSTO_EST_FISICO_ANT.Value    := 0.00;
                  P.Insert;

                  SetLength(arrInsert, Length(arrInsert) + 1);
                  arrInsert[High(arrInsert)]      := P.ID.Value;

                  mnImportaProdutos.Lines.Add('SKU: ' + arProdutos[I].CODIGO + ' - inserido com sucesso!');

                end else begin
                  P.ID.Value                      := arProdutos[I].ID_PRODUTO;
                  if (arProdutos[I].CUSTO_ESTOQUE_FISICO <> arProdutos[I].CUSTO_EST_FISICO_ANT) then
                    P.CUSTO_EST_FISICO_ANT.Value  := arProdutos[I].CUSTO_EST_FISICO_ANT;

                  P.Update;

                  SetLength(arrUpdate, Length(arrUpdate) + 1);
                  arrUpdate[High(arrUpdate)]      := P.ID.Value;

                  mnImportaProdutos.Lines.Add('SKU: ' + arProdutos[I].CODIGO + ' - alterado com sucesso!');
                end;
              end;
            end;
            pbImportaProdutos.Progress  := I;
            Application.ProcessMessages;
          end;

          if Length(arrInsert) > 0 then begin

            ListaProdutosInsert := EmptyStr;
            for I := 0 to High(arrInsert) do begin
              if I = 0 then
                ListaProdutosInsert                                                := IntToStr(arrInsert[I])
              else
                ListaProdutosInsert                                                := ListaProdutosInsert + ',' + IntToStr(arrInsert[I])
            end;

            if Length(Trim(ListaProdutosInsert)) > 0 then begin

              mnImportaProdutos.Lines.Add('Ajustando Fornecedores!');

              SQL               := TFDQuery.Create(nil);
              try
                SQL.Connection  := FWC.FDConnection;

                SQL.ExecSQL('UPDATE PRODUTO SET ID_FORNECEDORNOVO = COALESCE((SELECT F.ID FROM FORNECEDOR F WHERE UPPER(F.NOME) = UPPER(SUB_GRUPO) LIMIT 1),0) WHERE ID IN (' + ListaProdutosInsert + ')');
                SQL.ExecSQL('UPDATE PRODUTO SET ID_FORNECEDORANTERIOR = ID_FORNECEDORNOVO WHERE ID IN (' + ListaProdutosInsert + ')');
              finally
                FreeAndNil(SQL);
              end;
            end;
          end;

          FWC.Commit;

          if Length(arrInsert) > 0 then
            mnImportaProdutos.Lines.Add('Total de produtos inseridos: ' + IntToStr(Length(arrInsert)));
          if Length(arrUpdate) > 0 then
            mnImportaProdutos.Lines.Add('Total de produtos alterados: ' + IntToStr(Length(arrUpdate)));

          DisplayMsg(MSG_OK, 'Produtos Atualizadas com Sucesso!');

          pbImportaProdutos.Progress                                               := 0;

        end else begin
          DisplayMsg(MSG_WAR, 'Referências não encontradas, Verifique!', '', Aux);
          Exit;
        end;
      except
        on E : Exception do begin
          FWC.Rollback;
          DisplayMsg(MSG_ERR, 'Erro ao atualizar Produtos!' + sLineBreak + 'Linha = ' + IntToStr(I) + sLineBreak + ' Coluna = ' + IntToStr(J), '', E.Message);
          Exit;
        end;
      end;
    finally
      arrData                     := Unassigned;
      pbImportaProdutos.Progress  := 0;
      if not VarIsEmpty(Excel) then begin
        Excel.Quit;
        Excel := Unassigned;
      end;
      FreeAndNil(F);
      FreeAndNil(P);
      FreeAndNil(FWC);
      mnImportaProdutos.Lines.Add('Processo de Importação Finalizado!');
    end;
  end;
end;

procedure TfrmImportacao.btImportaAlmoxarifadoClick(Sender: TObject);
const
  xlCellTypeLastCell = $0000000B;
var
  XLSAplicacao,
  AbaXLS,
  Range         : Variant;
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
    Range                                             := XLSAplicacao.WorkSheets[1].Range['A1', XLSAplicacao.WorkSheets[1].Cells[vrow, vcol].Address];
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
  Nome           : String;
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
    Range                                                                      := XLSAplicacao.WorkSheets[1].Range['A1', XLSAplicacao.WorkSheets[1].Cells[vrow, vcol].Address];
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
      FORN.PRAZO_ENTREGA.excelTitulo                                           := 'PrazoEntregaDias';

      FORN.buscaIndicesExcel(edBuscaArquivoFornecedor.Text, XLSAplicacao);

      Count                                                                    := GetPropList(FORN.ClassInfo, tkProperties, @List, False);

      for J := 0 to Pred(Count) do begin
        if (TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(FORN, List[J]^.Name)).excelIndice <= 0) then begin
          DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas:' + sLineBreak +
                                                                               'ID_Forn, ' + sLineBreak +
                                                                               'Nome,' + sLineBreak +
                                                                               'ID_Almoxerifado' + sLineBreak +
                                                                               'PrazoEntregaDias');
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
            pbImportaFornecedor.Progress                      := pbImportaFornecedor.MaxValue;
            Break;
          end else begin
            ALM.SelectList('codigo_e10 = ' + FORN.ID_ALMOXARIFADO.asSQL);
            if ALM.Count > 0 then begin
              FORN.ID_ALMOXARIFADO.Value                      := TALMOXARIFADO(ALM.Itens[0]).ID.Value;

              //Add by Sergio on 24.03.16 -> a Pedido do benhur
              FORN.CNPJ.Value := AjustaTamnhoCNPJ(FORN.CNPJ.Value);

              FORN.SelectList('cnpj = ' + FORN.CNPJ.asSQL);
              if FORN.Count > 0 then begin
                FORN.ID.Value                                 := TFORNECEDOR(FORN.Itens[0]).ID.Value;
                FORN.Update;

                SetLength(arrUpdate, Length(arrUpdate) + 1);
                arrUpdate[High(arrUpdate)]                    := ALM.ID.Value;

                mnImportaFornecedor.Lines.Add('Código: ' + FORN.CNPJ.asString + ' - alterado com sucesso!');
              end else begin
                FORN.STATUS.Value                             := True;
                FORN.ESTOQUEMINIMO.Value                      := 1;
                FORN.ESTOQUEMAXIMO.Value                      := 200;
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
    Range                                                                      := XLSAplicacao.WorkSheets[1].Range[XLSAplicacao.WorkSheets[1].Cells[1, 1], XLSAplicacao.WorkSheets[1].Cells[vrow, vcol].Address];
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
            FORPROD.STATUS.Value                                               := True;
            FORPROD.MOTIVO.Value                                               := '';

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
begin
  if btImportarProdutos.Tag = 0 then begin
    btImportarProdutos.Tag := 1;
    try
      AtualizarProdutos;
    finally
      btImportarProdutos.Tag := 0;
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
