unit uBeanMargem;

interface

uses
  uFWPersistence,
  uDomains;

type
  TMARGEM = class(TFWPersistence)
  private
    FCODIGO: TFieldInteger;
    FMARGEMPERSONALIZADAMINIMA: TFieldCurrency;
    FMARGEMFISICOMAXIMA: TFieldCurrency;
    FMARGEMCROSSMAXIMA: TFieldCurrency;
    FMARGEMFISICOMINIMA: TFieldCurrency;
    FMARGEMCROSSMINIMA: TFieldCurrency;
    FMARGEMPERSONALIZADAMAXIMA: TFieldCurrency;
    FDESCRICAO: TFieldString;
    procedure SetCODIGO(const Value: TFieldInteger);
    procedure SetMARGEMCROSSMAXIMA(const Value: TFieldCurrency);
    procedure SetMARGEMCROSSMINIMA(const Value: TFieldCurrency);
    procedure SetMARGEMFISICOMAXIMA(const Value: TFieldCurrency);
    procedure SetMARGEMFISICOMINIMA(const Value: TFieldCurrency);
    procedure SetMARGEMPERSONALIZADAMAXIMA(const Value: TFieldCurrency);
    procedure SetMARGEMPERSONALIZADAMINIMA(const Value: TFieldCurrency);
    procedure SetDESCRICAO(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property CODIGO                     : TFieldInteger   read FCODIGO                      write SetCODIGO;
    property DESCRICAO                  : TFieldString    read FDESCRICAO                   write SetDESCRICAO;
    property MARGEMCROSSMINIMA          : TFieldCurrency  read FMARGEMCROSSMINIMA           write SetMARGEMCROSSMINIMA;
    property MARGEMCROSSMAXIMA          : TFieldCurrency  read FMARGEMCROSSMAXIMA           write SetMARGEMCROSSMAXIMA;
    property MARGEMFISICOMINIMA         : TFieldCurrency  read FMARGEMFISICOMINIMA          write SetMARGEMFISICOMINIMA;
    property MARGEMFISICOMAXIMA         : TFieldCurrency  read FMARGEMFISICOMAXIMA          write SetMARGEMFISICOMAXIMA;
    property MARGEMPERSONALIZADAMINIMA  : TFieldCurrency  read FMARGEMPERSONALIZADAMINIMA   write SetMARGEMPERSONALIZADAMINIMA;
    property MARGEMPERSONALIZADAMAXIMA  : TFieldCurrency  read FMARGEMPERSONALIZADAMAXIMA   write SetMARGEMPERSONALIZADAMAXIMA;
  end;

implementation

{ TMARGEM }

procedure TMARGEM.InitInstance;
begin
  inherited;
  CODIGO.isPK         := True;

  DESCRICAO.isNotNull := True;

  DESCRICAO.Size      := 100;

end;

procedure TMARGEM.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TMARGEM.SetDESCRICAO(const Value: TFieldString);
begin
  FDESCRICAO := Value;
end;

procedure TMARGEM.SetMARGEMCROSSMAXIMA(const Value: TFieldCurrency);
begin
  FMARGEMCROSSMAXIMA := Value;
end;

procedure TMARGEM.SetMARGEMCROSSMINIMA(const Value: TFieldCurrency);
begin
  FMARGEMCROSSMINIMA := Value;
end;

procedure TMARGEM.SetMARGEMFISICOMAXIMA(const Value: TFieldCurrency);
begin
  FMARGEMFISICOMAXIMA := Value;
end;

procedure TMARGEM.SetMARGEMFISICOMINIMA(const Value: TFieldCurrency);
begin
  FMARGEMFISICOMINIMA := Value;
end;

procedure TMARGEM.SetMARGEMPERSONALIZADAMAXIMA(
  const Value: TFieldCurrency);
begin
  FMARGEMPERSONALIZADAMAXIMA := Value;
end;

procedure TMARGEM.SetMARGEMPERSONALIZADAMINIMA(
  const Value: TFieldCurrency);
begin
  FMARGEMPERSONALIZADAMINIMA := Value;
end;

end.
