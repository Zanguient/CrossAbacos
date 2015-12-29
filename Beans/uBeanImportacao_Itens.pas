unit uBeanImportacao_Itens;

interface
uses uFWPersistence, uDomains;

type TIMPORTACAO_ITENS = Class(TFWPersistence)
  private
    FCUSTO_DIA_E10: TFieldCurrency;
    FID_PRODUTO: TFieldInteger;
    FID: TFieldInteger;
    FSTATUS: TFieldInteger;
    FQUANTIDADE: TFieldFloat;
    FID_IMPORTACAO: TFieldInteger;
    FCUSTO: TFieldCurrency;
    procedure SetCUSTO(const Value: TFieldCurrency);
    procedure SetCUSTO_DIA_E10(const Value: TFieldCurrency);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_IMPORTACAO(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
    procedure SetQUANTIDADE(const Value: TFieldFloat);
    procedure SetSTATUS(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID   : TFieldInteger read FID write SetID;
    property CUSTO : TFieldCurrency read FCUSTO write SetCUSTO;
    property QUANTIDADE : TFieldFloat read FQUANTIDADE write SetQUANTIDADE;
    property ID_IMPORTACAO : TFieldInteger read FID_IMPORTACAO write SetID_IMPORTACAO;
    property ID_PRODUTO : TFieldInteger read FID_PRODUTO write SetID_PRODUTO;
    property STATUS : TFieldInteger read FSTATUS write SetSTATUS;
    property CUSTO_DIA_E10 : TFieldCurrency read FCUSTO_DIA_E10 write SetCUSTO_DIA_E10;
End;

implementation

{ TIMPORTACAO_ITENS }

procedure TIMPORTACAO_ITENS.InitInstance;
begin
  inherited;
  ID.isPK     := True;
end;

procedure TIMPORTACAO_ITENS.SetCUSTO(const Value: TFieldCurrency);
begin
  FCUSTO := Value;
end;

procedure TIMPORTACAO_ITENS.SetCUSTO_DIA_E10(const Value: TFieldCurrency);
begin
  FCUSTO_DIA_E10 := Value;
end;

procedure TIMPORTACAO_ITENS.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TIMPORTACAO_ITENS.SetID_IMPORTACAO(const Value: TFieldInteger);
begin
  FID_IMPORTACAO := Value;
end;

procedure TIMPORTACAO_ITENS.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

procedure TIMPORTACAO_ITENS.SetQUANTIDADE(const Value: TFieldFloat);
begin
  FQUANTIDADE := Value;
end;

procedure TIMPORTACAO_ITENS.SetSTATUS(const Value: TFieldInteger);
begin
  FSTATUS := Value;
end;

end.
