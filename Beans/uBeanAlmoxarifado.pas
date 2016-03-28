unit uBeanAlmoxarifado;

interface
uses
  uDomains,
  uFWPersistence;

type
  TALMOXARIFADO = class(TFWPersistence)
  private
    FCODIGO_E10: TFieldInteger;
    FID: TFieldInteger;
    FNOME: TFieldString;
    procedure SetCODIGO_E10(const Value: TFieldInteger);
    procedure SetID(const Value: TFieldInteger);
    procedure SetNOME(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property NOME : TFieldString read FNOME write SetNOME;
    property CODIGO_E10 : TFieldInteger read FCODIGO_E10 write SetCODIGO_E10;
end;

implementation

{ TALMOXARIFADO }

procedure TALMOXARIFADO.InitInstance;
begin
  inherited;
  ID.isPK   := True;

  NOME.Size := 100;

  NOME.isSearchField      := True;

  NOME.displayLabel       := 'Almoxarifado';

  NOME.displayWidth       := 100;

end;

procedure TALMOXARIFADO.SetCODIGO_E10(const Value: TFieldInteger);
begin
  FCODIGO_E10 := Value;
end;

procedure TALMOXARIFADO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TALMOXARIFADO.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

end.
