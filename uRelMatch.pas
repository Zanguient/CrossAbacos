unit uRelMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB;

type
  TfrmRelMatch = class(TForm)
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    gbSelecionaPeriodo: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edDataInicial: TDateTimePicker;
    edDataFinal: TDateTimePicker;
    gbLote: TGroupBox;
    edLote: TEdit;
    procedure btSairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure Visualizar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelMatch: TfrmRelMatch;

implementation

uses
  uFWConnection,
  uDMUtil,
  uMensagem;

{$R *.dfm}

procedure TfrmRelMatch.btRelatorioClick(Sender: TObject);
begin
  if btRelatorio.Tag = 0 then begin
    btRelatorio.Tag   := 1;
    try
      Visualizar;
    finally
      btRelatorio.Tag := 0;
    end;
  end;
end;

procedure TfrmRelMatch.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelMatch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelMatch.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelMatch.Visualizar;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
begin

  DisplayMsg(MSG_WAIT, 'Buscando dados...');

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  try
    try

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	L.ID AS LOTE,');
      SQL.SQL.Add('	CAST(L.DATA_HORA AS DATE) AS DATALOTE,');
      SQL.SQL.Add('	U.ID AS IDUSUARIO,');
      SQL.SQL.Add('	U.NOME AS NOMEUSUARIO,');
      SQL.SQL.Add('	M.DATA_HORA AS DATAHORAMATCH');
      SQL.SQL.Add('FROM LOTE L');
      SQL.SQL.Add('INNER JOIN MATCH M ON (L.ID = M.ID_LOTE)');
      SQL.SQL.Add('INNER JOIN USUARIO U ON (M.ID_USUARIO = U.ID)');
      SQL.SQL.Add('WHERE 1 = 1');

      if StrToIntDef(edLote.Text, 0) = 0 then begin
        SQL.SQL.Add('AND CAST(L.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
        SQL.ParamByName('DATAI').DataType   := ftDate;
        SQL.ParamByName('DATAF').DataType   := ftDate;
        SQL.ParamByName('DATAI').Value      := edDataInicial.Date;
        SQL.ParamByName('DATAF').Value      := edDataFinal.Date
      end else begin
        SQL.SQL.Add('AND L.ID = :IDLOTE');
        SQL.ParamByName('IDLOTE').DataType  := ftInteger;
        SQL.ParamByName('IDLOTE').Value     := StrToIntDef(edLote.Text,0);
      end;

      SQL.SQL.Add('ORDER BY L.ID DESC, M.DATA_HORA');

      SQL.Connection                    := FWC.FDConnection;
      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frListagemMatch.fr3');
      DisplayMsgFinaliza;

    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao buscar dados!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;
end;

end.
