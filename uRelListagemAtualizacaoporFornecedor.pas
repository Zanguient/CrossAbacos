unit uRelListagemAtualizacaoporFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB, Datasnap.DBClient;

type
  TfrmRelListagemAtualizacaoporFornecedor = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaPeriodo: TGroupBox;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    edDataInicial: TDateTimePicker;
    edDataFinal: TDateTimePicker;
    CDS_Dados: TClientDataSet;
    CDS_DadosDATA: TDateField;
    CDS_DadosFORNECEDOR: TStringField;
    CDS_DadosLOTE: TIntegerField;
    CDS_DadosATUALIZADO: TBooleanField;
    procedure btSairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure Visualizar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelListagemAtualizacaoporFornecedor: TfrmRelListagemAtualizacaoporFornecedor;

implementation

uses
  uFWConnection,
  uBeanFornecedor,
  uBeanImportacao,
  uDMUtil,
  uMensagem;

{$R *.dfm}

procedure TfrmRelListagemAtualizacaoporFornecedor.btRelatorioClick(
  Sender: TObject);
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

procedure TfrmRelListagemAtualizacaoporFornecedor.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelListagemAtualizacaoporFornecedor.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelListagemAtualizacaoporFornecedor.FormShow(Sender: TObject);
begin

  CDS_Dados.CreateDataSet;

  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelListagemAtualizacaoporFornecedor.Visualizar;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
  F   : TFORNECEDOR;
  IMP : TIMPORTACAO;
  I   : Integer;
begin

  DisplayMsg(MSG_WAIT, 'Buscando dados...');

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);
  F   := TFORNECEDOR.Create(FWC);
  IMP := TIMPORTACAO.Create(FWC);

  CDS_Dados.DisableControls;
  CDS_Dados.EmptyDataSet;
  try
    try

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	L.ID AS LOTE,');
      SQL.SQL.Add('	CAST(L.DATA_HORA AS DATE) AS DATA');
      SQL.SQL.Add('FROM LOTE L');
      SQL.SQL.Add('WHERE CAST(L.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND L.ID > 0');
      SQL.SQL.Add('ORDER BY L.ID');
      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;
      SQL.Params[0].Value               := edDataInicial.Date;
      SQL.Params[1].Value               := edDataFinal.Date;
      SQL.Open;
      SQL.FetchAll;

      if Not SQL.IsEmpty then begin
        F.SelectList('', 'ID');
        if F.Count > 0 then begin
          SQL.First;
          while not SQL.Eof do begin
            for I := 0 to F.Count - 1 do begin
              CDS_Dados.Append;
              CDS_DadosDATA.Value       := SQL.Fields[1].Value;
              CDS_DadosLOTE.Value       := SQL.Fields[0].Value;
              CDS_DadosFORNECEDOR.Value := TFORNECEDOR(F.Itens[I]).NOME.Value;
              CDS_DadosATUALIZADO.Value := False;
              IMP.SelectList('ID_LOTE = ' + CDS_DadosLOTE.AsString + ' AND ID_FORNECEDOR = ' + TFORNECEDOR(F.Itens[I]).ID.asString);
              if IMP.Count > 0 then
                CDS_DadosATUALIZADO.Value := True;
              CDS_Dados.Post;
            end;
            SQL.Next;
          end;
        end;
      end;

      DMUtil.frxDBDataset1.DataSet := CDS_Dados;
      DMUtil.ImprimirRelatorio('frAtualizacaoFornecedoresporLote.fr3');
      DisplayMsgFinaliza;

    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao buscar dados!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(IMP);
    FreeAndNil(F);
    FreeAndNil(SQL);
    FreeAndNil(FWC);
    CDS_Dados.EnableControls;
  end;
end;

end.
