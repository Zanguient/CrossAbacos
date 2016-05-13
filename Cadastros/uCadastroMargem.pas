unit uCadastroMargem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.DBCtrls, System.TypInfo, System.Win.ComObj, Vcl.Samples.Gauges,
  FireDAC.Comp.Client, Vcl.ComCtrls, JvToolEdit, JvExMask, JvBaseEdits;

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
    Label9: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edAutorizadoPor: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label8: TLabel;
    edMargemSKU: TJvCalcEdit;
    edPrecoPonta: TJvCalcEdit;
    edPrecoPromocional: TJvCalcEdit;
    edMargemAnalista: TJvCalcEdit;
    edPercentualVPC: TJvCalcEdit;
    edPercentualFrete: TJvCalcEdit;
    edPercentualOutros: TJvCalcEdit;
    edValidadePromocional: TJvDateEdit;
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
  uFuncoes,
  uBeanProduto;

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
    edMargemSKU.Value           := cds_MargensMARGEMSKU.Value;
    edPrecoPonta.Value          := cds_MargensPRECOPONTA.Value;
    edPrecoPromocional.Value    := cds_MargensPRECOPROMOCIONAL.Value;
    edValidadePromocional.Date  := cds_MargensVALPRECOPROMOCIONAL.Value;
    edMargemAnalista.Value      := cds_MargensMARGEMANALISTA.Value;
    edPercentualVPC.Value       := cds_MargensPERCENTUALVPC.Value;
    edPercentualFrete.Value     := cds_MargensPERCENTUALFRETE.Value;
    edPercentualOutros.Value    := cds_MargensPERCENTUALOUTROS.Value;
    edAutorizadoPor.Text        := cds_MargensAUTORIZADOPOR.AsString;
    btGravar.Tag                := cds_MargensID.Value;
  end;
end;

procedure TFrmCadastroMargem.Atualizar;

type
  TArrayMargens = record
    ID_PRODUTO : Integer;
    SKU : string;
    Margem_Sku : Currency;
    Preco_Ponta : Currency;
    Margem_Promocional : Currency;
    Val_Margem_Promocional : TDate;
    Preco_Promocional : Currency;
    Val_Preco_Promocional: TDate;
    Margem_Analista : Currency;
    Percentual_VPC : Currency;
    Percentual_Frete : Currency;
    Percentual_Outros : Currency;
    Solicitado_Por : String;
    Autorizado_Por : String;
    Data_Autorizacao : TDate;
  end;

const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  M       : TMARGEM;
  P       : TPRODUTO;
  Arquivo,
  Aux     : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  I,
  J       : Integer;
  ArqValido,
  AchouColuna : Boolean;
  arMargens   : array of TArrayMargens;
  Colunas     : array of String;
begin

  SetLength(arMargens, 0);

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
      P                         := TPRODUTO.Create(FWC);

      pbAtualiza.Visible        := True;

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

          DisplayMsg(MSG_WAIT, 'Validando arquivo!');

          SetLength(Colunas, 14);
          Colunas[0]  := 'SKU';
          Colunas[1]  := 'Margem Sku';
          Colunas[2]  := 'Preco Ponta';
          Colunas[3]  := 'Margem Promocional';
          Colunas[4]  := 'Val Margem Promocional';
          Colunas[5]  := 'Preco Promocional';
          Colunas[6]  := 'Val Preco Promocional';
          Colunas[7]  := 'Margem Analista';
          Colunas[8]  := 'Percentual VPC';
          Colunas[9]  := 'Percentual Frete';
          Colunas[10] := 'Percentual Outros';
          Colunas[11] := 'Solicitado Por';
          Colunas[12] := 'Autorizado Por';
          Colunas[13] := 'Data Autorizacao';

          ArqValido := True;
          for I := Low(Colunas) to High(Colunas) do begin
            AchouColuna := False;
            for J := 1 to vcol do begin
              if AnsiUpperCase(Colunas[I]) = AnsiUpperCase(arrData[1, J]) then begin
                AchouColuna := True;
                Break;
              end;
            end;
            if not AchouColuna then begin
              ArqValido := False;
              Break;
            end;
          end;

          if not ArqValido then begin
            Aux := 'Colunas.:';
            for I := Low(Colunas) to High(Colunas) do
              Aux := Aux + sLineBreak + Colunas[I];

            DisplayMsg(MSG_WAR, 'Arquivo Inválido, Verifique as Colunas!', '', Aux);
            Exit;
          end;

          pbAtualiza.Progress  := 0;
          pbAtualiza.MaxValue  := vrow;

          DisplayMsg(MSG_WAIT, 'Capturando Margens do arquivo!');

          for I := 2 to vrow do begin
            SetLength(arMargens, Length(arMargens) + 1);
            arMargens[High(arMargens)].ID_PRODUTO := 0;
            for J := 1 to vcol do begin
              if arrData[1, J] = 'SKU' then
                arMargens[High(arMargens)].SKU  := arrData[I, J]
              else
                if arrData[1, J] = 'Margem Sku' then
                  arMargens[High(arMargens)].Margem_Sku := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                else
                  if arrData[1, J] = 'Preco Ponta' then
                    arMargens[High(arMargens)].Preco_Ponta  := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                  else
                    if arrData[1, J] = 'Margem Promocional' then
                      arMargens[High(arMargens)].Margem_Promocional := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                    else
                      if arrData[1, J] = 'Val Margem Promocional' then
                        arMargens[High(arMargens)].Val_Margem_Promocional := arrData[I, J]
                      else
                        if arrData[1, J] = 'Preco Promocional' then
                          arMargens[High(arMargens)].Preco_Promocional  := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                        else
                          if arrData[1, J] = 'Val Preco Promocional' then
                            arMargens[High(arMargens)].Val_Preco_Promocional  := arrData[I, J]
                          else
                            if arrData[1, J] = 'Margem Analista' then
                              arMargens[High(arMargens)].Margem_Analista := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                            else
                              if arrData[1, J] = 'Percentual VPC' then
                                arMargens[High(arMargens)].Percentual_VPC := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                              else
                                if arrData[1, J] = 'Percentual Frete' then
                                  arMargens[High(arMargens)].Percentual_Frete := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                                  else
                                    if arrData[1, J] = 'Percentual Outros' then
                                      arMargens[High(arMargens)].Percentual_Outros  := StrToCurrDef(ExcluirCaracteresdeNumeric(arrData[I, J]), 0.00)
                                    else
                                      if arrData[1, J] = 'Solicitado Por' then
                                        arMargens[High(arMargens)].Solicitado_Por := arrData[I, J]
                                      else
                                        if arrData[1, J] = 'Autorizado Por' then
                                          arMargens[High(arMargens)].Autorizado_Por := arrData[I, J]
                                        else
                                          if arrData[1, J] = 'Data Autorizacao' then
                                            arMargens[High(arMargens)].Data_Autorizacao := arrData[I, J];
            end;
          end;

          DisplayMsg(MSG_WAIT, 'Identificando SKUs!');

          pbAtualiza.Progress  := 0;
          pbAtualiza.MaxValue  := High(arMargens);

          Aux := EmptyStr;
          for I := Low(arMargens) to High(arMargens) do begin

            //Consulta o produto no BD
            P.SelectList('SKU = ' + QuotedStr(arMargens[I].SKU));
            if P.Count = 1 then
              arMargens[I].ID_PRODUTO := TPRODUTO(P.Itens[0]).ID.Value;

            if arMargens[I].ID_PRODUTO = 0 then begin
              if Aux = EmptyStr then
                Aux := arMargens[I].SKU
              else
                Aux := Aux + sLineBreak + arMargens[I].SKU;
            end;
            pbAtualiza.Progress := I;
          end;

          if Aux = EmptyStr then begin

            DisplayMsg(MSG_WAIT, 'Gravando Margens no Banco de Dados!');

            pbAtualiza.Progress  := 0;
            pbAtualiza.MaxValue  := High(arMargens);

            //Começa a Gravação dos Dados no BD
            for I := Low(arMargens) to High(arMargens) do begin
              if arMargens[I].ID_PRODUTO > 0 then begin
                M.ID_PRODUTO.Value          := arMargens[I].ID_PRODUTO;
                M.MARGEMSKU.Value           := arMargens[I].Margem_Sku;
                M.PRECOPONTA.Value          := arMargens[I].Preco_Ponta;
                M.PRECOPROMOCIONAL.Value    := arMargens[I].Preco_Promocional;
                M.VALPRECOPROMOCIONAL.Value := arMargens[I].Val_Preco_Promocional;
                M.MARGEMANALISTA.Value      := arMargens[I].Margem_Analista;
                M.PERCENTUALVPC.Value       := arMargens[I].Percentual_VPC;
                M.PERCENTUALFRETE.Value     := arMargens[I].Percentual_Frete;
                M.PERCENTUALOUTROS.Value    := arMargens[I].Percentual_Outros;
                M.AUTORIZADOPOR.Value       := arMargens[I].Autorizado_Por;
                M.DATAAUTORIZADO.Value      := arMargens[I].Data_Autorizacao;

                M.SelectList('ID_PRODUTO = ' + M.ID_PRODUTO.asString);
                if M.Count = 0 then begin
                  M.ID.isNull := True;
                  M.Insert;
                end else begin
                  M.ID.Value  := TMARGEM(M.Itens[0]).ID.Value;
                  M.Update;
                end;

                pbAtualiza.Progress  := I;
              end;
            end;

            FWC.Commit;

            DisplayMsg(MSG_OK, 'Margens Atualizadas com Sucesso!');

          end else begin
            DisplayMsg(MSG_WAR, 'Há Produtos com SKU sem Cadastro, Verifique!', '', Aux);
            Exit;
          end;
        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Margens!' + sLineBreak + 'Linha = ' + IntToStr(I) + sLineBreak + ' Coluna = ' + IntToStr(J), '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData             := Unassigned;
        pbAtualiza.Visible  := False;
        pbAtualiza.Progress := 0;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(M);
        FreeAndNil(P);
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

      M.MARGEMSKU.Value             := edMargemSKU.Value;
      M.PRECOPONTA.Value            := edPrecoPonta.Value;
      M.PRECOPROMOCIONAL.Value      := edPrecoPromocional.Value;
      M.VALPRECOPROMOCIONAL.Value   := edValidadePromocional.Date;
      M.MARGEMANALISTA.Value        := edMargemAnalista.Value;
      M.PERCENTUALVPC.Value         := edPercentualVPC.Value;
      M.PERCENTUALFRETE.Value       := edPercentualFrete.Value;
      M.PERCENTUALOUTROS.Value      := edPercentualOutros.Value;
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
      SQL.SQL.Add('	M.VALPRECOPROMOCIONAL AS VALPRECOPROMOCIONAL,');
      SQL.SQL.Add('	COALESCE(M.MARGEMANALISTA,0.00) AS MARGEMANALISTA,');
      SQL.SQL.Add('	COALESCE(M.PERCENTUALVPC,0.00) AS PERCENTUALVPC,');
      SQL.SQL.Add('	COALESCE(M.PERCENTUALFRETE,0.00) AS PERCENTUALFRETE,');
      SQL.SQL.Add('	COALESCE(M.PERCENTUALOUTROS,0.00) AS PERCENTUALOUTROS,');
      SQL.SQL.Add('	COALESCE(M.AUTORIZADOPOR,'''') AS AUTORIZADOPOR,');
      SQL.SQL.Add('	M.DATAAUTORIZADO AS DATAAUTORIZADO');
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
          if SQL.FieldByName('VALPRECOPROMOCIONAL').AsDateTime > 0 then
            cds_MargensVALPRECOPROMOCIONAL.Value  := SQL.FieldByName('VALPRECOPROMOCIONAL').Value;
          cds_MargensMARGEMANALISTA.Value       := SQL.FieldByName('MARGEMANALISTA').Value;
          cds_MargensPERCENTUALVPC.Value        := SQL.FieldByName('PERCENTUALVPC').Value;
          cds_MargensPERCENTUALFRETE.Value      := SQL.FieldByName('PERCENTUALFRETE').Value;
          cds_MargensPERCENTUALOUTROS.Value     := SQL.FieldByName('PERCENTUALOUTROS').Value;
          cds_MargensAUTORIZADOPOR.Value        := SQL.FieldByName('AUTORIZADOPOR').Value;
          if SQL.FieldByName('DATAAUTORIZADO').AsDateTime > 0 then
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
