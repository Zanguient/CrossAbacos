unit uMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Data.DB, Datasnap.DBClient, Vcl.DBCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  frxClass, frxDMPExport, System.Win.ComObj;

type
  TfrmMatch = class(TForm)
    Panel2: TPanel;
    pnBotoesVisualizacao: TPanel;
    btSair: TSpeedButton;
    btExport1: TSpeedButton;
    btExport2: TSpeedButton;
    pnCabecalho: TPanel;
    gdMatch: TDBGrid;
    ds_Match: TDataSource;
    cds_Match: TClientDataSet;
    cds_MatchSKU: TStringField;
    cds_MatchMARCA: TStringField;
    cds_MatchCUSTOANTERIOR: TCurrencyField;
    cds_MatchCUSTOATUAL: TCurrencyField;
    cds_MatchPERCENTUALDIFERENCA: TCurrencyField;
    cds_MatchFORNCECEDORANTERIOR: TStringField;
    cds_MatchFORNECEDORATUAL: TStringField;
    SaveDialog1: TSaveDialog;
    btRelatorio: TSpeedButton;
    cds_MatchLOTE: TIntegerField;
    cds_MatchDATAULTIMOLOTE: TDateField;
    pnFiltro: TPanel;
    edFiltro: TEdit;
    btFiltrar: TSpeedButton;
    edTotalizador: TEdit;
    Label1: TLabel;
    edRegistroAtual: TEdit;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    cbLoteImportacao: TComboBox;
    rgFiltroStatus: TRadioGroup;
    btConsultar: TSpeedButton;
    rgFiltroAtualizacao: TRadioGroup;
    cds_MatchMATCH: TBooleanField;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure gdMatchTitleClick(Column: TColumn);
    procedure cds_MatchCalcFields(DataSet: TDataSet);
    procedure ExportClick(Sender: TObject);
    procedure cds_MatchFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btFiltrarClick(Sender: TObject);
    procedure ds_MatchDataChange(Sender: TObject; Field: TField);
    procedure gdMatchDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    Procedure CarregaLote;
    Procedure ConsultaMatch;
    procedure Filtrar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMatch: TfrmMatch;

implementation

uses
  uConstantes,
  uFuncoes,
  uBeanLOTEIMPORTACAO,
  uFWConnection,
  uMensagem,
  uDMUtil;

{$R *.dfm}

{ TfrmMatch }

procedure TfrmMatch.btConsultarClick(Sender: TObject);
begin
  ConsultaMatch;
  edTotalizador.Text := IntToStr(cds_Match.RecordCount);
end;

procedure TfrmMatch.btFiltrarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TfrmMatch.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMatch.CarregaLote;
Var
  FWC : TFWConnection;
  L  : TLOTE;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  L   := TLOTE.Create(FWC);

  try
    try

      L.SelectList('','ID DESC LIMIT 5');

      cbLoteImportacao.Items.Clear;

      if L.Count > 0 then begin
        for I := 0 to L.Count - 1 do
          cbLoteImportacao.Items.Add(IntToStr(TLOTE(L.Itens[I]).ID.Value) + ' - ' + FormatDateTime('dd/mm/yyyy', TLOTE(L.Itens[I]).DATA_HORA.Value));
      end;

      if cbLoteImportacao.Items.Count > 0 then
        cbLoteImportacao.ItemIndex := 0;

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

procedure TfrmMatch.cds_MatchCalcFields(DataSet: TDataSet);
begin
  with DataSet do begin
    FieldByName('PERCENTUALDIFERENCA').Value := 0.00;
    if FieldByName('CUSTOANTERIOR').Value > 0.00 then begin
      if FieldByName('CUSTOATUAL').Value > 0.00 then begin

        if FieldByName('CUSTOATUAL').Value > FieldByName('CUSTOANTERIOR').Value then
          FieldByName('PERCENTUALDIFERENCA').Value := Trunc((((FieldByName('CUSTOATUAL').Value * 100) / FieldByName('CUSTOANTERIOR').Value) - 100) * 100) / 100.00
        else begin
          if FieldByName('CUSTOATUAL').Value < FieldByName('CUSTOANTERIOR').Value then
            FieldByName('PERCENTUALDIFERENCA').Value := Trunc((100 - ((FieldByName('CUSTOATUAL').Value * 100) / FieldByName('CUSTOANTERIOR').Value)) * 100.00) / 100.00
        end;

      end;
    end;
  end;
end;

procedure TfrmMatch.cds_MatchFilterRecord(DataSet: TDataSet;
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

procedure TfrmMatch.ConsultaMatch;
Var
  FWC           : TFWConnection;
  SQL           : TFDQuery;
  SQLLOTE       : TFDQuery;
  SQLFORNECEDOR : TFDQuery;
  idLote        : Integer;
  AlteraForn    : Boolean;
begin

  FWC           := TFWConnection.Create;
  SQL           := TFDQuery.Create(nil);
  SQLLOTE       := TFDQuery.Create(nil);
  SQLFORNECEDOR := TFDQuery.Create(nil);

  cds_Match.DisableControls;
  cds_Match.EmptyDataSet;
  try

    idLote := StrToIntDef(Copy(cbLoteImportacao.Items[cbLoteImportacao.ItemIndex], 1, (Pos(' - ', cbLoteImportacao.Items[cbLoteImportacao.ItemIndex]) -1)),-1);

    if idLote = -1 then begin
      DisplayMsg(MSG_WAR, 'Não há lote selecionado para Consulta, Verifique!');
      Exit;
    end;

    SQLLOTE.Close;
    SQLLOTE.SQL.Clear;
    SQLLOTE.SQL.Add('SELECT');
    SQLLOTE.SQL.Add('	L.ID,');
    SQLLOTE.SQL.Add('	CAST(L.DATA_HORA AS DATE) AS DATA');
    SQLLOTE.SQL.Add('FROM LOTE L INNER JOIN IMPORTACAO IMP ON (IMP.ID_LOTE = L.ID)');
    SQLLOTE.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID)');
    SQLLOTE.SQL.Add('WHERE IMPI.ID_PRODUTO = :IDPRODUTO AND L.ID <> :IDLOTE AND IMPI.STATUS = 1');
    SQLLOTE.SQL.Add('ORDER BY ID_LOTE DESC');
    SQLLOTE.SQL.Add('LIMIT 1');
    SQLLOTE.Params[0].DataType := ftInteger;
    SQLLOTE.Params[1].DataType := ftInteger;
    SQLLOTE.Connection  := FWC.FDConnection;

    SQLFORNECEDOR.Close;
    SQLFORNECEDOR.SQL.Clear;
    SQLFORNECEDOR.SQL.Add('SELECT');
    SQLFORNECEDOR.SQL.Add('	F.NOME,');
    SQLFORNECEDOR.SQL.Add('	IMPI.CUSTO AS CUSTOATUAL');
    SQLFORNECEDOR.SQL.Add('FROM LOTE L INNER JOIN IMPORTACAO IMP ON (IMP.ID_LOTE = L.ID)');
    SQLFORNECEDOR.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID)');
    SQLFORNECEDOR.SQL.Add('INNER JOIN FORNECEDOR F ON (F.ID = IMP.ID_FORNECEDOR)');
    SQLFORNECEDOR.SQL.Add('WHERE L.ID = :IDLOTE AND IMPI.ID_PRODUTO = :IDPRODUTO AND IMPI.CUSTO > 0');
    SQLFORNECEDOR.SQL.Add('AND IMPI.QUANTIDADE > 0 AND IMPI.STATUS = :STATUS');
    SQLFORNECEDOR.SQL.Add('ORDER BY IMPI.CUSTO ASC');
    SQLFORNECEDOR.Params[0].DataType := ftInteger;
    SQLFORNECEDOR.Params[1].DataType := ftInteger;
    SQLFORNECEDOR.Params[2].DataType := ftInteger;
    SQLFORNECEDOR.Connection  := FWC.FDConnection;

    SQL.Close;
    SQL.SQL.Clear;
    SQL.SQL.Add('SELECT');
    SQL.SQL.Add('	P.ID,');
    SQL.SQL.Add('	P.SKU,');
    SQL.SQL.Add('	P.MARCA,');
    SQL.SQL.Add('	P.CUSTO AS CUSTOANTERIOR,');
    SQL.SQL.Add('	CAST(P.SUB_GRUPO AS VARCHAR(100)) AS FORNANTERIOR');
    if rgFiltroStatus.ItemIndex = 1 then
      SQL.SQL.Add('FROM PRODUTO P WHERE P.ID IN (SELECT IMPI.ID_PRODUTO FROM IMPORTACAO IMP INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID) WHERE IMP.ID_LOTE = :IDLOTE AND IMPI.STATUS = 1)')
    else begin
      SQL.SQL.Add('FROM PRODUTO P WHERE P.ID NOT IN (SELECT IMPI.ID_PRODUTO FROM IMPORTACAO IMP INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID) WHERE IMP.ID_LOTE = :IDLOTE AND IMPI.STATUS = 1)');
      SQL.SQL.Add('AND P.ID IN (SELECT IMPI.ID_PRODUTO FROM IMPORTACAO IMP INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID) WHERE IMP.ID_LOTE = :IDLOTE)');
    end;
    SQL.Params[0].DataType   := ftInteger;
    SQL.Connection           := FWC.FDConnection;
    SQL.Prepare;
    SQL.Params[0].Value      := idLote; //Passa o ID do Lote
    SQL.Open;

    if not SQL.IsEmpty then begin
      SQL.First;
      while not SQL.Eof do begin
        cds_Match.Append;
        cds_MatchSKU.Value                  := SQL.Fields[1].Value;
        cds_MatchMARCA.Value                := SQL.Fields[2].Value;
        cds_MatchCUSTOANTERIOR.Value        := SQL.Fields[3].Value;
        cds_MatchCUSTOATUAL.Value           := SQL.Fields[3].Value;
        cds_MatchFORNCECEDORANTERIOR.Value  := SQL.Fields[4].Value;
        cds_MatchFORNECEDORATUAL.Value      := SQL.Fields[4].Value;
        cds_MatchMATCH.Value                := False;

        //Carrega o último Lote
        SQLLOTE.Close;
        SQLLOTE.Prepare;
        SQLLOTE.Params[0].Value := SQL.Fields[0].Value; //Passa o IDPRODUTO
        SQLLOTE.Params[1].Value := idLote; //Passa o IDLOTE
        SQLLOTE.Open;
        if not SQLLOTE.IsEmpty then begin
          cds_MatchLOTE.Value                 := SQLLOTE.Fields[0].Value;
          cds_MatchDATAULTIMOLOTE.Value       := SQLLOTE.Fields[1].Value;
        end;

        //Verifica se tem Fornecedor com Custo Menor
        SQLFORNECEDOR.Close;
        SQLFORNECEDOR.Prepare;
        SQLFORNECEDOR.Params[0].Value := idLote; //Passa o IDLOTE
        SQLFORNECEDOR.Params[1].Value := SQL.Fields[0].Value; //Passa o IDPRODUTO
        SQLFORNECEDOR.Params[2].Value := rgFiltroStatus.ItemIndex; //Passa o Filtro de Status
        SQLFORNECEDOR.Open;

        if not SQLFORNECEDOR.IsEmpty then begin

          AlteraForn := False;

          SQLFORNECEDOR.First;
          while not SQLFORNECEDOR.Eof do begin
            if AnsiUpperCase(SQLFORNECEDOR.Fields[0].Value) = AnsiUpperCase(cds_MatchFORNCECEDORANTERIOR.Value) then begin
              AlteraForn := True;
              Break;
            end;
            SQLFORNECEDOR.Next;
          end;

          SQLFORNECEDOR.First;
          if ((AlteraForn) AND (SQLFORNECEDOR.Fields[1].Value < cds_MatchCUSTOATUAL.Value)) then begin
            cds_MatchFORNECEDORATUAL.Value  := SQLFORNECEDOR.Fields[0].Value;
            cds_MatchCUSTOATUAL.Value       := SQLFORNECEDOR.Fields[1].Value;
            cds_MatchMATCH.Value            := True;
          end;
        end;

        case rgFiltroAtualizacao.ItemIndex of
          0 : begin
            if cds_MatchMATCH.Value then
              cds_Match.Post
            else
              cds_Match.Cancel;
          end;
          1 : begin
            if cds_MatchMATCH.Value then
              cds_Match.Cancel
            else
              cds_Match.Post;

          end;
          2 : cds_Match.Post;

        end;

        SQL.Next
      end;
      cds_Match.First;
    end;

  finally
    cds_Match.EnableControls;
    FreeAndNil(SQLFORNECEDOR);
    FreeAndNil(SQLLOTE);
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;

end;

procedure TfrmMatch.ds_MatchDataChange(Sender: TObject; Field: TField);
begin
  edRegistroAtual.Text   := IntToStr(cds_Match.RecNo);
end;

procedure TfrmMatch.ExportClick(Sender: TObject);
Var
  Excel : Variant;
begin

  if not cds_Match.IsEmpty then begin


    cds_Match.DisableControls;
    Excel := CreateOleObject('Excel.Application');

    try

      Excel.WorkBooks.Add;
      Excel.WorkBooks[1].WorkSheets[1].Name := 'Estoque';
      Excel.Visible := False;

      if (Sender as TSpeedButton).Name = 'btExport1' then begin

        Excel.Caption := 'Atualização de Estoque Virtual';
        Excel.Cells[1,1] := 'SKU';
        Excel.Cells[1,2] := 'MARCA';
        Excel.Cells[1,3] := 'STATUS';

        cds_Match.First;
        While not cds_Match.Eof do begin
          Excel.Cells[cds_Match.RecNo + 1,1]  := cds_MatchSKU.Value;
          Excel.Cells[cds_Match.RecNo + 1,2]  := cds_MatchMARCA.Value;
          cds_Match.Next;
        end;

        Excel.Range['A1:C1'].Font.Bold       := True;
      end;

      if (Sender as TSpeedButton).Name = 'btExport2' then begin

      end;

      Excel.Columns.AutoFit;
      Excel.DisplayAlerts := False;

      if SaveDialog1.Execute then begin
        Excel.ActiveWorkbook.SaveAs(SaveDialog1.FileName);
        DisplayMsg(MSG_INF, 'Arquivo Gerado com Sucesso!');
      end;

    finally
      Excel.Workbooks.close;
      Excel.Quit;
      Excel := Unassigned;
      cds_Match.EnableControls;
    end;

  end else
    DisplayMsg(MSG_WAR, 'Não há Dados a serem Exportados, Verifique!');

end;

procedure TfrmMatch.Filtrar;
begin
  cds_Match.Filtered := False;
  cds_Match.Filtered := Length(Trim(edFiltro.Text)) > 0;
  edTotalizador.Text := IntToStr(cds_Match.RecordCount);
end;

procedure TfrmMatch.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmMatch.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfrmMatch.FormShow(Sender: TObject);
begin
  cds_Match.CreateDataSet;

  //AutoSizeDBGrid(gdPesquisa);

  CarregaLote;
  edTotalizador.Text := IntToStr(cds_Match.RecordCount);
end;

procedure TfrmMatch.gdMatchDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin

  if cds_MatchMATCH.Value then
    gdMatch.Canvas.Font.Color:= clBlue
  else
    gdMatch.Canvas.Font.Color:= clRed;

  gdMatch.DefaultDrawColumnCell( Rect, DataCol, Column, State);
end;

procedure TfrmMatch.gdMatchTitleClick(Column: TColumn);
Var
  I : Integer;
begin

  if (Column.Field.FieldKind <> fkCalculated) then begin

    cds_Match.IndexFieldNames := Column.FieldName;

    for I := 0 to gdMatch.Columns.Count -1 do begin
      if gdMatch.Columns[I].Color <> clWhite then begin
        gdMatch.Columns[I].Color := clWhite;
      end;
    end;
    Column.Color := clLime;
  end;
end;

end.
