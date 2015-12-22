unit uBeanProdutoFornecedor;

interface

uses
  uDomains,
  uFWPersistence;

type
  TPRODUTOFORNECEDOR = class(TFWPersistence)
  private
    FID_PRODUTO: TFieldInteger;
    FID: TFieldInteger;
    FCOD_PROD_FORNECEDOR: TFieldString;
    FID_FORNECEDOR: TFieldInteger;
    procedure SetCOD_PROD_FORNECEDOR(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_FORNECEDOR(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property COD_PROD_FORNECEDOR : TFieldString read FCOD_PROD_FORNECEDOR write SetCOD_PROD_FORNECEDOR;
    property ID_PRODUTO : TFieldInteger read FID_PRODUTO write SetID_PRODUTO;
    property ID_FORNECEDOR : TFieldInteger read FID_FORNECEDOR write SetID_FORNECEDOR;

end;

implementation

{ TPRODUTOFORNECEDOR }

procedure TPRODUTOFORNECEDOR.InitInstance;
begin
  inherited;
  ID.isPK := True;

  COD_PROD_FORNECEDOR.Size   := 100;
end;

procedure TPRODUTOFORNECEDOR.SetCOD_PROD_FORNECEDOR(const Value: TFieldString);
begin
  FCOD_PROD_FORNECEDOR := Value;
end;

procedure TPRODUTOFORNECEDOR.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPRODUTOFORNECEDOR.SetID_FORNECEDOR(const Value: TFieldInteger);
begin
  FID_FORNECEDOR := Value;
end;

procedure TPRODUTOFORNECEDOR.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

end.
