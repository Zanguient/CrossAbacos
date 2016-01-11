unit uConsultaMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, Vcl.DBCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  frxClass, frxDMPExport, System.Win.ComObj, Vcl.ComCtrls;

type
  TfrmConsultaMatch = class(TForm)
    Panel2: TPanel;
    pnBotoesVisualizacao: TPanel;
    btSair: TSpeedButton;
    btExport2: TSpeedButton;
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
    cds_MatchDATALOTE: TDateField;
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
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure btFiltrarClick(Sender: TObject);
    procedure ds_MatchItensDataChange(Sender: TObject; Field: TField);
    procedure btRelatorioClick(Sender: TObject);
    procedure btBuscarMatchClick(Sender: TObject);
    procedure cds_MatchItensCalcFields(DataSet: TDataSet);
    procedure cds_MatchItensFilterRecord(DataSet: TDataSet;
      var Accept: Boolean);
    procedure gdMatchItensDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btLimparClick(Sender: TObject);
  private
    Procedure CarregaLote;
    Procedure ConsultaItensMatch;
    Procedure CarregarMatch;
    Procedure LimparTela;
    procedure Filtrar;
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
  uDMUtil, uBeanProduto;

{$R *.dfm}

{ TfrmMatch }

procedure TfrmConsultaMatch.btConsultarClick(Sender: TObject);
begin
  ConsultaItensMatch;
  edTotalizador.Text := IntToStr(cds_MatchItens.RecordCount);
end;

procedure TfrmConsultaMatch.btFiltrarClick(Sender: TObject);
begin
  Filtrar;
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
      SQL.SQL.Add('	CAST(L.DATA_HORA AS DATE) AS DATALOTE,');
      SQL.SQL.Add('	U.NOME AS NOMEUSUARIO,');
      SQL.SQL.Add('	COALESCE((SELECT COUNT(MI.ID) FROM MATCH_ITENS MI WHERE MI.ID_MATCH = M.ID),0) AS QTDIMPORTADOS,');
      SQL.SQL.Add('	COALESCE((SELECT COUNT(MI.ID) FROM MATCH_ITENS MI WHERE MI.ID_MATCH = M.ID AND MI.ATUALIZADO = TRUE),0) AS QTDATUALIZADOS');
      SQL.SQL.Add('FROM LOTE L INNER JOIN MATCH M ON (L.ID = M.ID_LOTE) INNER JOIN USUARIO U ON (M.ID_USUARIO = U.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(L.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.ParamByName('DATAI').DataType   := ftDate;
      SQL.ParamByName('DATAF').DataType   := ftDate;

      //Filtro de Usuário
      if StrToIntDef(edUsuario.Text, -1) > -1 then begin
        SQL.SQL.Add('AND U.ID = :IDUSUARIO');
        SQL.ParamByName('IDUSUARIO').DataType   := ftInteger;
        SQL.ParamByName('IDUSUARIO').Value      := StrToIntDef(edUsuario.Text, 0);
      end;

      //Filtro de Lote
      if StrToIntDef(edLote.Text, -1) > -1 then begin
        SQL.SQL.Add('AND L.ID = :IDLOTE');
        SQL.ParamByName('IDLOTE').DataType    := ftInteger;
        SQL.ParamByName('IDLOTE').Value       := StrToIntDef(edLote.Text, 0);
      end;

      SQL.ParamByName('DATAI').Value := edDataI.Date;
      SQL.ParamByName('DATAF').Value := edDataF.Date;

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
          cds_MatchDATALOTE.Value       := SQL.Fields[2].Value;
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

procedure TfrmConsultaMatch.cds_MatchItensCalcFields(DataSet: TDataSet);
begin
  with DataSet do begin
    FieldByName('PERCENTUALDIFERENCA').Value := 0.00;
    if FieldByName('CUSTOANTERIOR').Value > 0.00 then
      if FieldByName('CUSTOATUAL').Value > 0.00 then
          FieldByName('PERCENTUALDIFERENCA').Value := Trunc((((FieldByName('CUSTOATUAL').Value * 100) / FieldByName('CUSTOANTERIOR').Value) - 100) * 100) / 100.00
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

  FWC           := TFWConnection.Create;
  SQL           := TFDQuery.Create(nil);

  cds_MatchItens.DisableControls;
  cds_MatchItens.EmptyDataSet;

  try
    try

      idMatch   := 0;
      ProdnoLote:= '';

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
        SQL.SQL.Add('	MI.ATUALIZADO AS MATCH');
        SQL.SQL.Add('FROM MATCH M');
        SQL.SQL.Add('INNER JOIN MATCH_ITENS MI ON (M.ID = MI.ID_MATCH)');
        SQL.SQL.Add('INNER JOIN PRODUTO P ON (MI.ID_PRODUTO = P.ID)');
        SQL.SQL.Add('INNER JOIN FORNECEDOR FA ON (MI.ID_FORNECEDORANTERIOR = FA.ID)');
        SQL.SQL.Add('INNER JOIN FORNECEDOR FN ON (MI.ID_FORNECEDORNOVO = FN.ID)');
        SQL.SQL.Add('INNER JOIN LOTE L ON (MI.ID_ULTIMOLOTE = L.ID)');
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
        end;

        SQL.Connection           := FWC.FDConnection;
        SQL.Prepare;
        SQL.Open;
        SQL.FetchAll;

        if not SQL.IsEmpty then begin
          SQL.First;
          while not SQL.Eof do begin
            cds_MatchItens.Append;
            cds_MatchItensSKU.Value                  := SQL.Fields[1].Value;
            cds_MatchItensMARCA.Value                := SQL.Fields[2].Value;
            cds_MatchItensCUSTOANTERIOR.Value        := SQL.Fields[3].Value;
            cds_MatchItensCUSTOATUAL.Value           := SQL.Fields[4].Value;
            cds_MatchItensFORNCECEDORANTERIOR.Value  := SQL.Fields[5].Value;
            cds_MatchItensFORNECEDORNOVO.Value       := SQL.Fields[6].Value;
            cds_MatchItensIDULTIMOLOTE.Value         := SQL.Fields[7].Value;
            cds_MatchItensDATAULTIMOLOTE.Value       := SQL.Fields[8].Value;
            cds_MatchItensATUALIZADONOMATCH.Value    := SQL.Fields[9].Value;
            cds_MatchItensESTANOMATCH.Value          := True;
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
        SQL.SQL.ADD('	P.SKU,');
        SQL.SQL.ADD('	P.MARCA,');
        SQL.SQL.ADD('	P.CUSTOANTERIOR,');
        SQL.SQL.ADD('	P.CUSTO AS CUSTONOVO,');
        SQL.SQL.ADD('	FA.NOME AS FORNECEDORANTERIOR,');
        SQL.SQL.ADD('	FN.NOME AS FORNECEDORNOVO,');
        SQL.SQL.ADD('	L.ID AS IDULTIMOLOTE,');
        SQL.SQL.ADD('	CAST(L.DATA_HORA AS DATE) AS DATAULTIMOLOTE,');
        SQL.SQL.ADD('	FALSE AS MATCH');
        SQL.SQL.ADD('FROM PRODUTO P');
        SQL.SQL.ADD('INNER JOIN LOTE L ON (P.ID_ULTIMOLOTE = L.ID)');
        SQL.SQL.ADD('INNER JOIN FORNECEDOR FA ON (P.ID_FORNECEDORANTERIOR = FA.ID)');
        SQL.SQL.ADD('INNER JOIN FORNECEDOR FN ON (P.ID_FORNECEDORNOVO = FN.ID)');
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
            cds_MatchItensSKU.Value                  := SQL.Fields[0].Value;
            cds_MatchItensMARCA.Value                := SQL.Fields[1].Value;
            cds_MatchItensCUSTOANTERIOR.Value        := SQL.Fields[2].Value;
            cds_MatchItensCUSTOATUAL.Value           := SQL.Fields[3].Value;
            cds_MatchItensFORNCECEDORANTERIOR.Value  := SQL.Fields[4].Value;
            cds_MatchItensFORNECEDORNOVO.Value       := SQL.Fields[5].Value;
            cds_MatchItensIDULTIMOLOTE.Value         := SQL.Fields[6].Value;
            cds_MatchItensDATAULTIMOLOTE.Value       := SQL.Fields[7].Value;
            cds_MatchItensATUALIZADONOMATCH.Value    := SQL.Fields[8].Value;
            cds_MatchItensESTANOMATCH.Value          := False;
            cds_MatchItens.Post;
            SQL.Next
          end;
        end;
      end;
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

procedure TfrmConsultaMatch.ExportClick(Sender: TObject);
Var
  Excel : Variant;
begin

//  if not cds_Match.IsEmpty then begin
//
//
//    cds_Match.DisableControls;
//    Excel := CreateOleObject('Excel.Application');
//
//    try
//
//      Excel.WorkBooks.Add;
//      Excel.WorkBooks[1].WorkSheets[1].Name := 'Estoque';
//      Excel.Visible := False;
//
//      if (Sender as TSpeedButton).Name = 'btExport1' then begin
//
//        Excel.Caption := 'Atualização de Estoque Virtual';
//        Excel.Cells[1,1] := 'SKU';
//        Excel.Cells[1,2] := 'MARCA';
//        Excel.Cells[1,3] := 'STATUS';
//
//        cds_Match.First;
//        While not cds_Match.Eof do begin
//          Excel.Cells[cds_Match.RecNo + 1,1]  := cds_MatchSKU.Value;
//          Excel.Cells[cds_Match.RecNo + 1,2]  := cds_MatchMARCA.Value;
//          cds_Match.Next;
//        end;
//
//        Excel.Range['A1:C1'].Font.Bold       := True;
//      end;
//
//      if (Sender as TSpeedButton).Name = 'btExport2' then begin
//
//      end;
//
//      Excel.Columns.AutoFit;
//      Excel.DisplayAlerts := False;
//
//      if SaveDialog1.Execute then begin
//        Excel.ActiveWorkbook.SaveAs(SaveDialog1.FileName);
//        DisplayMsg(MSG_INF, 'Arquivo Gerado com Sucesso!');
//      end;
//
//    finally
//      Excel.Workbooks.close;
//      Excel.Quit;
//      Excel := Unassigned;
//      cds_Match.EnableControls;
//    end;
//
//  end else
//    DisplayMsg(MSG_WAR, 'Não há Dados a serem Exportados, Verifique!');
//
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

procedure TfrmConsultaMatch.LimparTela;
begin
  edDataI.Date  := Date;
  edDataF.Date  := Date;
  edUsuario.Clear;
  edLote.Clear;
  edFiltro.Clear;
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
  CarregarMatch;
end;

end.
