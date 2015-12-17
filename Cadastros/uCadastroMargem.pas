unit uCadastroMargem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  Datasnap.DBClient, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls,
  Vcl.Mask, Vcl.DBCtrls;

type
  TFrmCadastroMargem = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnBotoesVisualizacao: TPanel;
    btFechar: TSpeedButton;
    btAlterar: TSpeedButton;
    pnAjusteBotoes1: TPanel;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    dsPesquisa: TDataSource;
    csPesquisa: TClientDataSet;
    csPesquisaCODIGO: TIntegerField;
    pnEdicao: TPanel;
    pnBotoesEdicao: TPanel;
    btGravar: TSpeedButton;
    btCancelar: TSpeedButton;
    pnAjusteBotoes2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    csPesquisaCROSSMINIMA: TCurrencyField;
    csPesquisaCROSSMAXIMA: TCurrencyField;
    csPesquisaFISICOMINIMA: TCurrencyField;
    csPesquisaFISICOMAXIMA: TCurrencyField;
    csPesquisaPERSONALIZADAMINIMA: TCurrencyField;
    csPesquisaPERSONALIZADAMAXIMA: TCurrencyField;
    btNovo: TSpeedButton;
    btExcluir: TSpeedButton;
    gbEstoqueFisico: TGroupBox;
    gbEstoqueVirtual: TGroupBox;
    gbEstoquePersonalizado: TGroupBox;
    edFisicoMinima: TDBEdit;
    edFisicoMaxima: TDBEdit;
    edVirtualMinima: TDBEdit;
    edVirtualMaxima: TDBEdit;
    edPersonalizadoMinima: TDBEdit;
    edPersonalizadoMaxima: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    csPesquisaDESCRICAO: TStringField;
    Label7: TLabel;
    edDescricao: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btAlterarClick(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CarregaDados;
    procedure InvertePaineis;
    procedure Cancelar;
    procedure Filtrar;
  end;

var
  FrmCadastroMargem: TFrmCadastroMargem;

implementation

uses
  uFuncoes,
  uBeanMargem,
  uFWConnection,
  uMensagem;

{$R *.dfm}

procedure TFrmCadastroMargem.btAlterarClick(Sender: TObject);
begin
  if not csPesquisa.IsEmpty then begin
    csPesquisa.Edit;
    InvertePaineis;
  end;
end;

procedure TFrmCadastroMargem.btCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TFrmCadastroMargem.btExcluirClick(Sender: TObject);
Var
  FWC     : TFWConnection;
  MARGEM  : TMARGEM;
begin
  if not csPesquisa.IsEmpty then begin

    DisplayMsg(MSG_CONF, 'Excluir a Margem Selecionada?');

    if ResultMsgModal = mrYes then begin

      try

        FWC     := TFWConnection.Create;
        MARGEM  := TMARGEM.Create(FWC);
        try

          MARGEM.CODIGO.Value := csPesquisaCODIGO.Value;
          MARGEM.Delete;

          FWC.Commit;

          csPesquisa.Delete;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao Excluir Usuário, Verifique!', '', E.Message);
          end;
        end;
      finally
        FreeAndNil(MARGEM);
        FreeAndNil(FWC);
      end;
    end;
  end;

end;

procedure TFrmCadastroMargem.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadastroMargem.btGravarClick(Sender: TObject);
Var
  FWC     : TFWConnection;
  MARGEM  : TMARGEM;
begin

  //Para Atualizar os Dados no ClientDataset
  Perform(WM_NEXTDLGCTL,0,0);

  FWC     := TFWConnection.Create;
  MARGEM  := TMARGEM.Create(FWC);

  try
    try
      if csPesquisa.State in [dsInsert, dsEdit] then begin

        MARGEM.DESCRICAO.Value                  := csPesquisaDESCRICAO.Value;
        MARGEM.MARGEMCROSSMINIMA.Value          := csPesquisaCROSSMINIMA.Value;
        MARGEM.MARGEMCROSSMAXIMA.Value          := csPesquisaCROSSMAXIMA.Value;
        MARGEM.MARGEMFISICOMINIMA.Value         := csPesquisaFISICOMINIMA.Value;
        MARGEM.MARGEMFISICOMAXIMA.Value         := csPesquisaFISICOMAXIMA.Value;
        MARGEM.MARGEMPERSONALIZADAMINIMA.Value  := csPesquisaPERSONALIZADAMINIMA.Value;
        MARGEM.MARGEMPERSONALIZADAMAXIMA.Value  := csPesquisaPERSONALIZADAMAXIMA.Value;

        if csPesquisa.State = dsInsert then begin
          MARGEM.CODIGO.isNull                    := True;
          MARGEM.Insert;
          csPesquisaCODIGO.Value                  := MARGEM.CODIGO.Value;
        end else begin
          MARGEM.CODIGO.Value                     := csPesquisaCODIGO.Value;
          MARGEM.Update;
        end;

        FWC.Commit;

        csPesquisa.Post;
        InvertePaineis;
      end;
    Except
      on E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_ERR, 'Erro ao Gravar Margem!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(MARGEM);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmCadastroMargem.btNovoClick(Sender: TObject);
begin
  csPesquisa.Append;
  InvertePaineis;
end;

procedure TFrmCadastroMargem.Cancelar;
begin
  if csPesquisa.State in [dsInsert, dsEdit] then
    csPesquisa.Cancel;
  InvertePaineis;
end;

procedure TFrmCadastroMargem.CarregaDados;
Var
  FWC : TFWConnection;
  MF  : TMARGEM;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    MF  := TMARGEM.Create(FWC);
    try

      csPesquisa.EmptyDataSet;

      MF.SelectList('', 'CODIGO');
      if MF.Count > 0 then begin
        for I := 0 to MF.Count -1 do begin
          csPesquisa.Append;
          csPesquisaCODIGO.Value              := TMARGEM(MF.Itens[I]).CODIGO.Value;
          csPesquisaDESCRICAO.Value           := TMARGEM(MF.Itens[I]).DESCRICAO.Value;
          csPesquisaCROSSMINIMA.Value         := TMARGEM(MF.Itens[I]).MARGEMCROSSMINIMA.Value;
          csPesquisaCROSSMAXIMA.Value         := TMARGEM(MF.Itens[I]).MARGEMCROSSMAXIMA.Value;
          csPesquisaFISICOMINIMA.Value        := TMARGEM(MF.Itens[I]).MARGEMFISICOMINIMA.Value;
          csPesquisaFISICOMAXIMA.Value        := TMARGEM(MF.Itens[I]).MARGEMFISICOMAXIMA.Value;
          csPesquisaPERSONALIZADAMINIMA.Value := TMARGEM(MF.Itens[I]).MARGEMPERSONALIZADAMINIMA.Value;
          csPesquisaPERSONALIZADAMAXIMA.Value := TMARGEM(MF.Itens[I]).MARGEMPERSONALIZADAMAXIMA.Value;
          csPesquisa.Post;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(MF);
    FreeAndNil(FWC);
  end;
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
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroMargem.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
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
        if not csPesquisa.IsEmpty then begin
          if csPesquisa.RecNo > 1 then
            csPesquisa.Prior;
        end;
      end;
      VK_DOWN : begin
        if not csPesquisa.IsEmpty then begin
          if csPesquisa.RecNo < csPesquisa.RecordCount then
            csPesquisa.Next;
        end;
      end else begin
        if not edPesquisa.Focused then begin
          if edPesquisa.CanFocus then begin
            edPesquisa.SetFocus;
          end;
        end;
      end;
    end;
  end;
end;

procedure TFrmCadastroMargem.FormResize(Sender: TObject);
Var
  I : Integer;
begin
  pnAjusteBotoes1.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - (btExcluir.Left - btNovo.Left));
  pnAjusteBotoes2.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - btGravar.Width) - 3;

  {I := pnBotoesVisualizacao.ClientWidth div 7;
  gbEstoqueFisico.Left  := I * 1;
  gbEstoqueVirtual.Left := I * 3;
  gbEstoquePersonalizado.Left := I * 5;

  I := (Self.ClientHeight div 2) - gbEstoqueFisico.Height div 2;
  gbEstoqueFisico.Top         := I;
  gbEstoqueVirtual.Top        := I;
  gbEstoquePersonalizado.Top  := I;}

end;

procedure TFrmCadastroMargem.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);
end;

procedure TFrmCadastroMargem.InvertePaineis;
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
