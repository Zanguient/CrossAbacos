unit uGeraMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Comp.Client, Data.DB;

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
    procedure FormResize(Sender: TObject);
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
  uBeanProduto,
  uBeanMatch,
  uConstantes, uBeanMatch_Itens;

{$R *.dfm}

procedure TfrmGeraMatch.btGerarClick(Sender: TObject);
Var
  FWC           : TFWConnection;
  M             : TMATCH;
  MI            : TMATCH_ITENS;
  P             : TPRODUTO;
  SQL           : TFDQuery;
  SQLFORN       : TFDQuery;
  SQLULTIMOLOTE : TFDQuery;
  I             : Integer;
  idLote        : Integer;
  AlteraForn    : Boolean;
begin

  FWC           := TFWConnection.Create;
  M             := TMATCH.Create(FWC);
  MI            := TMATCH_ITENS.Create(FWC);
  P             := TPRODUTO.Create(FWC);
  SQL           := TFDQuery.Create(nil);
  SQLFORN       := TFDQuery.Create(nil);
  SQLULTIMOLOTE := TFDQuery.Create(nil);

  try
    try

      lbProgresso.Caption := '0 %';

      idLote := StrToIntDef(Copy(cbLoteImportacao.Items[cbLoteImportacao.ItemIndex], 1, (Pos(' - ', cbLoteImportacao.Items[cbLoteImportacao.ItemIndex]) -1)),-1);
      if idLote = -1 then begin
        DisplayMsg(MSG_WAR, 'Não há lote selecionado, Verifique!');
        Exit;
      end;

      //SQL FORNECEDOR
      SQLFORN.Close;
      SQLFORN.SQL.Clear;
      SQLFORN.SQL.Add('SELECT');
      SQLFORN.SQL.Add('	F.ID,');
      SQLFORN.SQL.Add('	F.NOME,');
      SQLFORN.SQL.Add('	IMPI.CUSTO AS CUSTOATUAL');
      SQLFORN.SQL.Add('FROM LOTE L INNER JOIN IMPORTACAO IMP ON (IMP.ID_LOTE = L.ID)');
      SQLFORN.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMPI.ID_IMPORTACAO = IMP.ID)');
      SQLFORN.SQL.Add('INNER JOIN FORNECEDOR F ON (F.ID = IMP.ID_FORNECEDOR)');
      SQLFORN.SQL.Add('WHERE L.ID = :IDLOTE AND IMPI.ID_PRODUTO = :IDPRODUTO AND IMPI.CUSTO > 0');
      SQLFORN.SQL.Add('AND IMPI.QUANTIDADE > 0');
      SQLFORN.SQL.Add('ORDER BY IMPI.CUSTO ASC');
      SQLFORN.Params[0].DataType := ftInteger;
      SQLFORN.Params[1].DataType := ftInteger;
      SQLFORN.Connection  := FWC.FDConnection;

      //SQL DO ÚLTIMO LOTE
      SQLULTIMOLOTE.Close;
      SQLULTIMOLOTE.SQL.Clear;
      SQLULTIMOLOTE.SQL.Add('SELECT');
      SQLULTIMOLOTE.SQL.Add('COALESCE(MAX(L.ID),0) AS ULTIMOLOTE');
      SQLULTIMOLOTE.SQL.Add('FROM LOTE L INNER JOIN IMPORTACAO IMP ON (L.ID = IMP.ID_LOTE)');
      SQLULTIMOLOTE.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO)');
      SQLULTIMOLOTE.SQL.Add('WHERE IMPI.STATUS = 1 AND L.ID < :IDLOTE AND IMPI.ID_PRODUTO = :IDPRODUTO');
      SQLULTIMOLOTE.Params[0].DataType := ftInteger;
      SQLULTIMOLOTE.Params[1].DataType := ftInteger;
      SQLULTIMOLOTE.Connection  := FWC.FDConnection;

      //SQL BUSCA PRODUTOS
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('P.ID,');
      SQL.SQL.Add('P.CUSTO,');
      SQL.SQL.Add('COALESCE(F.ID,0) AS ID_FORNECEDOR');
      SQL.SQL.Add('FROM PRODUTO P');
      SQL.SQL.Add('LEFT JOIN FORNECEDOR F ON (UPPER(P.SUB_GRUPO) = UPPER(F.NOME))');
      SQL.SQL.Add('WHERE P.ID IN (SELECT IMPI.ID_PRODUTO FROM IMPORTACAO IMP INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO AND IMP.ID_LOTE = :IDLOTE AND IMPI.STATUS = 1))');
      SQL.Params[0].DataType   := ftInteger;
      SQL.Connection           := FWC.FDConnection;
      SQL.Prepare;
      SQL.Params[0].Value      := idLote; //Passa o ID do Lote
      SQL.Open;
      SQL.FetchAll;

      DisplayMsg(MSG_WAIT, 'Gerando Match!');

      if not SQL.IsEmpty then begin

        M.ID.isNull         := True;
        M.ID_LOTE.Value     := idLote;
        M.DATA_HORA.Value   := Now;
        M.ID_USUARIO.Value  := USUARIO.CODIGO;
        M.Insert;

        ProgressBar1.Max := SQL.RecordCount;
        SQL.First;

        while not SQL.Eof do begin

          MI.ID.isNull                    := True;
          MI.ID_MATCH.Value               := M.ID.Value; //id_match
          MI.ID_PRODUTO.Value             := SQL.Fields[0].Value; //id_produto
          MI.CUSTOANTERIOR.Value          := SQL.Fields[1].Value; //custoanterior
          MI.ID_FORNECEDORANTERIOR.Value  := SQL.Fields[2].Value; //id_fornecedoranterior
          MI.CUSTONOVO.Value              := SQL.Fields[1].Value; //custonovo
          MI.ID_FORNECEDORNOVO.Value      := SQL.Fields[2].Value; //id_fornecedornovo
          MI.ATUALIZADO.Value             := False;
          MI.IMPORTADO.Value              := False;
          MI.ID_ULTIMOLOTE.Value          := 0;

          //Verifica ultimo lote para o Produto
          SQLULTIMOLOTE.Close;
          SQLULTIMOLOTE.Prepare;
          SQLULTIMOLOTE.Params[0].Value := idLote; //Passa o IDLOTE
          SQLULTIMOLOTE.Params[1].Value := SQL.Fields[0].Value; //Passa o IDPRODUTO
          SQLULTIMOLOTE.Open;
          if not SQLULTIMOLOTE.IsEmpty then
            MI.ID_ULTIMOLOTE.Value   := SQLULTIMOLOTE.Fields[0].Value; //id_ultimolote

          //Verifica se tem Fornecedor com Custo Menor
          SQLFORN.Close;
          SQLFORN.Prepare;
          SQLFORN.Params[0].Value := idLote; //Passa o IDLOTE
          SQLFORN.Params[1].Value := SQL.Fields[0].Value; //Passa o IDPRODUTO
          SQLFORN.Open;

          if not SQLFORN.IsEmpty then begin

            AlteraForn := False;

            SQLFORN.First;
            while not SQLFORN.Eof do begin
              if SQLFORN.Fields[0].Value = SQL.Fields[2].Value then begin
                AlteraForn := True;
                Break;
              end;
              SQLFORN.Next;
            end;

            SQLFORN.First;
            if ((AlteraForn) OR (SQLFORN.Fields[2].Value < SQL.Fields[1].Value)) then begin
              MI.ID_FORNECEDORNOVO.Value  := SQLFORN.Fields[0].Value;
              MI.CUSTONOVO.Value          := SQLFORN.Fields[2].Value;
              MI.ATUALIZADO.Value         := True;
            end;
          end;

          P.SelectList('ID = ' + MI.ID_PRODUTO.asString);
          if P.Count > 0 then begin
            P.ID.Value                    := TPRODUTO(P.Itens[0]).ID.Value;
            P.CUSTOANTERIOR.Value         := TPRODUTO(P.Itens[0]).CUSTOANTERIOR.Value;
            P.CUSTO.Value                 := TPRODUTO(P.Itens[0]).CUSTO.Value;
            P.ID_ULTIMOLOTE.Value         := TPRODUTO(P.Itens[0]).ID_ULTIMOLOTE.Value;
            P.ID_FORNECEDORANTERIOR.Value := TPRODUTO(P.Itens[0]).ID_FORNECEDORANTERIOR.Value;
            P.ID_FORNECEDORNOVO.Value     := TPRODUTO(P.Itens[0]).ID_FORNECEDORNOVO.Value;

            //Atualiza o último lote para o produto caso for maior
            if idLote > P.ID_ULTIMOLOTE.Value then
              P.ID_ULTIMOLOTE.Value       := idLote;

            if MI.ATUALIZADO.Value = True then begin //Caso tenha Match/tenha atualização
              P.CUSTOANTERIOR.Value         := P.CUSTO.Value;
              P.ID_FORNECEDORANTERIOR.Value := P.ID_FORNECEDORNOVO.Value;
              P.CUSTO.Value                 := MI.CUSTONOVO.Value;
              P.ID_FORNECEDORNOVO.Value     := MI.ID_FORNECEDORNOVO.Value;
            end;

            P.Update;
          end;

          MI.Insert;

          ProgressBar1.Position := SQL.RecNo + 1;
          lbProgresso.Caption := FormatCurr('0.00', (ProgressBar1.Position * 100) / ProgressBar1.Max) + ' %';
          Application.ProcessMessages;
          SQL.Next;
        end;

        FWC.Commit;

        DisplayMsg(MSG_INF, 'Match gerado com Sucesso!');
      end;

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importação', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    DisplayMsgFinaliza;
    lbProgresso.Caption   := '0 %';
    ProgressBar1.Position := 0;
    FreeAndNil(SQLULTIMOLOTE);
    FreeAndNil(SQLFORN);
    FreeAndNil(SQL);
    FreeAndNil(MI);
    FreeAndNil(M);
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

procedure TfrmGeraMatch.FormResize(Sender: TObject);
begin
  cbLoteImportacao.Top  := Self.Height div 2;
  cbLoteImportacao.Left := ((Self.Width div 2) - (cbLoteImportacao.Width div 2));
end;

procedure TfrmGeraMatch.FormShow(Sender: TObject);
begin
  CarregaLote;
end;

end.
