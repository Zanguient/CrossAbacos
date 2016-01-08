unit uBeanMatch_Itens;

interface

uses
  uDomains,
  uFWPersistence;

type
  TMATCH_ITENS = class(TFWPersistence)
  private
    FATUALIZADO: TFieldBoolean;
    FID_PRODUTO: TFieldInteger;
    FID_FORNECEDORANTERIOR: TFieldInteger;
    FCUSTONOVO: TFieldCurrency;
    FCUSTOANTERIOR: TFieldCurrency;
    FID: TFieldInteger;
    FIMPORTADO: TFieldBoolean;
    FID_MATCH: TFieldInteger;
    FID_FORNECEDORNOVO: TFieldInteger;
    FID_ULTIMOLOTE: TFieldInteger;
    procedure SetATUALIZADO(const Value: TFieldBoolean);
    procedure SetCUSTOANTERIOR(const Value: TFieldCurrency);
    procedure SetCUSTONOVO(const Value: TFieldCurrency);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_FORNECEDORANTERIOR(const Value: TFieldInteger);
    procedure SetID_FORNECEDORNOVO(const Value: TFieldInteger);
    procedure SetID_MATCH(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
    procedure SetIMPORTADO(const Value: TFieldBoolean);
    procedure SetID_ULTIMOLOTE(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property ID_MATCH : TFieldInteger read FID_MATCH write SetID_MATCH;
    property ID_PRODUTO : TFieldInteger read FID_PRODUTO write SetID_PRODUTO;
    property CUSTOANTERIOR : TFieldCurrency read FCUSTOANTERIOR write SetCUSTOANTERIOR;
    property CUSTONOVO : TFieldCurrency read FCUSTONOVO write SetCUSTONOVO;
    property ID_FORNECEDORANTERIOR : TFieldInteger read FID_FORNECEDORANTERIOR write SetID_FORNECEDORANTERIOR;
    property ID_FORNECEDORNOVO : TFieldInteger read FID_FORNECEDORNOVO write SetID_FORNECEDORNOVO;
    property ATUALIZADO : TFieldBoolean read FATUALIZADO write SetATUALIZADO;
    property IMPORTADO : TFieldBoolean read FIMPORTADO write SetIMPORTADO;
    property ID_ULTIMOLOTE : TFieldInteger read FID_ULTIMOLOTE write SetID_ULTIMOLOTE;
  end;

implementation

{ TMATCH_ITENS }

procedure TMATCH_ITENS.InitInstance;
begin
  inherited;

  ID.isPK                         := True;

  ID_MATCH.isNotNull              := True;
  ID_PRODUTO.isNotNull            := True;
  CUSTOANTERIOR.isNotNull         := True;
  CUSTONOVO.isNotNull             := True;
  ID_FORNECEDORANTERIOR.isNotNull := True;
  ID_FORNECEDORNOVO.isNotNull     := True;
  ID_ULTIMOLOTE.isNotNull         := True;
  ATUALIZADO.isNotNull            := True;
  IMPORTADO.isNotNull             := True;
end;

procedure TMATCH_ITENS.SetATUALIZADO(const Value: TFieldBoolean);
begin
  FATUALIZADO := Value;
end;

procedure TMATCH_ITENS.SetCUSTOANTERIOR(const Value: TFieldCurrency);
begin
  FCUSTOANTERIOR := Value;
end;

procedure TMATCH_ITENS.SetCUSTONOVO(const Value: TFieldCurrency);
begin
  FCUSTONOVO := Value;
end;

procedure TMATCH_ITENS.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TMATCH_ITENS.SetID_FORNECEDORANTERIOR(const Value: TFieldInteger);
begin
  FID_FORNECEDORANTERIOR := Value;
end;

procedure TMATCH_ITENS.SetID_FORNECEDORNOVO(const Value: TFieldInteger);
begin
  FID_FORNECEDORNOVO := Value;
end;

procedure TMATCH_ITENS.SetID_MATCH(const Value: TFieldInteger);
begin
  FID_MATCH := Value;
end;

procedure TMATCH_ITENS.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

procedure TMATCH_ITENS.SetID_ULTIMOLOTE(const Value: TFieldInteger);
begin
  FID_ULTIMOLOTE := Value;
end;

procedure TMATCH_ITENS.SetIMPORTADO(const Value: TFieldBoolean);
begin
  FIMPORTADO := Value;
end;

end.
