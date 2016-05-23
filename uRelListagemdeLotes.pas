unit uRelListagemdeLotes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Buttons, FireDAC.Comp.Client, Data.DB;

type
  TfrmRelListagemdeLotes = class(TForm)
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
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure Visualizar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelListagemdeLotes: TfrmRelListagemdeLotes;

implementation

uses
  uFWConnection,
  uMensagem,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelListagemdeLotes.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelListagemdeLotes.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelListagemdeLotes.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelListagemdeLotes.Visualizar;
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
      SQL.SQL.Add('	L.DATA_HORA,');
      SQL.SQL.Add('	COALESCE((SELECT COUNT(DISTINCT IMPI.ID_PRODUTO) FROM IMPORTACAO IMP INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO) WHERE IMP.ID_LOTE = L.ID),0) AS SKU_IMPORTADOS_LOTE,');
      SQL.SQL.Add('	F.NOME AS NOMEFORNECEDOR,');
      SQL.SQL.Add('	COUNT(DISTINCT IMPI.ID_PRODUTO) AS SKU_IMPORTADOS_FORNECEDOR');
      SQL.SQL.Add('FROM LOTE L');
      SQL.SQL.Add('INNER JOIN IMPORTACAO IMP ON (L.ID = IMP.ID_LOTE)');
      SQL.SQL.Add('INNER JOIN FORNECEDOR F ON (IMP.ID_FORNECEDOR = F.ID)');
      SQL.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO)');
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

      SQL.SQL.Add('GROUP BY 1,2,4');
      SQL.SQL.Add('ORDER BY L.ID DESC, F.NOME');

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frListagemLotes.fr3');
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
