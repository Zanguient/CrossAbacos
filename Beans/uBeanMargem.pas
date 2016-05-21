unit uBeanMargem;

interface

uses
  uFWPersistence,
  uDomains;

type
  TMARGEM = class(TFWPersistence)
  private
    FDATA_AUTORIZACAO: TFieldDateTime;
    FRESP_MARGEM_PROMOCIONAL: TFieldString;
    FID_PRODUTO: TFieldInteger;
    FPRECO_PONTA: TFieldCurrency;
    FRESP_PRECO_PROMOCIONAL: TFieldString;
    FPERCENTUAL_OUTROS: TFieldCurrency;
    FDATA_MARGEM_PROMOCIONAL: TFieldDateTime;
    FSOLICITADO_POR: TFieldString;
    FDATA_PRECO_PROMOCIONAL: TFieldDateTime;
    FID: TFieldInteger;
    FPERCENTUAL_FRETE: TFieldCurrency;
    FPERCENTUAL_VPC: TFieldCurrency;
    FAUTORIZADO_POR: TFieldString;
    FVAL_MARGEM_PROMOCIONAL: TFieldDateTime;
    FMARGEM_ANALISTA: TFieldCurrency;
    FMARGEM_PROMOCIONAL: TFieldCurrency;
    FVAL_PRECO_PROMOCIONAL: TFieldDateTime;
    FPRECO_PROMOCIONAL: TFieldCurrency;
    procedure SetAUTORIZADO_POR(const Value: TFieldString);
    procedure SetDATA_AUTORIZACAO(const Value: TFieldDateTime);
    procedure SetDATA_MARGEM_PROMOCIONAL(const Value: TFieldDateTime);
    procedure SetDATA_PRECO_PROMOCIONAL(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
    procedure SetMARGEM_ANALISTA(const Value: TFieldCurrency);
    procedure SetMARGEM_PROMOCIONAL(const Value: TFieldCurrency);
    procedure SetPERCENTUAL_FRETE(const Value: TFieldCurrency);
    procedure SetPERCENTUAL_OUTROS(const Value: TFieldCurrency);
    procedure SetPERCENTUAL_VPC(const Value: TFieldCurrency);
    procedure SetPRECO_PONTA(const Value: TFieldCurrency);
    procedure SetPRECO_PROMOCIONAL(const Value: TFieldCurrency);
    procedure SetRESP_MARGEM_PROMOCIONAL(const Value: TFieldString);
    procedure SetRESP_PRECO_PROMOCIONAL(const Value: TFieldString);
    procedure SetSOLICITADO_POR(const Value: TFieldString);
    procedure SetVAL_MARGEM_PROMOCIONAL(const Value: TFieldDateTime);
    procedure SetVAL_PRECO_PROMOCIONAL(const Value: TFieldDateTime);
  protected
    procedure InitInstance; override;
  published
    property ID 				              : TFieldInteger read FID write SetID;
    property ID_PRODUTO			          : TFieldInteger read FID_PRODUTO write SetID_PRODUTO;
    property MARGEM_ANALISTA          : TFieldCurrency read FMARGEM_ANALISTA write SetMARGEM_ANALISTA;
    property PRECO_PONTA              : TFieldCurrency read FPRECO_PONTA write SetPRECO_PONTA;
    property MARGEM_PROMOCIONAL       : TFieldCurrency read FMARGEM_PROMOCIONAL write SetMARGEM_PROMOCIONAL;
    property VAL_MARGEM_PROMOCIONAL   : TFieldDateTime read FVAL_MARGEM_PROMOCIONAL write SetVAL_MARGEM_PROMOCIONAL;
    property RESP_MARGEM_PROMOCIONAL  : TFieldString read FRESP_MARGEM_PROMOCIONAL write SetRESP_MARGEM_PROMOCIONAL;
    property DATA_MARGEM_PROMOCIONAL  : TFieldDateTime read FDATA_MARGEM_PROMOCIONAL write SetDATA_MARGEM_PROMOCIONAL;
    property PRECO_PROMOCIONAL        : TFieldCurrency read FPRECO_PROMOCIONAL write SetPRECO_PROMOCIONAL;
    property VAL_PRECO_PROMOCIONAL    : TFieldDateTime read FVAL_PRECO_PROMOCIONAL write SetVAL_PRECO_PROMOCIONAL;
    property RESP_PRECO_PROMOCIONAL   : TFieldString read FRESP_PRECO_PROMOCIONAL write SetRESP_PRECO_PROMOCIONAL;
    property DATA_PRECO_PROMOCIONAL   : TFieldDateTime read FDATA_PRECO_PROMOCIONAL write SetDATA_PRECO_PROMOCIONAL;
    property PERCENTUAL_VPC           : TFieldCurrency read FPERCENTUAL_VPC write SetPERCENTUAL_VPC;
    property PERCENTUAL_FRETE         : TFieldCurrency read FPERCENTUAL_FRETE write SetPERCENTUAL_FRETE;
    property PERCENTUAL_OUTROS        : TFieldCurrency read FPERCENTUAL_OUTROS write SetPERCENTUAL_OUTROS;
    property DATA_AUTORIZACAO         : TFieldDateTime read FDATA_AUTORIZACAO write SetDATA_AUTORIZACAO;
    property AUTORIZADO_POR           : TFieldString read FAUTORIZADO_POR write SetAUTORIZADO_POR;
    property SOLICITADO_POR           : TFieldString read FSOLICITADO_POR write SetSOLICITADO_POR;
  end;

implementation

{ TMARGEM }

procedure TMARGEM.InitInstance;
begin
  inherited;
  FID.isPK                            := True;

  FID_PRODUTO.isNotNull               := True;
  FMARGEM_ANALISTA.isNotNull          := True;
  FPRECO_PONTA.isNotNull              := True;
  FMARGEM_PROMOCIONAL.isNotNull       := True;
  FVAL_MARGEM_PROMOCIONAL.isNotNull   := True;
  FRESP_MARGEM_PROMOCIONAL.isNotNull  := True;
  FDATA_MARGEM_PROMOCIONAL.isNotNull  := True;
  FPRECO_PROMOCIONAL.isNotNull        := True;
  FVAL_PRECO_PROMOCIONAL.isNotNull    := True;
  FRESP_PRECO_PROMOCIONAL.isNotNull   := True;
  FDATA_PRECO_PROMOCIONAL.isNotNull   := True;
  FPERCENTUAL_VPC.isNotNull           := True;
  FPERCENTUAL_FRETE.isNotNull         := True;
  FPERCENTUAL_OUTROS.isNotNull        := True;
  FDATA_AUTORIZACAO.isNotNull         := True;
  FAUTORIZADO_POR.isNotNull           := True;
  FSOLICITADO_POR.isNotNull           := True;

  FRESP_MARGEM_PROMOCIONAL.Size       := 100;
  FRESP_PRECO_PROMOCIONAL.Size        := 100;
  FAUTORIZADO_POR.Size                := 100;
  FSOLICITADO_POR.Size                := 100;

end;

procedure TMARGEM.SetAUTORIZADO_POR(const Value: TFieldString);
begin
  FAUTORIZADO_POR := Value;
end;

procedure TMARGEM.SetDATA_AUTORIZACAO(const Value: TFieldDateTime);
begin
  FDATA_AUTORIZACAO := Value;
end;

procedure TMARGEM.SetDATA_MARGEM_PROMOCIONAL(const Value: TFieldDateTime);
begin
  FDATA_MARGEM_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetDATA_PRECO_PROMOCIONAL(const Value: TFieldDateTime);
begin
  FDATA_PRECO_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TMARGEM.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

procedure TMARGEM.SetMARGEM_ANALISTA(const Value: TFieldCurrency);
begin
  FMARGEM_ANALISTA := Value;
end;

procedure TMARGEM.SetMARGEM_PROMOCIONAL(const Value: TFieldCurrency);
begin
  FMARGEM_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetPERCENTUAL_FRETE(const Value: TFieldCurrency);
begin
  FPERCENTUAL_FRETE := Value;
end;

procedure TMARGEM.SetPERCENTUAL_OUTROS(const Value: TFieldCurrency);
begin
  FPERCENTUAL_OUTROS := Value;
end;

procedure TMARGEM.SetPERCENTUAL_VPC(const Value: TFieldCurrency);
begin
  FPERCENTUAL_VPC := Value;
end;

procedure TMARGEM.SetPRECO_PONTA(const Value: TFieldCurrency);
begin
  FPRECO_PONTA := Value;
end;

procedure TMARGEM.SetPRECO_PROMOCIONAL(const Value: TFieldCurrency);
begin
  FPRECO_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetRESP_MARGEM_PROMOCIONAL(const Value: TFieldString);
begin
  FRESP_MARGEM_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetRESP_PRECO_PROMOCIONAL(const Value: TFieldString);
begin
  FRESP_PRECO_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetSOLICITADO_POR(const Value: TFieldString);
begin
  FSOLICITADO_POR := Value;
end;

procedure TMARGEM.SetVAL_MARGEM_PROMOCIONAL(const Value: TFieldDateTime);
begin
  FVAL_MARGEM_PROMOCIONAL := Value;
end;

procedure TMARGEM.SetVAL_PRECO_PROMOCIONAL(const Value: TFieldDateTime);
begin
  FVAL_PRECO_PROMOCIONAL := Value;
end;

end.
