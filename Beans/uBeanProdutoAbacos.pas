unit uBeanProdutoAbacos;

interface
uses uFWPersistence, uDomains;

type TPRODUTOABACOS = Class(TFWPersistence)
  private
    FUNIDADEMEDIDAABREV: TFieldString;
    FCODIGOFABRICANTE: TFieldString;
    FPESO: TFieldFloat;
    FQUANTIDADEMAXIMA: TFieldInteger;
    FCODIGOPRODUTO: TFieldString;
    FCODIGO: TFieldInteger;
    FCODIGOBARRAS: TFieldString;
    FUNIDADEMEDIDA: TFieldString;
    FLARGURA: TFieldFloat;
    FQUANTIDADEMINIMA: TFieldInteger;
    FDIASGARANTIA: TFieldInteger;
    FCODIGOCATEGORIAFISCAL: TFieldInteger;
    FCLASSIFICACAOFISCAL: TFieldInteger;
    FNOMEPRODUTO: TFieldString;
    FESPESSURA: TFieldFloat;
    FCOMPRIMENTO: TFieldFloat;
    FTIPOPRODUTO: TFieldInteger;
    FQUANTIDADEPOREMBALAGEM: TFieldInteger;
    FPRECOTABELA2: TFieldFloat;
    FPRECOTABELA1: TFieldFloat;
    FCUSTO: TFieldFloat;
    FCODIGOGRUPO: TFieldInteger;
    FCODIGOFAMILIA: TFieldInteger;
    procedure SetCLASSIFICACAOFISCAL(const Value: TFieldInteger);
    procedure SetCODIGO(const Value: TFieldInteger);
    procedure SetCODIGOBARRAS(const Value: TFieldString);
    procedure SetCODIGOCATEGORIAFISCAL(const Value: TFieldInteger);
    procedure SetCODIGOFABRICANTE(const Value: TFieldString);
    procedure SetCODIGOPRODUTO(const Value: TFieldString);
    procedure SetCOMPRIMENTO(const Value: TFieldFloat);
    procedure SetDIASGARANTIA(const Value: TFieldInteger);
    procedure SetESPESSURA(const Value: TFieldFloat);
    procedure SetLARGURA(const Value: TFieldFloat);
    procedure SetNOMEPRODUTO(const Value: TFieldString);
    procedure SetPESO(const Value: TFieldFloat);
    procedure SetQUANTIDADEMAXIMA(const Value: TFieldInteger);
    procedure SetQUANTIDADEMINIMA(const Value: TFieldInteger);
    procedure SetQUANTIDADEPOREMBALAGEM(const Value: TFieldInteger);
    procedure SetTIPOPRODUTO(const Value: TFieldInteger);
    procedure SetUNIDADEMEDIDA(const Value: TFieldString);
    procedure SetUNIDADEMEDIDAABREV(const Value: TFieldString);
    procedure SetCUSTO(const Value: TFieldFloat);
    procedure SetPRECOTABELA1(const Value: TFieldFloat);
    procedure SetPRECOTABELA2(const Value: TFieldFloat);
    procedure SetCODIGOFAMILIA(const Value: TFieldInteger);
    procedure SetCODIGOGRUPO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property CODIGO                  : TFieldInteger read FCODIGO write SetCODIGO;
    property CODIGOPRODUTO           : TFieldString read FCODIGOPRODUTO write SetCODIGOPRODUTO;
    property CODIGOBARRAS            : TFieldString read FCODIGOBARRAS write SetCODIGOBARRAS;
    property CODIGOFABRICANTE        : TFieldString read FCODIGOFABRICANTE write SetCODIGOFABRICANTE;
    property TIPOPRODUTO             : TFieldInteger read FTIPOPRODUTO write SetTIPOPRODUTO;
    property NOMEPRODUTO             : TFieldString read FNOMEPRODUTO write SetNOMEPRODUTO;
    property PESO                    : TFieldFloat read FPESO write SetPESO;
    property COMPRIMENTO             : TFieldFloat read FCOMPRIMENTO write SetCOMPRIMENTO;
    property LARGURA                 : TFieldFloat read FLARGURA write SetLARGURA;
    property ESPESSURA               : TFieldFloat read FESPESSURA write SetESPESSURA;
    property QUANTIDADEPOREMBALAGEM  : TFieldInteger read FQUANTIDADEPOREMBALAGEM write SetQUANTIDADEPOREMBALAGEM;
    property QUANTIDADEMINIMA        : TFieldInteger read FQUANTIDADEMINIMA write SetQUANTIDADEMINIMA;
    property QUANTIDADEMAXIMA        : TFieldInteger read FQUANTIDADEMAXIMA write SetQUANTIDADEMAXIMA;
    property UNIDADEMEDIDA           : TFieldString read FUNIDADEMEDIDA write SetUNIDADEMEDIDA;
    property UNIDADEMEDIDAABREV      : TFieldString read FUNIDADEMEDIDAABREV write SetUNIDADEMEDIDAABREV;
    property CODIGOCATEGORIAFISCAL   : TFieldInteger read FCODIGOCATEGORIAFISCAL write SetCODIGOCATEGORIAFISCAL;
    property CLASSIFICACAOFISCAL     : TFieldInteger read FCLASSIFICACAOFISCAL write SetCLASSIFICACAOFISCAL;
    property DIASGARANTIA            : TFieldInteger read FDIASGARANTIA write SetDIASGARANTIA;
    property CUSTO                   : TFieldFloat read FCUSTO write SetCUSTO;
    property PRECOTABELA1            : TFieldFloat read FPRECOTABELA1 write SetPRECOTABELA1;
    property PRECOTABELA2            : TFieldFloat read FPRECOTABELA2 write SetPRECOTABELA2;
    property CODIGOFAMILIA           : TFieldInteger read FCODIGOFAMILIA write SetCODIGOFAMILIA;
    property CODIGOGRUPO             : TFieldInteger read FCODIGOGRUPO write SetCODIGOGRUPO;
End;
implementation

{ TPRODUTOABACOS }

procedure TPRODUTOABACOS.InitInstance;
begin
  inherited;
  CODIGO.isPK              := True;

  CODIGOPRODUTO.Size       := 50;
  CODIGOBARRAS.Size        := 50;
  CODIGOFABRICANTE.Size    := 50;
  NOMEPRODUTO.Size         := 50;
  UNIDADEMEDIDA.Size       := 50;
  UNIDADEMEDIDAABREV.Size  := 3;
end;

procedure TPRODUTOABACOS.SetCLASSIFICACAOFISCAL(const Value: TFieldInteger);
begin
  FCLASSIFICACAOFISCAL := Value;
end;

procedure TPRODUTOABACOS.SetCODIGO(const Value: TFieldInteger);
begin
  FCODIGO := Value;
end;

procedure TPRODUTOABACOS.SetCODIGOBARRAS(const Value: TFieldString);
begin
  FCODIGOBARRAS := Value;
end;

procedure TPRODUTOABACOS.SetCODIGOCATEGORIAFISCAL(const Value: TFieldInteger);
begin
  FCODIGOCATEGORIAFISCAL := Value;
end;

procedure TPRODUTOABACOS.SetCODIGOFABRICANTE(const Value: TFieldString);
begin
  FCODIGOFABRICANTE := Value;
end;

procedure TPRODUTOABACOS.SetCODIGOFAMILIA(const Value: TFieldInteger);
begin
  FCODIGOFAMILIA := Value;
end;

procedure TPRODUTOABACOS.SetCODIGOGRUPO(const Value: TFieldInteger);
begin
  FCODIGOGRUPO := Value;
end;

procedure TPRODUTOABACOS.SetCODIGOPRODUTO(const Value: TFieldString);
begin
  FCODIGOPRODUTO := Value;
end;

procedure TPRODUTOABACOS.SetCOMPRIMENTO(const Value: TFieldFloat);
begin
  FCOMPRIMENTO := Value;
end;

procedure TPRODUTOABACOS.SetCUSTO(const Value: TFieldFloat);
begin
  FCUSTO := Value;
end;

procedure TPRODUTOABACOS.SetDIASGARANTIA(const Value: TFieldInteger);
begin
  FDIASGARANTIA := Value;
end;

procedure TPRODUTOABACOS.SetESPESSURA(const Value: TFieldFloat);
begin
  FESPESSURA := Value;
end;

procedure TPRODUTOABACOS.SetLARGURA(const Value: TFieldFloat);
begin
  FLARGURA := Value;
end;

procedure TPRODUTOABACOS.SetNOMEPRODUTO(const Value: TFieldString);
begin
  FNOMEPRODUTO := Value;
end;

procedure TPRODUTOABACOS.SetPESO(const Value: TFieldFloat);
begin
  FPESO := Value;
end;

procedure TPRODUTOABACOS.SetPRECOTABELA1(const Value: TFieldFloat);
begin
  FPRECOTABELA1 := Value;
end;

procedure TPRODUTOABACOS.SetPRECOTABELA2(const Value: TFieldFloat);
begin
  FPRECOTABELA2 := Value;
end;

procedure TPRODUTOABACOS.SetQUANTIDADEMAXIMA(const Value: TFieldInteger);
begin
  FQUANTIDADEMAXIMA := Value;
end;

procedure TPRODUTOABACOS.SetQUANTIDADEMINIMA(const Value: TFieldInteger);
begin
  FQUANTIDADEMINIMA := Value;
end;

procedure TPRODUTOABACOS.SetQUANTIDADEPOREMBALAGEM(const Value: TFieldInteger);
begin
  FQUANTIDADEPOREMBALAGEM := Value;
end;

procedure TPRODUTOABACOS.SetTIPOPRODUTO(const Value: TFieldInteger);
begin
  FTIPOPRODUTO := Value;
end;

procedure TPRODUTOABACOS.SetUNIDADEMEDIDA(const Value: TFieldString);
begin
  FUNIDADEMEDIDA := Value;
end;

procedure TPRODUTOABACOS.SetUNIDADEMEDIDAABREV(const Value: TFieldString);
begin
  FUNIDADEMEDIDAABREV := Value;
end;

end.
