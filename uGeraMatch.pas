unit uGeraMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TfrmGeraMatch = class(TForm)
    Panel2: TPanel;
    pnBotoesVisualizacao: TPanel;
    btSair: TSpeedButton;
    btGerar: TSpeedButton;
    cbLoteImportacao: TComboBox;
    ProgressBar1: TProgressBar;
    lbProgresso: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btGerarClick(Sender: TObject);
  private
    Procedure CarregaLote;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGeraMatch: TfrmGeraMatch;

implementation

uses
  uFuncoes,
  uMensagem,
  uFWConnection,
  uBeanLoteImportacao,
  uBeanProduto;

{$R *.dfm}

procedure TfrmGeraMatch.btGerarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  P   : TPRODUTO;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  P   := TPRODUTO.Create(FWC);

  try
    try

      lbProgresso.Caption := '0 %';

      P.SelectList('','ID');

      if P.Count > 0 then begin
        ProgressBar1.Max := P.Count;
        for I := 0 to P.Count - 1 do begin
          Sleep(1);
          ProgressBar1.Position := I + 1;
          lbProgresso.Caption := FormatCurr('0.00', (ProgressBar1.Position * 100) / ProgressBar1.Max);
          Application.ProcessMessages;
        end;
      end;

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importação', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    FreeAndNil(P);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmGeraMatch.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGeraMatch.CarregaLote;
Var
  FWC : TFWConnection;
  L  : TLOTE;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  L   := TLOTE.Create(FWC);

  try
    try

      L.SelectList('','ID DESC LIMIT 5');

      cbLoteImportacao.Items.Clear;

      if L.Count > 0 then begin
        for I := 0 to L.Count - 1 do
          cbLoteImportacao.Items.Add(IntToStr(TLOTE(L.Itens[I]).ID.Value) + ' - ' + FormatDateTime('dd/mm/yyyy', TLOTE(L.Itens[I]).DATA_HORA.Value));
      end;

      if cbLoteImportacao.Items.Count > 0 then
        cbLoteImportacao.ItemIndex := 0;

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importação', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    FreeAndNil(L);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmGeraMatch.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmGeraMatch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : begin
        Close;
    end;
  end;
end;

procedure TfrmGeraMatch.FormShow(Sender: TObject);
begin
  CarregaLote;
end;

end.
