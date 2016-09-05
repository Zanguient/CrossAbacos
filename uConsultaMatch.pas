unit uConsultaMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, Vcl.DBCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, DateUtils,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  frxClass, frxDMPExport, System.Win.ComObj, Vcl.ComCtrls, Vcl.Samples.Gauges;

type
  TfrmConsultaMatch = class(TForm)
    Panel2: TPanel;
    pnBotoesVisualizacao: TPanel;
    btSair: TSpeedButton;
    btExport: TSpeedButton;
    pnCabecalho: TPanel;
    gdMatchItens: TDBGrid;
    ds_MatchItens: TDataSource;
    SaveDialog1: TSaveDialog;
    btRelatorio: TSpeedButton;
    pnFiltro: TPanel;
    edFiltro: TEdit;
    btFiltrar: TSpeedButton;
    edTotalizador: TEdit;
    Label1: TLabel;
    edRegistroAtual: TEdit;
    Label2: TLabel;
    gbConsultar: TGroupBox;
    btConsultar: TSpeedButton;
    rgFiltroAtualizacao: TRadioGroup;
    ds_Match: TDataSource;
    cds_Match: TClientDataSet;
    cds_MatchIDMATCH: TIntegerField;
    cds_MatchIDLOTE: TIntegerField;
    cds_MatchNOMEUSUARIO: TStringField;
    cds_MatchQTDIMPORTADOS: TIntegerField;
    cds_MatchQTDATUALIZADOS: TIntegerField;
    cds_MatchItens: TClientDataSet;
    cds_MatchItensSKU: TStringField;
    cds_MatchItensMARCA: TStringField;
    cds_MatchItensCUSTOANTERIOR: TCurrencyField;
    cds_MatchItensCUSTOATUAL: TCurrencyField;
    cds_MatchItensPERCENTUALDIFERENCA: TCurrencyField;
    cds_MatchItensFORNCECEDORANTERIOR: TStringField;
    cds_MatchItensFORNECEDORNOVO: TStringField;
    cds_MatchItensIDULTIMOLOTE: TIntegerField;
    cds_MatchItensDATAULTIMOLOTE: TDateField;
    cds_MatchItensESTANOMATCH: TBooleanField;
    cbProdutosForadoLote: TCheckBox;
    pnFiltroMatch: TPanel;
    gdMatch: TDBGrid;
    btBuscarMatch: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edDataI: TDateTimePicker;
    edDataF: TDateTimePicker;
    edUsuario: TEdit;
    edLote: TEdit;
    cds_MatchItensATUALIZADONOMATCH: TBooleanField;
    btLimpar: TSpeedButton;
    cds_MatchDATAHORAMATCH: TDateTimeField;
    cds_MatchItensID_PRODUTO: TIntegerField;
    pbExportaFornecedor: TGauge;
    cds_MatchItensQUANTIDADE: TIntegerField;
    cds_MatchItensID_FORNECEDORNOVO: TIntegerField;
    cds_MatchItensSTATUS: TBooleanField;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure btFiltrarClick(Sender: TObject);
    procedure ds_MatchItensDataChange(Sender: TObject; Field: TField);
    procedure btRelatorioClick(Sender: TObject);
    procedure btBuscarMatchClick(Sender: TObject);
    procedure cds_MatchItensFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure gdMatchItensDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btLimparClick(Sender: TObject);
    procedure gdMatchItensTitleClick(Column: TColumn);
    procedure btExportClick(Sender: TObject);
  private
    Procedure CarregaLote;
    Procedure ConsultaItensMatch;
    Procedure CarregarMatch;
    Procedure LimparTela;
    procedure Filtrar;
    procedure ExportarProdutos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConsultaMatch: TfrmConsultaMatch;

implementation

uses
  uConstantes,
  uFuncoes,
  uBeanLOTEIMPORTACAO,
  uFWConnection,
  uMensagem,
  uDMUtil,
  uBeanProduto,
  uBeanProdutoFornecedor,
  uBeanFornecedor,
  uBeanFamilia;

{$R *.dfm}

{ TfrmMatch }

procedure TfrmConsultaMatch.btConsultarClick(Sender: TObject);
begin
  if btConsultar.Tag = 0 then begin
    btConsultar.Tag := 1;
    try
      ConsultaItensMatch;
      edTotalizador.Text := IntToStr(cds_MatchItens.RecordCount);
    finally
      btConsultar.Tag := 0;
    end;
  end;
end;

procedure TfrmConsultaMatch.btExportClick(Sender: TObject);
begin
  if btExport.Tag = 0 then begin
    btExport.Tag := 1;
    pbExportaFornecedor.Visible      := True;
    pbExportaFornecedor.MaxValue     := cds_MatchItens.RecordCount;
    pbExportaFornecedor.Progress     := 0;
    try
      ExportarProdutos;
    finally
      btExport.Tag := 0;
      pbExportaFornecedor.Progress   := 0;
    pbExportaFornecedor.Visible      := False;
    end;
  end;
end;

procedure TfrmConsultaMatch.btFiltrarClick(Sender: TObject);
begin
  if btFiltrar.Tag = 0 then begin
    btFiltrar.Tag := 1;
    try
      Filtrar;
    finally
      btFiltrar.Tag := 0;
    end;
  end;
end;

procedure TfrmConsultaMatch.btLimparClick(Sender: TObject);
begin
  LimparTela;
end;

procedure TfrmConsultaMatch.btRelatorioClick(Sender: TObject);
begin
  DMUtil.frxReport1.LoadFromFile('D:\Projetos\CrossAbacos\Relatorios\frMatch.fr3');
  DMUtil.frxReport1.Modified := False;
  DMUtil.frxReport1.ShowReport();
end;

procedure TfrmConsultaMatch.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConsultaMatch.CarregaLote;
Var
  FWC : TFWConnection;
  L  : TLOTE;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  L   := TLOTE.Create(FWC);

  try
    try

//      L.SelectList('','ID DESC LIMIT 5');
//
//      //cbLoteImportacao.Items.Clear;
//
//      if L.Count > 0 then begin
//        for I := 0 to L.Count - 1 do
//          cbLoteImportacao.Items.Add(IntToStr(TLOTE(L.Itens[I]).ID.Value) + ' - ' + FormatDateTime('dd/mm/yyyy', TLOTE(L.Itens[I]).DATA_HORA.Value));
//      end;
//
//      if cbLoteImportacao.Items.Count > 0 then
//        cbLoteImportacao.ItemIndex := 0;

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importação', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    FreeAndNil(L);
    FreeAndNil(FWC);
  end;

end;

procedure TfrmConsultaMatch.CarregarMatch;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
begin

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  try
    try

      cds_Match.EmptyDataSet;

      //SQL BUSCA MATCH
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	M.ID AS IDMATCH,');
      SQL.SQL.Add('	L.ID AS IDLOTE,');
      SQL.SQL.Add('	M.DATA_HORA AS DATAHORAMATCH,');
      SQL.SQL.Add('	U.NOME AS NOMEUSUARIO,');
      SQL.SQL.Add('	COALESCE((SELECT COUNT(MI.ID) FROM MATCH_ITENS MI WHERE MI.ID_MATCH = M.ID),0) AS QTDIMPORTADOS,');
      SQL.SQL.Add('	COALESCE((SELECT COUNT(MI.ID) FROM MATCH_ITENS MI WHERE MI.ID_MATCH = M.ID AND MI.ATUALIZADO = TRUE),0) AS QTDATUALIZADOS');
      SQL.SQL.Add('FROM LOTE L INNER JOIN MATCH M ON (L.ID = M.ID_LOTE) INNER JOIN USUARIO U ON (M.ID_USUARIO = U.ID)');
      SQL.SQL.Add('WHERE 1 = 1');

      if StrToIntDef(edLote.Text, 0) > 0 then begin
        SQL.SQL.Add('AND L.ID = :IDLOTE');
        SQL.ParamByName('IDLOTE').DataType  := ftInteger;
        SQL.ParamByName('IDLOTE').Value     := StrToIntDef(edLote.Text, 0);
      end else begin
        SQL.SQL.Add('AND CAST(L.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
        SQL.ParamByName('DATAI').DataType   := ftDate;
        SQL.ParamByName('DATAF').DataType   := ftDate;
        SQL.ParamByName('DATAI').Value      := edDataI.Date;
        SQL.ParamByName('DATAF').Value      := edDataF.Date;
      end;

      //Filtro de Usuário
      if StrToIntDef(edUsuario.Text, -1) > -1 then begin
        SQL.SQL.Add('AND U.ID = :IDUSUARIO');
        SQL.ParamByName('IDUSUARIO').DataType   := ftInteger;
        SQL.ParamByName('IDUSUARIO').Value      := StrToIntDef(edUsuario.Text, 0);
      end;

      SQL.Connection  := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open;
      SQL.FetchAll;

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          cds_Match.Append;
          cds_MatchIDMATCH.Value        := SQL.Fields[0].Value;
          cds_MatchIDLOTE.Value         := SQL.Fields[1].Value;
          cds_MatchDATAHORAMATCH.Value  := SQL.Fields[2].Value;
          cds_MatchNOMEUSUARIO.Value    := SQL.Fields[3].Value;
          cds_MatchQTDIMPORTADOS.Value  := SQL.Fields[4].Value;
          cds_MatchQTDATUALIZADOS.Value := SQL.Fields[5].Value;
          cds_Match.Post;
          SQL.Next;
        end;
      end;

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Pesquisar os Match', 'ClassName ' + E.ClassName + ' ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmConsultaMatch.cds_MatchItensFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
Var
  I : Integer;
begin
  Accept := False;
  for I := 0 to DataSet.Fields.Count - 1 do begin
    if not DataSet.Fields[I].IsNull then begin
      if Pos(AnsiLowerCase(edFiltro.Text),AnsiLowerCase(DataSet.Fields[I].AsVariant)) > 0 then begin
        Accept := True;
        Break;
      end;
    end;
  end;
end;

procedure TfrmConsultaMatch.ConsultaItensMatch;
Var
  FWC         : TFWConnection;
  SQL         : TFDQuery;
  idMatch     : Integer;
  ProdnoLote  : String;
begin
  DisplayMsg(MSG_WAIT, 'Buscando dados!');

  FWC           := TFWConnection.Create;
  SQL           := TFDQuery.Create(nil);

  cds_MatchItens.DisableControls;
  cds_MatchItens.EmptyDataSet;

  try
    try

      idMatch   := 0;
      ProdnoLote:= '';
      cds_MatchItens.IndexFieldNames := ''; //Limpa uma possível Ordenação

      //Carrega o id do Match se tiver selecionado
      if not cds_Match.IsEmpty then
        idMatch := cds_MatchIDMATCH.Value;

      if idMatch > 0 then begin

        SQL.Close;
        SQL.SQL.Clear;
        SQL.SQL.Add('SELECT');
        SQL.SQL.Add('	P.ID,');
        SQL.SQL.Add('	P.SKU,');
        SQL.SQL.Add('	P.MARCA,');
        SQL.SQL.Add('	MI.CUSTOANTERIOR,');
        SQL.SQL.Add('	MI.CUSTONOVO,');
        SQL.SQL.Add('	FA.NOME AS FORNECEDORANTERIOR,');
        SQL.SQL.Add('	FN.NOME AS FORNECEDORNOVO,');
        SQL.SQL.Add('	L.ID AS IDULTIMOLOTE,');
        SQL.SQL.Add('	CAST(L.DATA_HORA AS DATE) AS DATAULTIMOLOTE,');
        SQL.SQL.Add('	MI.ATUALIZADO AS MATCH,');
        SQL.SQL.Add('	COALESCE(MI.QUANTIDADE,0) AS QUANTIDADE,');
        SQL.SQL.Add('	FN.ID AS ID_FORNECEDORNOVO,');
        SQL.SQL.Add('	COALESCE(PF.STATUS, True) AS STATUS');
        SQL.SQL.Add('FROM MATCH M');
        SQL.SQL.Add('INNER JOIN MATCH_ITENS MI ON (M.ID = MI.ID_MATCH)');
        SQL.SQL.Add('INNER JOIN PRODUTO P ON (MI.ID_PRODUTO = P.ID)');
        SQL.SQL.Add('INNER JOIN FORNECEDOR FA ON (MI.ID_FORNECEDORANTERIOR = FA.ID)');
        SQL.SQL.Add('INNER JOIN FORNECEDOR FN ON (MI.ID_FORNECEDORNOVO = FN.ID)');
        SQL.SQL.Add('INNER JOIN LOTE L ON (MI.ID_ULTIMOLOTE = L.ID)');
        //Change by Sergio on 21.05.16 -> de inner para Left Senão produtos que foram para Fornecedor novo 0(Zero) não aparecem, porque o sku não está vinculado ao Zero
        SQL.SQL.Add('LEFT JOIN PRODUTOFORNECEDOR PF ON (MI.ID_PRODUTO = PF.ID_PRODUTO) AND (MI.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR)');
        SQL.SQL.Add('WHERE 1 = 1');
        SQL.SQL.Add('AND M.ID = :IDMATCH');
        SQL.ParamByName('IDMATCH').DataType   := ftInteger;
        SQL.ParamByName('IDMATCH').Value      := idMatch; //Passa o ID do Match

        //Se o Filtro de Match Atualizado for diferente de Ambos aplica o Filtro
        if rgFiltroAtualizacao.ItemIndex IN [0,1] then begin
          SQL.SQL.Add('AND MI.ATUALIZADO = :ATUALIZADO');
          SQL.ParamByName('ATUALIZADO').DataType  := ftBoolean;
          case rgFiltroAtualizacao.ItemIndex of
            0 : SQL.ParamByName('ATUALIZADO').Value := True;
            1 : SQL.ParamByName('ATUALIZADO').Value := False;
          end;
        end else if rgFiltroAtualizacao.ItemIndex = 2 then begin
          SQL.SQL.Add('AND MI.ID_FORNECEDORANTERIOR <> MI.ID_FORNECEDORNOVO');
        end;

        SQL.Connection           := FWC.FDConnection;
        SQL.Prepare;
        SQL.Open;
        SQL.FetchAll;

        if not SQL.IsEmpty then begin
          SQL.First;
          while not SQL.Eof do begin
            cds_MatchItens.Append;
            cds_MatchItensID_PRODUTO.Value           := SQL.Fields[0].Value;
            cds_MatchItensSKU.Value                  := SQL.Fields[1].Value;
            cds_MatchItensMARCA.Value                := SQL.Fields[2].Value;
            cds_MatchItensCUSTOANTERIOR.Value        := SQL.Fields[3].Value;
            cds_MatchItensCUSTOATUAL.Value           := SQL.Fields[4].Value;
            cds_MatchItensFORNCECEDORANTERIOR.Value  := SQL.Fields[5].Value;
            cds_MatchItensFORNECEDORNOVO.Value       := SQL.Fields[6].Value;
            cds_MatchItensIDULTIMOLOTE.Value         := SQL.Fields[7].Value;
            cds_MatchItensDATAULTIMOLOTE.Value       := SQL.Fields[8].Value;
            cds_MatchItensATUALIZADONOMATCH.Value    := SQL.Fields[9].Value;
            cds_MatchItensPERCENTUALDIFERENCA.Value  := CalculaPercentualDiferenca(cds_MatchItensCUSTOANTERIOR.AsCurrency, cds_MatchItensCUSTOATUAL.AsCurrency);
            cds_MatchItensESTANOMATCH.Value          := True;
            cds_MatchItensQUANTIDADE.Value           := SQL.Fields[10].Value;
            cds_MatchItensID_FORNECEDORNOVO.Value    := SQL.Fields[11].Value;
            cds_MatchItensSTATUS.Value               := SQL.Fields[12].Value;
            cds_MatchItens.Post;

            if Length(Trim(ProdnoLote)) = 0 then
              ProdnoLote := SQL.Fields[0].Value
            else
              ProdnoLote := ProdnoLote + ',' + IntToStr(SQL.Fields[0].Value);

            SQL.Next
          end;
        end;
      end;

      //se estiver marcado itens fora do Lote
      if cbProdutosForadoLote.Checked then begin

        SQL.Close;
        SQL.SQL.Clear;
        SQL.SQL.ADD('SELECT');
        SQL.SQL.ADD('	P.ID,');
        SQL.SQL.ADD('	P.SKU,');
        SQL.SQL.ADD('	P.MARCA,');
        SQL.SQL.ADD('	P.CUSTOANTERIOR,');
        SQL.SQL.ADD('	P.CUSTO AS CUSTONOVO,');
        SQL.SQL.ADD('	FA.NOME AS FORNECEDORANTERIOR,');
        SQL.SQL.ADD('	FN.NOME AS FORNECEDORNOVO,');
        SQL.SQL.ADD('	L.ID AS IDULTIMOLOTE,');
        SQL.SQL.ADD('	CAST(L.DATA_HORA AS DATE) AS DATAULTIMOLOTE,');
        SQL.SQL.ADD('	FALSE AS MATCH,');
        SQL.SQL.ADD(' COALESCE(PF.QUANTIDADE ,0),');
        SQL.SQL.ADD(' FN.ID AS ID_FORNECEDORNOVO');
        SQL.SQL.ADD('FROM PRODUTO P');
        SQL.SQL.ADD('INNER JOIN LOTE L ON (P.ID_ULTIMOLOTE = L.ID)');
        SQL.SQL.ADD('INNER JOIN FORNECEDOR FA ON (P.ID_FORNECEDORANTERIOR = FA.ID)');
        SQL.SQL.ADD('INNER JOIN FORNECEDOR FN ON (P.ID_FORNECEDORNOVO = FN.ID)');
        SQL.SQL.ADD('LEFT JOIN PRODUTOFORNECEDOR PF ON (P.ID = PF.ID_PRODUTO) AND (P.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR) AND (PF.STATUS = TRUE )');
        SQL.SQL.ADD('WHERE 1 = 1');
        if Length(Trim(ProdnoLote)) > 0 then
          SQL.SQL.Add('AND P.ID NOT IN (' + Trim(ProdnoLote) + ')');

        SQL.Connection           := FWC.FDConnection;
        SQL.Prepare;
        SQL.Open;
        SQL.FetchAll;

        if not SQL.IsEmpty then begin
          SQL.First;
          while not SQL.Eof do begin
            cds_MatchItens.Append;
            cds_MatchItensID_PRODUTO.Value           := SQL.Fields[0].Value;
            cds_MatchItensSKU.Value                  := SQL.Fields[1].Value;
            cds_MatchItensMARCA.Value                := SQL.Fields[2].Value;
            cds_MatchItensCUSTOANTERIOR.Value        := SQL.Fields[3].Value;
            cds_MatchItensCUSTOATUAL.Value           := SQL.Fields[4].Value;
            cds_MatchItensFORNCECEDORANTERIOR.Value  := SQL.Fields[5].Value;
            cds_MatchItensFORNECEDORNOVO.Value       := SQL.Fields[6].Value;
            cds_MatchItensIDULTIMOLOTE.Value         := SQL.Fields[7].Value;
            cds_MatchItensDATAULTIMOLOTE.Value       := SQL.Fields[8].Value;
            cds_MatchItensATUALIZADONOMATCH.Value    := SQL.Fields[9].Value;
            cds_MatchItensQUANTIDADE.Value           := SQL.Fields[10].Value;
            cds_MatchItensID_FORNECEDORNOVO.Value    := SQL.Fields[11].Value;
            cds_MatchItensPERCENTUALDIFERENCA.Value  := CalculaPercentualDiferenca(cds_MatchItensCUSTOANTERIOR.AsCurrency, cds_MatchItensCUSTOATUAL.AsCurrency);
            cds_MatchItensESTANOMATCH.Value          := False;
            cds_MatchItensSTATUS.Value               := True;
            cds_MatchItens.Post;
            SQL.Next
          end;
        end;
      end;
      DisplayMsgFinaliza;
    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Consultar Produtos', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    cds_MatchItens.EnableControls;
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmConsultaMatch.ds_MatchItensDataChange(Sender: TObject; Field: TField);
begin
  edRegistroAtual.Text   := IntToStr(cds_MatchItens.RecNo);
end;

procedure TfrmConsultaMatch.ExportarProdutos;
var
  PLANILHA,
  Sheet,
  Range,
  arrData : Variant;
  Linha,
  I       : Integer;
  FWC     : TFWConnection;
  P       : TPRODUTO;
  PF      : TPRODUTOFORNECEDOR;
  F       : TFORNECEDOR;
  FA      : TFAMILIA;
  DirArquivo : String;
Begin

  if Not cds_MatchItens.IsEmpty then begin

    DirArquivo := DirArquivosExcel + FormatDateTime('yyyymmdd', Date);

    if not DirectoryExists(DirArquivo) then begin
      if not ForceDirectories(DirArquivo) then begin
        DisplayMsg(MSG_WAR, 'Não foi possível criar o diretório,' + sLineBreak + DirArquivo + sLineBreak + 'Verifique!');
        Exit;
      end;
    end;

    DirArquivo := DirArquivo + '\Fornecedor.'+ StrZero(IntToStr(HourOf(Now)),2) + '.' + StrZero(IntToStr(MinuteOf(Now)),0) +'.xls';
    if FileExists(DirArquivo) then begin
      DisplayMsg(MSG_CONF, 'Já existe um arquivo em,' + sLineBreak + DirArquivo + sLineBreak +
                            'Deseja Sobreescrever?');
      if ResultMsgModal <> mrYes then
        Exit;

      DeleteFile(DirArquivo);
    end;
    DisplayMsg(MSG_WAIT, 'Buscando informações dos produtos!');
    arrData := VarArrayCreate([1, cds_MatchItens.RecordCount + 1, 1, 65], varVariant);

    FWC     := TFWConnection.Create;
    P       := TPRODUTO.Create(FWC);
    PF      := TPRODUTOFORNECEDOR.Create(FWC);
    F       := TFORNECEDOR.Create(FWC);
    FA      := TFAMILIA.Create(FWC);
    Try
      try

        cds_MatchItens.DisableControls;

        PLANILHA := CreateOleObject('Excel.Application');
        PLANILHA.Caption := 'PRODUTOS';
        PLANILHA.Visible := False;
        PLANILHA.WorkBooks.add(1);
        PLANILHA.Workbooks[1].WorkSheets[1].Name := 'PRODUTOS';
        Sheet := PLANILHA.Workbooks[1].WorkSheets['PRODUTOS'];
        Sheet.Range['A1','BN1'].Font.Bold  := True;
        Sheet.Range['A1','BN1'].Font.Color := clBlue;

        // TITULO DAS COLUNAS
//        arrData[1,1]  := 'CodigoProduto';
//        arrData[1,2]  := 'CodigoProdutoPai';
//        arrData[1,3]  := 'Codigobarras';
//        arrData[1,4]  := 'CodigoFabricante';
//        arrData[1,5]  := 'TipoProduto';
//        arrData[1,6]  := 'NomeProduto';
//        arrData[1,7]  := 'Descricao';
//        arrData[1,8]  := 'DescricaoNotaFiscal';
//        arrData[1,9]  := 'Classe';
//        arrData[1,10] := 'Marca';
//        arrData[1,11] := 'Familia';
//        arrData[1,12] := 'Grupo';
//        arrData[1,13] := 'SubGrupo';
//        arrData[1,14] := 'Peso';
//        arrData[1,15] := 'Comprimento';
//        arrData[1,16] := 'Largura';
//        arrData[1,17] := 'Espessura';
//        arrData[1,18] := 'QtdePorEmbalagem';
//        arrData[1,19] := 'QtdeMinimaEstoque';
//        arrData[1,20] := 'QtdeMaximaEstoque';
//        arrData[1,21] := 'UnidadeMedidaNome';
//        arrData[1,22] := 'UnidadeMedidaAbrev';
//        arrData[1,23] := 'CodigoCategoriaFiscal';
//        arrData[1,24] := 'ClassificacaoFiscal';
//        arrData[1,25] := 'DescritorSimples1';
//        arrData[1,26] := 'DescritorSimples2';
//        arrData[1,27] := 'DescritorSimples3';
//        arrData[1,28] := 'DescritorPreDefinido1';
//        arrData[1,29] := 'DescritorPreDefinido2';
//        arrData[1,30] := 'DescritorPreDefinido3';
//        arrData[1,31] := 'DescricaoComplementar1';
//        arrData[1,32] := 'DescricaoComplementar2';
//        arrData[1,33] := 'DescricaoComplementar3';
//        arrData[1,34] := 'DescricaoComplementar4';
//        arrData[1,35] := 'DescricaoComplementar5';
//        arrData[1,36] := 'DescricaoComplementar6';
//        arrData[1,37] := 'DescricaoComplementar7';
//        arrData[1,38] := 'DescricaoComplementar8';
//        arrData[1,39] := 'DescricaoComplementar9';
//        arrData[1,40] := 'DescricaoComplementar10';
//        arrData[1,41] := 'PrecoTabela1';
//        arrData[1,42] := 'PrecoPromocao1';
//        arrData[1,43] := 'InicioPromocao1';
//        arrData[1,44] := 'TerminoPromocao1';
//        arrData[1,45] := 'PrecoTabela2';
//        arrData[1,46] := 'PrecoPromocao2';
//        arrData[1,47] := 'InicioPromocao2';
//        arrData[1,48] := 'TerminoPromocao2';
//        arrData[1,49] := 'DiasGarantia';
//        arrData[1,50] := 'PrazoEntregaDias';
//        arrData[1,51] := 'ControlaEstoque';
//        arrData[1,52] := 'ProdutoSerBrinde';
//        arrData[1,53] := 'CategoriasSite';
//        arrData[1,54] := 'Interfaces';
//        arrData[1,55] := 'AtributoEstendido1';
//        arrData[1,56] := 'AtributoEstendido2';
//        arrData[1,57] := 'AtributoEstendido3';
//        arrData[1,58] := 'AtributoEstendido4';
//        arrData[1,59] := 'AtributoEstendido5';
//        arrData[1,60] := 'AtributoEstendido6';
//        arrData[1,61] := 'AtributoEstendido7';
//        arrData[1,62] := 'AtributoEstendido8';
//        arrData[1,63] := 'AtributoEstendido9';
//        arrData[1,64] := 'AtributoEstendido10';
//        arrData[1,65] := 'OrigemMercadoria';
        arrData[1,1]  := 'Id do item';
        arrData[1,2]  := 'Departamento';
        arrData[1,3]  := 'Setor';
        arrData[1,4]  := 'Família';
        arrData[1,5]  := 'Sub Família';
        arrData[1,6]  := 'Tp. Abc';
        arrData[1,7]  := 'Fornecedor';
        arrData[1,8]  := 'Cod.Fornecedor (Produto)';
        arrData[1,9]  := 'Ped.Automatico';
        arrData[1,10] := 'Item Fornecedor';
        arrData[1,11] := 'Classe Compra';
        arrData[1,12] := 'Categoria Compra';
        arrData[1,13] := 'Tabela de preço';
        arrData[1,14] := 'Preço unitário';
        arrData[1,15] := 'Apaga tabela de preço';
        arrData[1,16] := 'Qt. Mín. Forn. Pelo Fornec.';
        arrData[1,17] := 'Preço frete';
        arrData[1,18] := 'Situação';
        arrData[1,19] := 'Nome do item';
        arrData[1,20] := 'Peso Unitário';
        arrData[1,21] := 'Peso Bruto';
        arrData[1,22] := 'Altura';
        arrData[1,23] := 'Largura';
        arrData[1,24] := 'Comprimento';
        arrData[1,25] := 'Qt grade';
        arrData[1,26] := 'Prazo Validade';
        arrData[1,27] := 'Prazo Mínimo de Recebimento';
        arrData[1,28] := 'Prazo Alarme Validade';
        arrData[1,29] := 'Prazo Mínimo de Expedição';
        arrData[1,30] := 'Controle de Lote';
        arrData[1,31] := 'Tipo de Lote';
        arrData[1,32] := 'Cod. Agrup';
        arrData[1,33] := 'Fabricante';
        arrData[1,34] := 'Nome do Fabricante';
        arrData[1,35] := 'EAN';
        arrData[1,36] := 'Pz.Garantia Fabric. Meses';
        arrData[1,37] := 'Modelo Fabricante';
        arrData[1,38] := 'Tempo de Reposição';
        arrData[1,39] := 'Dt.Lançamento';
        arrData[1,40] := 'NBM';
        arrData[1,41] := 'Sequencial do NBM';
        arrData[1,42] := 'Procedencia';
        arrData[1,43] := 'Tipo de Transporte';
        arrData[1,44] := 'Observaçao do Item';
        arrData[1,45] := 'Percentual de desconto';
        arrData[1,46] := 'Indicativo de Montagem';
        arrData[1,47] := 'Origem';
        arrData[1,48] := 'Código de Origem';
        arrData[1,49] := 'Id da Filial de vendas';
        arrData[1,50] := 'Ean Preferencial';
        arrData[1,51] := 'Marca';
        arrData[1,52] := 'Controla Venda';
        arrData[1,53] := 'Vendável';
        arrData[1,54] := 'Título no Site';
        arrData[1,55] := 'Descrição';
        arrData[1,56] := 'Tags';

        Linha :=  2;
        cds_MatchItens.First;
        while not cds_MatchItens.Eof do begin

          P.SelectList('ID = ' + cds_MatchItensID_PRODUTO.AsString);

          if (P.Count > 0) then begin
            PF.SelectList('id_produto = ' + TPRODUTO(P.Itens[0]).ID.asString + ' and id_fornecedor = ' + cds_MatchItensID_FORNECEDORNOVO.AsString + ' and status = True');
            if (TPRODUTO(P.Itens[0]).ID_FORNECEDORNOVO.Value <> 0) and (PF.Count > 0) then begin
              arrData[Linha,1]    := TPRODUTO(P.Itens[0]).SKU.Value; //Id do item
              arrData[Linha,2]    := ''; //Departamento
              arrData[Linha,3]    := ''; //Setor
              arrData[Linha,4]    := ''; //Familia
              arrData[Linha,5]    := ''; //Sub Família
              arrData[Linha,6]    := ''; //Tp. Abc
              if cds_MatchItensID_FORNECEDORNOVO.Value > 0 then begin
                F.SelectList('id = ' + cds_MatchItensID_FORNECEDORNOVO.AsString);
                if F.Count > 0 then
                  arrData[Linha,7]    := TFORNECEDOR(F.Itens[0]).CNPJ.Value; //Fornecedor
              end;
              arrData[Linha,8]    := ''; //Cod.Fornecedor (Produto)
              arrData[Linha,8]    := TPRODUTOFORNECEDOR(PF.Itens[0]).COD_PROD_FORNECEDOR.Value; //Cod.Fornecedor (Produto);
              arrData[Linha,9]    := 'S'; //Ped.Automatico
              arrData[Linha,10]   := 'S'; //Item Fornecedor
              arrData[Linha,11]   := ''; //Classe Compra
              arrData[Linha,12]   := ''; //Categoria Compra
              arrData[Linha,13]   := ''; //Tabela de preço
              arrData[Linha,14]   := ''; //Preço unitário
              arrData[Linha,15]   := ''; //Apaga tabela de preço
              arrData[Linha,16]   := ''; //Qt. Mín. Forn. Pelo Fornec.
              arrData[Linha,17]   := ''; //Preço frete
              arrData[Linha,18]   := ''; //Situação
              arrData[Linha,19]   := ''; //Nome do item
              arrData[Linha,20]   := ''; //Peso Unitário
              arrData[Linha,21]   := ''; //Peso Bruto
              arrData[Linha,22]   := ''; //Altura
              arrData[Linha,23]   := ''; //Largura
              arrData[Linha,24]   := ''; //Comprimento
              arrData[Linha,25]   := ''; //Qt grade
              arrData[Linha,26]   := ''; //Prazo Validade
              arrData[Linha,27]   := ''; //Prazo Mínimo de Recebimento
              arrData[Linha,28]   := ''; //Prazo Alarme Validade
              arrData[Linha,29]   := ''; //Prazo Mínimo de Expedição
              arrData[Linha,30]   := ''; //Controle de Lote
              arrData[Linha,31]   := ''; //Tipo de Lote
              arrData[Linha,32]   := ''; //Cod. Agrup
              arrData[Linha,33]   := ''; //Fabricante
              arrData[Linha,34]   := ''; //Nome do Fabricante
              arrData[Linha,35]   := ''; //EAN
              arrData[Linha,36]   := ''; //Pz.Garantia Fabric. Meses
              arrData[Linha,37]   := ''; //Modelo Fabricante
              arrData[Linha,38]   := ''; //Tempo de Reposição
              arrData[Linha,39]   := ''; //Dt.Lançamento
              arrData[Linha,40]   := ''; //NBM
              arrData[Linha,41]   := ''; //Sequencial do NBM
              arrData[Linha,42]   := ''; //Procedencia
              arrData[Linha,43]   := ''; //Tipo de Transporte
              arrData[Linha,44]   := ''; //Observaçao do Item
              arrData[Linha,45]   := ''; //Percentual de desconto
              arrData[Linha,46]   := ''; //Indicativo de Montagem
              arrData[Linha,47]   := ''; //Origem
              arrData[Linha,48]   := ''; //Código de Origem
              arrData[Linha,49]   := ''; //Id da Filial de vendas
              arrData[Linha,50]   := ''; //Ean Preferencial
              arrData[Linha,51]   := ''; //Marca
              arrData[Linha,52]   := ''; //Controla Venda
              arrData[Linha,53]   := ''; //Vendável
              arrData[Linha,54]   := ''; //Título no Site
              arrData[Linha,55]   := ''; //Descrição
              arrData[Linha,56]   := ''; //Tags
              Linha               := Linha + 1;
            end;
          end;

          pbExportaFornecedor.Progress   := cds_MatchItens.RecNo + 1;
          cds_MatchItens.Next;
        end;

        DisplayMsg(MSG_WAIT, 'Salvando dados no arquivo Excel!');

        Range               := Sheet.Range[Sheet.cells[1,1].Address, Sheet.Cells[cds_MatchItens.RecordCount + 1, 65].Address];
        Range.NumberFormat  := '@';
        Range.Value         := arrData;

        PLANILHA.Columns.AutoFit;
        PLANILHA.WorkBooks[1].Sheets[1].SaveAs(DirArquivo, 18);

        DisplayMsg(MSG_OK, 'Arquivo gerado com Sucesso!', '', DirArquivo);

      except
        on E : Exception do begin
          DisplayMsg(MSG_ERR, 'Erro ao Gerar arquivo,' + sLineBreak + DirArquivo);
        end;
      end;
    Finally
      FreeAndNil(P);
      FreeAndNil(PF);
      FreeAndNil(F);
      FreeAndNil(FA);
      FreeAndNil(FWC);
      DisplayMsg(MSG_WAIT, 'Finalizando processo do Excel no Windows!');
      if not VarIsEmpty(PLANILHA) then begin
        PLANILHA.Quit;
        PLANILHA := Unassigned;
      end;
      cds_MatchItens.EnableControls;
      DisplayMsgFinaliza;
    end;
  end else begin
    DisplayMsg(MSG_WAR, 'Não há dados para Geração dos Fornecedores, Verifique!');
  end;
end;

procedure TfrmConsultaMatch.Filtrar;
begin
  cds_MatchItens.Filtered := False;
  cds_MatchItens.Filtered := Length(Trim(edFiltro.Text)) > 0;
  edTotalizador.Text := IntToStr(cds_MatchItens.RecordCount);
end;

procedure TfrmConsultaMatch.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmConsultaMatch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : begin
        Close;
    end;
    VK_RETURN : begin
      if edFiltro.Focused then
        Filtrar;
    end;
  end;
end;

procedure TfrmConsultaMatch.FormShow(Sender: TObject);
begin
  cds_Match.CreateDataSet;
  cds_MatchItens.CreateDataSet;

  edDataI.Date := Date;
  edDataF.Date := Date;

  AutoSizeDBGrid(gdMatch);
  AutoSizeDBGrid(gdMatchItens);

  CarregaLote;
  edTotalizador.Text := IntToStr(cds_MatchItens.RecordCount);
end;

procedure TfrmConsultaMatch.gdMatchItensDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if not cds_MatchItensESTANOMATCH.Value then
    gdMatchItens.Canvas.Font.Color:= clBlack
  else begin
    if cds_MatchItensATUALIZADONOMATCH.Value then
      gdMatchItens.Canvas.Font.Color:= clBlue
    else
      gdMatchItens.Canvas.Font.Color:= clRed;
  end;

  gdMatchItens.DefaultDrawColumnCell( Rect, DataCol, Column, State);
end;

procedure TfrmConsultaMatch.gdMatchItensTitleClick(Column: TColumn);
begin
  OrdenarGrid(Column);
end;

procedure TfrmConsultaMatch.LimparTela;
begin
  edDataI.Date  := Date;
  edDataF.Date  := Date;
  edUsuario.Clear;
  edLote.Clear;

  edFiltro.Clear;
  Filtrar;

  cbProdutosForadoLote.Checked := False;
  cds_Match.EmptyDataSet;
  cds_MatchItens.EmptyDataSet;
  rgFiltroAtualizacao.ItemIndex := 2;
  edRegistroAtual.Text := '0';
  edTotalizador.Text := '0';

  if edDataI.CanFocus then
    edDataI.SetFocus;
end;

procedure TfrmConsultaMatch.btBuscarMatchClick(Sender: TObject);
begin
  if btBuscarMatch.Tag = 0 then begin
    btBuscarMatch.Tag := 1;
    try
      CarregarMatch;
    finally
      btBuscarMatch.Tag := 0;
    end;
  end;
end;

end.
