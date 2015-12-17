unit uCadastroFamilia;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.DBCtrls;

type
  TFrmCadastroFamilia = class(TForm)
    pnVisualizacao: TPanel;
    gdPesquisa: TDBGrid;
    pnBotoesVisualizacao: TPanel;
    btFechar: TSpeedButton;
    btAlterar: TSpeedButton;
    btNovo: TSpeedButton;
    btExcluir: TSpeedButton;
    pnAjusteBotoes1: TPanel;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    dsPesquisa: TDataSource;
    csPesquisa: TClientDataSet;
    csPesquisaCODIGO: TIntegerField;
    csPesquisaDESCRICAO: TStringField;
    pnEdicao: TPanel;
    pnBotoesEdicao: TPanel;
    btGravar: TSpeedButton;
    btCancelar: TSpeedButton;
    pnAjusteBotoes2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    csPesquisaCODIGOABACOS: TIntegerField;
    csPesquisaCODIGOMARGEM: TIntegerField;
    csPesquisaCROSSMINIMA: TCurrencyField;
    csPesquisaCROSSMAXIMA: TCurrencyField;
    csPesquisaFISICOMINIMA: TCurrencyField;
    csPesquisaFISICOMAXIMA: TCurrencyField;
    csPesquisaPERSONALIZADAMINIMA: TCurrencyField;
    csPesquisaPERSONALIZADAMAXIMA: TCurrencyField;
    Panel4: TPanel;
    edDescricao: TDBEdit;
    Label7: TLabel;
    Panel5: TPanel;
    edCodigoMargem: TDBEdit;
    Label1: TLabel;
    dsMargens: TDataSource;
    csMargens: TClientDataSet;
    csMargensCODIGO: TIntegerField;
    csMargensDESCRICAO: TStringField;
    csMargensCROSSMINIMA: TCurrencyField;
    csMargensCROSSMAXIMA: TCurrencyField;
    csMargensFISICOMINIMA: TCurrencyField;
    csMargensFISICOMAXIMA: TCurrencyField;
    csMargensPERSONALIZADAMINIMA: TCurrencyField;
    csMargensPERSONALIZADAMAXIMA: TCurrencyField;
    Panel6: TPanel;
    gdMargens: TDBGrid;
    Panel7: TPanel;
    Label2: TLabel;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure csPesquisaFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure btCancelarClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
    procedure gdMargensDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CarregaDados;
    procedure InvertePaineis;
    procedure Cancelar;
    procedure Filtrar;
  end;

var
  FrmCadastroFamilia: TFrmCadastroFamilia;

implementation

uses
  uConstantes,
  uFWConnection,
  uBeanFamilia,
  uBeanMargem,
  uMensagem,
  uFuncoes;

{$R *.dfm}

procedure TFrmCadastroFamilia.btAlterarClick(Sender: TObject);
begin
  if not csPesquisa.IsEmpty then begin
    csPesquisa.Edit;
    if csPesquisaCODIGOMARGEM.Value > 0 then
      csMargens.Locate('CODIGO', csPesquisaCODIGOMARGEM.Value, []);
    InvertePaineis;
    AutoSizeDBGrid(gdMargens);
  end;
end;

procedure TFrmCadastroFamilia.btCancelarClick(Sender: TObject);
begin
  Cancelar;
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

  //Para Atualizar os Dados no ClientDataset
  Perform(WM_NEXTDLGCTL,0,0);

  FWC := TFWConnection.Create;
  F   := TFAMILIA.Create(FWC);

  try
    try
      if csPesquisa.State in [dsEdit] then begin

        F.CODIGO.Value        := csPesquisaCODIGO.Value;
        F.CODIGOMARGEM.Value  := csPesquisaCODIGOMARGEM.Value;
        F.Update;

        FWC.Commit;

        csPesquisa.Post;
        InvertePaineis;
      end;
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

procedure TFrmCadastroFamilia.Cancelar;
begin
  if csPesquisa.State in [dsInsert, dsEdit] then
    csPesquisa.Cancel;
  InvertePaineis;
end;

procedure TFrmCadastroFamilia.CarregaDados;
Var
  FWC : TFWConnection;
  F   : TFAMILIA;
  M   : TMARGEM;
  I   : Integer;
begin

  try
    FWC := TFWConnection.Create;
    F  := TFAMILIA.Create(FWC);
    M  := TMARGEM.Create(FWC);
    try

      csPesquisa.EmptyDataSet;

      F.SelectList('', 'CODIGO');
      if F.Count > 0 then begin
        for I := 0 to F.Count -1 do begin
          csPesquisa.Append;
          csPesquisaCODIGO.Value              := TFAMILIA(F.Itens[I]).CODIGO.Value;
          csPesquisaDESCRICAO.Value           := TFAMILIA(F.Itens[I]).DESCRICAO.Value;
          csPesquisaCODIGOABACOS.Value        := TFAMILIA(F.Itens[I]).CODIGOABACOS.Value;
          csPesquisaCODIGOMARGEM.Value        := TFAMILIA(F.Itens[I]).CODIGOMARGEM.Value;
          csPesquisaCROSSMINIMA.Value         := 0.00;
          csPesquisaCROSSMAXIMA.Value         := 0.00;
          csPesquisaFISICOMINIMA.Value        := 0.00;
          csPesquisaFISICOMAXIMA.Value        := 0.00;
          csPesquisaPERSONALIZADAMINIMA.Value := 0.00;
          csPesquisaPERSONALIZADAMAXIMA.Value := 0.00;

          M.SelectList('CODIGO = ' + TFAMILIA(F.Itens[0]).CODIGOMARGEM.asString);
          if M.Count > 0 then begin
            csPesquisaCROSSMINIMA.Value         := TMARGEM(M.Itens[0]).MARGEMCROSSMINIMA.Value;
            csPesquisaCROSSMAXIMA.Value         := TMARGEM(M.Itens[0]).MARGEMCROSSMAXIMA.Value;
            csPesquisaFISICOMINIMA.Value        := TMARGEM(M.Itens[0]).MARGEMFISICOMINIMA.Value;
            csPesquisaFISICOMAXIMA.Value        := TMARGEM(M.Itens[0]).MARGEMFISICOMAXIMA.Value;
            csPesquisaPERSONALIZADAMINIMA.Value := TMARGEM(M.Itens[0]).MARGEMPERSONALIZADAMINIMA.Value;
            csPesquisaPERSONALIZADAMAXIMA.Value := TMARGEM(M.Itens[0]).MARGEMPERSONALIZADAMAXIMA.Value;
          end;
          csPesquisa.Post;
        end;
      end;

      csMargens.EmptyDataSet;

      M.SelectList('', 'CODIGO');
      if M.Count > 0 then begin
        for I := 0 to M.Count -1 do begin
          csMargens.Append;
          csMargensCODIGO.Value               := TMARGEM(M.Itens[I]).CODIGO.Value;
          csMargensDESCRICAO.Value            := TMARGEM(M.Itens[I]).DESCRICAO.Value;
          csMargensCROSSMINIMA.Value          := TMARGEM(M.Itens[I]).MARGEMCROSSMINIMA.Value;
          csMargensCROSSMAXIMA.Value          := TMARGEM(M.Itens[I]).MARGEMCROSSMAXIMA.Value;
          csMargensFISICOMINIMA.Value         := TMARGEM(M.Itens[I]).MARGEMFISICOMINIMA.Value;
          csMargensFISICOMAXIMA.Value         := TMARGEM(M.Itens[I]).MARGEMFISICOMAXIMA.Value;
          csMargensPERSONALIZADAMINIMA.Value  := TMARGEM(M.Itens[I]).MARGEMPERSONALIZADAMINIMA.Value;
          csMargensPERSONALIZADAMAXIMA.Value  := TMARGEM(M.Itens[I]).MARGEMPERSONALIZADAMAXIMA.Value;
          csMargens.Post;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(F);
    FreeAndNil(M);
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
  csPesquisa.Filtered := False;
  csPesquisa.Filtered := Length(edPesquisa.Text) > 0;
end;

procedure TFrmCadastroFamilia.FormCreate(Sender: TObject);
begin
  Self.ClientHeight := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.ClientWidth  := Application.MainForm.ClientWidth;
  Self.Height       := Application.MainForm.ClientHeight - 2; //Cabeçalho form principal
  Self.Width        := Application.MainForm.ClientWidth;
  Self.Top          := Application.MainForm.Top   + Application.MainForm.BorderWidth + 47;
  Self.Left         := Application.MainForm.Left  + Application.MainForm.BorderWidth + 3;
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

procedure TFrmCadastroFamilia.FormResize(Sender: TObject);
begin
  pnAjusteBotoes1.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - (btAlterar.Left ));
  pnAjusteBotoes2.Width := ((pnBotoesVisualizacao.ClientWidth div 2) - btGravar.Width) - 3;
end;

procedure TFrmCadastroFamilia.FormShow(Sender: TObject);
begin
  csPesquisa.CreateDataSet;
  csMargens.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPesquisa);
end;

procedure TFrmCadastroFamilia.gdMargensDblClick(Sender: TObject);
begin
  csPesquisaCODIGOMARGEM.Value        := csMargensCODIGO.Value;
  csPesquisaCROSSMINIMA.Value         := csMargensCROSSMINIMA.Value;
  csPesquisaCROSSMAXIMA.Value         := csMargensCROSSMAXIMA.Value;
  csPesquisaFISICOMINIMA.Value        := csMargensFISICOMINIMA.Value;
  csPesquisaFISICOMAXIMA.Value        := csMargensFISICOMAXIMA.Value;
  csPesquisaPERSONALIZADAMINIMA.Value := csMargensPERSONALIZADAMINIMA.Value;
  csPesquisaPERSONALIZADAMAXIMA.Value := csMargensPERSONALIZADAMAXIMA.Value;
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
