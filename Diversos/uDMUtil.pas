unit uDMUtil;

interface

uses
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, forms, Vcl.Controls,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, Vcl.ImgList, uFWPersistence, Vcl.StdCtrls,
  frxClass, frxDesgn, frxDBSet, frxExportPDF, frxExportXLS, fs_ichartrtti,
  Data.DB, VCLTee.TeeData;

type
  TDMUtil = class(TDataModule)
    frxReport1: TfrxReport;
    frxDesigner1: TfrxDesigner;
    frxDBDataset1: TfrxDBDataset;
    frxPDFExport1: TfrxPDFExport;
    frxXLSExport1: TfrxXLSExport;
    ImageList1: TImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Selecionar(Tabela : TFWPersistence; ValorControl : String = '') : Integer;
    procedure ImprimirRelatorio(Relatorio : String);
  end;

var
  DMUtil: TDMUtil;
  RelParams : TStringList;

implementation

Uses
  uConstantes,
  uFuncoes,
  uSeleciona,
  uMensagem;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDMUtil.DataModuleCreate(Sender: TObject);
begin
  DirInstall        := GetCurrentDir;
  if DirInstall[Length(DirInstall)] <> '\' then
    DirInstall := DirInstall + '\';

  DirArqConf        := DirInstall + 'CrossAbacos.ini';
  DirArquivosExcel  := DirInstall + 'Arquivos\';

  if not DirectoryExists(DirInstall) then
    CreateDir(DirInstall);

  CarregarConfigLocal;

  CarregarConexaoBD;

  RelParams    := TStringList.Create;
  carregaArrayClassificacao;
end;

procedure TDMUtil.DataModuleDestroy(Sender: TObject);
begin
  FreeAndNil(RelParams);
end;

procedure TDMUtil.ImprimirRelatorio(Relatorio: String);
var
  Arquivo : String;
  ArqText : TextFile;
  I       : Integer;
begin
  frxReport1.Clear;

  Arquivo                  := CONFIG_LOCAL.DirRelatorios + Relatorio;

  if not FileExists(Arquivo) then begin
    DisplayMsg(MSG_WAR, 'Arquivo ' + Arquivo + ' n�o encontrado, Verifique!');
    Exit;
  end;

  frxReport1.LoadFromFile(Arquivo);

  frxReport1.Variables['Usuario'] := QuotedStr(USUARIO.NOME);

  for I := 0 to Pred(RelParams.Count) do begin
    FrxReport1.Variables[Copy(RelParams.Strings[I], 0, Pos('=',RelParams.Strings[I]) -1)] := QuotedStr(Copy(RelParams.Strings[I], Pos('=',RelParams.Strings[I]) + 1, Length(RelParams.Strings[I]) - Pos('=',RelParams.Strings[I]) + 1));
  end;

  try
    if DESIGNREL then begin
      AssignFile(ArqText, Arquivo);
      frxReport1.DesignReport();
      Reset(ArqText);
      CloseFile(ArqText);
    end else
      frxReport1.ShowReport();
  finally
    frxReport1.Clear;
  end;
end;

function TDMUtil.Selecionar(Tabela: TFWPersistence; ValorControl : String): Integer;
var
  Control : TEdit;
begin
  Result                      := 0;
  Control                     := TEdit.Create(nil);
  try
    if not Assigned(frmSeleciona) then
      frmSeleciona            := TfrmSeleciona.Create(nil);
    if ValorControl <> '' then
      Control.Text            := ValorControl;
    frmSeleciona.Retorno      := Control;
    frmSeleciona.FTabelaPai   := Tabela;
    if (frmSeleciona.ShowModal = mrOk) or (Control.Text <> '') then
      Result                  := StrToIntDef(Control.Text,0);
  finally
    FreeAndNil(Control);
  end;
end;

end.
