unit uGeraPrecificacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Comp.Client, Data.DB, System.Win.ComObj,
  Vcl.Samples.Gauges, JvExStdCtrls, JvEdit, JvValidateEdit;

type
  TfrmGeraPrecificacao = class(TForm)
    pnBotoes: TPanel;
    btSair: TSpeedButton;
    BarradeProgresso: TGauge;
    btGerar: TSpeedButton;
    lblMensagem: TLabel;
    pnMedia: TPanel;
    edMedia: TJvValidateEdit;
    Label1: TLabel;
    procedure btGerarClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure GerarPrecificacao;
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
  uMensagem, System.IniFiles;
{$R *.dfm}

{ TfrmGeraPrecificacao }

procedure TfrmGeraPrecificacao.btGerarClick(Sender: TObject);
begin
  if btGerar.Tag = 0 then begin
    btGerar.Tag := 1;
    try
      GerarPrecificacao;
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
var
  arqIni : TiniFile;
begin
  arqIni := TIniFile.Create(DirArqConf);
  try
    arqIni.WriteString('CONFIGURACOES', 'MEDIA', edMedia.Text);
  finally
    FreeAndNil(arqIni);
  end;

  frmGeraPrecificacao := nil;
  Action              := caFree;
end;

procedure TfrmGeraPrecificacao.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmGeraPrecificacao.FormShow(Sender: TObject);
var
  arqIni : TiniFile;
begin
  arqIni := TIniFile.Create(DirArqConf);
  try
    edMedia.Text := arqIni.ReadString('CONFIGURACOES', 'MEDIA', '0');
  finally
    FreeAndNil(arqIni);
  end;
end;

procedure TfrmGeraPrecificacao.GerarPrecificacao;
var
  FWC    : TFWConnection;
  PRECOS : array of TPRECOS;
  SQL    : TFDQuery;
  PR     : TPRECIFICACAO;
  PRI    : TPRECIFICACAO_ITENS;
  P      : TPRODUTO;
  I      : Integer;
begin

  FWC  := TFWConnection.Create;
  SQL  := TFDQuery.Create(nil);
  PR   := TPRECIFICACAO.Create(FWC);
  PRI  := TPRECIFICACAO_ITENS.Create(FWC);
  P    := TPRODUTO.Create(FWC);

  SetLength(PRECOS, 0);

  try
    lblMensagem.Caption := 'Processando Etapa 1 de 2.';
    Application.ProcessMessages;

    SQL.Close;
    SQL.SQL.Clear;
    SQL.SQL.Add('SELECT');
    SQL.SQL.Add('	P.ID,');
    SQL.SQL.Add('	P.SKU,');
    SQL.SQL.Add(' P.IMPORTADO,');
    SQL.SQL.Add('	COALESCE(P.CUSTO_ESTOQUE_FISICO, 0.00) AS CUSTO_ESTOQUE_FISICO,');
    SQL.SQL.Add('	COALESCE(P.CUSTO_EST_FISICO_ANT, 0.00) AS CUSTO_EST_FISICO_ANT,');
    SQL.SQL.Add('	COALESCE(P.CUSTOFINALANTERIOR, 0.00) AS CUSTOFINALANTERIOR,');
    SQL.SQL.Add('	COALESCE(P.CUSTOFINAL, 0.00) AS CUSTOFINAL,');
    SQL.SQL.Add('	COALESCE(P.PRECO_VENDA, 0.00) AS PRECO_VENDA,');
    SQL.SQL.Add('	COALESCE(P.MEDIA_ALTERACAO, 0.00) AS MEDIA_ALTERACAO,');
    SQL.SQL.Add('	COALESCE(F.MARGEM, 0.0000) AS MARGEM_FAMILIA,');
    SQL.SQL.Add('	COALESCE(M.MARGEM_ANALISTA, 0.0000) AS MARGEM_ANALISTA,');
    SQL.SQL.Add('	COALESCE(M.PRECO_PONTA, 0.00) AS PRECO_PONTA,');
    SQL.SQL.Add('	COALESCE(PERCENTUAL_VPC, 0.00) AS PERCENTUAL_VPC,');
    SQL.SQL.Add('	COALESCE(PERCENTUAL_FRETE, 0.00) AS PERCENTUAL_FRETE,');
    SQL.SQL.Add('	COALESCE(PERCENTUAL_OUTROS, 0.00) AS PERCENTUAL_OUTROS,');
    SQL.SQL.Add('	CASE WHEN (CAST(M.VAL_MARGEM_PROMOCIONAL AS DATE) >= CURRENT_DATE) THEN COALESCE(M.MARGEM_PROMOCIONAL, 0.0000) ELSE 0.0000 END AS MARGEM_PROMOCIONAL,');
    SQL.SQL.Add('	CASE WHEN (CAST(M.VAL_PRECO_PROMOCIONAL AS DATE) >= CURRENT_DATE) THEN COALESCE(M.PRECO_PROMOCIONAL, 0.0000) ELSE 0.0000 END AS PRECO_PROMOCIONAL');
    SQL.SQL.Add('FROM PRODUTO P');
    SQL.SQL.Add('INNER JOIN FAMILIA F ON (P.ID_FAMILIA = F.ID)');
    SQL.SQL.Add('LEFT JOIN MARGEM M ON (P.ID = M.ID_PRODUTO)');
    SQL.SQL.Add('WHERE 1 = 1');
    SQL.SQL.Add('AND ((P.CUSTOFINAL > 0) OR (P.QUANTIDADE_ESTOQUE_FISICO > 0))');
    SQL.SQL.Add('ORDER BY P.ID');
    SQL.Connection  := FWC.FDConnection;
    SQL.Prepare;
    SQL.Open;
    SQL.FetchAll;

    if not SQL.IsEmpty then begin
      BarradeProgresso.MaxValue := SQL.RecordCount;
      SQL.First;
      while not SQL.Eof do begin
        SetLength(PRECOS, Length(PRECOS) + 1);
        PRECOS[High(PRECOS)].TIPO               := eNenhum;
        PRECOS[High(PRECOS)].ID_PRODUTO         := SQL.FieldByName('ID').AsInteger;
        PRECOS[High(PRECOS)].SKU                := SQL.FieldByName('SKU').AsString;
        PRECOS[High(PRECOS)].PRECO_CADASTRO     := SQL.FieldByName('PRECO_VENDA').AsCurrency;
        PRECOS[High(PRECOS)].MEDIA              := StrToCurr(edMedia.Text) / 100;
        PRECOS[High(PRECOS)].PERCENTUAL_VPC     := SQL.FieldByName('PERCENTUAL_VPC').AsCurrency;
        PRECOS[High(PRECOS)].PERCENTUAL_FRETE   := SQL.FieldByName('PERCENTUAL_FRETE').AsCurrency;
        PRECOS[High(PRECOS)].PERCENTUAL_OUTROS  := SQL.FieldByName('PERCENTUAL_OUTROS').AsCurrency;
        PRECOS[High(PRECOS)].CUSTOFINAL_ANT     := 0.00;
        PRECOS[High(PRECOS)].CUSTOFINAL_NOVO    := 0.00;
        PRECOS[High(PRECOS)].PRECO_ESPECIAL     := 0.00;
        PRECOS[High(PRECOS)].MARGEM_SUGERIDA    := 0.00;
        PRECOS[High(PRECOS)].PRECO_SUGESTAO     := 0.00;
        PRECOS[High(PRECOS)].PRECODE            := 0.00;
        PRECOS[High(PRECOS)].PRECOPOR           := 0.00;
        PRECOS[High(PRECOS)].MARGEM_PRATICAR    := 0.00;

        if SQL.FieldByName('CUSTO_ESTOQUE_FISICO').AsCurrency > 0.00 then begin
          PRECOS[High(PRECOS)].CUSTOFINAL_ANT          := SQL.FieldByName('CUSTO_EST_FISICO_ANT').AsCurrency;
          PRECOS[High(PRECOS)].CUSTOFINAL_NOVO         := SQL.FieldByName('CUSTO_ESTOQUE_FISICO').AsCurrency;
        end else begin
          PRECOS[High(PRECOS)].CUSTOFINAL_ANT          := SQL.FieldByName('CUSTOFINALANTERIOR').AsCurrency;
          PRECOS[High(PRECOS)].CUSTOFINAL_NOVO         := SQL.FieldByName('CUSTOFINAL').AsCurrency;
        end;

        if SQL.FieldByName('MARGEM_FAMILIA').AsCurrency > 0.00 then begin
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA    := SQL.FieldByName('MARGEM_FAMILIA').AsCurrency / 100;
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA    := (PRECOS[High(PRECOS)].MARGEM_SUGERIDA + (PRECOS[High(PRECOS)].PERCENTUAL_VPC + PRECOS[High(PRECOS)].PERCENTUAL_FRETE + PRECOS[High(PRECOS)].PERCENTUAL_OUTROS)) * 100;
          PRECOS[High(PRECOS)].TIPO               := eMargem;
        end;

        if SQL.FieldByName('MARGEM_ANALISTA').AsCurrency > 0.00 then begin
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := SQL.FieldByName('MARGEM_ANALISTA').AsCurrency / 100;
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := (PRECOS[High(PRECOS)].MARGEM_SUGERIDA + (PRECOS[High(PRECOS)].PERCENTUAL_VPC + PRECOS[High(PRECOS)].PERCENTUAL_FRETE + PRECOS[High(PRECOS)].PERCENTUAL_OUTROS)) * 100;
          PRECOS[High(PRECOS)].TIPO             := eMargem;
        end;

        if SQL.FieldByName('IMPORTADO').AsInteger = 0 then
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := PRECOS[High(PRECOS)].MARGEM_SUGERIDA + 0.045
        else
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := PRECOS[High(PRECOS)].MARGEM_SUGERIDA + 0.038;

        if SQL.FieldByName('PRECO_PONTA').AsCurrency > 0.00 then begin
          PRECOS[High(PRECOS)].PRECO_SUGESTAO   := SQL.FieldByName('PRECO_PONTA').AsCurrency;
          PRECOS[High(PRECOS)].PRECO_ESPECIAL   := PRECOS[High(PRECOS)].PRECO_SUGESTAO;
          PRECOS[High(PRECOS)].TIPO             := ePrecoEspecial;
        end;

        if SQL.FieldByName('MARGEM_PROMOCIONAL').AsCurrency > 0.00 then begin
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := SQL.FieldByName('MARGEM_PROMOCIONAL').AsCurrency / 100;
          PRECOS[High(PRECOS)].MARGEM_SUGERIDA  := (PRECOS[High(PRECOS)].MARGEM_SUGERIDA + (PRECOS[High(PRECOS)].PERCENTUAL_VPC + PRECOS[High(PRECOS)].PERCENTUAL_FRETE + PRECOS[High(PRECOS)].PERCENTUAL_OUTROS)) * 100;
          PRECOS[High(PRECOS)].TIPO             := eMargem;
        end;

        if SQL.FieldByName('PRECO_PROMOCIONAL').AsCurrency > 0.00 then begin
          PRECOS[High(PRECOS)].PRECO_SUGESTAO   := SQL.FieldByName('PRECO_PROMOCIONAL').AsCurrency;
          PRECOS[High(PRECOS)].PRECO_ESPECIAL   := PRECOS[High(PRECOS)].PRECO_SUGESTAO;
          PRECOS[High(PRECOS)].TIPO             := ePrecoEspecial;
        end;

        case PRECOS[High(PRECOS)].TIPO of
          eMargem : begin
            if PRECOS[High(PRECOS)].MARGEM_SUGERIDA > 0 then
              PRECOS[High(PRECOS)].PRECOPOR         := PRECOS[High(PRECOS)].CUSTOFINAL_NOVO + (PRECOS[High(PRECOS)].CUSTOFINAL_NOVO * PRECOS[High(PRECOS)].MARGEM_SUGERIDA);
          end;
          ePrecoEspecial : begin
            if PRECOS[High(PRECOS)].PRECO_SUGESTAO > 0 then
              PRECOS[High(PRECOS)].PRECOPOR         := PRECOS[High(PRECOS)].PRECO_SUGESTAO;
          end;
        end;

        PRECOS[High(PRECOS)].PRECOPOR             := Trunc(PRECOS[High(PRECOS)].PRECOPOR) + 0.90;
        PRECOS[High(PRECOS)].PRECODE              := PRECOS[High(PRECOS)].PRECOPOR + (PRECOS[High(PRECOS)].PRECOPOR * 0.30);
        PRECOS[High(PRECOS)].MARGEM_PRATICAR      := (PRECOS[High(PRECOS)].PRECOPOR / PRECOS[High(PRECOS)].CUSTOFINAL_NOVO) - 1;

        BarradeProgresso.Progress := BarradeProgresso.Progress + 1;

        SQL.Next;
      end;
    end;

    lblMensagem.Caption := 'Processando Etapa 2 de 2.';
    Application.ProcessMessages;
    if Length(PRECOS) > 0 then begin

      BarradeProgresso.MaxValue     := Length(PRECOS);
      BarradeProgresso.Progress     := 0;

      FWC.StartTransaction;
      try
        PR.ID.isNull                  := True;
        PR.DATA_HORA.Value            := Now;
        PR.USUARIO_ID.Value           := USUARIO.CODIGO;
        PR.Insert;

        for I := Low(PRECOS) to High(PRECOS) do begin
          PRI.ID.isNull               := True;
          PRI.PRECIFICACAO_ID.Value   := PR.ID.Value;
          PRI.ID_PRODUTO.Value        := PRECOS[I].ID_PRODUTO;
          PRI.CUSTO_ANT.Value         := PRECOS[I].CUSTOFINAL_ANT;
          PRI.CUSTO_ATUAL.Value       := PRECOS[I].CUSTOFINAL_NOVO;
          PRI.PRECOESPECIAL.Value     := PRECOS[I].PRECO_ESPECIAL;
          PRI.PRECOCADASTRO.Value     := PRECOS[I].PRECO_CADASTRO;
          PRI.MARGEMSUGERIDA.Value    := PRECOS[I].MARGEM_SUGERIDA;
          PRI.PRECODE.Value           := PRECOS[I].PRECODE;
          PRI.PRECOPOR.Value          := PRECOS[I].PRECOPOR;
          PRI.MARGEMPRATICAR.Value    := PRECOS[I].MARGEM_PRATICAR;
          PRI.MEDIA.Value             := PRECOS[I].MEDIA;
          PRI.TIPOCALCULO.Value       := Integer(PRECOS[I].TIPO);
          PRI.Insert;

//          P.ID.Value                  := PRECOS[I].ID_PRODUTO;
//          P.PRECO_VENDA.Value         := PRECOS[I].PRECOPOR;
//          P.Update;

          BarradeProgresso.Progress   := I;
          Application.ProcessMessages;
        end;

        FWC.Commit;

        DisplayMsg(MSG_OK, 'Dados gerados com sucesso!');

      except
        on E : Exception do begin
          FWC.Rollback;
          DisplayMsg(MSG_WAR, 'Dados gerados com problemas!', '', E.Message);
        end;
      end;
    end;
  finally
    FreeAndNil(SQL);
    FreeAndNil(P);
    FreeAndNil(PR);
    FreeAndNil(PRI);
    FreeAndNil(FWC);
    lblMensagem.Caption := '';
    BarradeProgresso.Progress := 0;
  end;
end;

end.
