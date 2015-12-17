unit uBeanFamilia;

interface

uses
  uDomains,
  uFWPersistence;

type
  TFAMILIA = class(TFWPersistence)
  private
    FDESCRICAO: TFieldString;
    FCODIGO: TFieldInteger;
    FCODIGOMARGEM: TFieldInteger;
    FCODIGOABACOS: TFieldInteger;
    procedure SetCODIGO(const Value: TFieldInteger);
    procedure SetCODIGOMARGEM(const Value: TFieldInteger);
    procedure SetDESCRICAO(const Value: TFieldString);
    procedure SetCODIGOABACOS(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property CODIGO       : TFieldInteger   read  FCODIGO       write SetCODIGO;
    property CODIGOABACOS : TFieldInteger   read  FCODIGOABACOS write SetCODIGOABACOS;
    property DESCRICAO    : TFieldString    read  FDESCRICAO    write SetDESCRICAO;
    property CODIGOMARGEM : TFieldInteger   read  FCODIGOMARGEM write SetCODIGOMARGEM;
  end;

implementation

{ TFAMILIA }

procedure TFAMILIA.InitInstance;
begin
  inherited;

  FCODIGO.isPK          := True;

  FDESCRICAO.isNotNull  := True;

  FDESCRICAO.Size       := 100;
end;

procedure TFAMILIA.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TFAMILIA.SetCODIGOABACOS(const Value: TFieldInteger);
begin
  FCODIGOABACOS := Value;
end;

procedure TFAMILIA.SetCODIGOMARGEM(const Value: TFieldInteger);
begin
  FCODIGOMARGEM := Value;
end;

procedure TFAMILIA.SetDESCRICAO(const Value: TFieldString);
begin
  FDESCRICAO := Value;
end;

end.
