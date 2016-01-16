unit uGeraMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Comp.Client, Data.DB, System.Win.ComObj,
  Vcl.Samples.Gauges;

type
  TfrmGeraMatch = class(TForm)
    pnBotoes: TPanel;
    btSair: TSpeedButton;
    pnPrincipal: TPanel;
    IMFundo: TImage;
    GridPanel1: TGridPanel;
    Panel3: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    btGerar: TSpeedButton;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    btExportarEstoque: TSpeedButton;
    rgSaldoDisponivel: TRadioGroup;
    GridPanel2: TGridPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    cbLoteImportacao: TComboBox;
    BarradeProgresso: TGauge;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure btGerarClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btExportarEstoqueClick(Sender: TObject);
  private
    Procedure CarregaLote;
    procedure ExportarEstoque;
    procedure GerarMatch;
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

procedure TfrmGeraMatch.btExportarEstoqueClick(Sender: TObject);
begin
  if btExportarEstoque.Tag = 0 then begin
    btExportarEstoque.Tag := 1;
    try
      ExportarEstoque;
    finally
      btExportarEstoque.Tag := 0;
    end;
  end;
end;

procedure TfrmGeraMatch.btGerarClick(Sender: TObject);
begin
  if btGerar.Tag = 0 then begin
    btGerar.Tag := 1;
    try
      GerarMatch;
    finally
      btGerar.Tag := 0;
    end;
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

      L.SelectList('ID > 0','ID DESC LIMIT 10');

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

procedure TfrmGeraMatch.ExportarEstoque;
var
  PLANILHA,
  Sheet   : Variant;
  Linha   : Integer;
  FWC     : TFWConnection;
  Consulta: TFDQuery;
  DirArquivo : String;
  idLote  : Integer;
Begin

  idLote := StrToIntDef(Copy(cbLoteImportacao.Items[cbLoteImportacao.ItemIndex], 1, (Pos(' - ', cbLoteImportacao.Items[cbLoteImportacao.ItemIndex]) -1)),-1);
  if idLote = -1 then begin
    DisplayMsg(MSG_WAR, 'Não há lote selecionado, Verifique!');
    Exit;
  end;

  DirArquivo := DirArquivosExcel + FormatDateTime('ddmmyyyy', Date);

  if not DirectoryExists(DirArquivo) then begin
    if not ForceDirectories(DirArquivo) then begin
      DisplayMsg(MSG_WAR, 'Não foi possível criar o diretório,' + sLineBreak + DirArquivo + sLineBreak + 'Verifique!');
      Exit;
    end;
  end;

  DirArquivo := DirArquivo + '\Estoque.xlsx';

  if FileExists(DirArquivo) then begin
    DisplayMsg(MSG_CONF, 'Já existe um arquivo em,' + sLineBreak + DirArquivo + sLineBreak +
                          'Deseja Sobreescrever?');
    if ResultMsgModal <> mrYes then
      Exit;

    DeleteFile(DirArquivo);
  end;

  FWC       := TFWConnection.Create;
  Consulta  := TFDQuery.Create(nil);

  Try
    try

      Consulta.Close;
      Consulta.SQL.Clear;
      Consulta.SQL.Add('SELECT');
      Consulta.SQL.Add('	P.SKU,');
      Consulta.SQL.Add('	IMPI.QUANTIDADE AS SALDODISPONIVEL,');
      Consulta.SQL.Add('	A.NOME AS NOMEALMOXARIFADO FROM LOTE L');
      Consulta.SQL.Add('INNER JOIN IMPORTACAO IMP ON (L.ID = IMP.ID_LOTE)');
      Consulta.SQL.Add('INNER JOIN FORNECEDOR F ON (F.ID = IMP.ID_FORNECEDOR)');
      Consulta.SQL.Add('INNER JOIN ALMOXARIFADO A ON (A.ID = F.ID_ALMOXARIFADO)');
      Consulta.SQL.Add('INNER JOIN IMPORTACAO_ITENS IMPI ON (IMP.ID = IMPI.ID_IMPORTACAO)');
      Consulta.SQL.Add('INNER JOIN PRODUTO P ON (P.ID = IMPI.ID_PRODUTO)');
      Consulta.SQL.Add('WHERE IMP.ID_LOTE = :IDLOTE');

      case rgSaldoDisponivel.ItemIndex of
        0 : Consulta.SQL.Add('AND IMPI.QUANTIDADE > 0');//Com Saldo
        1 : Consulta.SQL.Add('AND IMPI.QUANTIDADE = 0');//Sem Saldo
      end;

      Consulta.SQL.Add('ORDER BY P.SKU');
      Consulta.Params[0].DataType := ftInteger;
      Consulta.Connection         := FWC.FDConnection;
      Consulta.Prepare;
      Consulta.Params[0].Value    := idLote;
      Consulta.Open;
      Consulta.FetchAll;

      if Not Consulta.IsEmpty then begin

        BarradeProgresso.Progress := 0;
        BarradeProgresso.MaxValue := Consulta.RecordCount;

        //cds_MatchItens.Filtered := False;
        Linha :=  2;
        PLANILHA := CreateOleObject('Excel.Application');
        PLANILHA.Caption := 'ESTOQUE';
        PLANILHA.Visible := False;
        PLANILHA.WorkBooks.add(1);
        PLANILHA.Workbooks[1].WorkSheets[1].Name := 'ESTOQUE';
        Sheet := PLANILHA.Workbooks[1].WorkSheets['ESTOQUE'];
        Sheet.Range['A1','C1'].Font.Bold  := True;
        Sheet.Range['A1','C1'].Font.Color := clBlue;

        // TITULO DAS COLUNAS
        PLANILHA.Cells[1,1] := 'IdentificadorProduto';
        PLANILHA.Cells[1,2] := 'SaldoDisponivel';
        PLANILHA.Cells[1,3] := 'Almoxarifado';

        Consulta.First;
        While not Consulta.Eof do Begin
          PLANILHA.Cells[Linha,1] := Consulta.FieldByName('SKU').AsString; //SKU
          PLANILHA.Cells[linha,2] := Consulta.FieldByName('SALDODISPONIVEL').AsString; //ESTOQUE
          PLANILHA.Cells[Linha,3] := Consulta.FieldByName('NOMEALMOXARIFADO').AsString; //ALMOXARIFADO
          Linha := Linha + 1;
          BarradeProgresso.Progress := Consulta.RecNo;
          Consulta.Next;
        End;

        PLANILHA.Columns.AutoFit;

        PLANILHA.WorkBooks[1].Sheets[1].SaveAs(DirArquivo);

        DisplayMsg(MSG_INF, 'Arquivo gerado com Sucesso em:' + sLineBreak + DirArquivo);
      end else
        DisplayMsg(MSG_WAR, 'Não há dados para Geração do Arquivo de Estoque, Verifique!');

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Gerar arquivo,' + sLineBreak + DirArquivo);
      end;
    end;
  Finally
    BarradeProgresso.Progress := 0;
    FreeAndNil(Consulta);
    FreeAndNil(FWC);
    if not VarIsEmpty(PLANILHA) then begin
      PLANILHA.Quit;
      PLANILHA := Unassigned;
    end;
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
  if FileExists(DirInstall + 'Imagens\Fundo.jpg') then
    IMFundo.Picture.LoadFromFile(DirInstall + 'Imagens\Fundo.jpg');
  CarregaLote;
end;

procedure TfrmGeraMatch.GerarMatch;
type
  TArLote = record
    idLote : Integer;
  end;
Var
  FWC           : TFWConnection;
  M             : TMATCH;
  MI            : TMATCH_ITENS;
  P             : TPRODUTO;
  SQL           : TFDQuery;
  SQLFORN       : TFDQuery;
  SQLULTIMOLOTE : TFDQuery;
  I             : Integer;
  ArLote        : array of TArLote;
  idLoteAnterior,
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

      SetLength(ArLote, 0);

      idLote := StrToIntDef(Copy(cbLoteImportacao.Items[cbLoteImportacao.ItemIndex], 1, (Pos(' - ', cbLoteImportacao.Items[cbLoteImportacao.ItemIndex]) -1)),-1);
      if idLote = -1 then begin
        DisplayMsg(MSG_WAR, 'Não há lote selecionado, Verifique!');
        Exit;
      end;

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('MAX(L.ID) AS MAIORLOTE');
      SQL.SQL.Add('FROM LOTE L INNER JOIN MATCH M ON (L.ID = M.ID_LOTE)');
      SQL.Connection  := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open;
      SQL.FetchAll;

      if SQL.FieldByName('MAIORLOTE').AsInteger > idLote then begin
        DisplayMsg(MSG_WAR, 'Já existe Match para Lote posterior, não permitido gerar Match, Verifique!');
        Exit;
      end;

      idLoteAnterior := SQL.FieldByName('MAIORLOTE').AsInteger + 1;

      if idLoteAnterior < idLote then begin
        DisplayMsg(MSG_CONF, 'Existem Lotes anteriores sem Gerar o Match' + sLineBreak + 'Deseja Gerar para Todos agora?');
        if ResultMsgModal = mrYes then begin
          while idLoteAnterior < idLote do begin
            SetLength(ArLote, Length(ArLote) + 1);
            ArLote[High(ArLote)].idLote := idLoteAnterior;
            idLoteAnterior := idLoteAnterior + 1;
          end;
        end;
      end;

      //Adiciona o Lote Selecionado para Gerar
      SetLength(ArLote, Length(ArLote) + 1);
      ArLote[High(ArLote)].idLote := idLote;

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

      for I := Low(ArLote) to High(ArLote) do begin

        BarradeProgresso.Progress := 0;

        DisplayMsg(MSG_WAIT, 'Gerando Match para o Lote ' + IntToStr(ArLote[I].idLote));

        FWC.StartTransaction;

        SQL.Close;
        SQL.Prepare;
        SQL.Params[0].Value      := ArLote[I].idLote; //Passa o ID do Lote
        SQL.Open;
        SQL.FetchAll;

        if not SQL.IsEmpty then begin

          M.ID.isNull         := True;
          M.ID_LOTE.Value     := ArLote[I].idLote;
          M.DATA_HORA.Value   := Now;
          M.ID_USUARIO.Value  := USUARIO.CODIGO;
          M.Insert;

          BarradeProgresso.MaxValue   := SQL.RecordCount;
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
            MI.ID_ULTIMOLOTE.Value          := 0;

            //Verifica ultimo lote para o Produto
            SQLULTIMOLOTE.Close;
            SQLULTIMOLOTE.Prepare;
            SQLULTIMOLOTE.Params[0].Value := ArLote[I].idLote; //Passa o IDLOTE
            SQLULTIMOLOTE.Params[1].Value := SQL.Fields[0].Value; //Passa o IDPRODUTO
            SQLULTIMOLOTE.Open;
            if not SQLULTIMOLOTE.IsEmpty then
              MI.ID_ULTIMOLOTE.Value   := SQLULTIMOLOTE.Fields[0].Value; //id_ultimolote

            //Verifica se tem Fornecedor com Custo Menor
            SQLFORN.Close;
            SQLFORN.Prepare;
            SQLFORN.Params[0].Value := ArLote[I].idLote; //Passa o IDLOTE
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
                MI.ATUALIZADO.Value         := ((MI.ID_FORNECEDORNOVO.Value <> MI.ID_FORNECEDORANTERIOR.Value) or (MI.CUSTONOVO.Value <> MI.CUSTOANTERIOR.Value));
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
              if ArLote[I].idLote > P.ID_ULTIMOLOTE.Value then
                P.ID_ULTIMOLOTE.Value       := ArLote[I].idLote;

              if MI.ATUALIZADO.Value = True then begin //Caso tenha Match/tenha atualização
                P.CUSTOANTERIOR.Value         := P.CUSTO.Value;
                P.ID_FORNECEDORANTERIOR.Value := P.ID_FORNECEDORNOVO.Value;
                P.CUSTO.Value                 := MI.CUSTONOVO.Value;
                P.ID_FORNECEDORNOVO.Value     := MI.ID_FORNECEDORNOVO.Value;
              end;

              P.Update;
            end;

            MI.Insert;

            BarradeProgresso.Progress       := SQL.RecNo + 1;
            Application.ProcessMessages;
            SQL.Next;
          end;

          FWC.Commit;

        end else
          DisplayMsg(MSG_WAR, 'Não há Dados de Importação para o Lote ' + IntToStr(ArLote[I].idLote) + sLineBreak + 'O Match não será gerado, Verifique!');
      end;

      DisplayMsg(MSG_INF, 'Geração de Match Concluído com Sucesso!');

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importação', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    BarradeProgresso.Progress := 0;
    FreeAndNil(SQLULTIMOLOTE);
    FreeAndNil(SQLFORN);
    FreeAndNil(SQL);
    FreeAndNil(MI);
    FreeAndNil(M);
    FreeAndNil(P);
    FreeAndNil(FWC);
  end;
end;

end.
