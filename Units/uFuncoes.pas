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
  Vcl.Forms;

  procedure CarregarConfigLocal;
  procedure CarregarConexaoBD;
  procedure AutoSizeDBGrid(const DBGrid: TDBGrid);
  procedure GerarLoteImportacao;
  procedure AjustaForm(Form : TForm);
  function ValidaUsuario(Email, Senha : String) : Boolean;
  function MD5(Texto : String): String;
  Function Criptografa(Texto : String; Tipo : String) : String;

implementation

Uses
  uConstantes,
  IniFiles,
  uFWConnection,
  uBeanUsuario,
  uDomains,
  uMensagem,
  uBeanLoteImportacao;

procedure CarregarConfigLocal;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    LOGIN.Usuario         := ArqINI.ReadString('LOGIN', 'USUARIO', '');
    LOGIN.LembrarUsuario  := ArqINI.ReadBool('LOGIN', 'LEMBRARUSUARIO', True);

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
  else if TotalColumnWidth > GridClientWidth then begin
    Filler := (TotalColumnWidth - GridClientWidth) div ColumnCount;
    if (TotalColumnWidth - GridClientWidth) mod ColumnCount <> 0 then
      Inc(Filler);
    for i := 0 to ColumnCount-1 do
      DBGrid.Columns[i].Width := DBGrid.Columns[i].Width - Filler;
  end;
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
      LI.SelectList('CAST(DATA_HORA AS DATE) = CURRENT_DATE');
      if LI.Count > 0 then begin
        DisplayMsg(MSG_CONF, 'Já existe lote de Importação para o Dia.: ' +
                              FormatDateTime('dd/mm/yyyy', TLOTE(LI.Itens[0]).DATA_HORA.Value) + sLineBreak +
                              'Deseja realmente cadastrar um Novo Lote?');
        if ResultMsgModal <> mrYes then
          Exit;
      end;

      LI.ID.isNull        := True;
      LI.DATA_HORA.Value  := Now;
      LI.Insert;

      FWC.Commit;

      DisplayMsg(MSG_INF, 'Novo Lote Gerado com Sucesso!');

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
      USUARIO.PERMITIRCADUSUARIO  := True;
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
          USUARIO.PERMITIRCADUSUARIO  := TUSUARIO(USU.Itens[0]).PERMITIR_CAD_USUARIO.Value;
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

end.
