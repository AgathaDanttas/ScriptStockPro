/*Criando o banco de dados,nomeando de STOCK_PROdb*/
create database STOCK_PROdb;

/*Ativando o Banco de Dados*/
use STOCK_PROdb;

/*Suporte a acentuação para o Banco de Dados*/
CREATE DATABASE stock_pro CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

/*Criando a tabela Colaborador (Corresponde aos Funcionários da Empresa que tem acesso ao Software Stock Pro)*/
Create Table Colaborador (
idColaborador int auto_increment primary key,
matricula int (8) unique not null,
senha varchar (12) not null,
email varchar(30),
cpf varchar(14) unique not null,
nomeColaborador varchar(16) not null,
sobrenomeColaborador varchar(35),
ddd int,
telefone varchar(45),
logradouro varchar(45),
bairro varchar(15),
cidade varchar(15),
numero varchar(3),
cep varchar(9),
estado varchar(18),
tipo varchar(20)
);

/*Criando a tabela Produto (Corresponde aos Produtos Comprados pela Empresa)*/
create table Produto (
    idProduto int auto_increment primary key,
    nomeProduto varchar(15),
    quantidadeProduto int (300),
    precouUnico double,
    numeroLote int,
    precoCompra varchar(45),
    dataValidade date,
    categoria varchar(45)
);

/*Tabela onde registra as transações de entrada dos Produtos entregue do Forncedor*/
create table entrada (
    idEntrada int primary key,
    dataEntrada date default now(),
    horaEntrada time generated always as (time(dataEntrada)),
    qtdProdutos int (300)
);

/*Tabela onde registra as transações de Saídsa dos Produtos entregue do Forncedor*/
create table saida (
    idSaida int auto_increment primary key,
    dataSaida date default now(),
    horaSaida time generated always as (time(dataSaida)),
    tipo varchar (50) not null,
    qtdProdutos int (300)
);

/* Tabela onde registra a ação realizada saida/entrada do produto*/
create table afeta_produto (
    saida_idSaida INT,
    entrada_idEntrada INT,
    produto_idProduto INT,
    foreign key (Saida_idSaida) references saida(idSaida),
    foreign key (Entrada_idEntrada) references entrada(idEntrada),
    foreign key (Produto_idProduto) references produto(idProduto)
);

/* Tabela onde registra a atualização da ação do produto*/
create table realiza_atualizacao (
    Usuario_idUsuario int,
    Saida_idSaida int ,
    Entrada_idEntrada INT,
    foreign key (Usuario_idUsuario) references Colaborador(idColaborador),
    foreign key (Saida_idSaida) references saida(idSaida),
	foreign key(Entrada_idEntrada) references entrada(idEntrada)
);

create table cadastra (
    Colaborador_idColaborador int,
    Produto_idProduto int,
   foreign key (Usuario_idUsuario) references Colaborador(idColaborador),
    foreign key (Produto_idProduto) references Produto(idProduto)
);

create table cadastroFornecedor (
    idFornecedor int auto_increment primary key,
    nomeFornecedor varchar(16),
    sobrenomeForncedor varchar(45),
    empresa varchar (15),
    ddd int,
    telefone varchar(9),
    email varchar(20),
    cnpj varchar(14),
    cep varchar(10),
    cidade varchar(15),
    numero varchar(4),
    estado varchar(18),
    bairro varchar(15),
    logradouro varchar(45)
);

create table fornece (
    Produto_idProduto int,
    Fornecedor_idFornecedor int,
    foreign key (Produto_idProduto) references Produto(idProduto),
    foreign key  (Fornecedor_idFornecedor) references Fornecedor(idFornecedor)
);

/*comandos para manipular dados*/
/* inserir dados */
-- Esse Insert é para quando for trabalhas com dados mais simples,menos complexos....Caso ao contrário usar o Stored Procedure
insert into Colaborador (idColaborador, login, senha, email, cpf, nomeColaborador, Sobrenome, ddd, telefone, logradouro, bairro, cidade, numero, cep, estado, tipo)
values (1, 'user1', 'password1', 'user1@example.com', '12345678901', 'Nome1', 'Sobrenome1', 11, '123456789', 'Rua A', 'Bairro A', 'Cidade A', '123', '12345678', 'Estado A', 'Tipo A'); -- exemplo

/*atualizar dados */ -- exemplo
update colaborador set nomeColaborador = 'NomeAtualizado' where idColaborador = 1;

/*deletar dados */
delete from colaborador where idColaborador = 1;



/*selecionar todos os usuários*/
SELECT * FROM Colaborador;

-- Selecionar todos os produtos com preço acima de um certo valor
select * from Produto
where precoUnico > 50;


/* VIEWS 
 uma consulta armazenada que combina dados de várias tabelas para exibir informações sobre os produtos comprados pela empresa, 
incluindo o nome do fornecedor, o valor da compra, o lote e a data da entrada dos produtos. */
/* essa view lista todos os produtos com seus fornecedores */
CREATE VIEW ProdutosComFornecedores AS
SELECT P.nomeProduto, F.nomeFornecedor
FROM Produto P
JOIN fornece F ON P.idProduto = F.Produto_idProduto
JOIN Fornecedor F2 ON F.Fornecedor_idFornecedor = F2.idFornecedor;

    
/* Procedure para Adicionar um novo Produto,diferente do insert puro*/    
/* o delimiter é um delimitador temporário,pq dentro das instruções Stored Procedures, Functions, Triggers,também a ; */
delimiter //

create procedure addproduto(
    in p_nomeproduto varchar(45),
    in p_qtdproduto int,
    in p_precouni double,
    in p_numlote int,
    in p_precocompra varchar(45),
    in p_dtvalidade date,
    in p_categoria varchar(45)
)
begin
    insert into produto (nomeproduto, qtdproduto, precouni, numlote, precocompra, dtvalidade, categoria)
    values (p_nomeproduto, p_qtdproduto, p_precouni, p_numlote, p_precocompra, p_dtvalidade, p_categoria);
end //

delimiter ;

-- função / function
-- função para calcular a quantidade total de produtos em estoque
DELIMITER //
create function TotalProdutosEstoque()
returns int
begin
   declare total int;
    select sum(qtdProduto) into total from Produto;
   return total;
end //
DELIMITER ;

/* trigger para atualizar a quantidade de produtos após inserção na tabela Entrada */
DELIMITER //
create trigger atualizaQuantidadeProdutoEntrada after insert on Entrada
for each row
begin
    update Produto
    set qtdProduto = qtdProduto + new.qtdProdutos
    WHERE idProduto = NEW.Produto_idProduto;
END //
DELIMITER ;





    
    






