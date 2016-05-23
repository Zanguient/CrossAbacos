unit uRelHistoricoporSKU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB;

type
  TfrmRelHistoricoporSKU = class(TForm)
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
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edProdutoChange(Sender: TObject);
    procedure edProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edProdutoRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
  private
    procedure SelecionaProduto;
    procedure Visualizar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelHistoricoporSKU: TfrmRelHistoricoporSKU;

implementation

uses
  uBeanProduto,
  uFWConnection,
  uDMUtil,
  uMensagem;

{$R *.dfm}

procedure TfrmRelHistoricoporSKU.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelHistoricoporSKU.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelHistoricoporSKU.edProdutoChange(Sender: TObject);
begin
  edNomeProduto.Clear;
end;

procedure TfrmRelHistoricoporSKU.edProdutoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaProduto;
end;

procedure TfrmRelHistoricoporSKU.edProdutoRightButtonClick(Sender: TObject);
begin
  SelecionaProduto;
end;

procedure TfrmRelHistoricoporSKU.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelHistoricoporSKU.FormShow(Sender: TObject);
begin
  edProduto.Clear;
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelHistoricoporSKU.SelecionaProduto;
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

procedure TfrmRelHistoricoporSKU.Visualizar;
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
      SQL.SQL.Add('	P.MARCA,');
      SQL.SQL.Add('	FM.DESCRICAO AS CATEGORIA,');
      SQL.SQL.Add('	L.ID AS LOTE,');
      SQL.SQL.Add('	CAST(L.DATA_HORA AS DATE) AS DATA,');
      SQL.SQL.Add('	IMPI.CUSTO,');
      SQL.SQL.Add('	IMPI.QUANTIDADE AS SALDO,');
      SQL.SQL.Add('	F.NOME AS NOMEFORNECEDOR');
      SQL.SQL.Add('FROM LOTE L');
      SQL.SQL.Add('INNER JOIN IMPORTACAO IMP ON (L.ID = IMP.ID_LOTE)');
      SQL.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO)');
      SQL.SQL.Add('INNER JOIN FORNECEDOR F ON (IMP.ID_FORNECEDOR = F.ID)');
      SQL.SQL.Add('INNER JOIN PRODUTO P ON (IMPI.ID_PRODUTO = P.ID)');
      SQL.SQL.Add('INNER JOIN FAMILIA FM ON (P.ID_FAMILIA = FM.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND ((:IDPRODUTO = -1) OR (P.ID = :IDPRODUTO))');
      SQL.SQL.Add('AND CAST(L.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('ORDER BY P.SKU, L.ID DESC, IMPI.CUSTO');

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
      DMUtil.ImprimirRelatorio('frHistoricoporSKU.fr3');
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
