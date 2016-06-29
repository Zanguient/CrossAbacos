unit uArquivoMatchs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ImgList, Datasnap.DBClient, Vcl.Samples.Gauges,
  Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmArquivoMatchs = class(TForm)
    pnPrincipal: TPanel;
    gbSelecionaFornecedor: TGroupBox;
    edFornecedor: TButtonedEdit;
    edNomeFornecedor: TEdit;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    btSair: TSpeedButton;
    gbProduto: TGroupBox;
    edProduto: TButtonedEdit;
    edNomeProduto: TEdit;
    gbMarca: TGroupBox;
    edMarca: TEdit;
    gbCategoria: TGroupBox;
    edFamilia: TButtonedEdit;
    edNomeFamilia: TEdit;
    btExportarMatchs: TSpeedButton;
    CDS_MATCHS: TClientDataSet;
    CDS_MATCHSSKU: TStringField;
    CDS_MATCHSMARCA: TStringField;
    BarradeProgresso: TGauge;
    gbFiltroDatas: TGroupBox;
    edDataCustoAnterior: TJvDateEdit;
    Label18: TLabel;
    Label1: TLabel;
    edDataCustoAtual: TJvDateEdit;
    CDS_MATCHSCUSTOANTERIOR: TCurrencyField;
    CDS_MATCHSSALDOANTERIOR: TIntegerField;
    CDS_MATCHSFORNECEDORANTERIOR: TStringField;
    CDS_MATCHSCUSTOATUAL: TCurrencyField;
    CDS_MATCHSSALDOATUAL: TIntegerField;
    CDS_MATCHSFORNECEDORATUAL: TStringField;
    CDS_MATCHSDIFERENCA: TCurrencyField;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btSairClick(Sender: TObject);
    procedure edFornecedorChange(Sender: TObject);
    procedure edProdutoChange(Sender: TObject);
    procedure edProdutoRightButtonClick(Sender: TObject);
    procedure edFornecedorRightButtonClick(Sender: TObject);
    procedure edFornecedorKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edProdutoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFamiliaChange(Sender: TObject);
    procedure edFamiliaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFamiliaRightButtonClick(Sender: TObject);
    procedure btExportarMatchsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SelecionaFornecedor;
    procedure SelecionaProduto;
    procedure SelecionaFamilia;
    procedure Exportar;
  end;

var
  frmArquivoMatchs: TfrmArquivoMatchs;

implementation

uses
  uFuncoes,
  uDMUtil,
  uFWConnection,
  uBeanFornecedor,
  uBeanProduto,
  uMensagem,
  uBeanFamilia;
{$R *.dfm}

procedure TfrmArquivoMatchs.btExportarMatchsClick(Sender: TObject);
begin
  if btExportarMatchs.Tag = 0 then begin
    btExportarMatchs.Tag   := 1;
    try
      BarradeProgresso.Visible := True;
      Application.ProcessMessages;
      Exportar;
    finally
      BarradeProgresso.Visible := False;
      btExportarMatchs.Tag := 0;
    end;
  end;
end;

procedure TfrmArquivoMatchs.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmArquivoMatchs.edFamiliaChange(Sender: TObject);
begin
  edNomeFamilia.Clear;
end;

procedure TfrmArquivoMatchs.edFamiliaKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaFamilia;
end;

procedure TfrmArquivoMatchs.edFamiliaRightButtonClick(Sender: TObject);
begin
  SelecionaFamilia;
end;

procedure TfrmArquivoMatchs.edFornecedorChange(Sender: TObject);
begin
  edNomeFornecedor.Clear;
end;

procedure TfrmArquivoMatchs.edFornecedorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaFornecedor;
end;

procedure TfrmArquivoMatchs.edFornecedorRightButtonClick(Sender: TObject);
begin
  SelecionaFornecedor;
end;

procedure TfrmArquivoMatchs.edProdutoChange(Sender: TObject);
begin
  edNomeProduto.Clear;
end;

procedure TfrmArquivoMatchs.edProdutoKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelecionaProduto;
end;

procedure TfrmArquivoMatchs.edProdutoRightButtonClick(Sender: TObject);
begin
  SelecionaProduto;
end;

procedure TfrmArquivoMatchs.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmArquivoMatchs.FormShow(Sender: TObject);
begin
  CDS_MATCHS.CreateDataSet;
  edDataCustoAnterior.Date  := Date;
  edDataCustoAtual.Date     := Date;
end;

procedure TfrmArquivoMatchs.SelecionaFornecedor;
var
  CON : TFWConnection;
  F   : TFORNECEDOR;
begin
  CON                       := TFWConnection.Create;
  F                         := TFORNECEDOR.Create(CON);
  edNomeFornecedor.Text     := '';
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

procedure TfrmArquivoMatchs.SelecionaProduto;
var
  CON : TFWConnection;
  P   : TPRODUTO;
begin
  CON    := TFWConnection.Create;
  P      := TPRODUTO.Create(CON);
  edNomeProduto.Clear;
  try
    edProduto.Text       := IntToStr(DMUtil.Selecionar(P, edProduto.Text));
    P.SelectList('id = ' + edProduto.Text);
    if P.Count > 0 then
      edNomeProduto.Text := TPRODUTO(P.Itens[0]).NOME.asString;
  finally
    FreeAndNil(P);
    FreeAndNil(CON);
  end;
end;

procedure TfrmArquivoMatchs.SelecionaFamilia;
var
  CON : TFWConnection;
  F   : TFAMILIA;
begin
  CON    := TFWConnection.Create;
  F      := TFAMILIA.Create(CON);
  edNomeFamilia.Clear;
  try
    edFamilia.Text       := IntToStr(DMUtil.Selecionar(F, edFamilia.Text));
    F.SelectList('id = ' + edFamilia.Text);
    if F.Count > 0 then
      edNomeFamilia.Text := TFAMILIA(F.Itens[0]).DESCRICAO.asString;
  finally
    FreeAndNil(F);
    FreeAndNil(CON);
  end;
end;

procedure TfrmArquivoMatchs.Exportar;
var
  FWC   : TFWConnection;
  SQL   : TFDQuery;
  SQLAN : TFDQuery;
  SQLAT : TFDQuery;
  Achou : Boolean;
begin

  if edDataCustoAnterior.Date = 0 then begin
    DisplayMsg(MSG_WAR, 'Data do Custo Anterior Inválida, Verifique!');
    if edDataCustoAnterior.CanFocus then
      edDataCustoAnterior.SetFocus;
    Exit;
  end;

  if edDataCustoAtual.Date = 0 then begin
    DisplayMsg(MSG_WAR, 'Data do Custo Atual Inválida, Verifique!');
    if edDataCustoAtual.CanFocus then
      edDataCustoAtual.SetFocus;
    Exit;
  end;

  if edDataCustoAtual.Date <= edDataCustoAnterior.Date then begin
    DisplayMsg(MSG_WAR, 'Data do custo atual precisa ser maior que a data do custo anterior, Verifique!');
    if edDataCustoAtual.CanFocus then
      edDataCustoAtual.SetFocus;
    Exit;
  end;

  FWC   := TFWConnection.Create;
  SQL   := TFDQuery.Create(nil);
  SQLAN := TFDQuery.Create(nil);
  SQLAT := TFDQuery.Create(nil);

  CDS_MATCHS.DisableControls;

  try
    try

      CDS_MATCHS.EmptyDataSet;

      SQLAN.Close;
      SQLAN.SQL.Clear;
      SQLAN.SQL.Add('SELECT');
      SQLAN.SQL.Add('	MI.CUSTONOVO AS CUSTO,');
      SQLAN.SQL.Add('	MI.QUANTIDADE AS SALDO,');
      SQLAN.SQL.Add('	F.NOME AS FORNECEDOR');
      SQLAN.SQL.Add('FROM MATCH M');
      SQLAN.SQL.Add('INNER JOIN MATCH_ITENS MI ON (M.ID = MI.ID_MATCH)');
      SQLAN.SQL.Add('INNER JOIN FORNECEDOR F ON (MI.ID_FORNECEDORNOVO = F.ID)');
      SQLAN.SQL.Add('WHERE 1 = 1');
      SQLAN.SQL.Add('AND MI.ID_PRODUTO = :ID_PRODUTO');
      SQLAN.SQL.Add('AND CAST(M.DATA_HORA AS DATE) <= :DATA');
      SQLAN.SQL.Add('ORDER BY M.ID DESC');
      SQLAN.SQL.Add('LIMIT 1');
      SQLAN.ParamByName('ID_PRODUTO').DataType  := ftInteger;
      SQLAN.ParamByName('DATA').DataType        := ftDate;
      SQLAN.Connection                          := FWC.FDConnection;

      SQLAT.Close;
      SQLAT.SQL.Clear;
      SQLAT.SQL.Add('SELECT');
      SQLAT.SQL.Add('	MI.CUSTONOVO AS CUSTO,');
      SQLAT.SQL.Add('	MI.QUANTIDADE AS SALDO,');
      SQLAT.SQL.Add('	F.NOME AS FORNECEDOR');
      SQLAT.SQL.Add('FROM MATCH M');
      SQLAT.SQL.Add('INNER JOIN MATCH_ITENS MI ON (M.ID = MI.ID_MATCH)');
      SQLAT.SQL.Add('INNER JOIN FORNECEDOR F ON (MI.ID_FORNECEDORNOVO = F.ID)');
      SQLAT.SQL.Add('WHERE 1 = 1');
      SQLAT.SQL.Add('AND MI.ID_PRODUTO = :ID_PRODUTO');
      SQLAT.SQL.Add('AND CAST(M.DATA_HORA AS DATE) <= :DATA');
      SQLAT.SQL.Add('ORDER BY M.ID DESC');
      SQLAT.SQL.Add('LIMIT 1');
      SQLAT.ParamByName('ID_PRODUTO').DataType  := ftInteger;
      SQLAT.ParamByName('DATA').DataType        := ftDate;
      SQLAT.Connection                          := FWC.FDConnection;

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.ID,');
      SQL.SQL.Add('	P.SKU,');
      SQL.SQL.Add('	P.MARCA');
      SQL.SQL.Add('FROM PRODUTO P');
      SQL.SQL.Add('WHERE 1 = 1');
      if Trim(edMarca.Text) <> '' then
        SQL.SQL.Add('AND UPPER(P.MARCA) = ' + QuotedStr(AnsiUpperCase(Trim(edMarca.Text))));
      if Trim(edFamilia.Text) <> '' then
        SQL.SQL.Add('AND P.ID_FAMILIA = ' + edFamilia.Text);
      if Trim(edProduto.Text) <> '' then
        SQL.SQL.Add('AND P.ID = ' + edProduto.Text);

      SQL.Connection    := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open();
      SQL.FetchAll;

      if not SQL.IsEmpty then begin
        BarradeProgresso.Progress := 0;
        BarradeProgresso.MaxValue := SQL.RecordCount;
        SQL.First;
        while not SQL.Eof do begin
          Achou := False;
          //Anterior
          SQLAN.Close;
          SQLAN.ParamByName('ID_PRODUTO').AsInteger := SQL.Fields[0].Value;
          SQLAN.ParamByName('DATA').AsDate          := edDataCustoAnterior.Date;
          SQLAN.Open();
          if not SQLAN.IsEmpty then
            Achou := True;

          //Atual
          SQLAT.Close;
          SQLAT.ParamByName('ID_PRODUTO').AsInteger := SQL.Fields[0].Value;
          SQLAT.ParamByName('DATA').AsDate          := edDataCustoAtual.Date;
          SQLAT.Open();
          if not SQLAT.IsEmpty then
            Achou := True;

          if Achou then begin

            CDS_MATCHS.Append;
            CDS_MATCHSSKU.Value             := SQL.Fields[1].Value;
            CDS_MATCHSMARCA.Value           := SQL.Fields[2].Value;
            CDS_MATCHSCUSTOANTERIOR.Value   := 0.00;
            CDS_MATCHSCUSTOATUAL.Value      := 0.00;

            //Anterior
            if not SQLAN.IsEmpty then begin
              CDS_MATCHSCUSTOANTERIOR.Value       := SQLAN.Fields[0].Value;
              CDS_MATCHSSALDOANTERIOR.Value       := SQLAN.Fields[1].Value;
              CDS_MATCHSFORNECEDORANTERIOR.Value  := SQLAN.Fields[2].Value;
            end;

            //Atual
            if not SQLAT.IsEmpty then begin
              CDS_MATCHSCUSTOATUAL.Value          := SQLAT.Fields[0].Value;
              CDS_MATCHSSALDOATUAL.Value          := SQLAT.Fields[1].Value;
              CDS_MATCHSFORNECEDORATUAL.Value     := SQLAT.Fields[2].Value;
            end;

            CDS_MATCHSDIFERENCA.Value             := CalculaPercentualDiferenca(CDS_MATCHSCUSTOANTERIOR.AsCurrency, CDS_MATCHSCUSTOATUAL.AsCurrency);

            CDS_MATCHS.Post;
          end;

          BarradeProgresso.Progress := BarradeProgresso.Progress + 1;
          Application.ProcessMessages;

          SQL.Next;
        end;
      end;

      if not CDS_MATCHS.IsEmpty then begin

        ExpXLS(CDS_MATCHS, Caption + '.xlsx');

      end else begin
        DisplayMsg(MSG_WAR, 'Não há Dados para Exportar!');
        Exit;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao consultar dados! Verifique!', '', E.Message);
      end;
    end;
  finally
    CDS_MATCHS.EnableControls;
    FreeAndNil(SQL);
    FreeAndNil(SQLAN);
    FreeAndNil(SQLAT);
    FreeAndNil(FWC);
  end;

end;

end.
