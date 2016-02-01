unit uRelRatingporFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Datasnap.DBClient;

type
  TfrmRatingporFornecedor = class(TForm)
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
    csPesquisaCODIGO: TIntegerField;
    csPesquisaFORNECEDOR: TStringField;
    csPesquisaGANHA: TIntegerField;
    csPesquisaPERDE: TIntegerField;
    csPesquisaUNICO: TIntegerField;
    procedure btSairClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SelecionaFornecedor;
    procedure Visualizar;
  end;

var
  frmRatingporFornecedor: TfrmRatingporFornecedor;

implementation
uses
  uDMUtil,
  uFWConnection,
  uMensagem,
  uBeanFornecedor,
  uBeanProdutoFornecedor;

{$R *.dfm}

procedure TfrmRatingporFornecedor.btRelatorioClick(Sender: TObject);
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

procedure TfrmRatingporFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRatingporFornecedor.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRatingporFornecedor.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaFornecedor;
end;

procedure TfrmRatingporFornecedor.edFornecedorRightButtonClick(Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRatingporFornecedor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRatingporFornecedor.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  csPesquisa.Open;
end;

procedure TfrmRatingporFornecedor.SelecionaFornecedor;
var
  F    : TFORNECEDOR;
  CON  : TFWConnection;
begin
  CON := TFWConnection.Create;
  F   := TFORNECEDOR.Create(CON);
  try
    edFornecedor.Text  := IntToStr(DMUtil.Selecionar(F, edFornecedor.Text));
    if StrToIntDef(edFornecedor.Text,0) > 0 then begin
      F.SelectList('id = ' + edFornecedor.Text);
      if F.Count > 0 then
        edNomeFornecedor.Text   := TFORNECEDOR(F.Itens[0]).NOME.asString;
    end;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;

end;

procedure TfrmRatingporFornecedor.Visualizar;
var
  CON : TFWConnection;
  SQL,
  SQL1,
  SQL2 : TFDQuery;
  F    : TFORNECEDOR;
  PF,
  PF2  : TPRODUTOFORNECEDOR;
  I,
  J,
  K    : Integer;
  Produtos : String;
begin
  csPesquisa.EmptyDataSet;
  DisplayMsg(MSG_WAIT, 'Buscando dados...');

  CON       := TFWConnection.Create;
  F         := TFORNECEDOR.Create(CON);
  PF        := TPRODUTOFORNECEDOR.Create(CON);
  PF2       := TPRODUTOFORNECEDOR.Create(CON);
  SQL       := TFDQuery.Create(nil);
  SQL1      := TFDQuery.Create(nil);
  csPesquisa.DisableControls;
  try
    try
      if edNomeFornecedor.Text <> '' then
        F.SelectList('id = ' + edFornecedor.Text)
      else
        F.SelectList();
      for I := 0 to Pred(F.Count) do begin
        csPesquisa.Append;
        csPesquisaCODIGO.Value    := TFORNECEDOR(F.Itens[I]).ID.Value;
        csPesquisaFORNECEDOR.Value:= TFORNECEDOR(F.Itens[I]).NOME.Value;
        csPesquisaGANHA.Value     := 0;
        csPesquisaPERDE.Value     := 0;
        csPesquisaUNICO.Value     := 0;

        PF.SelectList('id_fornecedor = ' + TFORNECEDOR(F.Itens[I]).ID.asString + ' and status');
        Produtos                  := '';
        for J := 0 to Pred(PF.Count) do begin
          PF2.SelectList('id_produto = ' + TPRODUTOFORNECEDOR(PF.Itens[J]).ID_PRODUTO.asString + ' and status');
          if PF2.Count = 1 then begin
            csPesquisaUNICO.Value  := csPesquisaUNICO.Value + 1;
            if Produtos = '' then
              Produtos := TPRODUTOFORNECEDOR(PF2.Itens[0]).ID_PRODUTO.asString
            else
              Produtos :=Produtos + ', ' + TPRODUTOFORNECEDOR(PF2.Itens[0]).ID_PRODUTO.asString ;
          end;
        end;

        SQL.Close;
        SQL.SQL.Clear;
        SQL.SQL.Add('SELECT COUNT (PF.ID_PRODUTO)');
        SQL.SQL.Add('FROM PRODUTOFORNECEDOR PF');
        SQL.SQL.Add('LEFT JOIN PRODUTO P ON PF.ID_PRODUTO = P.ID AND P.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR AND PF.STATUS');
        SQL.SQL.Add('WHERE PF.ID_FORNECEDOR = :FORNECEDOR');
        SQL.SQL.Add('AND PF.STATUS');
        SQL.SQL.Add('AND PF.ID_PRODUTO NOT IN (' + Produtos + ')');
        SQL.SQL.Add('AND P.ID IS NULL');
        SQL.ParamByName('FORNECEDOR').DataType  := ftInteger;
        SQL.Connection                          := CON.FDConnection;
        SQL.Prepare;
        SQL.Params[0].Value                     := csPesquisaCODIGO.Value;
        SQL.Open();

        if not SQL.IsEmpty then
          csPesquisaPERDE.Value   := SQL.Fields[0].Value;

        SQL1.Close;
        SQL1.SQL.Clear;
        SQL1.SQL.Add('SELECT COUNT (PF.ID_PRODUTO)');
        SQL1.SQL.Add('FROM PRODUTOFORNECEDOR PF');
        SQL1.SQL.Add('LEFT JOIN PRODUTO P ON PF.ID_PRODUTO = P.ID AND P.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR');
        SQL1.SQL.Add('WHERE PF.ID_FORNECEDOR = :FORNECEDOR');
        SQL1.SQL.Add('AND PF.STATUS');
        SQL1.SQL.Add('AND PF.ID_PRODUTO NOT IN (' + Produtos + ')');
        SQL1.SQL.Add('AND NOT P.ID IS NULL');
        SQL1.ParamByName('FORNECEDOR').DataType  := ftInteger;
        SQL1.Connection                          := CON.FDConnection;
        SQL1.Prepare;
        SQL1.Params[0].Value                     := csPesquisaCODIGO.Value;
        SQL1.Open();

        if not SQL1.IsEmpty then
          csPesquisaGANHA.Value   := SQL1.Fields[0].Value;
        csPesquisa.Post;
      end;


      DMUtil.frxDBDataset1.DataSet := csPesquisa;
      DMUtil.ImprimirRelatorio('frRatingFornecedor.fr3');
      DisplayMsgFinaliza;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao consultar dados!', '', E.Message);
      end;
    end;
  finally
    csPesquisa.EnableControls;
    FreeAndNil(F);
    FreeAndNil(PF);
    FreeAndNil(PF2);
    FreeAndNil(SQL);
    FreeAndNil(SQL1);
    FreeAndNil(CON);
  end;

end;

end.
