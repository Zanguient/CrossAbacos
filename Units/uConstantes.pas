unit uConstantes;

interface

type
  TDADOSLOGIN = record
    Usuario : String;
    LembrarUsuario : Boolean;
    DirRelatorio : String;
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

Const
  DirArqConf: String = 'C:\CrossAbacos\CrossAbacos.ini';
  DirInstall: String = 'C:\CrossAbacos\';
  DirArquivosExcel: String = 'C:\CrossAbacos\Arquivos\';

Var
  LOGIN       : TDADOSLOGIN;
  CONEXAO     : TDADOSCONEXAO;
  USUARIO     : TDADOSUSUARIO;
  MENUS       : array of TMENU;
  DESIGNREL   : Boolean;

implementation

end.
