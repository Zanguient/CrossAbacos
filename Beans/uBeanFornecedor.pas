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
    FPRAZO_ENTREGA: TFieldInteger;
    FESTOQUEMINIMO: TFieldInteger;
    FSTATUS: TFieldBoolean;
    FESTOQUEMAXIMO: TFieldInteger;
    procedure SetCNPJ(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_ALMOXARIFADO(const Value: TFieldInteger);
    procedure SetNOME(const Value: TFieldString);
    procedure SetPRAZO_ENTREGA(const Value: TFieldInteger);
    procedure SetESTOQUEMAXIMO(const Value: TFieldInteger);
    procedure SetESTOQUEMINIMO(const Value: TFieldInteger);
    procedure SetSTATUS(const Value: TFieldBoolean);
  protected
    procedure InitInstance; override;
  published
    property ID               : TFieldInteger   read FID              write SetID;
    property NOME             : TFieldString    read FNOME            write SetNOME;
    property CNPJ             : TFieldString    read FCNPJ            write SetCNPJ;
    property ID_ALMOXARIFADO  : TFieldInteger   read FID_ALMOXARIFADO write SetID_ALMOXARIFADO;
    property PRAZO_ENTREGA    : TFieldInteger   read FPRAZO_ENTREGA   write SetPRAZO_ENTREGA;
    property STATUS           : TFieldBoolean   read FSTATUS          write SetSTATUS;
    property ESTOQUEMINIMO    : TFieldInteger   read FESTOQUEMINIMO   write SetESTOQUEMINIMO;
    property ESTOQUEMAXIMO    : TFieldInteger   read FESTOQUEMAXIMO   write SetESTOQUEMAXIMO;
End;

implementation

{ TFORNECEDOR }

procedure TFORNECEDOR.InitInstance;
begin
  inherited;

  ID.isPK                 := True;

  NOME.isNotNull          := True;
  PRAZO_ENTREGA.isNotNull := True;

  NOME.Size               := 100;
  CNPJ.Size               := 14;

  NOME.isSearchField      := True;
  CNPJ.isSearchField      := True;

  NOME.displayLabel       := 'Nome';
  CNPJ.displayLabel       := 'Cnpj';

  NOME.displayWidth       := 100;
  CNPJ.displayWidth       := 50;
end;
procedure TFORNECEDOR.SetCNPJ(const Value: TFieldString);
begin
  FCNPJ := Value;
end;

procedure TFORNECEDOR.SetESTOQUEMAXIMO(const Value: TFieldInteger);
begin
  FESTOQUEMAXIMO := Value;
end;

procedure TFORNECEDOR.SetESTOQUEMINIMO(const Value: TFieldInteger);
begin
  FESTOQUEMINIMO := Value;
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

procedure TFORNECEDOR.SetPRAZO_ENTREGA(const Value: TFieldInteger);
begin
  FPRAZO_ENTREGA := Value;
end;

procedure TFORNECEDOR.SetSTATUS(const Value: TFieldBoolean);
begin
  FSTATUS := Value;
end;

end.
