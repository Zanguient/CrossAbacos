unit uBeanImportacao;

interface
uses uFWPersistence, uDomains;

type TIMPORTACAO = Class(TFWPersistence)
  private
    FID: TFieldInteger;
    FID_LOTE: TFieldInteger;
    FID_FORNECEDOR: TFieldInteger;
    FID_USUARIO: TFieldInteger;
    FDATA: TFieldDateTime;
    procedure SetDATA(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_FORNECEDOR(const Value: TFieldInteger);
    procedure SetID_LOTE(const Value: TFieldInteger);
    procedure SetID_USUARIO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID            : TFieldInteger read FID write SetID;
    property DATA          : TFieldDateTime read FDATA write SetDATA;
    property ID_USUARIO    : TFieldInteger read FID_USUARIO write SetID_USUARIO;
    property ID_FORNECEDOR : TFieldInteger read FID_FORNECEDOR write SetID_FORNECEDOR;
    property ID_LOTE       : TFieldInteger read FID_LOTE write SetID_LOTE;
End;
implementation

{ TIMPORTACAO }

procedure TIMPORTACAO.InitInstance;
begin
  inherited;
  ID.isPK        := True;
end;

procedure TIMPORTACAO.SetDATA(const Value: TFieldDateTime);
begin
  FDATA := Value;
end;

procedure TIMPORTACAO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TIMPORTACAO.SetID_FORNECEDOR(const Value: TFieldInteger);
begin
  FID_FORNECEDOR := Value;
end;

procedure TIMPORTACAO.SetID_LOTE(const Value: TFieldInteger);
begin
  FID_LOTE := Value;
end;

procedure TIMPORTACAO.SetID_USUARIO(const Value: TFieldInteger);
begin
  FID_USUARIO := Value;
end;

end.
