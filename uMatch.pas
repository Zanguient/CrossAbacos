unit uMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfrmMatch = class(TForm)
    Panel2: TPanel;
    pnBotoesVisualizacao: TPanel;
    btFechar: TSpeedButton;
    btAlterar: TSpeedButton;
    btExcluir: TSpeedButton;
    pnAjusteBotoes1: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMatch: TfrmMatch;

implementation

{$R *.dfm}

end.
