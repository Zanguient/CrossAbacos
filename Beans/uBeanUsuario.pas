unit uBeanUsuario;

interface

uses uFWPersistence, uDomains;

type
  TUSUARIO = class(TFWPersistence)
  private
    FID: TFieldInteger;
    FEMAIL: TFieldString;
    FSENHA: TFieldString;
    FNOME: TFieldString;
    FPERMITIR_CAD_USUARIO: TFieldBoolean;
    procedure SetID(const Value: TFieldInteger);
    procedure SetEMAIL(const Value: TFieldString);
    procedure SetNOME(const Value: TFieldString);
    procedure SetSENHA(const Value: TFieldString);
    procedure SetPERMITIR_CAD_USUARIO(const Value: TFieldBoolean);
  protected
    procedure InitInstance; override;
  published
    property ID                   : TFieldInteger read FID                    write SetID;
    property NOME                 : TFieldString  read FNOME                  write SetNOME;
    property EMAIL                : TFieldString  read FEMAIL                 write SetEMAIL;
    property SENHA                : TFieldString  read FSENHA                 write SetSENHA;
    property PERMITIR_CAD_USUARIO : TFieldBoolean read FPERMITIR_CAD_USUARIO  write SetPERMITIR_CAD_USUARIO;
  end;

implementation

{ TUSUARIO }

procedure TUSUARIO.InitInstance;
begin
  inherited;
  ID.isPK                         := True;

  NOME.isNotNull                  := True;
  EMAIL.isNotNull                 := True;
  PERMITIR_CAD_USUARIO.isNotNull  := True;

  NOME.Size                       := 100;
  EMAIL.Size                      := 100;
  SENHA.Size                      := 100;
end;

procedure TUSUARIO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TUSUARIO.SetEMAIL(const Value: TFieldString);
begin
  FEMAIL := Value;
end;

procedure TUSUARIO.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

procedure TUSUARIO.SetPERMITIR_CAD_USUARIO(const Value: TFieldBoolean);
begin

end;

procedure TUSUARIO.SetSENHA(const Value: TFieldString);
begin
  FSENHA := Value;
end;

end.
