unit uConstantes;

interface

type
  TTipoPrecificacao = (eNenhum, eMargem, ePrecoEspecial);

type
  TDADOSLOGIN = record
    Usuario : String;
    LembrarUsuario : Boolean;
  end;

  TDADOSCONEXAO = record
    LibVendor : string;
    Database : string;
    Server : string;
    User_Name : string;
    Password : string;
    CharacterSet : string;
    DriverID : string;
    Port : string;
  end;

  TDADOSUSUARIO = record
    CODIGO : Integer;
    NOME : string;
    EMAIL : string;
  end;

  TMENU = record
    NOME    : string;
    CAPTION : string;
  end;

  TCONFIGURACOESLOCAIS = record
    DirRelatorios : string;
  end;

  TCLASSIFICACAO = record
    Codigo : Integer;
    Descricao : String;
  end;

  TPRECOS = record
    ID_PRODUTO : integer;
    SKU : String;
    CUSTO_ANT : Currency;
    CUSTO_NOVO : Currency;
    PRECO_CADASTRO : Currency;
    PRECO_ESPECIAL : Currency;
    MARGEM_SUGERIDA : Currency;
    TIPO : TTipoPrecificacao;
    PRECO_SUGESTAO : Currency;
    PRECODE : Currency;
    PRECOPOR : Currency;
    MARGEM_PRATICAR : Currency;
    MEDIA : Currency;
    PERCENTUAL_VPC : Currency;
    PERCENTUAL_FRETE : Currency;
    PERCENTUAL_OUTROS : Currency;
  end;

Const
  DirArqConf: String = 'C:\CrossAbacos\CrossAbacos.ini';
  DirInstall: String = 'C:\CrossAbacos\';
  DirArquivosExcel: String = 'C:\CrossAbacos\Arquivos\';
  Alfabeto: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

Var
  LOGIN         : TDADOSLOGIN;
  CONEXAO       : TDADOSCONEXAO;
  USUARIO       : TDADOSUSUARIO;
  CONFIG_LOCAL  : TCONFIGURACOESLOCAIS;
  MENUS         : array of TMENU;
  CLASSIFICACAO : array of TCLASSIFICACAO;
  DESIGNREL     : Boolean;

implementation

end.
