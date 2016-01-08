unit uBeanMatch;

interface

uses
  uDomains,
  uFWPersistence;

type
  TMATCH = class(TFWPersistence)
  private
    FID: TFieldInteger;
    FID_LOTE: TFieldInteger;
    FDATA_HORA: TFieldDateTime;
    FID_USUARIO: TFieldInteger;
    procedure SetDATA_HORA(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_LOTE(const Value: TFieldInteger);
    procedure SetID_USUARIO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property ID_LOTE : TFieldInteger read FID_LOTE write SetID_LOTE;
    property DATA_HORA : TFieldDateTime read FDATA_HORA write SetDATA_HORA;
    property ID_USUARIO : TFieldInteger read FID_USUARIO write SetID_USUARIO;
  end;
implementation

{ TMATCH }

procedure TMATCH.InitInstance;
begin
  inherited;

  ID.isPK               := True;

  ID_LOTE.isNotNull     := True;
  DATA_HORA.isNotNull   := True;
  ID_USUARIO.isNotNull  := True;

end;

procedure TMATCH.SetDATA_HORA(const Value: TFieldDateTime);
begin
  FDATA_HORA := Value;
end;

procedure TMATCH.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TMATCH.SetID_LOTE(const Value: TFieldInteger);
begin
  FID_LOTE := Value;
end;

procedure TMATCH.SetID_USUARIO(const Value: TFieldInteger);
begin
  FID_USUARIO := Value;
end;

end.
