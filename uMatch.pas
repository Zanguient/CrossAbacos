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
    pnFiltro: TPanel;
    btConsultar: TSpeedButton;
    gdMatch: TDBGrid;
    cbLoteImportacao: TComboBox;
    ds_Match: TDataSource;
    cds_Match: TClientDataSet;
    cds_MatchSKU: TStringField;
    cds_MatchMARCA: TStringField;
    cds_MatchCUSTOANTERIOR: TCurrencyField;
    cds_MatchCUSTOATUAL: TCurrencyField;
    cds_MatchPERCENTUALDIFERENCA: TCurrencyField;
    cds_MatchFORNCECEDORANTERIOR: TStringField;
    cds_MatchFORNECEDORATUAL: TStringField;
    cds_MatchSTATUS: TStringField;
    SaveDialog1: TSaveDialog;
    btRelatorio: TSpeedButton;
    edFiltroSKU: TLabeledEdit;
    edFiltroMarca: TLabeledEdit;
    cds_MatchLOTE: TIntegerField;
    cds_MatchDATAULTIMOLOTE: TDateField;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure gdMatchTitleClick(Column: TColumn);
    procedure cds_MatchCalcFields(DataSet: TDataSet);
    procedure ExportClick(Sender: TObject);
  private
    Procedure CarregaLoteImportacao;
    Procedure ConsultaMatch;
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
  uMensagem;

{$R *.dfm}

{ TfrmMatch }

procedure TfrmMatch.btConsultarClick(Sender: TObject);
begin
  ConsultaMatch;
end;

procedure TfrmMatch.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMatch.CarregaLoteImportacao;
Var
  FWC : TFWConnection;
  LI  : TLOTE;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  LI  := TLOTE.Create(FWC);

  try
    try

      LI.SelectList('','DATA_HORA DESC');
      cbLoteImportacao.Items.Clear;

      if LI.Count > 0 then begin
        for I := 0 to LI.Count - 1 do begin
          cbLoteImportacao.Items.Add(IntToStr(TLOTE(LI.Itens[I]).ID.Value) + ' - ' + FormatDateTime('dd/mm/yyyy', TLOTE(LI.Itens[I]).DATA_HORA.Value));
          if cbLoteImportacao.Items.Count >= 5 then
            Break;
        end;
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
    FreeAndNil(LI);
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

procedure TfrmMatch.ConsultaMatch;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  cds_Match.DisableControls;
  cds_Match.EmptyDataSet;
  try
    SQL.Close;
    SQL.SQL.Clear;
    SQL.SQL.Add('SELECT');
    SQL.SQL.Add('	P.SKU,');
    SQL.SQL.Add('	P.MARCA,');
    SQL.SQL.Add('	5.33 AS CUSTOANTERIOR,');
    SQL.SQL.Add('	7.23 AS CUSTOATUAL,');
    SQL.SQL.Add('	CAST(''Fornec. Anterior'' AS VARCHAR(100)) AS FORNANTERIOR,');
    SQL.SQL.Add('	CAST(''Fornec. Atual'' AS VARCHAR(100)) AS FORNATUAL,');
    SQL.SQL.Add('	CAST(''NÃO ATUALIZADO'' AS VARCHAR(100)) AS STATUS,');
    SQL.SQL.Add('	(SELECT max(LI.DATA_HORA) FROM LOTEIMPORTACAO LI) AS DATAULTIMOLOTE');
    SQL.SQL.Add('FROM PRODUTO P');

    SQL.Connection  := FWC.FDConnection;
    SQL.Transaction := FWC.FDTransaction;
    SQL.Open;

    if not SQL.IsEmpty then begin
      SQL.First;
      while not SQL.Eof do begin
        cds_Match.Append;

        cds_MatchSKU.Value                  := SQL.Fields[0].Value;
        cds_MatchMARCA.Value                := SQL.Fields[1].Value;
        cds_MatchCUSTOANTERIOR.Value        := SQL.Fields[2].Value;
        cds_MatchCUSTOATUAL.Value           := SQL.Fields[3].Value;
        //cds_MatchPERCENTUALDIFERENCA.Value  := SQL.Fields[0].Value;//Percentual Diferença Calculado
        cds_MatchFORNCECEDORANTERIOR.Value  := SQL.Fields[4].Value;
        cds_MatchFORNECEDORATUAL.Value      := SQL.Fields[5].Value;
        cds_MatchSTATUS.Value               := SQL.Fields[6].Value;
        cds_MatchDATAULTIMOLOTE.Value       := SQL.Fields[7].Value;

        cds_Match.Post;
        SQL.Next
      end;
      cds_Match.First;
    end;

  finally
    cds_Match.EnableControls;
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;

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
          Excel.Cells[cds_Match.RecNo + 1,3]  := cds_MatchSTATUS.Value;
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
  end;
end;

procedure TfrmMatch.FormShow(Sender: TObject);
begin
  cds_Match.CreateDataSet;

  //AutoSizeDBGrid(gdPesquisa);

  CarregaLoteImportacao;
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
