unit uArquivoProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.Samples.Gauges, FireDAC.Comp.Client, System.Win.ComObj;

type
  TFrmArquivoProdutos = class(TForm)
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    btSair: TSpeedButton;
    rgSaldoDisponivel: TRadioGroup;
    btExportar: TSpeedButton;
    BarradeProgresso: TGauge;
    procedure btSairClick(Sender: TObject);
    procedure btExportarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure ExportarProdutos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmArquivoProdutos: TFrmArquivoProdutos;

implementation

uses
  uMensagem,
  uFuncoes,
  uConstantes,
  uFWConnection;

{$R *.dfm}

procedure TFrmArquivoProdutos.btExportarClick(Sender: TObject);
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

procedure TFrmArquivoProdutos.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmArquivoProdutos.ExportarProdutos;
var
  PLANILHA,
  Sheet   : Variant;
  Linha   : Integer;
  FWC     : TFWConnection;
  Consulta: TFDQuery;
  DirArquivo : String;
  idLote  : Integer;
Begin

  DirArquivo := DirArquivosExcel + FormatDateTime('yyyymmdd', Date);

  if not DirectoryExists(DirArquivo) then begin
    if not ForceDirectories(DirArquivo) then begin
      DisplayMsg(MSG_WAR, 'Não foi possível criar o diretório,' + sLineBreak + DirArquivo + sLineBreak + 'Verifique!');
      Exit;
    end;
  end;

  DirArquivo := DirArquivo + '\Produtos.xls';

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
      Consulta.SQL.Add('	P.SKU AS SKU,');
      Consulta.SQL.Add('	P.CUSTO AS CUSTO,');
      Consulta.SQL.Add('	F.NOME AS NOMEFORNECEDOR');
      Consulta.SQL.Add('FROM PRODUTO P');
      Consulta.SQL.Add('INNER JOIN PRODUTOFORNECEDOR PF ON (P.ID = PF.ID_PRODUTO AND P.ID_FORNECEDORNOVO = PF.ID_FORNECEDOR)');
      Consulta.SQL.Add('INNER JOIN FORNECEDOR F ON (PF.ID_FORNECEDOR = F.ID)');
      Consulta.SQL.Add('WHERE 1 = 1');
      Consulta.SQL.Add('AND PF.STATUS');

      case rgSaldoDisponivel.ItemIndex of
        0 : Consulta.SQL.Add('AND PF.QUANTIDADE > 0');//Com Saldo
        1 : Consulta.SQL.Add('AND PF.QUANTIDADE = 0');//Sem Saldo
      end;

      Consulta.SQL.Add('ORDER BY P.SKU');

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
        //Sheet.Range['A1','C1'].Font.Bold  := True;
        //Sheet.Range['A1','C1'].Font.Color := clBlue;

        // TITULO DAS COLUNAS
        //PLANILHA.Cells[1,1] := 'SKU';
        //PLANILHA.Cells[1,2] := 'CUSTO';
        //PLANILHA.Cells[1,3] := 'Fornecedor';
        Linha :=  1;

        Consulta.First;
        While not Consulta.Eof do Begin
          PLANILHA.Cells[Linha,1].NumberFormat  := '@';
          PLANILHA.Cells[Linha,2].NumberFormat  := '#.##0,00';
          PLANILHA.Cells[Linha,3].NumberFormat  := '@';
          PLANILHA.Cells[Linha,1]               := Consulta.FieldByName('SKU').AsString; //SKU
          PLANILHA.Cells[linha,2]               := Consulta.FieldByName('CUSTO').AsString; //CUSTO
          PLANILHA.Cells[Linha,3]               := Consulta.FieldByName('NOMEFORNECEDOR').AsString; //FORNECEDOR
          Linha := Linha + 1;
          BarradeProgresso.Progress := Consulta.RecNo;
          Consulta.Next;
        End;

        PLANILHA.Columns.AutoFit;

        PLANILHA.WorkBooks[1].Sheets[1].SaveAs(DirArquivo, 18);

      end else
        DisplayMsg(MSG_WAR, 'Não há dados para Geração do Arquivo de Produtos, Verifique!');

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

procedure TFrmArquivoProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

end.
