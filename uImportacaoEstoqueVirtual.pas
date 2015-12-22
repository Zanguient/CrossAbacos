unit uImportacaoEstoqueVirtual;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,  System.Win.ComObj,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, TypInfo;

type
  TCamposExcel = record
    NomeCampoExcel    : String;
    IndiceCampoExcel  : Integer;
    CampoBancodeDados : string;
  end;

type
  TfrmImportacaodeEstoqueVirtual = class(TForm)
    pnPrincipal: TPanel;
    OpenDialog1: TOpenDialog;
    gbBuscaArquivo: TGroupBox;
    lbNomeArquivo: TLabel;
    sbBuscaArquivo: TSpeedButton;
    cbFornecedores: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    gbCampos: TGroupBox;
    pnSelecionaCampos: TPanel;
    cbCamposExcel: TComboBox;
    Label3: TLabel;
    cbCamposBancodeDados: TComboBox;
    Label4: TLabel;
    gdCamposRelacionados: TDBGrid;
    csCamposRelacionados: TClientDataSet;
    dsCamposRelacionados: TDataSource;
    csCamposRelacionadosEXCEL: TStringField;
    csCamposRelacionadosBANCODADOS: TStringField;
    csCamposRelacionadosINDICEEXCEL: TIntegerField;
    sbAdicionarRelacaoCampos: TSpeedButton;
    sbRemoverRelacaoCampos: TSpeedButton;
    csDadosCarregados: TClientDataSet;
    csDadosCarregadosSKU: TStringField;
    csDadosCarregadosCODIGOABACOS: TStringField;
    csDadosCarregadosCODIGOFORNECEDORABACOS: TStringField;
    csDadosCarregadosSALDO: TFloatField;
    csDadosCarregadosCUSTO: TFloatField;
    dsDadosCarregados: TDataSource;
    gbMostraDados: TGroupBox;
    pnCarregaDados: TPanel;
    SpeedButton1: TSpeedButton;
    gdDadosCarregados: TDBGrid;
    sbEnviaAbacos: TSpeedButton;
    btCancelar: TSpeedButton;
    procedure sbBuscaArquivoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbAdicionarRelacaoCamposClick(Sender: TObject);
    procedure sbRemoverRelacaoCamposClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
  private
    CamposExcel : array of TCamposExcel;
    { Private declarations }
  public
    function BuscaCamposExcel(xFileXLS: string) : Boolean;
    { Public declarations }
  end;

var
  frmImportacaodeEstoqueVirtual: TfrmImportacaodeEstoqueVirtual;

implementation
uses uMensagem, uBeanProdutoAbacos, uDomains, uFWConnection, uFuncoes;
{$R *.dfm}

{ TfrmImportacaodeEstoqueVirtual }

procedure TfrmImportacaodeEstoqueVirtual.btCancelarClick(Sender: TObject);
begin
  Close;
end;

function TfrmImportacaodeEstoqueVirtual.BuscaCamposExcel(
  xFileXLS: string): Boolean;
 const
   xlCellTypeLastCell = $0000000B;
 var
   XLSAplicacao, AbaXLS: OLEVariant;
   x, y, k, r: Integer;
 begin
   Result := False;
   // Cria Excel- OLE Object
   XLSAplicacao := CreateOleObject('Excel.Application');
   try
     // Esconde Excel
     XLSAplicacao.Visible := False;
     // Abre o Workbook
     XLSAplicacao.Workbooks.Open(xFileXLS);
     AbaXLS := XLSAplicacao.Workbooks[ExtractFileName(xFileXLS)].WorkSheets[1];
     AbaXLS.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
     y := XLSAplicacao.ActiveCell.Column;
     k := 1;
     SetLength(CamposExcel, 0);
     repeat
       if Trim(XLSAplicacao.Cells.Item[1, k].Text) <> '' then begin
         SetLength(CamposExcel, Length(CamposExcel) + 1);
         CamposExcel[High(CamposExcel)].NomeCampoExcel   := UpperCase(Trim(XLSAplicacao.Cells.Item[1, k].Text));
         CamposExcel[High(CamposExcel)].IndiceCampoExcel := k;
       end;
       Inc(k, 1);
     until k > y;
   finally
     // Fecha o Microsoft Excel
     if not VarIsEmpty(XLSAplicacao) then begin
       XLSAplicacao.Quit;
       XLSAplicacao := Unassigned;
       AbaXLS := Unassigned;
       Result := True;
     end;
   end;
 end;

procedure TfrmImportacaodeEstoqueVirtual.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
end;

procedure TfrmImportacaodeEstoqueVirtual.FormShow(Sender: TObject);
var
  PRODUTO : TPRODUTO;
  List    : TPropList;
  I,
  Count   : Integer;
  FWC     : TFWConnection;
begin
  FWC          := TFWConnection.Create;
  PRODUTO      := TPRODUTO.Create(FWC);
  try
    Count := GetPropList(PRODUTO.ClassInfo, tkProperties, @List, False);
    for I := 0 to Pred(Count) do begin
      if not TFieldTypeDomain(GetObjectProp(PRODUTO, List[I]^.Name)).isPK then
        cbCamposBancodeDados.Items.Add(List[I]^.Name);
    end;
    csCamposRelacionados.CreateDataSet;
    csCamposRelacionados.Open;
  finally
    FreeAndNil(PRODUTO);
    FreeAndNil(FWC);
  end;
  AutoSizeDBGrid(gdDadosCarregados);
  AutoSizeDBGrid(gdCamposRelacionados);
end;

procedure TfrmImportacaodeEstoqueVirtual.sbAdicionarRelacaoCamposClick(
  Sender: TObject);
var
  I : Integer;
begin
  if cbCamposExcel.Text = EmptyStr then begin
    DisplayMsg(MSG_WAR, 'Informe o campo do excel que deseja relacionar!');
    if cbCamposExcel.CanFocus then cbCamposExcel.SetFocus;
    Exit;
  end;
  if cbCamposBancodeDados.Text = EmptyStr then begin
    DisplayMsg(MSG_WAR, 'Informe o campo do banco de dados que deseja relacionar!');
    if cbCamposBancodeDados.CanFocus then cbCamposBancodeDados.SetFocus;
    Exit;
  end;
  try
    for I := 0 to High(CamposExcel) do begin
      if UpperCase(cbCamposExcel.Text) = UpperCase(CamposExcel[I].NomeCampoExcel) then begin
        if CamposExcel[I].CampoBancodeDados <> EmptyStr then begin
          DisplayMsg(MSG_WAR, 'Campo do arquivo selecionado ja foi incluido!');
          Exit;
        end;
        CamposExcel[I].CampoBancodeDados        := cbCamposBancodeDados.Text;
        csCamposRelacionados.Append;
        csCamposRelacionadosEXCEL.Value         := CamposExcel[I].NomeCampoExcel;
        csCamposRelacionadosBANCODADOS.Value    := cbCamposBancodeDados.Text;
        csCamposRelacionadosINDICEEXCEL.Value   := CamposExcel[I].IndiceCampoExcel;
        csCamposRelacionados.Post;
        Break;
      end;
    end;
    cbCamposExcel.ItemIndex                     := -1;
    cbCamposBancodeDados.ItemIndex              := -1;
  except
    on E : Exception do begin
      DisplayMsg(MSG_WAR, 'Erro ao buscar campos!', '', E.Message);
      Exit;
    end;
  end;
end;

procedure TfrmImportacaodeEstoqueVirtual.sbBuscaArquivoClick(Sender: TObject);
var
  I : Integer;
begin
  if OpenDialog1.Execute then begin
    DisplayMsg(MSG_WAIT, 'Buscando colunas do arquivo selecionado!');
    BuscaCamposExcel(OpenDialog1.FileName);
    lbNomeArquivo.Caption   := '...\' + ExtractFileName(OpenDialog1.FileName);
    for I := 0 to High(CamposExcel) do
      cbCamposExcel.Items.Add(CamposExcel[I].NomeCampoExcel);

    DisplayMsgFinaliza;
  end;
end;

procedure TfrmImportacaodeEstoqueVirtual.sbRemoverRelacaoCamposClick(
  Sender: TObject);
var
  I : Integer;
begin
  if csCamposRelacionados.IsEmpty then begin
    DisplayMsg(MSG_WAR, 'Não existem campos relacionados para excluir!');
    Exit;
  end;
  try
    for I := 0 to High(CamposExcel) do begin
      if csCamposRelacionadosINDICEEXCEL.Value = CamposExcel[I].IndiceCampoExcel then begin
        CamposExcel[I].CampoBancodeDados     := EmptyStr;
        csCamposRelacionados.Delete;
      end;
    end;
  Except
    on E : Exception do begin
      DisplayMsg(MSG_WAR, 'Erro ao excluir relação de campos selecionado!', '', E.Message);
      Exit;
    end;
  end;
end;

end.
