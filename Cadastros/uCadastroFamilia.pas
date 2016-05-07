unit uCadastroFamilia;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.DBCtrls, System.TypInfo, System.Win.ComObj, Vcl.Samples.Gauges;

type
  TFrmCadastroFamilia = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnBotoesVisualizacao: TPanel;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    pnEdicao: TPanel;
    pnBotoesEdicao: TPanel;
    ds_Familias: TDataSource;
    cds_Familias: TClientDataSet;
    cds_FamiliasID: TIntegerField;
    cds_FamiliasDESCRICAO: TStringField;
    cds_FamiliasMARGEM: TCurrencyField;
    cds_FamiliasAUTORIZADOPOR: TStringField;
    cds_FamiliasDATAAUTORIZADO: TDateTimeField;
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
    Label1: TLabel;
    Label2: TLabel;
    edAutorizadoPor: TEdit;
    edDescricao: TEdit;
    pnUsuarioDireita: TPanel;
    Label3: TLabel;
    edMargem: TEdit;
    btAtualizar: TSpeedButton;
    btExportar: TSpeedButton;
    OpenDialog1: TOpenDialog;
    pbAtualiza: TGauge;
    GridPanel2: TGridPanel;
    Panel4: TPanel;
    btCancelar: TSpeedButton;
    Panel5: TPanel;
    btGravar: TSpeedButton;
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
  FrmCadastroFamilia: TFrmCadastroFamilia;

implementation

uses
  uDomains,
  uConstantes,
  uFWConnection,
  uBeanFamilia,
  uMensagem,
  uFuncoes;

{$R *.dfm}

procedure TFrmCadastroFamilia.AtualizarEdits(Limpar: Boolean);
begin
  if Limpar then begin
    edDescricao.Clear;
    edAutorizadoPor.Clear;
    edMargem.Clear;
    btGravar.Tag  := 0;
  end else begin
    edDescricao.Text      := cds_FamiliasDESCRICAO.Value;
    edMargem.Text         := cds_FamiliasMARGEM.AsString;
    edAutorizadoPor.Text  := cds_FamiliasAUTORIZADOPOR.Value;
    btGravar.Tag          := cds_FamiliasID.Value;
  end;
end;

procedure TFrmCadastroFamilia.Atualizar;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  F       : TFAMILIA;
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
      F                         := TFAMILIA.Create(FWC);
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

          F.DESCRICAO.excelTitulo               := 'Descrição';
          F.MARGEM.excelTitulo                  := '(%) Margem';

          F.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(F.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(F, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(F, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Segue colunas necessárias: ' + sLineBreak +
                                                                                    'Descrição, ' + sLineBreak +
                                                                                    '(%) Margem');
              Exit;
            end;
          end;

          for I := 2 to vrow do begin
            for J := 0 to Pred(Count) do begin
              if (TFieldTypeDomain(GetObjectProp(F, List[J]^.Name)).excelIndice > 0) then begin
                Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(F, List[J]^.Name)).excelIndice]);
                if Valor <> '' then
                  TFieldTypeDomain(GetObjectProp(F, List[J]^.Name)).asVariant := Valor;
              end;
            end;

            F.AUTORIZADOPOR.Value   := USUARIO.NOME;
            F.DATAAUTORIZADO.Value  := Now;

            F.SelectList('DESCRICAO = ' + F.DESCRICAO.asSQL);
            if F.Count > 0 then begin
              F.ID.Value    := TFAMILIA(F.Itens[0]).ID.Value;
              F.Update;
            end else
              F.Insert;
            pbAtualiza.Progress     := I;
            Application.ProcessMessages;
          end;

          FWC.Commit;

          DisplayMsg(MSG_OK, 'Famílias atualizadas com Sucesso!');

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Famílias!', '', E.Message);
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
        FreeAndNil(F);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmCadastroFamilia.btAlterarClick(Sender: TObject);
begin
  if not cds_Familias.IsEmpty then begin
    AtualizarEdits(False);
    InvertePaineis;
  end;
end;

procedure TFrmCadastroFamilia.btAtualizarClick(Sender: TObject);
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

procedure TFrmCadastroFamilia.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TFrmCadastroFamilia.btExcluirClick(Sender: TObject);
Var
  FWC : TFWConnection;
  F   : TFAMILIA;
begin
  if not cds_Familias.IsEmpty then begin

    DisplayMsg(MSG_CONF, 'Excluir a Família Selecionada?');

    if ResultMsgModal = mrYes then begin

      try

        FWC := TFWConnection.Create;
        F := TFAMILIA.Create(FWC);
        try

          F.ID.Value := cds_FamiliasID.Value;
          F.Delete;

          FWC.Commit;

          cds_Familias.Delete;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao Excluir Família, Verifique!', '', E.Message);
          end;
        end;
      finally
        FreeAndNil(F);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmCadastroFamilia.btExportarClick(Sender: TObject);
begin
  if btExportar.Tag = 0 then begin
    btExportar.Tag := 1;
    try
      ExpXLS(cds_Familias, Caption + '.xlsx');
    finally
      btExportar.Tag := 0;
    end;
  end;
end;

procedure TFrmCadastroFamilia.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroFamilia.btGravarClick(Sender: TObject);
Var
  FWC : TFWConnection;
  F   : TFAMILIA;
begin

  FWC := TFWConnection.Create;
  F   := TFAMILIA.Create(FWC);

  try
    try

      if Length(Trim(edDescricao.Text)) = 0 then begin
        DisplayMsg(MSG_WAR, 'Descrição não informada, Verifique!');
        if edDescricao.CanFocus then
          edDescricao.SetFocus;
        Exit;
      end;

      if StrToCurrDef(edMargem.Text,-1) = -1 then begin
        DisplayMsg(MSG_WAR, 'Margem inválida, Verifique!');
        if edMargem.CanFocus then
          edMargem.SetFocus;
        Exit;
      end;

      F.DESCRICAO.Value     := edDescricao.Text;
      F.MARGEM.Value        := StrToCurrDef(edMargem.Text,0.00);
      F.AUTORIZADOPOR.Value := edAutorizadoPor.Text;
      F.DATAAUTORIZADO.Value:= Date;

      if (Sender as TSpeedButton).Tag > 0 then begin
        F.ID.Value          := (Sender as TSpeedButton).Tag;
        F.Update;
      end else begin
        F.ID.isNull := True;
        F.Insert;
      end;

      FWC.Commit;

      InvertePaineis;

      CarregaDados;

    Except
      on E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gravar Familia!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(F);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroFamilia.btNovoClick(Sender: TObject);
begin
  AtualizarEdits(True);
  InvertePaineis;
end;

procedure TFrmCadastroFamilia.Cancelar;
begin
  if cds_Familias.State in [dsInsert, dsEdit] then
    cds_Familias.Cancel;
  InvertePaineis;
end;

procedure TFrmCadastroFamilia.CarregaDados;
Var
  FWC     : TFWConnection;
  F       : TFAMILIA;
  I,
  Codigo  : Integer;
begin

  try
    FWC := TFWConnection.Create;
    F  := TFAMILIA.Create(FWC);
    cds_Familias.DisableControls;
    try

      Codigo := cds_FamiliasID.Value;

      cds_Familias.EmptyDataSet;

      F.SelectList('', 'ID');
      if F.Count > 0 then begin
        for I := 0 to F.Count -1 do begin
          cds_Familias.Append;
          cds_FamiliasID.Value                := TFAMILIA(F.Itens[I]).ID.Value;
          cds_FamiliasDESCRICAO.Value         := TFAMILIA(F.Itens[I]).DESCRICAO.Value;
          cds_FamiliasMARGEM.Value            := TFAMILIA(F.Itens[I]).MARGEM.Value;
          cds_FamiliasAUTORIZADOPOR.Value     := TFAMILIA(F.Itens[I]).AUTORIZADOPOR.Value;
          cds_FamiliasDATAAUTORIZADO.Value    := TFAMILIA(F.Itens[I]).DATAAUTORIZADO.Value;
          cds_Familias.Post;
        end;
      end;

      if Codigo > 0 then
        cds_Familias.Locate('ID', Codigo, []);

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    cds_Familias.EnableControls;
    FreeAndNil(F);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroFamilia.csPesquisaFilterRecord(DataSet: TDataSet;
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

procedure TFrmCadastroFamilia.Filtrar;
begin
  cds_Familias.Filtered := False;
  cds_Familias.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroFamilia.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmCadastroFamilia.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if pnVisualizacao.Visible then begin
    case Key of
      VK_ESCAPE : begin
        if pnVisualizacao.Visible then
          Close
        else
          Cancelar;
      end;
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
        if not cds_Familias.IsEmpty then begin
          if cds_Familias.RecNo > 1 then
            cds_Familias.Prior;
        end;
      end;
      VK_DOWN : begin
        if not cds_Familias.IsEmpty then begin
          if cds_Familias.RecNo < cds_Familias.RecordCount then
            cds_Familias.Next;
        end;
      end;
    end;
  end;
end;

procedure TFrmCadastroFamilia.FormShow(Sender: TObject);
begin
  cds_Familias.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);
end;

procedure TFrmCadastroFamilia.gdPesquisaTitleClick(Column: TColumn);
begin
  OrdenarGrid(Column);
end;

procedure TFrmCadastroFamilia.InvertePaineis;
begin
  pnVisualizacao.Visible        := not pnVisualizacao.Visible;
  pnBotoesVisualizacao.Visible  := pnVisualizacao.Visible;
  pnEdicao.Visible              := not pnEdicao.Visible;
  pnBotoesEdicao.Visible        := pnEdicao.Visible;
  if pnEdicao.Visible then begin
    if edDescricao.CanFocus then
      edDescricao.SetFocus;
  end;
end;

end.
