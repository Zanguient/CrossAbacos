unit uCadPadrao;

interface

uses

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB,
  Datasnap.DBClient, uFWPersistence, System.TypInfo;

  {Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, System.TypInfo,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uFWPersistence;}

type
  TfrmCadPadrao = class(TForm)
    pnVisualizacao: TPanel;
    pnEdicao: TPanel;
    pnPequisa: TPanel;
    edPesquisa: TEdit;
    dgPesquisa: TDBGrid;
    csPesquisa: TClientDataSet;
    dsPesquisa: TDataSource;
    pnBotoesVisualizacao: TPanel;
    btPesquisar: TButton;
    btFechar: TButton;
    btInserir: TButton;
    btAlterar: TButton;
    Panel2: TPanel;
    btCancelar: TButton;
    btGravar: TButton;
    pnAjusteBotoes1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btInserirClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btPesquisarClick(Sender: TObject);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    procedure SelecionaDados(CriaCampos : Boolean);
    procedure InvertePaineis;
    procedure Cancelar;
    procedure Filtrar;
    { Private declarations }
  public
    FTabelaPai : TFWPersistence;
    { Public declarations }
  end;

var
  frmCadPadrao     : TfrmCadPadrao;

implementation

uses uDMUtil,
    uConstantes,
    uDomains,
    uFWConnection;

{$R *.dfm}

{ TForm1 }

procedure TfrmCadPadrao.btAlterarClick(Sender: TObject);
begin
  if not csPesquisa.IsEmpty then begin
    csPesquisa.Edit;
    InvertePaineis;
  end;
end;

procedure TfrmCadPadrao.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmCadPadrao.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadPadrao.btGravarClick(Sender: TObject);
begin
  InvertePaineis;
end;

procedure TfrmCadPadrao.btInserirClick(Sender: TObject);
begin
  csPesquisa.Append;
  InvertePaineis;
end;

procedure TfrmCadPadrao.btPesquisarClick(Sender: TObject);
begin
  Filtrar;
end;

procedure TfrmCadPadrao.Cancelar;
begin
  InvertePaineis;
end;

procedure TfrmCadPadrao.csPesquisaFilterRecord(DataSet: TDataSet;
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

procedure TfrmCadPadrao.Filtrar;
begin
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TfrmCadPadrao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmCadPadrao := nil;
  Action       := Cafree;
end;

procedure TfrmCadPadrao.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure TfrmCadPadrao.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FTabelaPai);
end;

procedure TfrmCadPadrao.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then begin
    Close;
  end else begin
    if Key = VK_RETURN then begin
      if edPesquisa.Focused then begin
        Filtrar;
      end else begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
          edPesquisa.SelectAll;
        end;
      end;
    end else begin
      if not edPesquisa.Focused then begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
        end;
      end;
    end;
  end;
end;

procedure TfrmCadPadrao.FormResize(Sender: TObject);
begin
  pnAjusteBotoes1.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - btInserir.Width) - 3;
end;

procedure TfrmCadPadrao.FormShow(Sender: TObject);
begin
  SelecionaDados(True);
end;

procedure TfrmCadPadrao.InvertePaineis;
begin
  pnVisualizacao.Visible  := not pnVisualizacao.Visible;
  pnEdicao.Visible        := not pnEdicao.Visible;
end;

procedure TfrmCadPadrao.sbFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadPadrao.SelecionaDados(CriaCampos: Boolean);
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
      if I = Pred(Count) then
        QRConsulta.SQL.Add(Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)) + '.' + List[I]^.Name)
      else
        QRConsulta.SQL.Add(Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)) + '.' + List[I]^.Name + ', ');
    end;

    QRConsulta.SQL.Add('FROM '+Copy(FTabelaPai.ClassName, 2, Length(FTabelaPai.ClassName)));

    QRConsulta.Connection := FDC.FDConnection;
    QRConsulta.Prepare;
    QRConsulta.Open();

    Count := GetPropList(FTabelaPai.ClassInfo, tkProperties, @List, False);

    for I := 0 to Pred(Count) do begin
      QRConsulta.FieldByName(List[I]^.Name).DisplayLabel := TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).displayLabel;
      QRConsulta.FieldByName(List[I]^.Name).DisplayWidth := TFieldTypeDomain(GetObjectProp(FTabelaPai, List[I]^.Name)).displayWidth;
    end;

    if CriaCampos then begin
      for I := 0 to QRConsulta.FieldCount - 1 do
        csPesquisa.FieldDefs.Add(QRConsulta.Fields[I].FieldName,QRConsulta.Fields[I].DataType,QRConsulta.Fields[I].Size);
      csPesquisa.CreateDataSet;
      csPesquisa.Open;
      for I := 0 to QRConsulta.FieldCount - 1 do begin
        csPesquisa.FindField(QRConsulta.Fields[I].FieldName).DisplayLabel                 := QRConsulta.Fields[I].DisplayLabel;
        csPesquisa.FindField(QRConsulta.Fields[I].FieldName).DisplayWidth                 := QRConsulta.Fields[I].DisplayWidth;
        csPesquisa.FieldByName(QRConsulta.Fields[I].FieldName).Origin                       := QRConsulta.Fields[I].Origin;
        if csPesquisa.FieldByName(QRConsulta.Fields[I].FieldName).DataType in [ftFloat, ftCurrency] then begin
          TFloatField(csPesquisa.FieldByName(QRConsulta.Fields[I].FieldName)).DisplayFormat := TFloatField(QRConsulta.Fields[I]).DisplayFormat;
          TFloatField(csPesquisa.FieldByName(QRConsulta.Fields[I].FieldName)).EditFormat    := TFloatField(QRConsulta.Fields[I]).EditFormat;
        end;
      end;
    end;

    csPesquisa.EmptyDataSet;
    while not QRConsulta.Eof do begin
      csPesquisa.Append;
      for I := 0 to QRConsulta.FieldCount - 1 do begin
        if csPesquisa.FindField(QRConsulta.Fields[I].FieldName) <> nil then
          csPesquisa.FieldByName(QRConsulta.Fields[I].FieldName).Value := QRConsulta.Fields[I].Value;
      end;
      csPesquisa.Post;
      QRConsulta.Next;
    end;

  finally
    FreeAndNil(QRConsulta);
    FreeAndNil(FDC);
  end;
end;

end.
