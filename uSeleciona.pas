unit uSeleciona;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, uFWPersistence, System.TypInfo,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSeleciona = class(TForm)
    pnPrincipal: TPanel;
    GroupBox1: TGroupBox;
    csSeleciona: TClientDataSet;
    dgSeleciona: TDBGrid;
    dsSeleciona: TDataSource;
    edPesquisa: TEdit;
    btSelecionar: TBitBtn;
    btBuscar: TBitBtn;
    procedure csSelecionaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btBuscarClick(Sender: TObject);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btSelecionarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FTabelaPai : TFWPersistence;
    Retorno    : TEdit;
    procedure SelecionaDados(CriaCampos : Boolean);
    procedure filter;
  end;

var
  frmSeleciona: TfrmSeleciona;

implementation
uses uFWConnection, uDomains;
{$R *.dfm}

{ TfrmSeleciona }

procedure TfrmSeleciona.btBuscarClick(Sender: TObject);
begin
  filter;
end;

procedure TfrmSeleciona.btSelecionarClick(Sender: TObject);
begin
  Retorno.Text    := csSeleciona.Fields[0].AsString;
end;

procedure TfrmSeleciona.csSelecionaFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
Var
  I : Integer;
begin
  Accept := False;
  for I := 0 to DataSet.Fields.Count - 1 do begin
    if Pos(AnsiLowerCase(edPesquisa.Text),AnsiLowerCase(DataSet.Fields[I].AsVariant)) > 0 then begin
      Accept := True;
      Break;
    end;
  end;
end;

procedure TfrmSeleciona.edPesquisaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    filter;
end;

procedure TfrmSeleciona.filter;
begin
  csSeleciona.Filtered := False;
  csSeleciona.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TfrmSeleciona.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmSeleciona   := nil;
  Action         := Cafree;
end;

procedure TfrmSeleciona.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure TfrmSeleciona.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then
    ModalResult := mrAbort;
end;

procedure TfrmSeleciona.FormShow(Sender: TObject);
begin
  SelecionaDados(True);
  edPesquisa.Text   := Retorno.Text;
  Filter;
  if csSeleciona.RecordCount = 1 then begin
    btSelecionarClick(nil);
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
  end;

end;

procedure TfrmSeleciona.SelecionaDados(CriaCampos: Boolean);
var
  List        : TPropList;
  Count,
  I           : Integer;
  QRConsulta  : TFDQuery;
  FDC         : TFWConnection;
begin

  FDC           := TFWConnection.Create;
  QRConsulta    := TFDQuery.Create(nil);
  try

    Count := GetPropList(FTabelaPai.ClassInfo, tkProperties, @List, False);
    QRConsulta.SQL.Add('SELECT ');

    for I := 0 to Pred(Count) do begin
      if (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isPK) or (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isSearchField) then
        QRConsulta.SQL.Add(Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)) + '.' + List[I]^.Name + ', ');
    end;
    QRConsulta.SQL.Text := Copy(QRConsulta.SQL.Text, 1, Length(QRConsulta.SQL.Text) - 4);
    QRConsulta.SQL.Add(' FROM '+Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)));

    QRConsulta.Connection := FDC.FDConnection;
    QRConsulta.Prepare;
    QRConsulta.Open();

    Count := GetPropList(FTabelaPai.ClassInfo, tkProperties, @List, False);

    for I := 0 to Pred(Count) do begin
      if (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isPK) or (TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).isSearchField) then begin
        QRConsulta.FieldByName(List[I]^.Name).DisplayLabel := TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).displayLabel;
        QRConsulta.FieldByName(List[I]^.Name).DisplayWidth := TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).displayWidth;
      end;
    end;

    if CriaCampos then begin
      for I := 0 to QRConsulta.FieldCount - 1 do
        csSeleciona.FieldDefs.Add(QRConsulta.Fields[I].FieldName,QRConsulta.Fields[I].DataType,QRConsulta.Fields[I].Size);
      csSeleciona.CreateDataSet;
      csSeleciona.Open;
      for I := 0 to QRConsulta.FieldCount - 1 do begin
        csSeleciona.FindField(QRConsulta.Fields[I].FieldName).DisplayLabel                 := QRConsulta.Fields[I].DisplayLabel;
        csSeleciona.FindField(QRConsulta.Fields[I].FieldName).DisplayWidth                 := QRConsulta.Fields[I].DisplayWidth;
        csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName).Origin                       := QRConsulta.Fields[I].Origin;
        if csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName).DataType in [ftFloat, ftCurrency] then begin
          TFloatField(csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName)).DisplayFormat := TFloatField(QRConsulta.Fields[I]).DisplayFormat;
          TFloatField(csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName)).EditFormat    := TFloatField(QRConsulta.Fields[I]).EditFormat;
        end;
      end;
    end;

    csSeleciona.EmptyDataSet;
    while not QRConsulta.Eof do begin
      csSeleciona.Append;
      for I := 0 to QRConsulta.FieldCount - 1 do begin
        if csSeleciona.FindField(QRConsulta.Fields[I].FieldName) <> nil then
          csSeleciona.FieldByName(QRConsulta.Fields[I].FieldName).Value := QRConsulta.Fields[I].Value;
      end;
      csSeleciona.Post;
      QRConsulta.Next;
    end;

  finally
    FreeAndNil(QRConsulta);
    FreeAndNil(FDC);
  end;
end;

end.
