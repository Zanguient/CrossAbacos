unit uRelItensdoFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ImgList;

type
  TfrmRelItensdoFornecedor = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    rgSaldo: TRadioGroup;
    rgStatus: TRadioGroup;
    GridPanel1: TGridPanel;
    ImageList1: TImageList;
    Panel1: TPanel;
    Panel2: TPanel;
    btRelatorio: TSpeedButton;
    btSair: TSpeedButton;
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFornecedorExit(Sender: TObject);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edFornecedorChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Visualizar;
    procedure SelecionaFornecedor;
  end;

var
  frmRelItensdoFornecedor: TfrmRelItensdoFornecedor;

implementation
uses
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uMensagem;

{$R *.dfm}

{ TfrmRelItensdoFornecedor }

procedure TfrmRelItensdoFornecedor.btRelatorioClick(Sender: TObject);
begin
  if btRelatorio.Tag = 0 then begin
    btRelatorio.Tag := 1;
    try
      Visualizar;
    finally
      btRelatorio.Tag := 0;
    end;
  end;


end;

procedure TfrmRelItensdoFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelItensdoFornecedor.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRelItensdoFornecedor.edFornecedorExit(Sender: TObject);
begin
  if (edFornecedor.Text = '') or (edFornecedor.Text = '0') then
    edNomeFornecedor.Clear;
end;

procedure TfrmRelItensdoFornecedor.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    selecionaFornecedor;
end;

procedure TfrmRelItensdoFornecedor.edFornecedorRightButtonClick(
  Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRelItensdoFornecedor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelItensdoFornecedor.SelecionaFornecedor;
var
  CON : TFWConnection;
  F   : TFORNECEDOR;
begin
  CON                       := TFWConnection.Create;
  F                         := TFORNECEDOR.Create(CON);
  edNomeFornecedor.Text     := '';
  try
    edFornecedor.Text       := IntToStr(DMUtil.Selecionar(F, edFornecedor.Text));
    F.SelectList('id = ' + edFornecedor.Text);
    if F.Count > 0 then
      edNomeFornecedor.Text := TFORNECEDOR(F.Itens[0]).NOME.asString;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;
end;

procedure TfrmRelItensdoFornecedor.Visualizar;
var
  FWC       : TFWConnection;
  Consulta  : TFDQuery;
begin
  DisplayMsg(MSG_WAIT, 'Buscando dados para visualizar!');

  FWC       := TFWConnection.Create;
  Consulta  := TFDQuery.Create(nil);

  try
    try

      Consulta.Close;
      Consulta.SQL.Clear;
      Consulta.SQL.Add('SELECT');
      Consulta.SQL.Add('	P.SKU,');
      Consulta.SQL.Add('	PF.COD_PROD_FORNECEDOR AS CODIGOFORNECEDOR,');
      Consulta.SQL.Add('	F.NOME AS NOMEFORNECEDOR,');
      Consulta.SQL.Add('	PF.QUANTIDADE,');
      Consulta.SQL.Add('	PF.CUSTO');
      Consulta.SQL.Add('FROM PRODUTOFORNECEDOR PF');
      Consulta.SQL.Add('INNER JOIN PRODUTO P ON (P.ID = PF.ID_PRODUTO)');
      Consulta.SQL.Add('INNER JOIN FORNECEDOR F ON (F.ID = PF.ID_FORNECEDOR)');
      Consulta.SQL.Add('WHERE 1 = 1');
      if StrToIntDef(edFornecedor.Text,0) > 0 then
        Consulta.SQL.Add('AND F.ID = ' + edFornecedor.Text);
      case rgSaldo.ItemIndex of
        0 : Consulta.SQL.Add('AND PF.QUANTIDADE > 0');
        1 : Consulta.SQL.Add('AND PF.QUANTIDADE = 0');
      end;
      case rgStatus.ItemIndex of
        0 : Consulta.SQL.Add('AND PF.STATUS');
        1 : Consulta.SQL.Add('AND NOT PF.STATUS');
      end;
      Consulta.SQL.Add('ORDER BY P.SKU, F.ID');
      Consulta.Connection           := FWC.FDConnection;
      Consulta.Prepare;
      Consulta.Open;
      Consulta.FetchAll;

      DMUtil.frxDBDataset1.DataSet := Consulta;
      DMUtil.ImprimirRelatorio('frProdutosFornecedor.fr3');
      DisplayMsgFinaliza;
    Except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros na consulta!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(Consulta);
    FreeAndNil(FWC);
  end;
end;

end.
