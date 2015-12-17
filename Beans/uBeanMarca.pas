unit uBeanMarca;

interface

uses
  uDomains,
  uFWPersistence;

type
  TMARCA = class(TFWPersistence)
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
    property CODIGO                 : TFieldInteger read FCODIGO        write SetCODIGO;
    property CODIGOABACOS           : TFieldInteger read FCODIGOABACOS  write SetCODIGOABACOS;
    property DESCRICAO              : TFieldString  read FDESCRICAO     write SetDESCRICAO;
  end;

implementation

{ TMARCA }

procedure TMARCA.InitInstance;
begin
  inherited;

  CODIGO.isPK         := True;

  DESCRICAO.isNotNull := True;

end;

procedure TMARCA.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TMARCA.SetCODIGOABACOS(const Value: TFieldInteger);
begin
  FCODIGOABACOS := Value;
end;

procedure TMARCA.SetDESCRICAO(const Value: TFieldString);
begin
  FDESCRICAO := Value;
end;

end.
