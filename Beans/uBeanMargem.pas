unit uBeanMargem;

interface

uses
  uFWPersistence,
  uDomains;

type
  TMARGEM = class(TFWPersistence)
  private
    FAUTORIZADOPOR: TFieldString;
    FID_PRODUTO: TFieldInteger;
    FMARGEMANALISTA: TFieldCurrency;
    FPRECOPROMOCIONAL: TFieldCurrency;
    FDATAAUTORIZADO: TFieldDateTime;
    FID: TFieldInteger;
    FPRECOPONTA: TFieldCurrency;
    FVALPRECOPROMOCIONAL: TFieldDateTime;
    FPERCENTUALOUTROS: TFieldCurrency;
    FPERCENTUALFRETE: TFieldCurrency;
    FPERCENTUALVPC: TFieldCurrency;
    FMARGEMSKU: TFieldCurrency;
    procedure SetAUTORIZADOPOR(const Value: TFieldString);
    procedure SetDATAAUTORIZADO(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
    procedure SetMARGEMANALISTA(const Value: TFieldCurrency);
    procedure SetMARGEMSKU(const Value: TFieldCurrency);
    procedure SetPERCENTUALFRETE(const Value: TFieldCurrency);
    procedure SetPERCENTUALOUTROS(const Value: TFieldCurrency);
    procedure SetPERCENTUALVPC(const Value: TFieldCurrency);
    procedure SetPRECOPONTA(const Value: TFieldCurrency);
    procedure SetPRECOPROMOCIONAL(const Value: TFieldCurrency);
    procedure SetVALPRECOPROMOCIONAL(const Value: TFieldDateTime);
  protected
    procedure InitInstance; override;
  published
    property ID 				          : TFieldInteger   read FID                  write SetID;
    property ID_PRODUTO			      : TFieldInteger   read FID_PRODUTO          write SetID_PRODUTO;
    property MARGEMSKU			      : TFieldCurrency  read FMARGEMSKU           write SetMARGEMSKU;
    property PRECOPONTA			      : TFieldCurrency  read FPRECOPONTA          write SetPRECOPONTA;
    property PRECOPROMOCIONAL	    : TFieldCurrency  read FPRECOPROMOCIONAL    write SetPRECOPROMOCIONAL;
    property VALPRECOPROMOCIONAL  : TFieldDateTime  read FVALPRECOPROMOCIONAL write SetVALPRECOPROMOCIONAL;
    property MARGEMANALISTA		    : TFieldCurrency  read FMARGEMANALISTA      write SetMARGEMANALISTA;
    property PERCENTUALVPC		    : TFieldCurrency  read FPERCENTUALVPC       write SetPERCENTUALVPC;
    property PERCENTUALFRETE	    : TFieldCurrency  read FPERCENTUALFRETE     write SetPERCENTUALFRETE;
    property PERCENTUALOUTROS	    : TFieldCurrency  read FPERCENTUALOUTROS    write SetPERCENTUALOUTROS;
    property AUTORIZADOPOR		    : TFieldString    read FAUTORIZADOPOR       write SetAUTORIZADOPOR;
    property DATAAUTORIZADO		    : TFieldDateTime  read FDATAAUTORIZADO      write SetDATAAUTORIZADO;
  end;

implementation

{ TMARGEM }

procedure TMARGEM.InitInstance;
begin
  inherited;

  FID.isPK                        := True;

  FID_PRODUTO.isNotNull           := True;
  FMARGEMSKU.isNotNull            := True;
  FPRECOPONTA.isNotNull           := True;
  FPRECOPROMOCIONAL.isNotNull     := True;
  FVALPRECOPROMOCIONAL.isNotNull  := True;
  FMARGEMANALISTA.isNotNull       := True;
  FPERCENTUALVPC.isNotNull        := True;
  FPERCENTUALFRETE.isNotNull      := True;
  FPERCENTUALOUTROS.isNotNull     := True;
  FAUTORIZADOPOR.isNotNull        := True;
  FDATAAUTORIZADO.isNotNull       := True;

  FAUTORIZADOPOR.Size             := 100;
end;

procedure TMARGEM.SetAUTORIZADOPOR(const Value: TFieldString);
begin
  FAUTORIZADOPOR := Value;
end;

procedure TMARGEM.SetDATAAUTORIZADO(const Value: TFieldDateTime);
begin
  FDATAAUTORIZADO := Value;
end;

procedure TMARGEM.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TMARGEM.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

procedure TMARGEM.SetMARGEMANALISTA(const Value: TFieldCurrency);
begin
  FMARGEMANALISTA := Value;
end;

procedure TMARGEM.SetMARGEMSKU(const Value: TFieldCurrency);
begin
  FMARGEMSKU := Value;
end;

procedure TMARGEM.SetPERCENTUALFRETE(const Value: TFieldCurrency);
begin
  FPERCENTUALFRETE := Value;
end;

procedure TMARGEM.SetPERCENTUALOUTROS(const Value: TFieldCurrency);
begin
  FPERCENTUALOUTROS := Value;
end;

procedure TMARGEM.SetPERCENTUALVPC(const Value: TFieldCurrency);
begin
  FPERCENTUALVPC := Value;
end;

procedure TMARGEM.SetPRECOPONTA(const Value: TFieldCurrency);
begin
  FPRECOPONTA := Value;
end;

procedure TMARGEM.SetPRECOPROMOCIONAL(const Value: TFieldCurrency);
begin
  FPRECOPROMOCIONAL := Value;
end;

procedure TMARGEM.SetVALPRECOPROMOCIONAL(const Value: TFieldDateTime);
begin
  FVALPRECOPROMOCIONAL := Value;
end;

end.
