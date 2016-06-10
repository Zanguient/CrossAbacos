unit uArquivoBaseProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Samples.Gauges, FireDAC.Comp.Client, System.Win.ComObj;

type
  TFrmArquivoBaseProdutos = class(TForm)
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    btSair: TSpeedButton;
    rgSaldoDisponivel: TRadioGroup;
    btExportar: TSpeedButton;
    BarradeProgresso: TGauge;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    procedure btSairClick(Sender: TObject);
    procedure btExportarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edFornecedorChange(Sender: TObject);
    procedure edFornecedorExit(Sender: TObject);
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFornecedorRightButtonClick(Sender: TObject);
  private
    procedure ExportarProdutos;
    procedure SelecionaFornecedor;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmArquivoBaseProdutos: TFrmArquivoBaseProdutos;

implementation

uses
  uMensagem,
  uFuncoes,
  uConstantes,
  uFWConnection,
  uBeanFornecedor,
  uDMUtil;

{$R *.dfm}

procedure TFrmArquivoBaseProdutos.btExportarClick(Sender: TObject);
begin
  if btExportar.Tag = 0 then begin
    btExportar.Tag := 1;
    try
      ExportarProdutos;
      Close;
    finally
      btExportar.Tag := 0;
    end;
  end;
end;

procedure TFrmArquivoBaseProdutos.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmArquivoBaseProdutos.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TFrmArquivoBaseProdutos.edFornecedorExit(Sender: TObject);
begin
  if (edFornecedor.Text = '') or (edFornecedor.Text = '0') then
    edNomeFornecedor.Clear;
end;

procedure TFrmArquivoBaseProdutos.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    selecionaFornecedor;
end;

procedure TFrmArquivoBaseProdutos.edFornecedorRightButtonClick(Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TFrmArquivoBaseProdutos.ExportarProdutos;
var
  PLANILHA,
  Sheet   : Variant;
  Linha   : Integer;
  FWC     : TFWConnection;
  Consulta: TFDQuery;
  DirArquivo : String;
Begin

  DirArquivo := DirArquivosExcel + FormatDateTime('yyyymmdd', Date);

  if not DirectoryExists(DirArquivo) then begin
    if not ForceDirectories(DirArquivo) then begin
      DisplayMsg(MSG_WAR, 'Não foi possível criar o diretório,' + sLineBreak + DirArquivo + sLineBreak + 'Verifique!');
      Exit;
    end;
  end;

  DirArquivo := DirArquivo + '\ProdutosBase.xls';

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
      Consulta.SQL.Add('	PF.COD_PROD_FORNECEDOR,');
      Consulta.SQL.Add('	P.CODIGO_BARRAS,');
      Consulta.SQL.Add('	PF.QUANTIDADE AS ESTOQUE,');
      Consulta.SQL.Add('	PF.CUSTO');
      Consulta.SQL.Add('FROM PRODUTO P');
      Consulta.SQL.Add('INNER JOIN PRODUTOFORNECEDOR PF ON (P.ID = PF.ID_PRODUTO)');
      Consulta.SQL.Add('WHERE 1 = 1');
      Consulta.SQL.Add('AND PF.STATUS = TRUE');

      if StrToIntDef(edFornecedor.Text,0) > 0 then
        Consulta.SQL.Add('AND PF.ID_FORNECEDOR = ' + IntToStr(StrToIntDef(edFornecedor.Text,0)));

      case rgSaldoDisponivel.ItemIndex of
        0 : Consulta.SQL.Add('AND PF.QUANTIDADE > 0');//Com Saldo
        1 : Consulta.SQL.Add('AND PF.QUANTIDADE = 0');//Sem Saldo
      end;

      Consulta.SQL.Add('ORDER BY P.SKU, PF.ID_FORNECEDOR');

      Consulta.Connection         := FWC.FDConnection;
      Consulta.Prepare;
      Consulta.Open;
      Consulta.FetchAll;

      if Not Consulta.IsEmpty then begin

        BarradeProgresso.Progress := 0;
        BarradeProgresso.MaxValue := Consulta.RecordCount;

        PLANILHA := CreateOleObject('Excel.Application');
        PLANILHA.Caption := 'CROSSDOCK';
        PLANILHA.Visible := False;
        PLANILHA.WorkBooks.add(1);
        PLANILHA.Workbooks[1].WorkSheets[1].Name := 'CROSSDOCK';
        Sheet := PLANILHA.Workbooks[1].WorkSheets['CROSSDOCK'];
        Sheet.Range['A1','E1'].Font.Bold  := True;
        Sheet.Range['A1','E1'].Font.Color := clBlue;

        // TITULO DAS COLUNAS
        PLANILHA.Cells[1,1] := 'IdentificadorProduto Estrela10';
        PLANILHA.Cells[1,2] := 'Cód. do Fornecedor';
        PLANILHA.Cells[1,3] := 'Cód de Barras';
        PLANILHA.Cells[1,4] := 'Estoque';
        PLANILHA.Cells[1,5] := 'Custo Final C/ IPI+ST+Desc';
        Linha :=  2;

        Consulta.First;
        While not Consulta.Eof do Begin
          PLANILHA.Cells[Linha,1].NumberFormat  := '@';
          PLANILHA.Cells[Linha,2].NumberFormat  := '@';
          PLANILHA.Cells[Linha,3].NumberFormat  := '@';
          PLANILHA.Cells[Linha,4].NumberFormat  := '@';
          PLANILHA.Cells[Linha,5].NumberFormat  := '#.##0,00';
          PLANILHA.Cells[Linha,1]               := Consulta.FieldByName('SKU').AsString;
          PLANILHA.Cells[linha,2]               := Consulta.FieldByName('COD_PROD_FORNECEDOR').AsString;
          PLANILHA.Cells[Linha,3]               := Consulta.FieldByName('CODIGO_BARRAS').AsString;
          PLANILHA.Cells[Linha,4]               := Consulta.FieldByName('ESTOQUE').AsString;
          PLANILHA.Cells[Linha,5]               := Consulta.FieldByName('CUSTO').AsString;
          Linha := Linha + 1;
          BarradeProgresso.Progress := Consulta.RecNo;
          Consulta.Next;
        End;

        PLANILHA.Columns.AutoFit;

        PLANILHA.WorkBooks[1].Sheets[1].SaveAs(DirArquivo, 18);

      end else
        DisplayMsg(MSG_WAR, 'Não há dados para Geração do Arquivo Base de Produtos, Verifique!');

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

procedure TFrmArquivoBaseProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFrmArquivoBaseProdutos.SelecionaFornecedor;
var
  CON : TFWConnection;
  F   : TFORNECEDOR;
begin
  CON                       := TFWConnection.Create;
  F                         := TFORNECEDOR.Create(CON);
  edNomeFornecedor.Clear;
  try
    edFornecedor.Text       := IntToStr(DMUtil.Selecionar(F, edFornecedor.Text));
    F.SelectList('id = ' + edFornecedor.Text);
    if F.Count > 0 then
      edNomeFornecedor.Text := TFORNECEDOR(F.Itens[0]).NOME.asString;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;

end;

end.
