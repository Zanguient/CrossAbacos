unit uBeanUsuario;

interface

uses uFWPersistence, uDomains;

type
  TUSUARIO = class(TFWPersistence)
  private
    FCODIGO: TFieldInteger;
    FEMAIL: TFieldString;
    FSENHA: TFieldString;
    FNOME: TFieldString;
    FPERMITIRCADUSUARIO: TFieldBoolean;
    procedure SetCODIGO(const Value: TFieldInteger);
    procedure SetEMAIL(const Value: TFieldString);
    procedure SetNOME(const Value: TFieldString);
    procedure SetSENHA(const Value: TFieldString);
    procedure SetPERMITIRCADUSUARIO(const Value: TFieldBoolean);
  protected
    procedure InitInstance; override;
  published
    property CODIGO             : TFieldInteger read FCODIGO              write SetCODIGO;
    property NOME               : TFieldString  read FNOME                write SetNOME;
    property EMAIL              : TFieldString  read FEMAIL               write SetEMAIL;
    property SENHA              : TFieldString  read FSENHA               write SetSENHA;
    property PERMITIRCADUSUARIO : TFieldBoolean read FPERMITIRCADUSUARIO  write SetPERMITIRCADUSUARIO;
  end;

implementation

{ TUSUARIO }

procedure TUSUARIO.InitInstance;
begin
  inherited;
  CODIGO.isPK                   := True;

  NOME.isNotNull                := True;
  EMAIL.isNotNull               := True;
  PERMITIRCADUSUARIO.isNotNull  := True;

  NOME.Size                     := 100;
  EMAIL.Size                    := 100;
  SENHA.Size                    := 100;
end;

procedure TUSUARIO.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TUSUARIO.SetEMAIL(const Value: TFieldString);
begin
  FEMAIL := Value;
end;

procedure TUSUARIO.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

procedure TUSUARIO.SetPERMITIRCADUSUARIO(const Value: TFieldBoolean);
begin
  FPERMITIRCADUSUARIO := Value;
end;

procedure TUSUARIO.SetSENHA(const Value: TFieldString);
begin
  FSENHA := Value;
end;

end.
