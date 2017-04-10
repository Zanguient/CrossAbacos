unit uConsultaProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Data.DB, Datasnap.DBClient, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmConsultaProdutos = class(TForm)
    pnPrincipal: TPanel;
    pnTopo: TPanel;
    dgConsulta: TDBGrid;
    edFiltro: TEdit;
    Label1: TLabel;
    csConsulta: TClientDataSet;
    dsConsulta: TDataSource;
    csConsultaSKU: TStringField;
    csConsultaMENORCUSTO: TCurrencyField;
    csConsultaFORNECEDOR: TStringField;
    csConsultaDATAULTIMAATUA: TDateTimeField;
    csConsultaNOMEPRODUTO: TStringField;
    csConsultaMARCA: TStringField;
    csConsultaCATEGORIA: TStringField;
    csConsultaID_PAI: TStringField;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure csConsultaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure edFiltroKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dgConsultaDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dgConsultaTitleClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ConsultaProdutos;
    procedure Filtrar;
  end;

var
  frmConsultaProdutos: TfrmConsultaProdutos;

implementation
uses uFuncoes, uBeanProduto, uBeanFornecedor, uBeanProdutoFornecedor, uDMUtil,
     uFWConnection, uMensagem;
{$R *.dfm}

{ TfrmConsultaProdutos }

procedure TfrmConsultaProdutos.ConsultaProdutos;
var
  CON  : TFWConnection;
  SQL  : TFDQuery;
begin
  CON   := TFWConnection.Create;
  SQL   := TFDQuery.Create(nil);

  csConsulta.DisableControls;
  DisplayMsg(MSG_WAIT, 'Consultando dados!');
  try
    try
      csConsulta.EmptyDataSet;

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.SKU,');
      SQL.SQL.Add('	P.NOME AS NOMEPRODUTO,');
      SQL.SQL.Add('	P.MARCA,');
      SQL.SQL.Add('	FM.DESCRICAO AS CATEGORIA,');
      SQL.SQL.Add('	COALESCE(PF.CUSTO,0) AS CUSTO,');
      SQL.SQL.Add('	F.ID AS FORN,');
      SQL.SQL.Add('	F.NOME,');
      SQL.SQL.Add(' CAST(L.DATA_HORA AS DATE) AS DATA_HORA,');
      SQL.SQL.Add('	COALESCE(P.PRODUTO_PAI, '''') AS PRODUTO_PAI');
      SQL.SQL.Add('FROM PRODUTO P');
      SQL.SQL.Add('INNER JOIN FAMILIA FM ON (P.ID_FAMILIA = FM.ID)');
      SQL.SQL.Add('LEFT JOIN PRODUTOFORNECEDOR PF ON P.ID = PF.ID_PRODUTO AND P.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR');
      SQL.SQL.Add('INNER JOIN FORNECEDOR F ON P.ID_FORNECEDORNOVO = F.ID');
      SQL.SQL.Add('INNER JOIN LOTE L ON P.ID_ULTIMOLOTE = L.ID');

      SQL.Connection       := CON.FDConnection;
      SQL.Prepare;
      SQL.Open();
      SQL.DisableControls;

      SQL.First;
      while not SQL.Eof do begin
        csConsulta.Append;
        csConsultaSKU.Value              := SQL.Fields[0].Value;
        csConsultaNOMEPRODUTO.Value      := SQL.Fields[1].Value;
        csConsultaMARCA.Value            := SQL.Fields[2].Value;
        csConsultaCATEGORIA.Value        := SQL.Fields[3].Value;
        csConsultaMENORCUSTO.Value       := SQL.Fields[4].Value;
        csConsultaFORNECEDOR.Value       := SQL.Fields[5].AsString + ' - ' + SQL.Fields[6].AsString;
        csConsultaDATAULTIMAATUA.Value   := SQL.Fields[7].Value;
        csConsultaID_PAI.Value           := SQL.Fields[8].Value;
        csConsulta.Post;

        SQL.Next;
      end;
      DisplayMsgFinaliza;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Erro ao consultar dados', '', E.Message);
        Exit;
      end;
    end;
  finally
    csConsulta.EnableControls;
    FreeAndNil(SQL);
    FreeAndNil(CON);
  end;
end;

procedure TfrmConsultaProdutos.csConsultaFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  Accept        := False;
  for I := 0 to Pred(csConsulta.FieldCount) do begin
    Accept := Pos(AnsiUpperCase(edFiltro.Text), AnsiUpperCase(csConsulta.Fields[I].AsString)) > 0;
    if Accept then Break;
  end;
end;

procedure TfrmConsultaProdutos.dgConsultaDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if ((gdSelected in State) or (gdFocused in State)) then begin
    dgConsulta.Canvas.Font.Color  := clWhite;
    dgConsulta.Canvas.Brush.Color := clBlue;
    dgConsulta.Canvas.Font.Style  := [];
    dgConsulta.Canvas.Font.Size   := 10;
  end else begin
    dgConsulta.Canvas.Font.Color  := clDefault;
    dgConsulta.Canvas.Font.Style  := [];
    dgConsulta.Canvas.Font.Size   := 10;
  end;

  dgConsulta.DefaultDrawDataCell(Rect,dgConsulta.Columns[DataCol].Field, State);
end;

procedure TfrmConsultaProdutos.dgConsultaTitleClick(Column: TColumn);
begin
  OrdenarGrid(Column);
end;

procedure TfrmConsultaProdutos.edFiltroKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Filtrar;
  if Key = VK_UP then begin
    if (csConsulta.IsEmpty) or (csConsulta.Bof) then Exit;
    csConsulta.Prior;
  end else if Key = VK_DOWN then begin
    if (csConsulta.IsEmpty) or (csConsulta.Eof) then Exit;
      csConsulta.Next;
  end;
end;

procedure TfrmConsultaProdutos.Filtrar;
begin
  csConsulta.Filtered := False;
  csConsulta.Filtered := edFiltro.Text <> '';
end;

procedure TfrmConsultaProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
    ConsultaProdutos;
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmConsultaProdutos.FormShow(Sender: TObject);
begin
  AjustaForm(Self);
  AutoSizeDBGrid(dgConsulta);
  csConsulta.CreateDataSet;
  csConsulta.Open;
  ConsultaProdutos;
end;

end.
