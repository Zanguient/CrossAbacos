unit uBeanFornecedor;

interface

uses
  uDomains,
  uFWPersistence;

type
  TFORNECEDOR = Class(TFWPersistence)
  private
    FCODIGO: TFieldInteger;
    FCPFCNPJ: TFieldString;
    FNOME: TFieldString;
    FCODIGOFORNECEDORABACOS: TFieldInteger;
    FIERG: TFieldString;
    procedure SetCODIGO(const Value: TFieldInteger);
    procedure SetCPFCNPJ(const Value: TFieldString);
    procedure SetNOME(const Value: TFieldString);
    procedure SetCODIGOFORNECEDORABACOS(const Value: TFieldInteger);
    procedure SetIERG(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property CODIGO                 : TFieldInteger read FCODIGO  write SetCODIGO;
    property CODIGOFORNECEDORABACOS : TFieldInteger read FCODIGOFORNECEDORABACOS write SetCODIGOFORNECEDORABACOS;
    property NOME                   : TFieldString  read FNOME    write SetNOME;
    property CPFCNPJ                : TFieldString  read FCPFCNPJ write SetCPFCNPJ;
    property IERG                   : TFieldString read FIERG write SetIERG;
End;

implementation

{ TFORNECEDOR }

procedure TFORNECEDOR.InitInstance;
begin
  inherited;

  CODIGO.isPK       := True;

  NOME.isNotNull    := True;
  CPFCNPJ.isNotNull := True;

  NOME.Size         := 100;
  CPFCNPJ.Size      := 14;
  IERG.Size         := 14;
end;

procedure TFORNECEDOR.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TFORNECEDOR.SetCODIGOFORNECEDORABACOS(const Value: TFieldInteger);
begin
  FCODIGOFORNECEDORABACOS := Value;
end;

procedure TFORNECEDOR.SetCPFCNPJ(const Value: TFieldString);
begin
  FCPFCNPJ := Value;
end;

procedure TFORNECEDOR.SetIERG(const Value: TFieldString);
begin
  FIERG := Value;
end;

procedure TFORNECEDOR.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

end.
