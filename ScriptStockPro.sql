/* Criando o banco de dados, nomeando de STOCK_PROdb */
CREATE DATABASE STOCK_PROdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

/* Ativando o Banco de Dados */
USE STOCK_PROdb;

/* Criando a tabela Colaborador (Corresponde aos Funcionários da Empresa que têm acesso ao Software Stock Pro) */
CREATE TABLE Colaborador (
    idColaborador INT AUTO_INCREMENT PRIMARY KEY,
    matricula INT(8) UNIQUE NOT NULL,
    senha VARCHAR(12) NOT NULL,
    email VARCHAR(30),
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nomeColaborador VARCHAR(16) NOT NULL,
    sobrenomeColaborador VARCHAR(35),
    ddd INT,
    telefone VARCHAR(15),
    logradouro VARCHAR(45),
    bairro VARCHAR(15),
    cidade VARCHAR(15),
    numero VARCHAR(10),
    cep VARCHAR(9),
    estado VARCHAR(18),
    tipo VARCHAR(20)
);

/* Criando a tabela Produto (Corresponde aos Produtos Comprados pela Empresa) */
CREATE TABLE Produto (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    nomeProduto VARCHAR(45),
    quantidadeProduto INT,
    precoUnico DOUBLE,
    numeroLote INT,
    precoCompra VARCHAR(45),
    dataValidade DATE,
    categoria VARCHAR(45)
);

/* Tabela onde registra as transações de entrada dos Produtos entregues pelo Fornecedor */
CREATE TABLE entrada (
    idEntrada INT AUTO_INCREMENT PRIMARY KEY,
    dataEntrada DATE,
    horaEntrada TIME,
    qtdProdutos INT
);

/* Tabela onde registra as transações de Saída dos Produtos */
CREATE TABLE saida (
    idSaida INT AUTO_INCREMENT PRIMARY KEY,
    dataSaida DATE,
    horaSaida TIME,
    tipo VARCHAR(50) NOT NULL,
    qtdProdutos INT
);

/* Tabela onde registra a ação realizada (saída/entrada do produto) */
CREATE TABLE afeta_produto (
    saida_idSaida INT,
    entrada_idEntrada INT,
    produto_idProduto INT,
    FOREIGN KEY (saida_idSaida) REFERENCES saida(idSaida),
    FOREIGN KEY (entrada_idEntrada) REFERENCES entrada(idEntrada),
    FOREIGN KEY (produto_idProduto) REFERENCES Produto(idProduto)
);

/* Tabela onde registra a atualização da ação do produto */
CREATE TABLE realiza_atualizacao (
    Usuario_idUsuario INT,
    Saida_idSaida INT,
    Entrada_idEntrada INT,
    FOREIGN KEY (Usuario_idUsuario) REFERENCES Colaborador(idColaborador),
    FOREIGN KEY (Saida_idSaida) REFERENCES saida(idSaida),
    FOREIGN KEY (Entrada_idEntrada) REFERENCES entrada(idEntrada)
);

/* Tabela de cadastro de produtos por colaboradores */
CREATE TABLE cadastra (
    Colaborador_idColaborador INT,
    Produto_idProduto INT,
    FOREIGN KEY (Colaborador_idColaborador) REFERENCES Colaborador(idColaborador),
    FOREIGN KEY (Produto_idProduto) REFERENCES Produto(idProduto)
);

/* Tabela de cadastro de Fornecedores */
CREATE TABLE cadastroFornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nomeFornecedor VARCHAR(16),
    sobrenomeFornecedor VARCHAR(45),
    empresa VARCHAR(45),
    ddd INT,
    telefone VARCHAR(15),
    email VARCHAR(30),
    cnpj VARCHAR(14),
    cep VARCHAR(9),
    cidade VARCHAR(15),
    numero VARCHAR(10),
    estado VARCHAR(18),
    bairro VARCHAR(15),
    logradouro VARCHAR(45)
);

/* Tabela para registrar quais produtos são fornecidos por quais fornecedores */
CREATE TABLE fornece (
    Produto_idProduto INT,
    Fornecedor_idFornecedor INT,
    FOREIGN KEY (Produto_idProduto) REFERENCES Produto(idProduto),
    FOREIGN KEY (Fornecedor_idFornecedor) REFERENCES cadastroFornecedor(idFornecedor)
);

/* Comandos para manipular dados */

/* Inserir dados */
/* Este Insert é para quando for trabalhar com dados mais simples, menos complexos. Caso contrário, usar o Stored Procedure */
INSERT INTO Colaborador (matricula, senha, email, cpf, nomeColaborador, sobrenomeColaborador, ddd, telefone, logradouro, bairro, cidade, numero, cep, estado, tipo)
VALUES (123456, 'password1', 'user1@example.com', '12345678901', 'Nome1', 'Sobrenome1', 11, '123456789', 'Rua A', 'Bairro A', 'Cidade A', '123', '12345678', 'Estado A', 'Tipo A');


/* Atualizar dados */
UPDATE Colaborador SET nomeColaborador = 'NomeAtualizado' WHERE idColaborador = 1;

/* Deletar dados */
DELETE FROM Colaborador WHERE idColaborador = 1;

/* Selecionar todos os usuários */
SELECT * FROM Colaborador;

/* Selecionar todos os produtos com preço acima de um certo valor */
SELECT * FROM Produto WHERE precoUnico > 50;

/* VIEWS */
/* Uma consulta armazenada que combina dados de várias tabelas para exibir informações sobre os produtos comprados pela empresa, 
incluindo o nome do fornecedor, o valor da compra, o lote e a data da entrada dos produtos. */
/* Esta view lista todos os produtos com seus fornecedores */
CREATE VIEW ProdutosComFornecedores AS
SELECT P.nomeProduto, F2.nomeFornecedor
FROM Produto P
JOIN fornece F ON P.idProduto = F.Produto_idProduto
JOIN cadastroFornecedor F2 ON F.Fornecedor_idFornecedor = F2.idFornecedor;

/* Procedure para adicionar um novo Produto, diferente do insert puro */
/* O delimiter é um delimitador temporário, porque dentro das instruções Stored Procedures, Functions, Triggers, também usam ; */
DELIMITER //

CREATE PROCEDURE addproduto(
    IN p_nomeProduto VARCHAR(45),
    IN p_quantidadeProduto INT,
    IN p_precoUnico DOUBLE,
    IN p_numeroLote INT,
    IN p_precoCompra VARCHAR(45),
    IN p_dataValidade DATE,
    IN p_categoria VARCHAR(45)
)
BEGIN
    INSERT INTO Produto (nomeProduto, quantidadeProduto, precoUnico, numeroLote, precoCompra, dataValidade, categoria)
    VALUES (p_nomeProduto, p_quantidadeProduto, p_precoUnico, p_numeroLote, p_precoCompra, p_dataValidade, p_categoria);
END //

DELIMITER ;

/* Função para calcular a quantidade total de produtos em estoque */
DELIMITER //

CREATE FUNCTION TotalProdutosEstoque()
RETURNS INT
 READS SQL DATA
BEGIN
   DECLARE total INT;
   SELECT SUM(quantidadeProduto) INTO total FROM Produto;
   RETURN total;
END //

DELIMITER ;

/* Trigger para atualizar a quantidade de produtos após inserção na tabela Entrada */
DELIMITER //

CREATE TRIGGER atualizaQuantidadeProdutoEntrada AFTER INSERT ON entrada
FOR EACH ROW
BEGIN
    UPDATE Produto
    SET quantidadeProduto = quantidadeProduto + NEW.qtdProdutos
    WHERE idProduto = NEW.idEntrada;
END //

DELIMITER ;

-- pegar hora e data atual do sistema 
-- DEFAULT NOW()
-- TIME GENERATED ALWAYS AS (TIME(dataEntrada)) VIRTUAL
