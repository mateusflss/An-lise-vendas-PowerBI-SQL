# 📊 Análise de Vendas Superstore — SQL + Power BI

Projeto de portfólio de análise de dados, integrando **PostgreSQL** (tratamento e análise via SQL) e **Power BI** (visualização interativa), utilizando o clássico dataset *Superstore*.

---

## 🎯 Objetivo

Simular um pipeline real de análise de dados: desde a ingestão de um arquivo bruto (CSV) até um dashboard interativo, respondendo perguntas de negócio sobre vendas, produtos, regiões e clientes.

---

## 🛠️ Tecnologias utilizadas

- **PostgreSQL** (via pgAdmin) — armazenamento, tratamento e análise dos dados
- **Power BI Desktop** — construção do dashboard interativo
- **SQL** — queries de limpeza, transformação e análise de negócio

---

## 📁 Sobre o dataset

O dataset **Superstore** contém **9.800 registros** de pedidos de uma loja de varejo fictícia, com informações de:

- Pedidos (ID, datas de compra e envio)
- Clientes (ID, nome, segmento)
- Produtos (categoria, subcategoria, nome)
- Localização (cidade, estado, região)
- Vendas (valor de cada item vendido)

> **Observação:** esta versão do dataset não possui coluna de lucro (*profit*) — as análises foram construídas com foco em **receita e volume de vendas**.

---

## 🗄️ Etapa 1 — Banco de dados (PostgreSQL)

### Criação da tabela

```sql
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
```

### Importação do CSV

Os dados foram importados via interface do pgAdmin (*Import/Export Data*), com atenção especial à codificação do arquivo (**UTF-8**) — necessária por causa de caracteres especiais presentes em alguns nomes de produtos.

### Validação de qualidade dos dados

```sql
-- Checagem de valores nulos em colunas-chave
SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulos,
    COUNT(*) FILTER (WHERE sales IS NULL) AS sales_nulos,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulos
FROM superstore_sales;
-- Resultado: 0 nulos em todas as colunas
```

```sql
-- Checagem de possíveis duplicatas (mesmo pedido + mesmo produto)
SELECT order_id, product_id, COUNT(*)
FROM superstore_sales
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
-- Resultado: 8 casos encontrados
```

**Investigação:** ao analisar um dos casos, constatou-se que os valores de venda (`sales`) eram diferentes entre as linhas "duplicadas" — ou seja, não eram duplicatas de fato, e sim itens de pedido distintos para o mesmo produto dentro do mesmo pedido. Nenhuma linha foi removida.

### Criação de colunas derivadas

```sql
ALTER TABLE superstore_sales 
    ADD COLUMN order_year INTEGER,
    ADD COLUMN order_month INTEGER,
    ADD COLUMN order_month_name VARCHAR(20),
    ADD COLUMN order_weekday VARCHAR(20);

UPDATE superstore_sales
SET 
    order_year = EXTRACT(YEAR FROM order_date),
    order_month = EXTRACT(MONTH FROM order_date),
    order_month_name = TO_CHAR(order_date, 'Month'),
    order_weekday = TO_CHAR(order_date, 'Day');
```

---

## 📈 Etapa 2 — Análises de negócio (SQL)

### 1. Top 10 produtos por receita

```sql
SELECT 
    product_name,
    category,
    ROUND(SUM(sales)::NUMERIC, 2) AS receita_total,
    COUNT(*) AS qtd_vendas
FROM superstore_sales
GROUP BY product_name, category
ORDER BY receita_total DESC
LIMIT 10;
```

**Insight:** o produto líder (Canon imageCLASS 2200 Advanced Copier) gerou mais de R$ 61 mil em apenas 5 vendas — um item de ticket alto, não de alto volume.

### 2. Receita por região

```sql
SELECT 
    region,
    ROUND(SUM(sales)::NUMERIC, 2) AS receita_total,
    COUNT(*) AS qtd_vendas,
    ROUND(AVG(sales)::NUMERIC, 2) AS ticket_medio
FROM superstore_sales
GROUP BY region
ORDER BY receita_total DESC;
```

**Insight:** a região **West** lidera em receita e volume. Já a região **South**, apesar do menor volume de vendas, apresenta o maior ticket médio — perfil de vendas de menor frequência e maior valor por transação.

### 3. Sazonalidade mensal

```sql
SELECT 
    order_year,
    order_month,
    order_month_name,
    ROUND(SUM(sales)::NUMERIC, 2) AS receita_total
FROM superstore_sales
GROUP BY order_year, order_month, order_month_name
ORDER BY order_year, order_month;
```

**Insight:** janeiro e fevereiro são consistentemente os meses mais fracos em vendas, enquanto novembro/dezembro (temporada de fim de ano) apresentam picos de receita.

### 4. Top 10 clientes

```sql
SELECT 
    customer_name,
    segment,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_comprado,
    COUNT(DISTINCT order_id) AS qtd_pedidos
FROM superstore_sales
GROUP BY customer_name, segment
ORDER BY total_comprado DESC
LIMIT 10;
```

**Insight:** clientes com maior gasto total nem sempre são os que mais compram com frequência — alguns concentram alto valor em poucos pedidos, outros pulverizam o gasto em muitas compras menores.

### VIEW consolidada (fonte para o Power BI)

```sql
CREATE VIEW vw_vendas_resumo AS
SELECT 
    order_id, order_date, order_year, order_month, order_month_name, order_weekday,
    customer_id, customer_name, segment,
    region, state, city,
    category, sub_category, product_name,
    sales
FROM superstore_sales;
```

---

## 📊 Etapa 3 — Dashboard (Power BI)

O Power BI foi conectado diretamente ao PostgreSQL (conexão ao vivo), utilizando a view `vw_vendas_resumo` como única fonte de dados.

**Composição do dashboard:**

- **3 cartões de KPI:** Receita Total, Total de Clientes, Total de Pedidos
- **Top 10 Produtos por Receita** (gráfico de barras horizontais)
- **Receita por Região** (gráfico de colunas)
- **Evolução Mensal de Vendas** (gráfico de linha, ordenado cronologicamente por ano/mês)
- **Vendas por Categoria** (gráfico de pizza)
- **3 filtros interativos (slicers):** Região, Categoria e Ano

> 📌 *Adicione aqui um print do dashboard final (`dashboard.png`) para ilustrar o resultado visual.*

---

## 🧠 Principais desafios técnicos (e como foram resolvidos)

Durante o desenvolvimento, alguns problemas reais de engenharia de dados surgiram — documentados aqui porque fazem parte do aprendizado prático:

- **Erro de importação CSV (encoding):** a importação falhava por causa de caracteres especiais (ex: espaço não separável) em nomes de produtos. Resolvido definindo explicitamente o `Encoding = UTF8` na importação.
- **Nome de banco com caracteres inválidos:** o banco foi criado acidentalmente com um espaço e aspas simples no nome (`'portfolio_sql e power bi'`), o que impedia a conexão do Power BI. Resolvido identificando o nome exato via `pg_database`, encerrando conexões ativas com `pg_terminate_backend`, e renomeando com `ALTER DATABASE`.
- **Ordenação cronológica incorreta no Power BI:** o campo de nome do mês (texto) era ordenado alfabeticamente, distorcendo o gráfico de sazonalidade. Resolvido utilizando a coluna numérica `order_month` como critério de ordenação do eixo.

---

## 🚀 Como reproduzir este projeto

1. Restaure o dataset `superstore_sales.csv` em um banco PostgreSQL, usando o script de criação de tabela acima
2. Execute os scripts de tratamento e as queries de análise (pasta `/sql`)
3. Crie a view `vw_vendas_resumo`
4. Conecte o Power BI Desktop ao banco PostgreSQL e carregue a view
5. Recrie os visuais conforme a seção "Dashboard" acima

---

## 👤 Autor

**Mateus** — projeto desenvolvido como parte de um portfólio de análise de dados, aplicando conhecimentos de SQL e Power BI.
