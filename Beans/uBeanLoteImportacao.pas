unit uBeanLoteImportacao;

interface

uses
  uDomains,
  uFWPersistence;

type
  TLOTEIMPORTACAO = class(TFWPersistence)
    property ID : TFieldInteger;
    property DATAHORA : TFieldDateTime;
  end;

implementation

end.
