unit uBeanFamilia;

interface

uses uFWPersistence, uDomains;

type
  TFAMILIA = class(TFWPersistence)
  private
    FAUTORIZADOPOR: TFieldString;
    FMARGEM: TFieldCurrency;
    FDATAAUTORIZADO: TFieldDateTime;
    FDESCRICAO: TFieldString;
    FID: TFieldInteger;
    procedure SetAUTORIZADOPOR(const Value: TFieldString);
    procedure SetDATAAUTORIZADO(const Value: TFieldDateTime);
    procedure SetDESCRICAO(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetMARGEM(const Value: TFieldCurrency);
  protected
    procedure InitInstance; override;
  published
    property ID             : TFieldInteger read FID write SetID;
    property DESCRICAO      : TFieldString read FDESCRICAO write SetDESCRICAO;
    property MARGEM         : TFieldCurrency read FMARGEM write SetMARGEM;
    property AUTORIZADOPOR  : TFieldString read FAUTORIZADOPOR write SetAUTORIZADOPOR;
    property DATAAUTORIZADO : TFieldDateTime read FDATAAUTORIZADO write SetDATAAUTORIZADO;
  end;

implementation

{ TFAMILIA }

procedure TFAMILIA.InitInstance;
begin
  inherited;

  FID.isPK                  := True;

  FDESCRICAO.isNotNull      := True;
  FMARGEM.isNotNull         := True;
  FAUTORIZADOPOR.isNotNull  := True;
  FDATAAUTORIZADO.isNotNull := True;

  FDESCRICAO.Size           := 100;
  FAUTORIZADOPOR.Size       := 100;
end;

procedure TFAMILIA.SetAUTORIZADOPOR(const Value: TFieldString);
begin
  FAUTORIZADOPOR := Value;
end;

procedure TFAMILIA.SetDATAAUTORIZADO(const Value: TFieldDateTime);
begin
  FDATAAUTORIZADO := Value;
end;

procedure TFAMILIA.SetDESCRICAO(const Value: TFieldString);
begin
  FDESCRICAO := Value;
end;

procedure TFAMILIA.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TFAMILIA.SetMARGEM(const Value: TFieldCurrency);
begin
  FMARGEM := Value;
end;

end.
