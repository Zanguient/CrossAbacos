unit uBeanLoteImportacao;

interface

uses
  uDomains,
  uFWPersistence;

type
  TLOTE = class(TFWPersistence)
  private
    FID: TFieldInteger;
    FDATA_HORA: TFieldDateTime;
    procedure SetDATA_HORA(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property DATA_HORA : TFieldDateTime read FDATA_HORA write SetDATA_HORA;
  end;

implementation

{ TLOTEIMPORTACAO }

procedure TLOTE.InitInstance;
begin
  inherited;
  ID.isPK             := True;
  DATA_HORA.isNotNull := True;
end;

procedure TLOTE.SetDATA_HORA(const Value: TFieldDateTime);
begin
  FDATA_HORA := Value;
end;

procedure TLOTE.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

end.
