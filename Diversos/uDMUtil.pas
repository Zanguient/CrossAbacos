unit uDMUtil;

interface

uses
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, forms, Vcl.Controls,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, Vcl.ImgList, uFWPersistence, Vcl.StdCtrls,
  frxClass, frxDesgn;

type
  TDMUtil = class(TDataModule)
    frxReport1: TfrxReport;
    frxDesigner1: TfrxDesigner;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Selecionar(Tabela : TFWPersistence; ValorControl : String = '') : Integer;
    procedure ImprimirRelatorio(Relatorio : String);
  end;

var
  DMUtil: TDMUtil;

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

  if not DirectoryExists(DirInstall) then
    CreateDir(DirInstall);

  CarregarConfigLocal;

  CarregarConexaoBD;

end;

procedure TDMUtil.ImprimirRelatorio(Relatorio: String);
var
  Arquivo : String;
  ArqText : TextFile;
begin
  frxReport1.Clear;
  Arquivo                  := LOGIN.DirRelatorio + Relatorio;

  if not FileExists(Arquivo) then begin
    DisplayMsg(MSG_WAR, 'Arquivo não encontrado!');
    Exit;
  end;

  frxReport1.LoadFromFile(LOGIN.DirRelatorio + Relatorio);
  if DESIGNREL then begin
    AssignFile(ArqText, Arquivo);

    frxReport1.DesignReport();

    Reset(ArqText);
    CloseFile(ArqText);
  end else
    frxReport1.ShowReport();
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
