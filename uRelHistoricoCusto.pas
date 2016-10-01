unit uRelHistoricoCusto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  JvExMask, JvToolEdit, Vcl.Buttons, System.DateUtils, FireDAC.Comp.Client, Data.DB;

type
  TfrmRelHistoricoCusto = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edDataInicial: TJvDateEdit;
    edDataFinal: TJvDateEdit;
    gbProduto: TGroupBox;
    edProduto: TButtonedEdit;
    edNomeProduto: TEdit;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    procedure edProdutoChange(Sender: TObject);
    procedure edProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edProdutoRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SelecionaProduto;
    procedure VisualizarRelatorio;
  end;

var
  frmRelHistoricoCusto: TfrmRelHistoricoCusto;

implementation
uses
  uFWConnection,
  uMensagem,
  uDMUtil,
  uBeanProduto;

{$R *.dfm}

{ TfrmRelHistoricoCusto }

procedure TfrmRelHistoricoCusto.btRelatorioClick(Sender: TObject);
begin
  if btRelatorio.Tag = 0 then begin
    btRelatorio.Tag    := 1;
    try
      VisualizarRelatorio;
    finally
      btRelatorio.Tag  := 0;
    end;
  end;
end;

procedure TfrmRelHistoricoCusto.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelHistoricoCusto.edProdutoChange(Sender: TObject);
begin
  edNomeProduto.Clear;
end;

procedure TfrmRelHistoricoCusto.edProdutoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaProduto;
end;

procedure TfrmRelHistoricoCusto.edProdutoRightButtonClick(Sender: TObject);
begin
  SelecionaProduto;
end;

procedure TfrmRelHistoricoCusto.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    btSairClick(nil);
end;

procedure TfrmRelHistoricoCusto.FormShow(Sender: TObject);
begin
  edDataInicial.Date := StartOfTheMonth(Now);
  edDataFinal.Date   := Date;
end;

procedure TfrmRelHistoricoCusto.SelecionaProduto;
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

procedure TfrmRelHistoricoCusto.VisualizarRelatorio;
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
      SQL.SQL.Add('pr.sku,');
      SQL.SQL.Add('pr.nome,');
      SQL.SQL.Add('u.nome as funcionario,');
      SQL.SQL.Add('p.data_hora,');
      SQL.SQL.Add('pi.custo_atual,');
      SQL.SQL.Add('pi.precopor');
      SQL.SQL.Add('FROM precificacao p');
      SQL.SQL.Add('INNER JOIN usuario u ON p.usuario_id = u.id');
      SQL.SQL.Add('INNER JOIN precificacao_itens pi on pi.precificacao_id = p.id');
      SQL.SQL.Add('INNER JOIN produto pr on pi.id_produto = pr.id');
      SQL.SQL.Add('WHERE CAST(p.data_hora AS DATE) BETWEEN :DATAI AND :DATAF');
      if Length(Trim(edNomeProduto.Text)) > 0 then
        SQL.SQL.Add('AND pr.id = :IDPRODUTO');
      SQL.SQL.Add('ORDER BY pr.sku, p.id');

      if Length(Trim(edNomeProduto.Text)) > 0 then
        SQL.ParamByName('IDPRODUTO').DataType := ftInteger;
      SQL.ParamByName('DATAI').DataType     := ftDate;
      SQL.ParamByName('DATAF').DataType     := ftDate;
      SQL.Connection                        := FWC.FDConnection;
      SQL.Prepare;

      if Length(Trim(edNomeProduto.Text)) > 0 then
        SQL.ParamByName('IDPRODUTO').Value  := StrToIntDef(edProduto.Text, -1);

      SQL.ParamByName('DATAI').Value        := edDataInicial.Date;
      SQL.ParamByName('DATAF').Value        := edDataFinal.Date;
      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frHistoricoCusto.fr3');
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
