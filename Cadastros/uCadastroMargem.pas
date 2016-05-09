unit uCadastroMargem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.DBCtrls, System.TypInfo, System.Win.ComObj, Vcl.Samples.Gauges,
  FireDAC.Comp.Client, Vcl.ComCtrls;

type
  TFrmCadastroMargem = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnBotoesVisualizacao: TPanel;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    pnEdicao: TPanel;
    pnBotoesEdicao: TPanel;
    ds_Margens: TDataSource;
    cds_Margens: TClientDataSet;
    gpBotoes: TGridPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    btExcluir: TSpeedButton;
    btFechar: TSpeedButton;
    btAlterar: TSpeedButton;
    btNovo: TSpeedButton;
    Panel1: TPanel;
    Panel3: TPanel;
    GridPanel1: TGridPanel;
    pnUsuarioEsquerda: TPanel;
    Label2: TLabel;
    edNomeProduto: TEdit;
    pnUsuarioDireita: TPanel;
    btAtualizar: TSpeedButton;
    btExportar: TSpeedButton;
    OpenDialog1: TOpenDialog;
    pbAtualiza: TGauge;
    GridPanel2: TGridPanel;
    Panel4: TPanel;
    btCancelar: TSpeedButton;
    Panel5: TPanel;
    btGravar: TSpeedButton;
    cds_MargensID: TIntegerField;
    cds_MargensID_PRODUTO: TIntegerField;
    cds_MargensSKU: TStringField;
    cds_MargensNOME_PRODUTO: TStringField;
    cds_MargensMARGEMSKU: TCurrencyField;
    cds_MargensPRECOPONTA: TCurrencyField;
    cds_MargensPRECOPROMOCIONAL: TCurrencyField;
    cds_MargensVALPRECOPROMOCIONAL: TDateTimeField;
    cds_MargensMARGEMANALISTA: TCurrencyField;
    cds_MargensPERCENTUALVPC: TCurrencyField;
    cds_MargensPERCENTUALFRETE: TCurrencyField;
    cds_MargensPERCENTUALOUTROS: TCurrencyField;
    cds_MargensAUTORIZADOPOR: TStringField;
    cds_MargensDATAAUTORIZADO: TDateTimeField;
    cbFiltroMargens: TComboBox;
    cds_MargensSTATUS: TStringField;
    edSKU: TEdit;
    Label4: TLabel;
    edPercentualVPC: TEdit;
    Label9: TLabel;
    Label3: TLabel;
    edMargemSKU: TEdit;
    edPrecoPonta: TEdit;
    Label5: TLabel;
    edPrecoPromocional: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    edAutorizadoPor: TEdit;
    Label1: TLabel;
    edPercentualFrete: TEdit;
    Label10: TLabel;
    edPercentualOutros: TEdit;
    Label11: TLabel;
    edMargemAnalista: TEdit;
    Label8: TLabel;
    edValidadePromocional: TDateTimePicker;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure gdPesquisaTitleClick(Column: TColumn);
    procedure btExportarClick(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
    procedure cbFiltroMargensChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CarregaDados;
    procedure InvertePaineis;
    procedure Cancelar;
    procedure Filtrar;
    procedure AtualizarEdits(Limpar : Boolean);
    procedure Atualizar;
  end;

var
  FrmCadastroMargem: TFrmCadastroMargem;

implementation

uses
  uDomains,
  uConstantes,
  uFWConnection,
  uBeanMargem,
  uMensagem,
  uFuncoes;

{$R *.dfm}

procedure TFrmCadastroMargem.AtualizarEdits(Limpar: Boolean);
begin
  if Limpar then begin
    edSKU.Tag                   := cds_MargensID_PRODUTO.Value;
    edSKU.Text                  := cds_MargensSKU.Value;
    edNomeProduto.Text          := cds_MargensNOME_PRODUTO.Value;
    edMargemSKU.Clear;
    edPrecoPonta.Clear;
    edPrecoPromocional.Clear;
    edValidadePromocional.Date  := Date;
    edMargemAnalista.Clear;
    edPercentualVPC.Clear;
    edPercentualFrete.Clear;
    edPercentualOutros.Clear;
    edAutorizadoPor.Clear;
    btGravar.Tag  := 0;
  end else begin
    edSKU.Tag                   := cds_MargensID_PRODUTO.Value;
    edSKU.Text                  := cds_MargensSKU.Value;
    edNomeProduto.Text          := cds_MargensNOME_PRODUTO.Value;
    edMargemSKU.Text            := cds_MargensMARGEMSKU.AsString;
    edPrecoPonta.Text           := cds_MargensPRECOPONTA.AsString;
    edPrecoPromocional.Text     := cds_MargensPRECOPROMOCIONAL.AsString;
    edValidadePromocional.Date  := cds_MargensVALPRECOPROMOCIONAL.Value;
    edMargemAnalista.Text       := cds_MargensMARGEMANALISTA.AsString;
    edPercentualVPC.Text        := cds_MargensPERCENTUALVPC.AsString;
    edPercentualFrete.Text      := cds_MargensPERCENTUALFRETE.AsString;
    edPercentualOutros.Text     := cds_MargensPERCENTUALOUTROS.AsString;
    edAutorizadoPor.Text        := cds_MargensAUTORIZADOPOR.AsString;
    btGravar.Tag                := cds_MargensID.Value;
  end;
end;

procedure TFrmCadastroMargem.Atualizar;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  M       : TMARGEM;
  List    : TPropList;
  Arquivo : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  Count,
  I,
  J       : Integer;
begin
  if OpenDialog1.Execute then begin
    if Pos(ExtractFileExt(OpenDialog1.FileName), '|.xls|.xlsx|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
        Exit;
      end;

      // Cria Excel- OLE Object
      Excel                     := CreateOleObject('Excel.Application');
      FWC                       := TFWConnection.Create;
      M                         := TMARGEM.Create(FWC);
      pbAtualiza.Visible        := True;
      pbAtualiza.Progress       := 0;

      DisplayMsg(MSG_WAIT, 'Buscando dados do arquivo Excel!');
      try
        FWC.StartTransaction;
        try
          // Esconde Excel
          Excel.Visible  := False;
          // Abre o Workbook
          Excel.Workbooks.Open(Arquivo);

          Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
          vrow                                  := Excel.ActiveCell.Row;
          vcol                                  := Excel.ActiveCell.Column;
          pbAtualiza.MaxValue                   := vrow;
          arrData                               := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

          //M.DESCRICAO.excelTitulo               := 'Descrição';
          //M.MARGEM.excelTitulo                  := '(%) Margem';

          M.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(M.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(M, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(M, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Segue colunas necessárias: ' + sLineBreak +
                                                                                    'Descrição, ' + sLineBreak +
                                                                                    '(%) Margem');
              Exit;
            end;
          end;

          for I := 2 to vrow do begin
            for J := 0 to Pred(Count) do begin
              if (TFieldTypeDomain(GetObjectProp(M, List[J]^.Name)).excelIndice > 0) then begin
                Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(M, List[J]^.Name)).excelIndice]);
                if Valor <> '' then
                  TFieldTypeDomain(GetObjectProp(M, List[J]^.Name)).asVariant := Valor;
              end;
            end;

            M.AUTORIZADOPOR.Value   := USUARIO.NOME;
            M.DATAAUTORIZADO.Value  := Now;

            //M.SelectList('DESCRICAO = ' + M.DESCRICAO.asSQL);
            if M.Count > 0 then begin
              M.ID.Value    := TMARGEM(M.Itens[0]).ID.Value;
              M.Update;
            end else
              M.Insert;
            pbAtualiza.Progress     := I;
            Application.ProcessMessages;
          end;

          FWC.Commit;

          DisplayMsg(MSG_OK, 'Margens atualizadas com Sucesso!');

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Margens!', '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData := Unassigned;
        pbAtualiza.Visible  := False;
        pbAtualiza.Progress := 0;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(M);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmCadastroMargem.btAlterarClick(Sender: TObject);
begin
  if not cds_Margens.IsEmpty then begin
    AtualizarEdits(False);
    InvertePaineis;
  end else
    DisplayMsg(MSG_WAR, 'Produto não Selecionado, Verifique!')
end;

procedure TFrmCadastroMargem.btAtualizarClick(Sender: TObject);
begin
  if btAtualizar.Tag = 0 then begin
    btAtualizar.Tag := 1;
    try
      Atualizar;
      CarregaDados;
    finally
      btAtualizar.Tag := 0;
    end;
  end;
end;

procedure TFrmCadastroMargem.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TFrmCadastroMargem.btExcluirClick(Sender: TObject);
Var
  FWC : TFWConnection;
  M   : TMARGEM;
begin
  if not cds_Margens.IsEmpty then begin

    DisplayMsg(MSG_CONF, 'Excluir a Margem Selecionada?');

    if ResultMsgModal = mrYes then begin

      try

        FWC := TFWConnection.Create;
        M := TMargem.Create(FWC);
        try

          M.ID.Value := cds_MargensID.Value;
          M.Delete;

          FWC.Commit;

          cds_Margens.Delete;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao Excluir Margem, Verifique!', '', E.Message);
          end;
        end;
      finally
        FreeAndNil(M);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmCadastroMargem.btExportarClick(Sender: TObject);
begin
  if btExportar.Tag = 0 then begin
    btExportar.Tag := 1;
    try
      ExpXLS(cds_Margens, Caption + '.xlsx');
    finally
      btExportar.Tag := 0;
    end;
  end;
end;

procedure TFrmCadastroMargem.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroMargem.btGravarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  M   : TMARGEM;
begin

  FWC := TFWConnection.Create;
  M   := TMargem.Create(FWC);

  try
    try

      if StrToCurrDef(edMargemSKU.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Margem SKU inválida, Verifique!');
        if edMargemSKU.CanFocus then
          edMargemSKU.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edPrecoPonta.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Preço Ponta inválido, Verifique!');
        if edPrecoPonta.CanFocus then
          edPrecoPonta.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edPrecoPromocional.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Preço Promocional inválido, Verifique!');
        if edPrecoPromocional.CanFocus then
          edPrecoPromocional.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edMargemAnalista.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Margem Analista inválida, Verifique!');
        if edMargemAnalista.CanFocus then
          edMargemAnalista.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edPercentualVPC.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Percentual VPC inválido, Verifique!');
        if edPercentualVPC.CanFocus then
          edPercentualVPC.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edPercentualFrete.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Percentual Frete inválido, Verifique!');
        if edPercentualFrete.CanFocus then
          edPercentualFrete.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edPercentualOutros.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Percentual Outros inválido, Verifique!');
        if edPercentualOutros.CanFocus then
          edPercentualOutros.SetFocus;
        Exit;
      end;

      M.MARGEMSKU.Value             := StrToCurr(edMargemSKU.Text);
      M.PRECOPONTA.Value            := StrToCurr(edPrecoPonta.Text);
      M.PRECOPROMOCIONAL.Value      := StrToCurr(edPrecoPromocional.Text);
      M.VALPRECOPROMOCIONAL.Value   := edValidadePromocional.DateTime;
      M.MARGEMANALISTA.Value        := StrToCurr(edMargemAnalista.Text);
      M.PERCENTUALVPC.Value         := StrToCurr(edPercentualVPC.Text);
      M.PERCENTUALFRETE.Value       := StrToCurr(edPercentualFrete.Text);
      M.PERCENTUALOUTROS.Value      := StrToCurr(edPercentualOutros.Text);
      M.AUTORIZADOPOR.Value         := edAutorizadoPor.Text;
      M.DATAAUTORIZADO.Value        := Date;

      if (Sender as TSpeedButton).Tag > 0 then begin
        M.ID.Value          := (Sender as TSpeedButton).Tag;
        M.Update;
      end else begin
        M.ID.isNull         := True;
        M.ID_PRODUTO.Value  := edSKU.Tag;
        M.Insert;
      end;

      FWC.Commit;

      InvertePaineis;

      CarregaDados;

    Except
      on E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gravar Margem!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(M);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroMargem.btNovoClick(Sender: TObject);
begin
  if not cds_Margens.IsEmpty then begin
    AtualizarEdits(True);
    InvertePaineis;
  end else
    DisplayMsg(MSG_WAR, 'Produto não Selecionado, Verifique!')
end;

procedure TFrmCadastroMargem.Cancelar;
begin
  if cds_Margens.State in [dsInsert, dsEdit] then
    cds_Margens.Cancel;
  InvertePaineis;
end;

procedure TFrmCadastroMargem.CarregaDados;
Var
  FWC     : TFWConnection;
  SQL     : TFDQuery;
  I,
  Codigo  : Integer;
begin

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  try

    DisplayMsg(MSG_WAIT, 'Aguarde Carregando Dados...');

    cds_Margens.DisableControls;
    try

      Codigo := cds_MargensID.Value;

      cds_Margens.EmptyDataSet;

      //SQL BUSCA MARGENS
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.ID AS ID_PRODUTO,');
      SQL.SQL.Add('	P.SKU,');
      SQL.SQL.Add('	P.NOME AS NOMEPRODUTO,');
      SQL.SQL.Add('	COALESCE(M.ID,0) AS ID,');
      SQL.SQL.Add('	COALESCE(M.MARGEMSKU,0.00) AS MARGEMSKU,');
      SQL.SQL.Add('	COALESCE(M.PRECOPONTA,0.00) AS PRECOPONTA,');
      SQL.SQL.Add('	COALESCE(M.PRECOPROMOCIONAL,0.00) AS PRECOPROMOCIONAL,');
      SQL.SQL.Add('	COALESCE(M.VALPRECOPROMOCIONAL,CURRENT_TIMESTAMP) AS VALPRECOPROMOCIONAL,');
      SQL.SQL.Add('	COALESCE(M.MARGEMANALISTA,0.00) AS MARGEMANALISTA,');
      SQL.SQL.Add('	COALESCE(M.PERCENTUALVPC,0.00) AS PERCENTUALVPC,');
      SQL.SQL.Add('	COALESCE(M.PERCENTUALFRETE,0.00) AS PERCENTUALFRETE,');
      SQL.SQL.Add('	COALESCE(M.PERCENTUALOUTROS,0.00) AS PERCENTUALOUTROS,');
      SQL.SQL.Add('	COALESCE(M.AUTORIZADOPOR,'''') AS AUTORIZADOPOR,');
      SQL.SQL.Add('	COALESCE(M.DATAAUTORIZADO,CURRENT_TIMESTAMP) AS DATAAUTORIZADO');
      SQL.SQL.Add('FROM PRODUTO P LEFT JOIN MARGEM M ON (P.ID = M.ID_PRODUTO)');
      SQL.SQL.Add('WHERE 1 = 1');
      case cbFiltroMargens.ItemIndex of
        0 : SQL.SQL.Add('AND COALESCE(M.ID,0) > 0');
        1 : SQL.SQL.Add('AND COALESCE(M.ID,0) = 0');
      end;
      SQL.SQL.Add('ORDER BY P.ID');

      SQL.Connection  := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open;
      SQL.FetchAll;

      SQL.Offline;

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          cds_Margens.Append;
          cds_MargensID.Value                   := SQL.FieldByName('ID').Value;
          cds_MargensID_PRODUTO.Value           := SQL.FieldByName('ID_PRODUTO').Value;
          cds_MargensSKU.Value                  := SQL.FieldByName('SKU').Value;
          cds_MargensNOME_PRODUTO.Value         := SQL.FieldByName('NOMEPRODUTO').Value;
          cds_MargensMARGEMSKU.Value            := SQL.FieldByName('MARGEMSKU').Value;
          cds_MargensPRECOPONTA.Value           := SQL.FieldByName('PRECOPONTA').Value;
          cds_MargensPRECOPROMOCIONAL.Value     := SQL.FieldByName('PRECOPROMOCIONAL').Value;
          cds_MargensVALPRECOPROMOCIONAL.Value  := SQL.FieldByName('VALPRECOPROMOCIONAL').Value;
          cds_MargensMARGEMANALISTA.Value       := SQL.FieldByName('MARGEMANALISTA').Value;
          cds_MargensPERCENTUALVPC.Value        := SQL.FieldByName('PERCENTUALVPC').Value;
          cds_MargensPERCENTUALFRETE.Value      := SQL.FieldByName('PERCENTUALFRETE').Value;
          cds_MargensPERCENTUALOUTROS.Value     := SQL.FieldByName('PERCENTUALOUTROS').Value;
          cds_MargensAUTORIZADOPOR.Value        := SQL.FieldByName('AUTORIZADOPOR').Value;
          cds_MargensDATAAUTORIZADO.Value       := SQL.FieldByName('DATAAUTORIZADO').Value;
          if cds_MargensID.Value > 0 then
            cds_MargensSTATUS.Value             := 'Com Margem'
          else
            cds_MargensSTATUS.Value             := 'Sem Margem';
          cds_Margens.Post;
          SQL.Next;
        end;
      end;

      if Codigo > 0 then
        cds_Margens.Locate('ID', Codigo, []);

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    DisplayMsgFinaliza;
    cds_Margens.EnableControls;
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroMargem.cbFiltroMargensChange(Sender: TObject);
begin
  CarregaDados;
end;

procedure TFrmCadastroMargem.csPesquisaFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
Var
  I : Integer;
begin
  Accept := False;
  for I := 0 to DataSet.Fields.Count - 1 do begin
    if not DataSet.Fields[I].IsNull then begin
      if Pos(AnsiLowerCase(edPesquisa.Text),AnsiLowerCase(DataSet.Fields[I].AsVariant)) > 0 then begin
        Accept := True;
        Break;
      end;
    end;
  end;
end;

procedure TFrmCadastroMargem.Filtrar;
begin
  cds_Margens.Filtered := False;
  cds_Margens.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroMargem.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmCadastroMargem.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if pnVisualizacao.Visible then begin
    case Key of
      VK_ESCAPE : Close;
      VK_RETURN : begin
        if edPesquisa.Focused then begin
          Filtrar;
        end else begin
          if edPesquisa.CanFocus then begin
            edPesquisa.SetFocus;
            edPesquisa.SelectAll;
          end;
        end;
      end;
      VK_F5 : CarregaDados;
      VK_UP : begin
        if not cds_Margens.IsEmpty then begin
          if cds_Margens.RecNo > 1 then
            cds_Margens.Prior;
        end;
      end;
      VK_DOWN : begin
        if not cds_Margens.IsEmpty then begin
          if cds_Margens.RecNo < cds_Margens.RecordCount then
            cds_Margens.Next;
        end;
      end;
    end;
  end else begin
    case Key of
      VK_ESCAPE : Cancelar;
    end;
  end;
end;

procedure TFrmCadastroMargem.FormShow(Sender: TObject);
begin
  cds_Margens.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);
end;

procedure TFrmCadastroMargem.gdPesquisaTitleClick(Column: TColumn);
begin
  OrdenarGrid(Column);
end;

procedure TFrmCadastroMargem.InvertePaineis;
begin
  pnVisualizacao.Visible        := not pnVisualizacao.Visible;
  pnBotoesVisualizacao.Visible  := pnVisualizacao.Visible;
  pnEdicao.Visible              := not pnEdicao.Visible;
  pnBotoesEdicao.Visible        := pnEdicao.Visible;
  if pnEdicao.Visible then begin
    if edMargemSKU.CanFocus then
      edMargemSKU.SetFocus;
  end;
end;

end.
