unit uRelCustoPorMarca;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, DateUtils, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Datasnap.DBClient;

type
  TfrmRelCustoPorMarca = class(TForm)
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    GroupBox2: TGroupBox;
    edMarca: TEdit;
    cds_CustoPorMarca: TClientDataSet;
    cds_CustoPorMarcaSKU: TStringField;
    cds_CustoPorMarcaMARCA: TStringField;
    cds_CustoPorMarcaCUSTO: TCurrencyField;
    cds_CustoPorMarcaPRECO: TCurrencyField;
    cds_CustoPorMarcaMARGEM: TCurrencyField;
    cds_CustoPorMarcaNOME: TStringField;
    procedure btSairClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Visualizar;
  end;

var
  frmRelCustoPorMarca: TfrmRelCustoPorMarca;

implementation
uses
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uMensagem;
{$R *.dfm}

procedure TfrmRelCustoPorMarca.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelCustoPorMarca.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelCustoPorMarca.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    btSairClick(nil);
end;

procedure TfrmRelCustoPorMarca.FormShow(Sender: TObject);
begin
  cds_CustoPorMarca.CreateDataSet;
  cds_CustoPorMarca.Open;
end;

procedure TfrmRelCustoPorMarca.Visualizar;
var
  FWC       : TFWConnection;
  Consulta  : TFDQuery;
  Consulta2 : TFDQuery;
begin
  DisplayMsg(MSG_WAIT, 'Buscando dados para visualizar!');

  FWC       := TFWConnection.Create;
  Consulta  := TFDQuery.Create(nil);
  Consulta2 := TFDQuery.Create(nil);

  try
    try

      Consulta.Close;
      Consulta.SQL.Clear;
      Consulta.SQL.Add('SELECT');
      Consulta.SQL.Add('p.id,');
      Consulta.SQL.Add('p.sku,');
      Consulta.SQL.Add('p.nome,');
      Consulta.SQL.Add('p.marca');
      Consulta.SQL.Add('FROM produto p');
      Consulta.SQL.Add('LEFT JOIN margem m ON p.id = m.id_produto');
      Consulta.SQL.Add('WHERE ((P.CUSTOFINAL > 0) OR (P.QUANTIDADE_ESTOQUE_FISICO > 0))');

      if Trim(edMarca.Text) <> EmptyStr then
        Consulta.SQL.Add('AND UPPER(p.marca) LIKE ' + QuotedStr('%' + AnsiUpperCase(edMarca.Text) + '%'));

      Consulta.SQL.Add('ORDER BY P.marca');
      Consulta.Connection                     := FWC.FDConnection;
      Consulta.Prepare;
      Consulta.Open;
      Consulta.FetchAll;

      Consulta2.Close;
      Consulta2.SQL.Clear;
      Consulta2.SQL.Add('SELECT');
      Consulta2.SQL.Add('pi.custo_atual,');
      Consulta2.SQL.Add('(pi.margempraticar * 100) as margem,');
      Consulta2.SQL.Add('pi.precopor');
      Consulta2.SQL.Add('FROM precificacao p');
      Consulta2.SQL.Add('inner join precificacao_itens pi on p.id = pi.precificacao_id');
      Consulta2.SQL.Add('inner join produto pr on pi.id_produto = pr.id');
      Consulta2.SQL.Add('where pi.id_produto = :IDPRODUTO');
      Consulta2.SQL.Add('order by p.data_hora desc');
      Consulta2.SQL.Add('limit 1');
      Consulta2.Connection                        := FWC.FDConnection;
      Consulta2.ParamByName('IDPRODUTO').DataType := ftInteger;
      Consulta2.Prepare;

      cds_CustoPorMarca.EmptyDataSet;

      Consulta.First;
      while not Consulta.Eof do begin
        cds_CustoPorMarca.Append;
        cds_CustoPorMarcaSKU.Value      := Consulta.Fields[1].Value;
        cds_CustoPorMarcaNOME.Value     := Consulta.Fields[2].Value;
        cds_CustoPorMarcaMARCA.Value    := Consulta.Fields[3].Value;
        cds_CustoPorMarcaCUSTO.Value    := 0.00;
        cds_CustoPorMarcaPRECO.Value    := 0.00;
        cds_CustoPorMarcaMARGEM.Value   := 0.00;

        Consulta2.Close;
        Consulta2.Params[0].Value       := Consulta.Fields[0].Value;
        Consulta2.Open();

        if not Consulta2.IsEmpty then begin
          cds_CustoPorMarcaCUSTO.Value  := Consulta2.Fields[0].Value;
          cds_CustoPorMarcaMARGEM.Value := Consulta2.Fields[1].Value;
          cds_CustoPorMarcaPRECO.Value  := Consulta2.Fields[2].Value;
        end;
        cds_CustoPorMarca.Post;

        Consulta.Next;
      end;
      DMUtil.frxDBDataset1.DataSet := cds_CustoPorMarca;
      DMUtil.ImprimirRelatorio('frCustoMarca.fr3');
      DisplayMsgFinaliza;
    Except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros na consulta!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(Consulta);
    FreeAndNil(Consulta2);
    FreeAndNil(FWC);
  end;
end;

end.
