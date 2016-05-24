unit uRelAlteracaoCusto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, DateUtils,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ImgList, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelAlteracaoCusto = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    btRelatorio: TSpeedButton;
    btSair: TSpeedButton;
    GroupBox1: TGroupBox;
    edDataInicial: TJvDateEdit;
    edDataFinal: TJvDateEdit;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    edMarca: TEdit;
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFornecedorExit(Sender: TObject);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edFornecedorChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Visualizar;
    procedure SelecionaFornecedor;
  end;

var
  frmRelAlteracaoCusto: TfrmRelAlteracaoCusto;

implementation
uses
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uMensagem;

{$R *.dfm}

{ TfrmRelAlteracaoCusto }

procedure TfrmRelAlteracaoCusto.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelAlteracaoCusto.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelAlteracaoCusto.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRelAlteracaoCusto.edFornecedorExit(Sender: TObject);
begin
  if (edFornecedor.Text = '') or (edFornecedor.Text = '0') then
    edNomeFornecedor.Clear;
end;

procedure TfrmRelAlteracaoCusto.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    selecionaFornecedor;
end;

procedure TfrmRelAlteracaoCusto.edFornecedorRightButtonClick(
  Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRelAlteracaoCusto.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelAlteracaoCusto.FormShow(Sender: TObject);
begin
  edDataInicial.Date := Now;
  edDataFinal.Date   := Now;
end;

procedure TfrmRelAlteracaoCusto.SelecionaFornecedor;
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

procedure TfrmRelAlteracaoCusto.Visualizar;
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
      Consulta.SQL.Add('p.sku,');
      Consulta.SQL.Add('p.marca,');
      Consulta.SQL.Add('COALESCE(mi.custoanterior,0) AS custoanterior,');
      Consulta.SQL.Add('COALESCE(mi.custonovo, 0) AS custonovo,');
      Consulta.SQL.Add('COALESCE(mi.quantidade, 0) AS quantidade,');
      Consulta.SQL.Add('fa.nome,');
      Consulta.SQL.Add('fn.nome');
      Consulta.SQL.Add('FROM match m');
      Consulta.SQL.Add('INNER JOIN match_itens mi ON (m.id = mi.id_match)');
      Consulta.SQL.Add('INNER JOIN fornecedor fa ON (mi.id_fornecedoranterior = fa.id)');
      Consulta.SQL.Add('INNER JOIN fornecedor fn ON (mi.id_fornecedornovo = fn.id)');
      Consulta.SQL.Add('INNER JOIN produto p ON (mi.id_produto = p.id)');
      Consulta.SQL.Add('WHERE CAST(m.data_hora AS DATE) BETWEEN :datai AND :dataf');
      Consulta.SQL.Add('AND mi.atualizado');
      if StrToIntDef(edFornecedor.Text,0) > 0 then
        Consulta.SQL.Add('AND ((fa.id = ' + edFornecedor.Text + ') OR (fn.id = ' + edFornecedor.Text + '))');
      if Trim(edMarca.Text) <> EmptyStr then
        Consulta.SQL.Add('AND p.marca LIKE ' + QuotedStr('%' + edMarca.Text + '%'));

      Consulta.SQL.Add('ORDER BY P.sku');
      Consulta.Connection                     := FWC.FDConnection;
      Consulta.ParamByName('DATAI').DataType  := ftDate;
      Consulta.ParamByName('DATAF').DataType  := ftDate;

      Consulta.Params[0].Value                := edDataInicial.Date;
      Consulta.Params[1].Value                := edDataFinal.Date;

      Consulta.Prepare;
      Consulta.Open;
      Consulta.FetchAll;

      DMUtil.frxDBDataset1.DataSet := Consulta;
      DMUtil.ImprimirRelatorio('frAlteracaoCusto.fr3');
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
