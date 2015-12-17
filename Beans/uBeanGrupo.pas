unit uBeanGrupo;

interface

uses
  uDomains,
  uFWPersistence;

type
  TGRUPO = class(TFWPersistence)
  private
    FDESCRICAO: TFieldString;
    FCODIGO: TFieldInteger;
    FCODIGOABACOS: TFieldInteger;
    procedure SetCODIGO(const Value: TFieldInteger);
    procedure SetDESCRICAO(const Value: TFieldString);
    procedure SetCODIGOABACOS(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property CODIGO                 : TFieldInteger read FCODIGO    write SetCODIGO;
    property CODIGOABACOS           : TFieldInteger read FCODIGOABACOS  write SetCODIGOABACOS;
    property DESCRICAO              : TFieldString  read FDESCRICAO write SetDESCRICAO;
  end;

implementation

{ TGRUPO }

procedure TGRUPO.InitInstance;
begin
  inherited;

  CODIGO.isPK         := True;

  DESCRICAO.isNotNull := True;

end;

procedure TGRUPO.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TGRUPO.SetCODIGOABACOS(const Value: TFieldInteger);
begin
  FCODIGOABACOS := Value;
end;

procedure TGRUPO.SetDESCRICAO(const Value: TFieldString);
begin
  FDESCRICAO := Value;
end;

end.
