unit uRelListagemFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ImgList, Datasnap.DBClient;

type
  TfrmRelListagemFornecedor = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    csFornecedores: TClientDataSet;
    csFornecedoresNOME: TStringField;
    csFornecedoresCNPJ: TStringField;
    csFornecedoresDATAULTIMAATUA: TDateTimeField;
    csFornecedoresDATALOTE: TDateTimeField;
    csFornecedoresQUANTIDADE: TIntegerField;
    csFornecedoresSALDO: TIntegerField;
    csFornecedoresTICKET: TCurrencyField;
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  frmRelListagemFornecedor: TfrmRelListagemFornecedor;

implementation
uses
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uMensagem;
{$R *.dfm}

{ TfrmRelListagemFornecedor }

procedure TfrmRelListagemFornecedor.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelListagemFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelListagemFornecedor.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmRelListagemFornecedor.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaFornecedor;
end;

procedure TfrmRelListagemFornecedor.edFornecedorRightButtonClick(
  Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmRelListagemFornecedor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelListagemFornecedor.FormShow(Sender: TObject);
begin
  csFornecedores.CreateDataSet;
  csFornecedores.Open;
end;

procedure TfrmRelListagemFornecedor.SelecionaFornecedor;
var
  CON : TFWConnection;
  F   : TFORNECEDOR;
begin
  CON   := TFWConnection.Create;
  F     := TFORNECEDOR.Create(CON);
  try
    edFornecedor.Text := IntToStr(DMUtil.Selecionar(F, edFornecedor.Text));
    F.SelectList('id = ' + edFornecedor.Text);
    if F.Count > 0 then
      edNomeFornecedor.Text  := TFORNECEDOR(F.Itens[0]).NOME.Value;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;
end;

procedure TfrmRelListagemFornecedor.Visualizar;
var
  CON  : TFWConnection;
  F    : TFORNECEDOR;
  SQL,
  SQL2 : TFDQuery;
  I    : Integer;
begin
  DisplayMsg(MSG_WAIT, 'Buscando dados...');
  CON     := TFWConnection.Create;
  F       := TFORNECEDOR.Create(CON);
  SQL     := TFDQuery.Create(nil);
  SQL2    := TFDQuery.Create(nil);

  csFornecedores.EmptyDataSet;
  try
    try
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	I.ID AS IMPORTACAO,');
      SQL.SQL.Add('	I.DATA_HORA AS DATAIMPORTACAO,');
      SQL.SQL.Add('	L.DATA_HORA AS DATALOTE,');
      SQL.SQL.Add('	COUNT(*) AS QUANTIDADE');
      SQL.SQL.Add('FROM LOTE L');
      SQL.SQL.Add('INNER JOIN IMPORTACAO I ON L.ID = I.ID_LOTE');
      SQL.SQL.Add('INNER JOIN IMPORTACAO_ITENS II ON I.ID = II.ID_IMPORTACAO');
      SQL.SQL.Add('WHERE II.STATUS = 1');
      SQL.SQL.Add('AND I.ID_FORNECEDOR = :FORNECEDOR');
      SQL.SQL.Add('GROUP BY 1,2,3');
      SQL.SQL.Add('ORDER BY I.DATA_HORA DESC');
      SQL.SQL.Add('LIMIT 1');
      SQL.ParamByName('FORNECEDOR').DataType  := ftInteger;
      SQL.Connection                          := CON.FDConnection;
      SQL.Prepare;

      SQL2.Close;
      SQL2.SQL.Clear;
      SQL2.SQL.Add('SELECT');
      SQL2.SQL.Add('COUNT(COALESCE(II.QUANTIDADE,0)),');
      SQL2.SQL.Add('COALESCE(AVG(II.CUSTO),0)');
      SQL2.SQL.Add('FROM IMPORTACAO_ITENS II');
      SQL2.SQL.Add('WHERE II.STATUS = 1');
      SQL2.SQL.Add('AND II.QUANTIDADE > 0 AND II.CUSTO > 0');
      SQL2.SQL.Add('AND II.ID_IMPORTACAO = :IMPORTACAO');
      SQL2.ParamByName('IMPORTACAO').DataType  := ftInteger;
      SQL2.Connection                          := CON.FDConnection;
      SQL2.Prepare;

      if edNomeFornecedor.Text = '' then
        F.SelectList('','ID')
      else
        F.SelectList('ID = ' + edFornecedor.Text,'ID');

      if F.Count > 0 then begin
        for I := 0 to Pred(F.Count) do begin
          SQL.Close;
          SQL.Params[0].Value                     := TFORNECEDOR(F.Itens[I]).ID.Value;
          SQL.Open();
          csFornecedores.Append;
          csFornecedoresNOME.Value                := TFORNECEDOR(F.Itens[I]).NOME.Value;
          csFornecedoresCNPJ.Value                := TFORNECEDOR(F.Itens[I]).CNPJ.Value;
          csFornecedoresDATAULTIMAATUA.Value      := 0;
          csFornecedoresDATALOTE.Value            := 0;
          csFornecedoresQUANTIDADE.Value          := 0;
          csFornecedoresSALDO.Value               := 0;
          csFornecedoresTICKET.Value              := 0;
          if SQL.RecordCount > 0 then begin
            csFornecedoresDATAULTIMAATUA.Value    := SQL.Fields[1].Value;
            csFornecedoresDATALOTE.Value          := SQL.Fields[2].Value;
            csFornecedoresQUANTIDADE.Value        := SQL.Fields[3].Value;
            SQL2.Close;
            SQL2.Params[0].Value                  := SQL.Fields[0].Value;
            SQL2.Open();

            if SQL2.RecordCount > 0 then begin
              csFornecedoresSALDO.Value          := SQL2.Fields[0].Value;
              csFornecedoresTICKET.Value         := SQL2.Fields[1].Value;
            end;
          end;
          csFornecedores.Post;
        end;
      end;

      DMUtil.frxDBDataset1.DataSet := csFornecedores;
      DMUtil.ImprimirRelatorio('frListagemFornecedores.fr3');
      DisplayMsgFinaliza;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao buscar dados!', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(SQL);
    FreeAndNil(SQL2);
    FreeAndNil(F);
    FreeAndNil(CON);
    csFornecedores.EmptyDataSet;
  end;
end;

end.
