CREATE TABLE if not exists usuario
(
  id serial NOT NULL,
  nome character varying(100) NOT NULL,
  email character varying(100) NOT NULL,
  senha character varying(100),
  CONSTRAINT pk_usuario PRIMARY KEY (id)
);

CREATE TABLE if not exists lote
(
  id serial NOT NULL,
  data_hora timestamp,
  CONSTRAINT pk_lote PRIMARY KEY (id)
);

INSERT INTO LOTE(ID, DATA_HORA) VALUES (0, CURRENT_TIMESTAMP);

create table if not exists almoxarifado (
  id serial,
  nome character varying(100) not null,
  codigo_e10 int not null,
  primary key (id)
);

INSERT INTO ALMOXARIFADO(ID, NOME, CODIGO_E10) VALUES (0, 'GERAL', 0);

create table if not exists fornecedor (
  id serial,
  nome varchar(100) not null,
  cnpj varchar(14) not null,
  id_almoxarifado int not null,
  prazo_entrega integer,
  status boolean DEFAULT true,
  
  estoqueminimo integer DEFAULT 0,
  
  estoquemaximo integer DEFAULT 0,
  primary key (id),
  constraint fk_fornecedor_almoxarifado 
  foreign key (id_almoxarifado)
  references almoxarifado (id)
  on delete restrict
  on update cascade);

INSERT INTO FORNECEDOR(ID, NOME, CNPJ, ID_ALMOXARIFADO) VALUES (0, 'Fora de Estoque Virtual', '0', 0);

CREATE TABLE if not exists produto
(
  id serial NOT NULL,
  sku character varying(100) NOT NULL,
  codigo_barras integer,
  nome character varying(255),
  custoanterior numeric(18,2),
  saldo numeric(18,2),
  disponivel numeric(18,2),
  icms numeric(18,2),
  cf character varying(100),
  produto_pai character varying(100),
  marca character varying(100),
  familia character varying(100),
  classe character varying(100),
  unidade_medida character varying(100),
  grupo character varying(100),
  sub_grupo character varying(100),
  preco_venda numeric(18,2),
  promocao_ipi numeric(18,2),
  peso numeric(18,2),
  ncm character varying(10),
  estoque_minimo integer,
  estoque_maximo integer,
  prazo_entrega integer,
  quantidade_embalagem integer,
  c numeric(18,2),
  l numeric(18,2),
  e numeric(18,2),
  un character varying(3),
  codigo_cf integer,
  dias_garantia integer,
  origem_mercadoria character varying(255),
  id_ultimolote integer NOT NULL DEFAULT 0,
  custo numeric(18,2) NOT NULL DEFAULT 0,
  id_fornecedoranterior integer NOT NULL DEFAULT 0,
  id_fornecedornovo integer NOT NULL DEFAULT 0,
  CONSTRAINT produto_pkey PRIMARY KEY (id),
  CONSTRAINT fk_produto_fornecedor1 FOREIGN KEY (id_fornecedoranterior)
      REFERENCES fornecedor (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_produto_fornecedor2 FOREIGN KEY (id_fornecedornovo)
      REFERENCES fornecedor (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_produto_lote1 FOREIGN KEY (id_ultimolote)
      REFERENCES lote (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
);

create table if not exists produtofornecedor (
  id serial,
  cod_prod_fornecedor varchar(100) not null,
  id_produto int not null,
  id_fornecedor int not null,
  custo numeric(18,2),
  id_ultimolote integer,
  quantidade integer,
  status boolean,
  motivo character varying(100),
  primary key (id),
  constraint fk_produtofornecedor_produto1
    foreign key (id_produto)
    references produto (id)
	ON UPDATE CASCADE 
	ON DELETE RESTRICT,
  CONSTRAINT fk_produtofornecedor_lote1 
	FOREIGN KEY (id_ultimolote)
      
	REFERENCES lote (id) MATCH SIMPLE
      
	ON UPDATE CASCADE 
	ON DELETE RESTRICT,
  constraint fk_produtofornecedor_fornecedor1
    foreign key (id_fornecedor)
    references fornecedor (id)
	ON UPDATE CASCADE 
	ON DELETE RESTRICT);

create table if not exists importacao (
  id serial,
  data_hora timestamp,
  id_usuario int not null,
  id_fornecedor int not null,
  id_lote int not null,
  primary key (id),
  constraint fk_importacao_usuario1
    foreign key (id_usuario)
    references usuario (id)
    on delete RESTRICT
    on update cascade,
  constraint fk_importacao_fornecedor1
    foreign key (id_fornecedor)
    references fornecedor (id)
    on delete RESTRICT
    on update cascade,
  constraint fk_importacao_lote1
    foreign key (id_lote)
    references lote (id)
    on delete RESTRICT
    on update cascade);

create table if not exists importacao_itens (
  id serial,
  custo decimal(18,2) not null,
  quantidade int not null,
  id_importacao int not null,
  id_produto int not null,
  status smallint not null,
  primary key (id),
  constraint fk_importacao_itens_importacao1
    foreign key (id_importacao)
    references importacao (id)
    on delete cascade
    on update cascade,
  constraint fk_importacao_itens_produto1
    foreign key (id_produto)
    references produto (id)
    on delete restrict
    on update cascade);

CREATE TABLE if not exists match
( 
  id serial NOT NULL,
  id_lote integer,  
  data_hora timestamp without time zone NOT NULL,  
  id_usuario integer,  
CONSTRAINT pk_match_id PRIMARY KEY (id),  
CONSTRAINT fk_match_lote1 FOREIGN KEY (id_lote)      
REFERENCES lote (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
CONSTRAINT fk_match_usuario1 FOREIGN KEY (id_usuario)      
REFERENCES usuario (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists match_itens
(
  id serial NOT NULL,
  id_match integer,
  id_produto integer,
  custoanterior numeric(18,2),
  custonovo numeric(18,2),
  id_fornecedoranterior integer,
  id_fornecedornovo integer,
  id_ultimolote integer,
  atualizado boolean,
  quantidade integer,
  CONSTRAINT pk_matchitens_id PRIMARY KEY (id),
  CONSTRAINT fk_matchitens_fornecedor1 FOREIGN KEY (id_fornecedoranterior)
      REFERENCES fornecedor (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_matchitens_fornecedor2 FOREIGN KEY (id_fornecedornovo)
      REFERENCES fornecedor (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_matchitens_lote1 FOREIGN KEY (id_ultimolote)
      
      REFERENCES lote (id) MATCH SIMPLE
      
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_matchitens_match1 FOREIGN KEY (id_match)
      REFERENCES match (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_matchitens_produto1 FOREIGN KEY (id_produto)
      REFERENCES produto (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE TABLE usuario_permissao
(

  id serial NOT NULL,

  id_usuario bigint,

  menu character varying(100),

  CONSTRAINT pk_usuario_permissao PRIMARY KEY (id),

  CONSTRAINT fk_usuario_permissao_u FOREIGN KEY (id_usuario)

      REFERENCES usuario (id) MATCH SIMPLE

      ON UPDATE CASCADE ON DELETE CASCADE

);

////////////////////////////////////////////////////
///////Daqui em diante SQL da precificação//////////
////////////////////////////////////////////////////

CREATE TABLE IF NOT EXISTS familia (
  id serial NOT NULL,
  descricao varchar(100) not null,
  margem numeric(18,2) not null,
  autorizadopor varchar(100) not null,
  dataautorizado timestamp without time zone NOT NULL,  
  CONSTRAINT pk_familia_id PRIMARY KEY (id));

INSERT INTO familia(
            id, descricao, margem, autorizadopor, dataautorizado)
    VALUES (0, 'Sem Família', 0, '', CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS margem (
  id serial not null,
  id_produto int not null unique,
  margem_analista numeric(18,2) not null,
  preco_ponta numeric(18,2) not null,
  margem_promocional numeric(18,2) not null,  
  val_margem_promocional date not null,
  resp_margem_promocional varchar(100) not null,
  data_margem_promocional date not null,
  preco_promocional numeric(18,2) not null,
  val_preco_promocional date not null,
  resp_preco_promocional varchar(100) not null,
  data_preco_promocional date not null,
  percentual_vpc numeric(18,2) not null,
  percentual_frete numeric(18,2) not null,
  percentual_outros numeric(18,2) not null,
  data_autorizacao date not null,
  autorizado_por varchar(100) not null,
  solicitado_por varchar(100) not null,
  CONSTRAINT pk_margem_id PRIMARY KEY (id),
  CONSTRAINT fk_margem_produto FOREIGN KEY (id_produto)
      REFERENCES produto (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT);

alter table produto 
	add custo_estoque_fisico numeric(18,2),
	add quantidade_estoque_fisico integer,
	add media_alteracao numeric(18,2),
	add id_familia integer;

	////////////////////////////////////////////////////
	///////Importar as Famílias/////////////////////////
	////////////////////////////////////////////////////

update produto set id_familia = (select coalesce(f.id,0) from familia f where f.descricao = familia limit 1);

alter table produto drop if exists familia;

alter table produto add constraint fk_familia_produto foreign key (id_familia)
      references familia (id) match simple
      on update cascade on delete restrict;

ALTER TABLE produto ADD custo_est_fisico_ant numeric(18,2);

create table if not exists precificacao (
  id serial,
  data_hora timestamp null,
  usuario_id int not null,
  primary key (id),
  constraint fk_precificacao_usuario1 foreign key (usuario_id) references usuario (id) on delete restrict on update cascade);


create table if not exists precificacao_itens (
  id serial NOT NULL,
  custo_ant numeric(18,2),
  custo_atual numeric(18,2),
  precoespecial numeric(18,2),
  precocadastro numeric(18,2),
  margemsugerida numeric(18,2),
  precode numeric(18,2),
  precopor numeric(18,2),
  margempraticar numeric(18,2),
  media numeric(18,2),
  precificacao_id integer NOT NULL,
  tipocalculo integer,
  id_produto integer,
  CONSTRAINT precificacao_itens_pkey PRIMARY KEY (id),
  CONSTRAINT fk_precificacao_itens_precificacao1 FOREIGN KEY (precificacao_id)
      REFERENCES precificacao (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_precificao_itens_prod FOREIGN KEY (id_produto)
      REFERENCES produto (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);

alter table produtofornecedor add custofinal numeric(18,2);
update produtofornecedor set custofinal = custo;

alter table importacao_itens add custofinal numeric(18,2);
update importacao_itens set custofinal = custo;

alter table produto add custofinal numeric(18,2), add custofinalanterior numeric(18,2);
update produto set custofinal = custo, custofinalanterior = custoanterior;

alter table precificacao_itens alter column margempraticar type double precision;