-- ============================================================
-- 01 - CRIAÇÃO DA TABELA PRINCIPAL
-- Dataset: Superstore Sales (9.800 registros)
-- ============================================================

CREATE TABLE superstore_sales (
    row_id          INTEGER PRIMARY KEY,
    order_id        VARCHAR(20),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    country         VARCHAR(50),
    city            VARCHAR(100),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(20),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(255),
    sales           NUMERIC(10, 4)
);

-- Após criar a tabela, os dados foram importados via pgAdmin
-- (Import/Export Data), utilizando o arquivo superstore_sales.csv
-- com Encoding = UTF8, Header = true, Delimiter = ',', Quote = '"'
