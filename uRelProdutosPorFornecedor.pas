unit uRelProdutosPorFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, DateUtils,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ImgList, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelProdutoPorFornecedor = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    btRelatorio: TSpeedButton;
    btSair: TSpeedButton;
    rgSaldo: TRadioGroup;
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
  frmRelProdutoPorFornecedor: TfrmRelProdutoPorFornecedor;

implementation
uses
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uMensagem;

{$R *.dfm}

{ TfrmRelAlteracaoCusto }

procedure TfrmRelProdutoPorFornecedor.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelProdutoPorFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelProdutoPorFornecedor.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRelProdutoPorFornecedor.edFornecedorExit(Sender: TObject);
begin
  if (edFornecedor.Text = '') or (edFornecedor.Text = '0') then
    edNomeFornecedor.Clear;
end;

procedure TfrmRelProdutoPorFornecedor.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    selecionaFornecedor;
end;

procedure TfrmRelProdutoPorFornecedor.edFornecedorRightButtonClick(
  Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRelProdutoPorFornecedor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelProdutoPorFornecedor.SelecionaFornecedor;
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

procedure TfrmRelProdutoPorFornecedor.Visualizar;
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
      Consulta.SQL.Add('f.id,');
      Consulta.SQL.Add('f.nome as fornecedor,');
      Consulta.SQL.Add('p.sku,');
      Consulta.SQL.Add('pf.cod_prod_fornecedor,');
      Consulta.SQL.Add('pf.custo,');
      Consulta.SQL.Add('pf.quantidade,');
      Consulta.SQL.Add('p.nome,');
      Consulta.SQL.Add('p.marca,');
      Consulta.SQL.Add('fa.descricao as familia,');
      Consulta.SQL.Add('f.prazo_entrega,');
      Consulta.SQL.Add('pf.status');
      Consulta.SQL.Add('FROM produto p');
      Consulta.SQL.Add('INNER JOIN produtofornecedor pf ON (p.id = pf.id_produto)');
      Consulta.SQL.Add('INNER JOIN fornecedor f ON (pf.id_fornecedor = f.id)');
      Consulta.SQL.Add('INNER JOIN familia fa ON (p.id_familia = fa.id)');
      Consulta.SQL.Add('WHERE 1 = 1');
      if StrToIntDef(edFornecedor.Text,0) > 0 then
        Consulta.SQL.Add('AND f.id = ' + edFornecedor.Text);
      case rgSaldo.ItemIndex of
        0 : Consulta.SQL.Add('AND pf.quantidade > 0');
        1 : Consulta.SQL.Add('AND pf.quantidade = 0');
      end;

      Consulta.SQL.Add('ORDER BY f.id, p.sku');
      Consulta.Connection                     := FWC.FDConnection;

      Consulta.Prepare;
      Consulta.Open;
      Consulta.FetchAll;

      DMUtil.frxDBDataset1.DataSet := Consulta;
      DMUtil.ImprimirRelatorio('frProdutosPorFornecedor.fr3');
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
