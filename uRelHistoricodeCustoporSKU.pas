unit uRelHistoricodeCustoporSKU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, Data.DB, FireDAC.Comp.Client;

type
  TfrmRelHistoricodeCustoporSKU = class(TForm)
    pnPrincipal: TPanel;
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
    gbProduto: TGroupBox;
    edProduto: TButtonedEdit;
    edNomeProduto: TEdit;
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure edProdutoChange(Sender: TObject);
    procedure edProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edProdutoRightButtonClick(Sender: TObject);
  private
    procedure Visualizar;
    procedure SelecionaProduto;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelHistoricodeCustoporSKU: TfrmRelHistoricodeCustoporSKU;

implementation

uses
  uFWConnection,
  uMensagem,
  uDMUtil,
  uBeanProduto;

{$R *.dfm}

procedure TfrmRelHistoricodeCustoporSKU.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelHistoricodeCustoporSKU.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelHistoricodeCustoporSKU.edProdutoChange(Sender: TObject);
begin
  edNomeProduto.Clear;
end;

procedure TfrmRelHistoricodeCustoporSKU.edProdutoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaProduto;
end;

procedure TfrmRelHistoricodeCustoporSKU.edProdutoRightButtonClick(
  Sender: TObject);
begin
  SelecionaProduto;
end;

procedure TfrmRelHistoricodeCustoporSKU.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelHistoricodeCustoporSKU.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelHistoricodeCustoporSKU.SelecionaProduto;
var
  FWC : TFWConnection;
  P   : TPRODUTO;
begin
  FWC    := TFWConnection.Create;
  P      := TPRODUTO.Create(FWC);
  edNomeProduto.Clear;
  try
    edProduto.Text       := IntToStr(DMUtil.Selecionar(P, edProduto.Text));
    P.SelectList('id = ' + edProduto.Text);
    if P.Count > 0 then
      edNomeProduto.Text := TPRODUTO(P.Itens[0]).NOME.asString;
  finally
    FreeAndNil(P);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmRelHistoricodeCustoporSKU.Visualizar;
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
      SQL.SQL.Add('	P.SKU,');
      SQL.SQL.Add('	P.NOME AS NOMEPRODUTO,');
      SQL.SQL.Add('	L.ID AS LOTE,');
      SQL.SQL.Add('	L.DATA_HORA AS DATALOTE,');
      SQL.SQL.Add('	F.NOME AS NOMEFORNECEDOR,');
      SQL.SQL.Add('	IMPI.CUSTO,');
      SQL.SQL.Add('	IMPI.QUANTIDADE AS SALDO');
      SQL.SQL.Add('FROM PRODUTO P');
      SQL.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (P.ID = IMPI.ID_PRODUTO)');
      SQL.SQL.Add('INNER JOIN IMPORTACAO IMP ON (IMPI.ID_IMPORTACAO = IMP.ID)');
      SQL.SQL.Add('INNER JOIN LOTE L ON (IMP.ID_LOTE = L.ID)');
      SQL.SQL.Add('INNER JOIN FORNECEDOR F ON (IMP.ID_FORNECEDOR = F.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(L.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND ((:IDPRODUTO = -1) OR (P.ID = :IDPRODUTO))');
      SQL.SQL.Add('ORDER BY 1,3 DESC,5');

      SQL.ParamByName('IDPRODUTO').DataType := ftInteger;
      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      if Length(Trim(edNomeProduto.Text)) > 0 then
        SQL.ParamByName('IDPRODUTO').Value := StrToIntDef(edProduto.Text, -1)
      else
        SQL.ParamByName('IDPRODUTO').Value := -1;//Exibir todos

      SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
      SQL.ParamByName('DATAF').Value    := edDataFinal.Date;
      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frHistoricodeCustoporSKU.fr3');
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
