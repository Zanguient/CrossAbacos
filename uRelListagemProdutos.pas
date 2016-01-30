unit uRelListagemProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ImgList;

type
  TfrmRelListagemProdutos = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    rgSaldo: TRadioGroup;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    gbProduto: TGroupBox;
    edProduto: TButtonedEdit;
    edNomeProduto: TEdit;
    gbMarca: TGroupBox;
    edMarca: TEdit;
    gbCategoria: TGroupBox;
    edCategoria: TEdit;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btSairClick(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure edProdutoChange(Sender: TObject);
    procedure edProdutoRightButtonClick(Sender: TObject);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btRelatorioClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SelecionaFornecedor;
    procedure SelecionaProduto;
    procedure Visualizar;
  end;

var
  frmRelListagemProdutos: TfrmRelListagemProdutos;

implementation
uses
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uBeanProduto,
  uMensagem;
{$R *.dfm}

procedure TfrmRelListagemProdutos.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelListagemProdutos.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelListagemProdutos.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRelListagemProdutos.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaFornecedor;
end;

procedure TfrmRelListagemProdutos.edFornecedorRightButtonClick(Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRelListagemProdutos.edProdutoChange(Sender: TObject);
begin
  edNomeProduto.Clear;
end;

procedure TfrmRelListagemProdutos.edProdutoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaProduto;
end;

procedure TfrmRelListagemProdutos.edProdutoRightButtonClick(Sender: TObject);
begin
  SelecionaProduto;
end;

procedure TfrmRelListagemProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelListagemProdutos.SelecionaFornecedor;
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

procedure TfrmRelListagemProdutos.SelecionaProduto;
var
  CON : TFWConnection;
  P   : TPRODUTO;
begin
  CON    := TFWConnection.Create;
  P      := TPRODUTO.Create(CON);
  edNomeProduto.Clear;
  try
    edProduto.Text       := IntToStr(DMUtil.Selecionar(P, edProduto.Text));
    P.SelectList('id = ' + edProduto.Text);
    if P.Count > 0 then
      edNomeProduto.Text := TPRODUTO(P.Itens[0]).NOME.asString;
  finally
    FreeAndNil(P);
    FreeAndNil(CON);
  end;
end;

procedure TfrmRelListagemProdutos.Visualizar;
var
  CON   : TFWConnection;
  SQL   : TFDQuery;
begin
  DisplayMsg(MSG_WAIT, 'Consultando dados...');

  CON                 := TFWConnection.Create;
  SQL                 := TFDQuery.Create(nil);

  try
    try
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.ID,');
      SQL.SQL.Add('	P.SKU,');
      SQL.SQL.Add('	P.NOME,');
      SQL.SQL.Add('	P.MARCA,');
      SQL.SQL.Add('	P.FAMILIA,');
      SQL.SQL.Add('	F.CNPJ,');
      SQL.SQL.Add('	F.NOME,');
      SQL.SQL.Add('	COALESCE(PF.QUANTIDADE,0) AS QUANTIDADE,');
      SQL.SQL.Add('	COALESCE(PF.CUSTO,0) AS CUSTO');
      SQL.SQL.Add('FROM PRODUTO P');
      SQL.SQL.Add('INNER JOIN FORNECEDOR F ON (P.ID_FORNECEDORNOVO = F.ID)');
      SQL.SQL.Add('LEFT JOIN PRODUTOFORNECEDOR PF ON (P.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR) AND (P.ID = PF.ID_PRODUTO) AND (PF.STATUS)');
      SQL.SQL.Add('WHERE 1 = 1');
      if edNomeFornecedor.Text <> '' then
        SQL.SQL.Add('AND F.ID = ' + edFornecedor.Text);
      if edNomeProduto.Text <> '' then
        SQL.SQL.Add('AND P.ID = ' + edProduto.Text);
      if Trim(edMarca.Text) <> '' then
        SQL.SQL.Add('AND UPPER(P.MARCA) = ' + QuotedStr(AnsiUpperCase(Trim(edMarca.Text))));
      if Trim(edCategoria.Text) <> '' then
        SQL.SQL.Add('AND UPPER(P.FAMILIA) = ' + QuotedStr(AnsiUpperCase(Trim(edCategoria.Text))));
      case rgSaldo.ItemIndex of
        0 : SQL.SQL.Add('AND PF.QUANTIDADE > 0 AND PF.CUSTO > 0');
        1 : SQL.SQL.Add('AND NOT ((PF.QUANTIDADE > 0) AND (PF.CUSTO > 0))');
      end;

      SQL.Connection    := CON.FDConnection;
      SQL.Prepare;
      SQL.Open();
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet   := SQL;
      DMUtil.ImprimirRelatorio('frListagemProdutos.fr3');
      DisplayMsgFinaliza;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao consultar dados! Verifique!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(SQL);
    FreeAndNil(CON);
  end;

end;

end.
