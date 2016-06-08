unit uBeanPrecificacao;

interface
uses
  uDomains,
  uFWPersistence;

type
  TPRECIFICACAO = class(TFWPersistence)
  private
    FID: TFieldInteger;
    FDATA_HORA: TFieldDateTime;
    FUSUARIO_ID: TFieldInteger;
    procedure SetDATA_HORA(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetUSUARIO_ID(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property DATA_HORA : TFieldDateTime read FDATA_HORA write SetDATA_HORA;
    property USUARIO_ID : TFieldInteger read FUSUARIO_ID write SetUSUARIO_ID;
  end;
implementation

{ TPRECIFICACAO }

procedure TPRECIFICACAO.InitInstance;
begin
  inherited;
  ID.isPK              := True;
  USUARIO_ID.isNotNull := True;
end;

procedure TPRECIFICACAO.SetDATA_HORA(const Value: TFieldDateTime);
begin
  FDATA_HORA := Value;
end;

procedure TPRECIFICACAO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPRECIFICACAO.SetUSUARIO_ID(const Value: TFieldInteger);
begin
  FUSUARIO_ID := Value;
end;

end.
