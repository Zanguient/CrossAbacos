unit uBeanProduto;

interface
uses uFWPersistence, uDomains;

type TPRODUTO = Class(TFWPersistence)
  private
    FCODIGO_BARRAS: TFieldInteger;
    FPRECO_VENDA: TFieldFloat;
    FORIGEM_MERCADORIA: TFieldString;
    FPESO: TFieldFloat;
    FUNIDADE_MEDIDA: TFieldString;
    FL: TFieldFloat;
    FPROMOCAO_IPI: TFieldFloat;
    FDIAS_GARANTIA: TFieldInteger;
    FC: TFieldFloat;
    FICMS: TFieldFloat;
    FPRAZO_ENTREGA: TFieldInteger;
    FE: TFieldFloat;
    FESTOQUE_MAXIMO: TFieldInteger;
    FSUB_GRUPO: TFieldString;
    FID: TFieldInteger;
    FNCM: TFieldString;
    FCF: TFieldString;
    FCLASSE: TFieldString;
    FSKU: TFieldString;
    FDISPONIVEL: TFieldFloat;
    FSALDO: TFieldFloat;
    FMARCA: TFieldString;
    FPRODUTO_PAI: TFieldString;
    FNOME: TFieldString;
    FQUANTIDADE_EMBALAGEM: TFieldInteger;
    FGRUPO: TFieldString;
    FCUSTO: TFieldFloat;
    FID_ULTIMOLOTE: TFieldInteger;
    FID_FORNECEDORANTERIOR: TFieldInteger;
    FCUSTOANTERIOR: TFieldCurrency;
    FID_FORNECEDORNOVO: TFieldInteger;
    FUN: TFieldString;
    FCODIGO_CF: TFieldInteger;
    FESTOQUE_MINIMO: TFieldInteger;
    FID_FAMILIA: TFieldInteger;
    FCUSTO_ESTOQUE_FISICO: TFieldCurrency;
    FMEDIA_ALTERACAO: TFieldCurrency;
    FQUANTIDADE_ESTOQUE_FISICO: TFieldInteger;
    procedure SetC(const Value: TFieldFloat);
    procedure SetCF(const Value: TFieldString);
    procedure SetCLASSE(const Value: TFieldString);
    procedure SetCODIGO_BARRAS(const Value: TFieldInteger);
    procedure SetDIAS_GARANTIA(const Value: TFieldInteger);
    procedure SetDISPONIVEL(const Value: TFieldFloat);
    procedure SetE(const Value: TFieldFloat);
    procedure SetESTOQUE_MAXIMO(const Value: TFieldInteger);
    procedure SetGRUPO(const Value: TFieldString);
    procedure SetICMS(const Value: TFieldFloat);
    procedure SetID(const Value: TFieldInteger);
    procedure SetL(const Value: TFieldFloat);
    procedure SetMARCA(const Value: TFieldString);
    procedure SetNCM(const Value: TFieldString);
    procedure SetNOME(const Value: TFieldString);
    procedure SetORIGEM_MERCADORIA(const Value: TFieldString);
    procedure SetPESO(const Value: TFieldFloat);
    procedure SetPRAZO_ENTREGA(const Value: TFieldInteger);
    procedure SetPRECO_VENDA(const Value: TFieldFloat);
    procedure SetPRODUTO_PAI(const Value: TFieldString);
    procedure SetPROMOCAO_IPI(const Value: TFieldFloat);
    procedure SetQUANTIDADE_EMBALAGEM(const Value: TFieldInteger);
    procedure SetSALDO(const Value: TFieldFloat);
    procedure SetSKU(const Value: TFieldString);
    procedure SetSUB_GRUPO(const Value: TFieldString);
    procedure SetUNIDADE_MEDIDA(const Value: TFieldString);
    procedure SetCUSTO(const Value: TFieldFloat);
    procedure SetCUSTOANTERIOR(const Value: TFieldCurrency);
    procedure SetID_FORNECEDORANTERIOR(const Value: TFieldInteger);
    procedure SetID_FORNECEDORNOVO(const Value: TFieldInteger);
    procedure SetID_ULTIMOLOTE(const Value: TFieldInteger);
    procedure SetUN(const Value: TFieldString);
    procedure SetCODIGO_CF(const Value: TFieldInteger);
    procedure SetESTOQUE_MINIMO(const Value: TFieldInteger);
    procedure SetID_FAMILIA(const Value: TFieldInteger);
    procedure SetCUSTO_ESTOQUE_FISICO(const Value: TFieldCurrency);
    procedure SetMEDIA_ALTERACAO(const Value: TFieldCurrency);
    procedure SetQUANTIDADE_ESTOQUE_FISICO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID                         : TFieldInteger     read FID                          write SetID;
    property SKU                        : TFieldString      read FSKU                         write SetSKU;
    property CODIGO_BARRAS              : TFieldInteger     read FCODIGO_BARRAS               write SetCODIGO_BARRAS;
    property NOME                       : TFieldString      read FNOME                        write SetNOME;
    property CUSTOANTERIOR              : TFieldCurrency    read FCUSTOANTERIOR               write SetCUSTOANTERIOR;
    property SALDO                      : TFieldFloat       read FSALDO                       write SetSALDO;
    property DISPONIVEL                 : TFieldFloat       read FDISPONIVEL                  write SetDISPONIVEL;
    property ICMS                       : TFieldFloat       read FICMS                        write SetICMS;
    property CF                         : TFieldString      read FCF                          write SetCF;
    property PRODUTO_PAI                : TFieldString      read FPRODUTO_PAI                 write SetPRODUTO_PAI;
    property MARCA                      : TFieldString      read FMARCA                       write SetMARCA;
    property CLASSE                     : TFieldString      read FCLASSE                      write SetCLASSE;
    property UNIDADE_MEDIDA             : TFieldString      read FUNIDADE_MEDIDA              write SetUNIDADE_MEDIDA;
    property GRUPO                      : TFieldString      read FGRUPO                       write SetGRUPO;
    property SUB_GRUPO                  : TFieldString      read FSUB_GRUPO                   write SetSUB_GRUPO;
    property PRECO_VENDA                : TFieldFloat       read FPRECO_VENDA                 write SetPRECO_VENDA;
    property PROMOCAO_IPI               : TFieldFloat       read FPROMOCAO_IPI                write SetPROMOCAO_IPI;
    property PESO                       : TFieldFloat       read FPESO                        write SetPESO;
    property NCM                        : TFieldString      read FNCM                         write SetNCM;
    property ESTOQUE_MINIMO             : TFieldInteger     read FESTOQUE_MINIMO              write SetESTOQUE_MINIMO;
    property ESTOQUE_MAXIMO             : TFieldInteger     read FESTOQUE_MAXIMO              write SetESTOQUE_MAXIMO;
    property PRAZO_ENTREGA              : TFieldInteger     read FPRAZO_ENTREGA               write SetPRAZO_ENTREGA;
    property QUANTIDADE_EMBALAGEM       : TFieldInteger     read FQUANTIDADE_EMBALAGEM        write SetQUANTIDADE_EMBALAGEM;
    property C                          : TFieldFloat       read FC                           write SetC;
    property L                          : TFieldFloat       read FL                           write SetL;
    property E                          : TFieldFloat       read FE                           write SetE;
    property UN                         : TFieldString      read FUN                          write SetUN;
    property CODIGO_CF                  : TFieldInteger     read FCODIGO_CF                   write SetCODIGO_CF;
    property DIAS_GARANTIA              : TFieldInteger     read FDIAS_GARANTIA               write SetDIAS_GARANTIA;
    property ORIGEM_MERCADORIA          : TFieldString      read FORIGEM_MERCADORIA           write SetORIGEM_MERCADORIA;
    property CUSTO                      : TFieldFloat       read FCUSTO                       write SetCUSTO;
    property ID_FORNECEDORANTERIOR      : TFieldInteger     read FID_FORNECEDORANTERIOR       write SetID_FORNECEDORANTERIOR;
    property ID_FORNECEDORNOVO          : TFieldInteger     read FID_FORNECEDORNOVO           write SetID_FORNECEDORNOVO;
    property ID_ULTIMOLOTE              : TFieldInteger     read FID_ULTIMOLOTE               write SetID_ULTIMOLOTE;
    property CUSTO_ESTOQUE_FISICO       : TFieldCurrency    read FCUSTO_ESTOQUE_FISICO        write SetCUSTO_ESTOQUE_FISICO;
    property QUANTIDADE_ESTOQUE_FISICO  : TFieldInteger     read FQUANTIDADE_ESTOQUE_FISICO   write SetQUANTIDADE_ESTOQUE_FISICO;
    property MEDIA_ALTERACAO            : TFieldCurrency    read FMEDIA_ALTERACAO             write SetMEDIA_ALTERACAO;
    property ID_FAMILIA                 : TFieldInteger     read FID_FAMILIA                  write SetID_FAMILIA;

End;
implementation

{ TPRODUTOABACOS }

procedure TPRODUTO.InitInstance;
begin
  inherited;

  ID.isPK                               := True;

  NOME.isNotNull                        := True;
  SKU.isNotNull                         := True;
  GRUPO.isNotNull                       := True;
  SUB_GRUPO.isNotNull                   := True;
  NCM.isNotNull                         := True;
  CUSTO_ESTOQUE_FISICO.isNotNull        := True;
  QUANTIDADE_ESTOQUE_FISICO.isNotNull   := True;
  MEDIA_ALTERACAO.isNotNull             := True;
  ID_FAMILIA.isNotNull                  := True;

  SKU.isSearchField                     := True;
  NOME.isSearchField                    := True;
  MARCA.isSearchField                   := True;

  SKU.displayLabel                      := 'SKU';
  NOME.displayLabel                     := 'Nome';
  MARCA.displayLabel                    := 'Marca';

  SKU.displayWidth                      := 15;
  NOME.displayWidth                     := 60;
  MARCA.displayWidth                    := 40;

  SKU.Size                              := 100;
  NOME.Size                             := 255;
  CF.Size                               := 100;
  PRODUTO_PAI.Size                      := 100;
  MARCA.Size                            := 100;
  CLASSE.Size                           := 100;
  UNIDADE_MEDIDA.Size                   := 100;
  GRUPO.Size                            := 100;
  SUB_GRUPO.Size                        := 100;
  NCM.Size                              := 10;
  UN.Size                               := 3;
  ORIGEM_MERCADORIA.Size                := 255;
end;
procedure TPRODUTO.SetC(const Value: TFieldFloat);
begin
  FC := Value;
end;

procedure TPRODUTO.SetCF(const Value: TFieldString);
begin
  FCF := Value;
end;

procedure TPRODUTO.SetCLASSE(const Value: TFieldString);
begin
  FCLASSE := Value;
end;

procedure TPRODUTO.SetCODIGO_BARRAS(const Value: TFieldInteger);
begin
  FCODIGO_BARRAS := Value;
end;

procedure TPRODUTO.SetCODIGO_CF(const Value: TFieldInteger);
begin
  FCODIGO_CF := Value;
end;

procedure TPRODUTO.SetCUSTO(const Value: TFieldFloat);
begin
  FCUSTO := Value;
end;

procedure TPRODUTO.SetCUSTOANTERIOR(const Value: TFieldCurrency);
begin
  FCUSTOANTERIOR := Value;
end;

procedure TPRODUTO.SetCUSTO_ESTOQUE_FISICO(const Value: TFieldCurrency);
begin
  FCUSTO_ESTOQUE_FISICO := Value;
end;

procedure TPRODUTO.SetDIAS_GARANTIA(const Value: TFieldInteger);
begin
  FDIAS_GARANTIA := Value;
end;

procedure TPRODUTO.SetDISPONIVEL(const Value: TFieldFloat);
begin
  FDISPONIVEL := Value;
end;

procedure TPRODUTO.SetE(const Value: TFieldFloat);
begin
  FE := Value;
end;

procedure TPRODUTO.SetESTOQUE_MAXIMO(const Value: TFieldInteger);
begin
  FESTOQUE_MAXIMO := Value;
end;

procedure TPRODUTO.SetESTOQUE_MINIMO(const Value: TFieldInteger);
begin
  FESTOQUE_MINIMO := Value;
end;

procedure TPRODUTO.SetGRUPO(const Value: TFieldString);
begin
  FGRUPO := Value;
end;

procedure TPRODUTO.SetICMS(const Value: TFieldFloat);
begin
  FICMS := Value;
end;

procedure TPRODUTO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPRODUTO.SetID_FAMILIA(const Value: TFieldInteger);
begin
  FID_FAMILIA := Value;
end;

procedure TPRODUTO.SetID_FORNECEDORANTERIOR(const Value: TFieldInteger);
begin
  FID_FORNECEDORANTERIOR := Value;
end;

procedure TPRODUTO.SetID_FORNECEDORNOVO(const Value: TFieldInteger);
begin
  FID_FORNECEDORNOVO := Value;
end;

procedure TPRODUTO.SetID_ULTIMOLOTE(const Value: TFieldInteger);
begin
  FID_ULTIMOLOTE := Value;
end;

procedure TPRODUTO.SetL(const Value: TFieldFloat);
begin
  FL := Value;
end;

procedure TPRODUTO.SetMARCA(const Value: TFieldString);
begin
  FMARCA := Value;
end;

procedure TPRODUTO.SetMEDIA_ALTERACAO(const Value: TFieldCurrency);
begin
  FMEDIA_ALTERACAO := Value;
end;

procedure TPRODUTO.SetNCM(const Value: TFieldString);
begin
  FNCM := Value;
end;

procedure TPRODUTO.SetNOME(const Value: TFieldString);
begin
  FNOME := Value;
end;

procedure TPRODUTO.SetORIGEM_MERCADORIA(const Value: TFieldString);
begin
  FORIGEM_MERCADORIA := Value;
end;

procedure TPRODUTO.SetPESO(const Value: TFieldFloat);
begin
  FPESO := Value;
end;

procedure TPRODUTO.SetPRAZO_ENTREGA(const Value: TFieldInteger);
begin
  FPRAZO_ENTREGA := Value;
end;

procedure TPRODUTO.SetPRECO_VENDA(const Value: TFieldFloat);
begin
  FPRECO_VENDA := Value;
end;

procedure TPRODUTO.SetPRODUTO_PAI(const Value: TFieldString);
begin
  FPRODUTO_PAI := Value;
end;

procedure TPRODUTO.SetPROMOCAO_IPI(const Value: TFieldFloat);
begin
  FPROMOCAO_IPI := Value;
end;

procedure TPRODUTO.SetQUANTIDADE_EMBALAGEM(const Value: TFieldInteger);
begin
  FQUANTIDADE_EMBALAGEM := Value;
end;

procedure TPRODUTO.SetQUANTIDADE_ESTOQUE_FISICO(const Value: TFieldInteger);
begin
  FQUANTIDADE_ESTOQUE_FISICO := Value;
end;

procedure TPRODUTO.SetSALDO(const Value: TFieldFloat);
begin
  FSALDO := Value;
end;

procedure TPRODUTO.SetSKU(const Value: TFieldString);
begin
  FSKU := Value;
end;

procedure TPRODUTO.SetSUB_GRUPO(const Value: TFieldString);
begin
  FSUB_GRUPO := Value;
end;

procedure TPRODUTO.SetUN(const Value: TFieldString);
begin
  FUN := Value;
end;

procedure TPRODUTO.SetUNIDADE_MEDIDA(const Value: TFieldString);
begin
  FUNIDADE_MEDIDA := Value;
end;

end.
