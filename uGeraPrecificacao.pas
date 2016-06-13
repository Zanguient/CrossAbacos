unit uGeraPrecificacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Comp.Client, Data.DB, System.Win.ComObj,
  Vcl.Samples.Gauges;

type
  TfrmGeraPrecificacao = class(TForm)
    pnBotoes: TPanel;
    btSair: TSpeedButton;
    BarradeProgresso: TGauge;
    btGerar: TSpeedButton;
    lblMensagem: TLabel;
    procedure btGerarClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    procedure gerarPrecificacao;
    { Public declarations }
  end;

var
  frmGeraPrecificacao: TfrmGeraPrecificacao;

implementation
uses
  uFWConnection,
  uBeanProduto,
  uBeanPrecificacao,
  uBeanPrecificacao_itens,
  uBeanFamilia,
  uBeanMargem,
  uConstantes,
  uMensagem;
{$R *.dfm}

{ TfrmGeraPrecificacao }

procedure TfrmGeraPrecificacao.btGerarClick(Sender: TObject);
begin
  if btGerar.Tag = 0 then begin
    btGerar.Tag := 1;
    try
      gerarPrecificacao;
    finally
      btGerar.Tag := 0;
    end;
  end;
end;

procedure TfrmGeraPrecificacao.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGeraPrecificacao.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmGeraPrecificacao := nil;
  Action              := caFree;
end;

procedure TfrmGeraPrecificacao.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmGeraPrecificacao.gerarPrecificacao;
var
  FW      : TFWConnection;
  PRECOS  : array of TPRECOS;
  P       : TPRODUTO;
  F       : TFAMILIA;
  M       : TMARGEM;
  PR      : TPRECIFICACAO;
  PRI     : TPRECIFICACAO_ITENS;
  I: Integer;
begin
  FW   := TFWConnection.Create;
  P    := TPRODUTO.Create(FW);
  F    := TFAMILIA.Create(FW);
  M    := TMARGEM.Create(FW);
  PR   := TPRECIFICACAO.Create(FW);
  PRI  := TPRECIFICACAO_ITENS.Create(FW);
  SetLength(PRECOS, 0);
  try
    lblMensagem.Caption := 'Processando Etapa 1 de 2.';
    Application.ProcessMessages;
    P.SelectList('((custo > 0) or (quantidade_estoque_fisico > 0))');
    if P.Count > 0 then begin
      BarradeProgresso.MaxValue := P.Count;
      for I := 0 to Pred(P.Count) do begin
        BarradeProgresso.Progress := I;
        SetLength(PRECOS, Length(PRECOS) + 1);
        PRECOS[High(PRECOS)].TIPO                 := 0;
        PRECOS[High(PRECOS)].ID_PRODUTO           := TPRODUTO(P.Itens[I]).ID.Value;
        PRECOS[High(PRECOS)].SKU                  := TPRODUTO(P.Itens[I]).SKU.Value;
        if TPRODUTO(P.Itens[I]).CUSTO_ESTOQUE_FISICO.Value > 0 then begin
          PRECOS[High(PRECOS)].CUSTO_ANT          := TPRODUTO(P.Itens[I]).CUSTO_EST_FISICO_ANT.Value;
          PRECOS[High(PRECOS)].CUSTO_NOVO         := TPRODUTO(P.Itens[I]).CUSTO_ESTOQUE_FISICO.Value;
        end else begin
          PRECOS[High(PRECOS)].CUSTO_ANT          := TPRODUTO(P.Itens[I]).CUSTOANTERIOR.Value;
          PRECOS[High(PRECOS)].CUSTO_NOVO         := TPRODUTO(P.Itens[I]).CUSTO.Value;
        end;
        PRECOS[High(PRECOS)].PRECO_CADASTRO       := TPRODUTO(P.Itens[I]).PRECO_VENDA.Value;
        PRECOS[High(PRECOS)].MEDIA                := TPRODUTO(P.Itens[I]).MEDIA_ALTERACAO.Value;

        F.SelectList('id = ' + TPRODUTO(P.Itens[I]).ID_FAMILIA.asString);
        if F.Count > 0 then begin
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA    := TFAMILIA(F.Itens[0]).MARGEM.Value / 100;
          PRECOS[High(PRECOS)].TIPO               := 1;
        end;

        M.SelectList('id_produto = ' + TPRODUTO(P.Itens[I]).ID.asString);
        if M.Count > 0 then begin
          if TMARGEM(M.Itens[0]).MARGEM_ANALISTA.Value > 0 then begin
            PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := TMARGEM(M.Itens[0]).MARGEM_ANALISTA.Value / 100;
            PRECOS[High(PRECOS)].TIPO             := 1;
          end;
          if TMARGEM(M.Itens[0]).PRECO_PONTA.Value > 0 then begin
            PRECOS[High(PRECOS)].PRECO_SUGESTAO   := TMARGEM(M.Itens[0]).PRECO_PONTA.Value;
            PRECOS[High(PRECOS)].TIPO             := 2;
          end;
          if TMARGEM(M.Itens[0]).VAL_MARGEM_PROMOCIONAL.Value > Now then begin
            PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := TMARGEM(M.Itens[0]).MARGEM_PROMOCIONAL.Value / 100;
            PRECOS[High(PRECOS)].TIPO             := 1;
          end;
          if TMARGEM(M.Itens[0]).VAL_PRECO_PROMOCIONAL.Value > Now then begin
            PRECOS[High(PRECOS)].PRECO_SUGESTAO   := TMARGEM(M.Itens[0]).PRECO_PROMOCIONAL.Value;
            PRECOS[High(PRECOS)].TIPO             := 2;
          end;
          if PRECOS[High(PRECOS)].TIPO = 1 then
            PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := PRECOS[High(PRECOS)].MARGEM_SUGERIDA + (TMARGEM(M.Itens[0]).PERCENTUAL_VPC.Value + TMARGEM(M.Itens[0]).PERCENTUAL_FRETE.Value + TMARGEM(M.Itens[0]).PERCENTUAL_OUTROS.Value) * 100;
        end;

        if PRECOS[High(PRECOS)].TIPO = 1 then begin
          if PRECOS[High(PRECOS)].MARGEM_SUGERIDA > 0 then
            PRECOS[High(PRECOS)].PRECOPOR         := PRECOS[High(PRECOS)].CUSTO_NOVO + (PRECOS[High(PRECOS)].CUSTO_NOVO * PRECOS[High(PRECOS)].MARGEM_SUGERIDA);
        end else begin
          if PRECOS[High(PRECOS)].PRECO_SUGESTAO > 0 then
            PRECOS[High(PRECOS)].PRECOPOR         := PRECOS[High(PRECOS)].PRECO_SUGESTAO;
        end;

        PRECOS[High(PRECOS)].PRECOPOR             := Trunc(PRECOS[High(PRECOS)].PRECOPOR) + 0.90;
        PRECOS[High(PRECOS)].PRECODE              := PRECOS[High(PRECOS)].PRECOPOR + (PRECOS[High(PRECOS)].PRECOPOR * 0.30);
        PRECOS[High(PRECOS)].MARGEM_PRATICAR      := (PRECOS[High(PRECOS)].PRECOPOR / PRECOS[High(PRECOS)].CUSTO_NOVO) - 1;
      end;
    end;
    lblMensagem.Caption := 'Processando Etapa 2 de 2.';
    Application.ProcessMessages;
    if Length(PRECOS) > 0 then begin
      FW.StartTransaction;
      try
        PR.ID.isNull;
        PR.DATA_HORA.Value                          := Now;
        PR.USUARIO_ID.Value                         := USUARIO.CODIGO;
        PR.Insert;
        BarradeProgresso.MaxValue                   := Length(PRECOS);
        BarradeProgresso.Progress                   := 0;
        for I := Low(PRECOS) to High(PRECOS) do begin
          PRI.ID.isNull                             := True;
          PRI.PRECIFICACAO_ID.Value                 := PR.ID.Value;
          PRI.ID_PRODUTO.Value                      := PRECOS[I].ID_PRODUTO;
          PRI.CUSTO_ANT.Value                       := PRECOS[I].CUSTO_ANT;
          PRI.CUSTO_ATUAL.Value                     := PRECOS[I].CUSTO_NOVO;
          PRI.PRECOESPECIAL.Value                   := PRECOS[I].PRECO_ESPECIAL;
          PRI.PRECOCADASTRO.Value                   := PRECOS[I].PRECO_CADASTRO;
          PRI.MARGEMSUGERIDA.Value                  := PRECOS[I].MARGEM_SUGERIDA;
          PRI.PRECODE.Value                         := PRECOS[I].PRECODE;
          PRI.PRECOPOR.Value                        := PRECOS[I].PRECOPOR;
          PRI.MARGEMPRATICAR.Value                  := PRECOS[I].MARGEM_PRATICAR;
          PRI.MEDIA.Value                           := PRECOS[I].MEDIA;
          PRI.TIPOCALCULO.Value                     := PRECOS[I].TIPO;
          PRI.Insert;

          BarradeProgresso.Progress                 := I;
          Application.ProcessMessages;
        end;
        FW.Commit;
        DisplayMsg(MSG_OK, 'Dados gerados com sucesso!');
      except
        on E : Exception do begin
          FW.Rollback;
          DisplayMsg(MSG_WAR, 'Dados gerados com problemas!', '', E.Message);
        end;
      end;
    end;
  finally
    FreeAndNil(PR);
    FreeAndNil(PRI);
    FreeAndNil(P);
    FreeAndNil(F);
    FreeAndNil(M);
    FreeAndNil(FW);
    lblMensagem.Caption := '';
    BarradeProgresso.Progress := 0;
  end;
end;

end.
