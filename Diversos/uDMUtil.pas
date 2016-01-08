unit uDMUtil;

interface

uses
  System.SysUtils, System.Classes, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, forms, Vcl.Controls,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, Vcl.ImgList, uFWPersistence, Vcl.StdCtrls,
  frxClass;

type
  TDMUtil = class(TDataModule)
    frxReport1: TfrxReport;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Selecionar(Tabela : TFWPersistence; ValorControl : String = '') : Integer;
  end;

var
  DMUtil: TDMUtil;

implementation

Uses
  uConstantes,
  uFuncoes,
  uSeleciona;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDMUtil.DataModuleCreate(Sender: TObject);
begin

  if not DirectoryExists(DirInstall) then
    CreateDir(DirInstall);

  CarregarConfigLocal;

  CarregarConexaoBD;

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
      Result := StrToInt(Control.Text);
  finally
    FreeAndNil(Control);
  end;
end;

end.
