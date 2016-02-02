unit uRelRatingDetalhadoporFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Datasnap.DBClient;

type
  TfrmRelRatingDetalhadoporFornecedor = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    csPesquisa: TClientDataSet;
    csPesquisaFORNECEDOR: TStringField;
    csPesquisaSKU: TStringField;
    csPesquisaPRODUTO: TStringField;
    csPesquisaCUSTOFORNECEDORSEL: TCurrencyField;
    csPesquisaCUSTOFORNECEDOR: TCurrencyField;
    csPesquisaTIPO: TIntegerField;
    csPesquisaFORNECEDORCADASTRO: TStringField;
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SelecionaFornecedor;
    procedure Visualizar;
  end;

var
  frmRelRatingDetalhadoporFornecedor: TfrmRelRatingDetalhadoporFornecedor;

implementation
uses
  uDMUtil,
  uFWConnection,
  uMensagem,
  uBeanFornecedor,
  uBeanProdutoFornecedor,
  uBeanProduto;
{$R *.dfm}

{ TfrmRelRatingDetalhadoporFornecedor }

procedure TfrmRelRatingDetalhadoporFornecedor.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelRatingDetalhadoporFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.edFornecedorChange(
  Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.edFornecedorKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaFornecedor;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.edFornecedorRightButtonClick(
  Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  csPesquisa.Open;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.SelecionaFornecedor;
var
  CON : TFWConnection;
  F   : TFORNECEDOR;
begin
  CON   := TFWConnection.Create;
  F     := TFORNECEDOR.Create(CON);
  try
    edFornecedor.Text   := IntToStr(DMUtil.Selecionar(F, edFornecedor.Text));
    if StrToIntDef(edFornecedor.Text,0) > 0 then begin
      F.SelectList('id = ' + edFornecedor.Text);
      if F.Count > 0 then
        edNomeFornecedor.Text     := TFORNECEDOR(F.Itens[0]).NOME.Value;
    end;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;
end;

procedure TfrmRelRatingDetalhadoporFornecedor.Visualizar;
var
  CON : TFWConnection;
  PF,
  PF1 : TPRODUTOFORNECEDOR;
  P   : TPRODUTO;
  F   : TFORNECEDOR;
  I: Integer;
begin
  if edNomeFornecedor.Text = '' then begin
    DisplayMsg(MSG_WAR, 'Selecione o fornecedor!');
    Exit;
  end;
  DisplayMsg(MSG_WAIT, 'Consultando dados!');

  CON   := TFWConnection.Create;
  PF    := TPRODUTOFORNECEDOR.Create(CON);
  PF1   := TPRODUTOFORNECEDOR.Create(CON);
  P     := TPRODUTO.Create(CON);
  F     := TFORNECEDOR.Create(CON);
  csPesquisa.DisableControls;
  try
    try
      PF.SelectList('id_fornecedor = ' + edFornecedor.Text + ' and status');
      if PF.Count > 0 then begin
        for I := 0 to Pred(PF.Count) do begin

          P.SelectList('id = ' + TPRODUTOFORNECEDOR(PF.Itens[I]).ID_PRODUTO.asString);
          if P.Count > 0 then begin
            F.SelectList('id = ' + TPRODUTO(P.Itens[0]).ID_FORNECEDORNOVO.asString);
            PF1.SelectList('id_produto = ' + TPRODUTOFORNECEDOR(PF.Itens[I]).ID_PRODUTO.asString + ' and status');

            csPesquisa.Append;
            csPesquisaFORNECEDOR.Value              := edNomeFornecedor.Text;
            csPesquisaSKU.Value                     := TPRODUTO(P.Itens[0]).SKU.Value;
            csPesquisaPRODUTO.Value                 := TPRODUTO(P.Itens[0]).NOME.Value;
            csPesquisaCUSTOFORNECEDORSEL.Value      := TPRODUTOFORNECEDOR(PF.Itens[I]).CUSTO.Value;
            csPesquisaFORNECEDORCADASTRO.Value      := TFORNECEDOR(F.Itens[0]).NOME.Value;
            csPesquisaCUSTOFORNECEDOR.Value         := TPRODUTO(P.Itens[0]).CUSTO.Value;
            if PF1.Count > 0 then begin
              if PF1.Count = 1 then
                csPesquisaTIPO.Value                := 2
              else begin
                csPesquisaTIPO.Value                := 0;
                if TPRODUTOFORNECEDOR(PF.Itens[I]).ID_FORNECEDOR.Value <> TFORNECEDOR(F.Itens[0]).ID.Value then
                  csPesquisaTIPO.Value              := 1;
              end;
            end;
          end;
          csPesquisa.Post;
        end;

        csPesquisa.IndexFieldNames                  := csPesquisaTIPO.FieldName;
        DMUtil.frxDBDataset1.DataSet := csPesquisa;
        DMUtil.ImprimirRelatorio('frRatingDetalhadoFornecedor.fr3');
        DisplayMsgFinaliza;
      end;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao consultar dados!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(PF);
    FreeAndNil(PF1);
    FreeAndNil(P);
    FreeAndNil(F);
    FreeAndNil(CON);
    csPesquisa.EnableControls;
    csPesquisa.EmptyDataSet;
  end;
end;

end.
