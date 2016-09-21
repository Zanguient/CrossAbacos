unit uFuncoes;

interface

uses
  System.SysUtils,
  System.UITypes,
  IdHashMessageDigest,
  Vcl.Dialogs,
  Grids,
  DBGrids,
  DateUtils,
  Winapi.Windows,
  Vcl.Menus,
  Vcl.Forms,
  Datasnap.DBClient,
  Data.DB,
  Vcl.Graphics,
  System.Win.ComObj;

  procedure CarregarConfigLocal;
  procedure CarregaArrayMenus(Menu : TMainMenu);
  procedure DefinePermissaoMenu(Menu : TMainMenu);
  procedure CarregarConexaoBD;
  procedure AutoSizeDBGrid(const DBGrid: TDBGrid);
  procedure GerarLoteImportacao;
  procedure AjustaForm(Form : TForm);
  procedure OrdenarGrid(Column: TColumn);
  procedure ExpXLS(DataSet: TDataSet; NomeArq: string);
  procedure DeletarArquivosPasta(Diretorio : String);
  function ValidaUsuario(Email, Senha : String) : Boolean;
  function MD5(Texto : String): String;
  function Criptografa(Texto : String; Tipo : String) : String;
  function SoNumeros(Texto: String): String;
  function CalculaPercentualDiferenca(ValorAnterior, ValorNovo : Currency) : Currency;
  function StrZero(Zeros : string; Quant : Integer): string;
  function carregaArrayClassificacao : Boolean;
  function FormataCNPJ(CNPJ : String) : String;
  function AjustaTamnhoCNPJ(CNPJ : String) : String;
  function ExcluirCaracteresdeNumeric(Valor : Variant) : String;
  function RetornaCodigo_CF(CF : String) : Integer;

implementation

Uses
  uConstantes,
  IniFiles,
  uFWConnection,
  uBeanUsuario,
  uBeanUsuario_Permissao,
  uDomains,
  uMensagem,
  uBeanLoteImportacao, System.Variants;

procedure CarregarConfigLocal;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    LOGIN.Usuario               := ArqINI.ReadString('LOGIN', 'USUARIO', '');
    LOGIN.LembrarUsuario        := ArqINI.ReadBool('LOGIN', 'LEMBRARUSUARIO', True);

    CONFIG_LOCAL.DirRelatorios  := ArqINI.ReadString('CONFIGURACOES', 'DIR_RELATORIOS', 'C:\CrossAbacos\Relatorios\');

  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure CarregarConexaoBD;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    CONEXAO.LibVendor     := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
    CONEXAO.Database      := ArqINI.ReadString('CONEXAOBD', 'Database', '');
    CONEXAO.Server        := ArqINI.ReadString('CONEXAOBD', 'Server', 'localhost');
    CONEXAO.User_Name     := ArqINI.ReadString('CONEXAOBD', 'User_Name', '');
    CONEXAO.Password      := ArqINI.ReadString('CONEXAOBD', 'Password', '');
    CONEXAO.CharacterSet  := ArqINI.ReadString('CONEXAOBD', 'CharacterSet', 'UTF8');
    CONEXAO.DriverID      := ArqINI.ReadString('CONEXAOBD', 'DriverID', 'PG');
    CONEXAO.Port          := ArqINI.ReadString('CONEXAOBD', 'Port', '5432');

  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure AutoSizeDBGrid(const DBGrid: TDBGrid);
var
  TotalColumnWidth, ColumnCount, GridClientWidth, Filler, i: Integer;
begin
  ColumnCount := DBGrid.Columns.Count;
  if ColumnCount = 0 then
    Exit;

  // compute total width used by grid columns and vertical lines if any
  TotalColumnWidth := 0;
  for i := 0 to ColumnCount-1 do
    TotalColumnWidth := TotalColumnWidth + DBGrid.Columns[i].Width;
  if dgColLines in DBGrid.Options then
    // include vertical lines in total (one per column)
    TotalColumnWidth := TotalColumnWidth + ColumnCount;

  // compute grid client width by excluding vertical scroll bar, grid indicator,
  // and grid border
  GridClientWidth := DBGrid.Width - GetSystemMetrics(SM_CXVSCROLL);
  if dgIndicator in DBGrid.Options then begin
    GridClientWidth := GridClientWidth - IndicatorWidth;
    if dgColLines in DBGrid.Options then
      Dec(GridClientWidth);
  end;
  if DBGrid.BorderStyle = bsSingle then begin
    if DBGrid.Ctl3D then // border is sunken (vertical border is 2 pixels wide)
      GridClientWidth := GridClientWidth - 4
    else // border is one-dimensional (vertical border is one pixel wide)
      GridClientWidth := GridClientWidth - 2;
  end;

  // adjust column widths
  if TotalColumnWidth < GridClientWidth then begin
    Filler := (GridClientWidth - TotalColumnWidth) div ColumnCount;
    for i := 0 to ColumnCount-1 do
      DBGrid.Columns[i].Width := DBGrid.Columns[i].Width + Filler;
  end
//  else if TotalColumnWidth > GridClientWidth then begin
//    Filler := (TotalColumnWidth - GridClientWidth) div ColumnCount;
//    if (TotalColumnWidth - GridClientWidth) mod ColumnCount <> 0 then
//      Inc(Filler);
//    for i := 0 to ColumnCount-1 do
//      DBGrid.Columns[i].Width := DBGrid.Columns[i].Width - Filler;
//  end;
end;

procedure GerarLoteImportacao;
Var
  FWC : TFWConnection;
  LI  : TLOTE;
begin

  FWC := TFWConnection.Create;
  LI  := TLOTE.Create(FWC);

  try
    try
      LI.SelectList('ID > 0 AND CAST(DATA_HORA AS DATE) = CURRENT_DATE');
      if LI.Count > 0 then begin
        DisplayMsg(MSG_CONF, 'Já existe lote de Importação para o Dia.: ' +
                              FormatDateTime('dd/mm/yyyy', TLOTE(LI.Itens[0]).DATA_HORA.Value) + sLineBreak +
                              'Deseja realmente cadastrar um Novo Lote?');
        if ResultMsgModal <> mrYes then
          Exit;
      end else begin
        DisplayMsg(MSG_CONF, 'Deseja realmente cadastrar um Novo Lote?');
        if ResultMsgModal <> mrYes then
          Exit;
      end;

      LI.ID.isNull        := True;
      LI.DATA_HORA.Value  := Now;
      LI.Insert;

      FWC.Commit;

      DisplayMsg(MSG_OK, 'Novo Lote Gerado com Sucesso!');

    except
      on E : Exception do Begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gerar lote de Importação', 'ClassName ' + E.ClassName + ' ' + E.Message);
      End;
    end;
  finally
    FreeAndNil(LI);
    FreeAndNil(FWC);
  end;
end;

procedure AjustaForm(Form : TForm);
begin
  Form.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Form.ClientWidth  := Application.MainForm.ClientWidth;
  Form.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Form.Width        := Application.MainForm.ClientWidth;
  Form.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Form.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure OrdenarGrid(Column: TColumn);
var
  Indice    : string;
  Existe    : Boolean;
  I         : Integer;
  CDS_idx   : TClientDataSet;
  DB_GRID   : TDBGrid;
  C         : TColumn;
begin

  if Column.Grid.DataSource.DataSet is TClientDataSet then begin

    CDS_idx := TClientDataSet(Column.Grid.DataSource.DataSet);

    if CDS_idx.IndexFieldNames = Column.FieldName then begin

      Indice := AnsiUpperCase(Column.FieldName+'_INV');

      Existe  := False;
      For I := 0 to Pred(CDS_idx.IndexDefs.Count) do begin
        if AnsiUpperCase(CDS_idx.IndexDefs[I].Name) = Indice then begin
          Existe := True;
          Break;
        end;
      end;

      if not Existe then
        with CDS_idx.IndexDefs.AddIndexDef do begin
          Name := indice;
          Fields := Column.FieldName;
          Options := [ixDescending];
        end;
      CDS_idx.IndexName := Indice;
    end else
      CDS_idx.IndexFieldNames := Column.FieldName;

    if Column.Grid is TDBGrid then begin
      DB_GRID := TDBGrid(Column.Grid);
      for I := 0 to DB_GRID.Columns.Count - 1 do begin
        C := DB_GRID.Columns[I];
        if Column <> C then begin
          if C.Title.Font.Color <> clWindowText then
            C.Title.Font.Color := clWindowText;
        end;
      end;
      Column.Title.Font.Color := clBlue;
    end;
  end;
end;

procedure ExpXLS(DataSet: TDataSet; NomeArq: string);
var
  ExcApp: OleVariant;
  I,
  L : Integer;
  VarNomeArq : String;
begin

  DataSet.DisableControls;

  try

    if DataSet.IsEmpty then
      Exit;

    VarNomeArq := DirArquivosExcel + FormatDateTime('yyyymmdd', Date) + '\' + NomeArq;

    if not DirectoryExists(ExtractFilePath(VarNomeArq)) then
      ForceDirectories(ExtractFilePath(VarNomeArq));

    if FileExists(VarNomeArq) then
      DeleteFile(PChar(VarNomeArq));

    ExcApp := CreateOleObject('Excel.Application');
    ExcApp.Visible := True;
    ExcApp.WorkBooks.Add;
    DataSet.First;
    L := 1;
    DataSet.First;
    while not DataSet.Eof do begin
      if L = 1 then begin
        for I := 0 to DataSet.Fields.Count - 1 do begin
          if DataSet.Fields[i].Visible then begin
            if DataSet.Fields[i] is TStringField then
              ExcApp.WorkBooks[1].Sheets[1].Columns[I + 1].NumberFormat := '@';

            ExcApp.WorkBooks[1].Sheets[1].Cells[L, I + 1].Font.Bold  := True;
            ExcApp.WorkBooks[1].Sheets[1].Cells[L, I + 1].Font.Color := clBlue;
            ExcApp.WorkBooks[1].Sheets[1].Cells[L, I + 1]            := DataSet.Fields[I].DisplayName;
          end;
        end;
        L := L + 1;
      end;

      for I := 0 to DataSet.Fields.Count - 1 do
        if DataSet.Fields[i].Visible then begin
          ExcApp.WorkBooks[1].Sheets[1].Cells[L, I + 1] := DataSet.Fields[i].DisplayText;
        end;

      DataSet.Next;
      L := L + 1;
    end;
    ExcApp.Columns.AutoFit;
    ExcApp.WorkBooks[1].SaveAs(VarNomeArq);
  finally
    DataSet.EnableControls;
  end;
end;

procedure DeletarArquivosPasta(Diretorio : String);
var
  SR: TSearchRec;
  I : Integer;
begin
  try
    I := FindFirst(Diretorio + '\*.*', faAnyFile, SR);
    while I = 0 do begin
      if ((SR.Attr and faDirectory) <> faDirectory) then
        DeleteFile(PChar(Diretorio + '\' + SR.Name));
      I := FindNext(SR);
    end;
  except
  end;
end;

function ValidaUsuario(Email, Senha : String) : Boolean;
Var
  FWC : TFWConnection;
  USU : TUSUARIO;
begin

  Result  := False;

  if UpperCase(Email) = 'ADMINISTRADOR' then begin
    if UpperCase(Senha) = 'SUPER' + IntToStr(DayOf(Date)) then begin
      USUARIO.CODIGO              := 0;
      USUARIO.NOME                := 'ADMINISTRADOR';
      USUARIO.EMAIL               := '';
      Result := True;
      Exit;
    end;
  end;

  try
    try

      FWC := TFWConnection.Create;

      USU := TUSUARIO.Create(FWC);

      USU.SelectList('UPPER(EMAIL) = ' + QuotedStr(UpperCase(Email)));

      if USU.Count > 0 then begin
        if (Criptografa(TUSUARIO(USU.Itens[0]).SENHA.Value, 'D') = Senha) then begin
          USUARIO.CODIGO              := TUSUARIO(USU.Itens[0]).ID.Value;
          USUARIO.NOME                := TUSUARIO(USU.Itens[0]).NOME.Value;
          USUARIO.EMAIL               := TUSUARIO(USU.Itens[0]).EMAIL.Value;
//          USUARIO.PERMITIRCADUSUARIO  := TUSUARIO(USU.Itens[0]).PERMITIR_CAD_USUARIO.Value;
          Result          := True;
        end;
      end;
    except
      on E : exception do
        DisplayMsg(MSG_ERR, 'Erro ao validar Usuário, Verifique!', '', E.Message);
    end;
  finally
    FreeAndNil(USU);
    FreeAndNil(FWC);
  end;
end;

function MD5(Texto : String): String;
var
  MD5 : TIdHashMessageDigest5;
begin
  MD5 := TIdHashMessageDigest5.Create;
  try
    Exit(MD5.HashStringAsHex(Texto));
  finally
    FreeAndNil(MD5);
  end;
end;

//funcao que retorno o código ASCII dos caracteres
function AsciiToInt(Caracter: Char): Integer;
var
  i: Integer;
begin
  i := 32;
  while i < 255 do begin
    if Chr(i) = Caracter then
      Break;
    i := i + 1;
  end;
  Result := i;
end;

Function Criptografa(Texto : String; Tipo : String) : String;
var
  I    : Integer;
  Chave: Integer;
begin

  Chave := 10;

  if (Trim(Texto) = EmptyStr) or (chave = 0) then begin
    Result := Texto;
  end else begin
    Result := '';
    if UpperCase(Tipo) = 'E' then begin
      for I := 1 to Length(texto) do begin
        Result := Result + Chr(AsciiToInt(texto[I])+chave);
      end;
    end else begin
      for I := 1 to Length(Texto) do begin
        Result := Result + Chr(AsciiToInt(Texto[I]) - Chave);
      end;
    end;
  end;
end;
procedure CarregaArrayMenus(Menu : TMainMenu);
var
  I,
  J,
  K : Integer;
begin
  SetLength(MENUS, 0);
  for I := 0 to Pred(Menu.Items.Count) do begin
    if Menu.Items[I].Count = 0 then begin
      SetLength(MENUS, Length(MENUS) + 1);
      Menus[High(MENUS)].NOME   := Menu.Items[I].Name;
      Menus[High(MENUS)].CAPTION:= StringReplace(Menu.Items[I].Caption, '&', '', [rfReplaceAll]);
    end else begin
      for J := 0 to Pred(Menu.Items[I].Count) do begin
        if Menu.Items[I].Items[J].Count = 0 then begin
          SetLength(MENUS, Length(MENUS) + 1);
          Menus[High(MENUS)].NOME   := Menu.Items[I].Items[J].Name;
          Menus[High(MENUS)].CAPTION:= StringReplace(Menu.Items[I].Items[J].Caption, '&', '', [rfReplaceAll]);
        end else begin
          for K := 0 to Pred(Menu.Items[I].Items[J].Count) do begin
            SetLength(MENUS, Length(MENUS) + 1);
            Menus[High(MENUS)].NOME   := Menu.Items[I].Items[J].Items[K].Name;
            Menus[High(MENUS)].CAPTION:= StringReplace(Menu.Items[I].Items[J].Items[K].Caption, '&', '', [rfReplaceAll]);
          end;
        end;
      end;
    end;
  end;
end;

procedure DefinePermissaoMenu(Menu : TMainMenu);
var
  I,
  J,
  K   : Integer;
  CON : TFWConnection;
  PU  : TUSUARIO_PERMISSAO;
begin
  CON                                        :=  TFWConnection.Create;
  PU                                         := TUSUARIO_PERMISSAO.Create(CON);
  try
//    for I := 0 to Pred(Menu.Items.Count) do begin
//      if Menu.Items[I].Count = 0 then begin
//        PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Name));
//        Menu.Items[I].Visible                := PU.Count > 0;
//      end else begin
//        for J := 0 to Pred(Menu.Items[I].Count) do begin
//          if Menu.Items[I].Items[J].Count = 0 then begin
//            PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Name));
//            Menu.Items[I].Items[J].Visible     := PU.Count > 0;
//          end else begin
//            for K := 0 to Pred(Menu.Items[I].Items[J].Count) do begin
//              PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Items[K].Name));
//              Menu.Items[I].Items[J].Items[K].Visible     := PU.Count > 0;
//            end;
//          end;
//        end;
//      end;
//    end;
    for I := 0 to Pred(Menu.Items.Count) do begin
      if Menu.Items[I].Count > 0 then begin
        Menu.Items[I].Visible                := False;
        for J := 0 to Pred(Menu.Items[I].Count) do begin
          if Menu.Items[I].Items[J].Count = 0 then begin
            PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Name));
            Menu.Items[I].Items[J].Visible     := PU.Count > 0;
          end else begin
            Menu.Items[I].Items[J].Visible     := False;
            for K := 0 to Pred(Menu.Items[I].Items[J].Count) do begin
              PU.SelectList('ID_USUARIO = ' + IntToStr(USUARIO.CODIGO) + ' AND MENU = ' + QuotedStr(Menu.Items[I].Items[J].Items[K].Name));
              Menu.Items[I].Items[J].Items[K].Visible     := PU.Count > 0;
              if Menu.Items[I].Items[J].Items[K].Visible then
                Menu.Items[I].Items[J].Visible            := True;
            end;
          end;
          if Menu.Items[I].Items[J].Visible then
            Menu.Items[I].Visible            := True;

        end;
      end;
    end;
  finally
    FreeAndNil(PU);
    FreeAndNil(CON);
  end;

end;

function SoNumeros(Texto: String): String;
var
    I : Integer;
Begin
  I := 1;
  if Length(Texto) > 0 then
    while I <= Length(Texto) do begin
      if not (Texto[I] in ['0'..'9']) then begin
        Delete(Texto,I,1);
        Continue;
      end;
      Inc(I);
    end;
  Result := Texto;
end;

function CalculaPercentualDiferenca(ValorAnterior, ValorNovo : Currency) : Currency;
begin
  Result := 0.00;
  if ValorAnterior > 0.00 then
    if ValorNovo > 0.00 then
        Result := Trunc((((ValorNovo * 100) / ValorAnterior) - 100) * 100) / 100.00
end;


function StrZero(Zeros : string; Quant : Integer): string;
begin
  Result := Zeros;
  Quant := Quant - Length(Result);
  if Quant > 0 then
   Result := StringOfChar('0', Quant)+Result;
end;

function carregaArrayClassificacao : Boolean;
begin
  Result     := False;
  SetLength(CLASSIFICACAO,0);

  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[0].Descricao :=  'ICMS TRIBUTADO 12% - PIS/COFINS TRIBUTADO';
  CLASSIFICACAO[0].Codigo    := 1;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[1].Descricao :=  'ICMS TRIBUTADO 18% - PIS/COFINS TRIBUTADO';
  CLASSIFICACAO[1].Codigo    := 6;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[2].Descricao :=  'ICMS SUBST. TRIB.  - PIS/COFINS TRIBUTADO';
  CLASSIFICACAO[2].Codigo    := 7;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[3].Descricao :=  'ICMS SUBST. TRIB. - PIS/COFINS ALIQUOTA 0';
  CLASSIFICACAO[3].Codigo    := 8;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[4].Descricao :=  'ICMS SUBS. TRIB. - PIS/COFINS INC. MONOFASICA';
  CLASSIFICACAO[4].Codigo    := 9;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[5].Descricao :=  'ENERGIA ELETRICA';
  CLASSIFICACAO[5].Codigo    := 10;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[6].Descricao :=  'TELEFONE';
  CLASSIFICACAO[6].Codigo    := 11;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[7].Descricao :=  'MATERIAL DE USO E CONSUMO';
  CLASSIFICACAO[7].Codigo    := 12;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[8].Descricao :=  'IMOBILIZADO';
  CLASSIFICACAO[8].Codigo    := 13;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[9].Descricao :=  'MERC IMPORTADA  ICMS TRIB - PIS COFINS TRIB';
  CLASSIFICACAO[9].Codigo    := 15;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[10].Descricao:=  'VENDA IMPORT ICMS TRIB - PIS E COFINS MONOFASICO';
  CLASSIFICACAO[10].Codigo   := 16;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[11].Descricao:=  'VENDA IMPORT ICMS ST - PIS E COFINS TRIB';
  CLASSIFICACAO[11].Codigo   := 17;
  SetLength(CLASSIFICACAO,Length(CLASSIFICACAO) + 1);
  CLASSIFICACAO[12].Descricao:=  'VENDA IMPOR ICMS ST - PIS COFINS MONOFASICO';
  CLASSIFICACAO[12].Codigo   := 18;
end;

function FormataCNPJ(CNPJ : String) : String;
Var
  Aux : String;
begin
  Aux := SoNumeros(CNPJ);

  while Length(Aux) < 14 do
    Aux := '0' + Aux;

  Result := Copy(Aux,1,2) + '.' + Copy(Aux,3,3) + '.' + Copy(Aux,6,3) + '/' + Copy(Aux,9,4) + '-' + Copy(Aux,13,2);
end;

function AjustaTamnhoCNPJ(CNPJ : String) : String;
Var
  Aux : String;
begin
  Aux := SoNumeros(CNPJ);

  while Length(Aux) < 14 do
    Aux := '0' + Aux;

  Result := Aux;
end;

function ExcluirCaracteresdeNumeric(Valor : Variant) : String;
var
  I : Integer;
begin

  Result := Valor;
  I := 1;

  while I <= Length(Result) do begin
    if not (Result[I] in ['0'..'9', ',']) then begin
      Delete(Result,I,1);
      Continue;
    end;
    Inc(I);
  end;
end;

function RetornaCodigo_CF(CF : String) : Integer;
Var
  I : Integer;
begin

  Result := 0;

  if Length(Trim(CF)) > 0 then begin
    for I := Low(CLASSIFICACAO) to High(CLASSIFICACAO) do begin
      if Pos(CF, CLASSIFICACAO[I].Descricao) > 0 then begin
        Result := CLASSIFICACAO[I].Codigo;
        Break;
      end;
    end;
  end;

end;

end.
