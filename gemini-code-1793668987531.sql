-- Criar Banco de Dados
CREATE DATABASE IF NOT EXISTS mercadinho_fabio_db
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE mercadinho_fabio_db;

-- 1. TABELA DE USUÁRIOS / VENDEDORES
CREATE TABLE usuarios (
    id VARCHAR(36) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    cargo ENUM('Caixa', 'Gerente') NOT NULL DEFAULT 'Caixa',
    status ENUM('Ativo', 'Inativo') NOT NULL DEFAULT 'Ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. TABELA DE CLIENTES / COMANDAS
CREATE TABLE clientes (
    id VARCHAR(36) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) DEFAULT NULL,
    limite_credito DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    debito_atual DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status ENUM('Ativo', 'Bloqueado') NOT NULL DEFAULT 'Ativo',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. TABELA DE PRODUTOS
CREATE TABLE produtos (
    id VARCHAR(36) PRIMARY KEY,
    codigo_barras VARCHAR(50) NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,
    preco_custo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    preco_venda DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    estoque_atual INT NOT NULL DEFAULT 0,
    estoque_minimo INT NOT NULL DEFAULT 5,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 4. TABELA DE VENDAS
CREATE TABLE vendas (
    id VARCHAR(36) PRIMARY KEY,
    vendedor_id VARCHAR(36) NOT NULL,
    cliente_id VARCHAR(36) DEFAULT NULL,
    forma_pagamento ENUM('Dinheiro', 'PIX', 'Cartão de Débito', 'Cartão de Crédito', 'Comanda / Fiado') NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    lucro DECIMAL(10, 2) NOT NULL,
    valor_recebido DECIMAL(10, 2) DEFAULT 0.00,
    troco DECIMAL(10, 2) DEFAULT 0.00,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vendas_vendedor FOREIGN KEY (vendedor_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    CONSTRAINT fk_vendas_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
);

-- 5. TABELA DE ITENS DA VENDA
CREATE TABLE itens_venda (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venda_id VARCHAR(36) NOT NULL,
    produto_id VARCHAR(36) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    custo_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_itens_venda_venda FOREIGN KEY (venda_id) REFERENCES vendas(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_venda_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT
);

-- 6. TABELA DE ABATES DE COMANDA (PAGAMENTOS DE DÍVIDAS)
CREATE TABLE abates_comanda (
    id VARCHAR(36) PRIMARY KEY,
    cliente_id VARCHAR(36) NOT NULL,
    vendedor_id VARCHAR(36) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    forma_pagamento ENUM('Dinheiro', 'PIX', 'Cartão de Débito', 'Cartão de Crédito') NOT NULL,
    data_abate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_abates_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    CONSTRAINT fk_abates_vendedor FOREIGN KEY (vendedor_id) REFERENCES usuarios(id) ON DELETE RESTRICT
);