unit uBeanFornecedor;

interface

uses
  uDomains,
  uFWPersistence;

type
  TFORNECEDOR = Class(TFWPersistence)
  private
    FCNPJ: TFieldString;
    FID: TFieldInteger;
    FID_ALMOXARIFADO: TFieldInteger;
    FNOME: TFieldString;
    procedure SetCNPJ(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_ALMOXARIFADO(const Value: TFieldInteger);
    procedure SetNOME(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property NOME : TFieldString read FNOME write SetNOME;
    property CNPJ : TFieldString read FCNPJ write SetCNPJ;
    property ID_ALMOXARIFADO : TFieldInteger read FID_ALMOXARIFADO write SetID_ALMOXARIFADO;
End;

implementation

{ TFORNECEDOR }

procedure TFORNECEDOR.InitInstance;
begin
  inherited;

  ID.isPK       := True;

  NOME.isNotNull:= True;

  NOME.Size     := 100;
  CNPJ.Size     := 14;

  NOME.isSearchField := True;
  CNPJ.isSearchField := True;

  NOME.displayLabel  := 'Nome';
  CNPJ.displayLabel  := 'Cnpj';

  NOME.displayWidth  := 100;
  CNPJ.displayWidth  := 50;
end;
procedure TFORNECEDOR.SetCNPJ(const Value: TFieldString);
begin
  FCNPJ := Value;
end;

procedure TFORNECEDOR.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TFORNECEDOR.SetID_ALMOXARIFADO(const Value: TFieldInteger);
begin
  FID_ALMOXARIFADO := Value;
end;

procedure TFORNECEDOR.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

end.
