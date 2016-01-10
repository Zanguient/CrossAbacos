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
  SQL           : TFDQuery;
  SQLI          : TFDQuery;
  SQLFORN       : TFDQuery;
  SQLULTIMOLOTE : TFDQuery;
  I             : Integer;
  idLote        : Integer;
  AlteraForn    : Boolean;
begin

  FWC           := TFWConnection.Create;
  M             := TMATCH.Create(FWC);
  SQL           := TFDQuery.Create(nil);
  SQLI          := TFDQuery.Create(nil);
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

      //Verifica se o Lote já possui Match gravado
      M.SelectList('ID_LOTE = ' + IntToStr(idLote));
      if M.Count > 0 then begin
        DisplayMsg(MSG_CONF, 'Já existe Match para este Lote!' + sLineBreak + 'Deseja Sobreescrever o Match desse Lote?');
        if ResultMsgModal <> mrYes then
          Exit;
        M.ID.Value  := TMATCH(M.Itens[0]).ID.Value;
        M.Delete;
      end;

      //SQL DE INSERÇÃO
      SQLI.Close;
      SQLI.SQL.Clear;
      SQLI.SQL.ADD('INSERT INTO MATCH_ITENS(');
      SQLI.SQL.ADD('            ID_MATCH, ID_PRODUTO, CUSTOANTERIOR, CUSTONOVO, ID_FORNECEDORANTERIOR,');
      SQLI.SQL.ADD('            ID_FORNECEDORNOVO, ATUALIZADO, IMPORTADO, ID_ULTIMOLOTE)');
      SQLI.SQL.ADD('    VALUES (:ID_MATCH, :ID_PRODUTO, :CUSTOANTERIOR, :CUSTONOVO, :ID_FORNECEDORANTERIOR, :ID_FORNECEDORNOVO, :ATUALIZADO, :IMPORTADO, :ID_ULTIMOLOTE)');      SQLI.Params[0].DataType   := ftInteger; //id_match
      SQLI.Params[1].DataType   := ftInteger; //id_produto
      SQLI.Params[2].DataType   := ftCurrency;//custoanterior
      SQLI.Params[3].DataType   := ftCurrency; //custonovo
      SQLI.Params[4].DataType   := ftInteger; //id_fornecedoranterior
      SQLI.Params[5].DataType   := ftInteger; //id_fornecedornovo
      SQLI.Params[6].DataType   := ftBoolean; //atualizado
      SQLI.Params[7].DataType   := ftBoolean; //importado
      SQLI.Params[8].DataType   := ftInteger; //id_ultimolote
      SQLI.Connection           := FWC.FDConnection;

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
      SQL.SQL.Add('WHERE P.ID IN (SELECT IMPI.ID FROM IMPORTACAO IMP INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO AND IMP.ID_LOTE = :IDLOTE AND IMPI.STATUS = 1))');
      SQL.Params[0].DataType   := ftInteger;
      SQL.Connection           := FWC.FDConnection;
      SQL.Prepare;
      SQL.Params[0].Value      := idLote; //Passa o ID do Lote
      SQL.Open;
      SQL.FetchAll;

      if not SQL.IsEmpty then begin

        M.ID.isNull         := True;
        M.ID_LOTE.Value     := idLote;
        M.DATA_HORA.Value   := Now;
        M.ID_USUARIO.Value  := USUARIO.CODIGO;
        M.Insert;

        ProgressBar1.Max := SQL.RecordCount;
        SQL.First;

        while not SQL.Eof do begin

          SQLI.Close;
          SQLI.Prepare;
          SQLI.Params[0].Value   := M.ID.Value; //id_match
          SQLI.Params[1].Value   := SQL.Fields[0].Value; //id_produto
          SQLI.Params[2].Value   := SQL.Fields[1].Value; //custoanterior
          SQLI.Params[4].Value   := SQL.Fields[2].Value; //id_fornecedoranterior
          SQLI.Params[3].Value   := SQL.Fields[1].Value; //custonovo
          SQLI.Params[5].Value   := SQL.Fields[2].Value; //id_fornecedornovo
          SQLI.Params[6].Value   := False; //atualizado
          SQLI.Params[7].Value   := False; //importado
          SQLI.Params[8].Value   := 0; //id_ultimolote

          //Verifica ultimo lote para o Produto
          SQLULTIMOLOTE.Close;
          SQLULTIMOLOTE.Prepare;
          SQLULTIMOLOTE.Params[0].Value := idLote; //Passa o IDLOTE
          SQLULTIMOLOTE.Params[1].Value := SQL.Fields[0].Value; //Passa o IDPRODUTO
          SQLULTIMOLOTE.Open;
          if not SQLULTIMOLOTE.IsEmpty then
            SQLI.Params[8].Value   := SQLULTIMOLOTE.Fields[0].Value; //id_ultimolote

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
              if SQLFORN.Fields[0].Value = SQL.Fields[0].Value then begin
                AlteraForn := True;
                Break;
              end;
              SQLFORN.Next;
            end;

            SQLFORN.First;
            if ((AlteraForn) OR (SQLFORN.Fields[2].Value < SQL.Fields[1].Value)) then begin
              SQLI.Params[5].Value  := SQLFORN.Fields[0].Value;
              SQLI.Params[3].Value  := SQLFORN.Fields[2].Value;
              SQLI.Params[6].Value  := True;
            end;
          end;

          SQLI.ExecSQL;

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
    lbProgresso.Caption   := '0 %';
    ProgressBar1.Position := 0;
    FreeAndNil(SQLULTIMOLOTE);
    FreeAndNil(SQLFORN);
    FreeAndNil(SQLI);
    FreeAndNil(SQL);
    FreeAndNil(M);
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
