-- ============================================================
-- 04 - ANÁLISES DE NEGÓCIO
-- ============================================================

-- 1) Top 10 produtos por receita
-- Insight: o produto líder gerou mais de R$ 61 mil em apenas
-- 5 vendas — item de ticket alto, não de alto volume.
SELECT 
    product_name,
    category,
    ROUND(SUM(sales)::NUMERIC, 2) AS receita_total,
    COUNT(*) AS qtd_vendas
FROM superstore_sales
GROUP BY product_name, category
ORDER BY receita_total DESC
LIMIT 10;


-- 2) Receita por região
-- Insight: West lidera em receita e volume. South, apesar do
-- menor volume, tem o maior ticket médio.
SELECT 
    region,
    ROUND(SUM(sales)::NUMERIC, 2) AS receita_total,
    COUNT(*) AS qtd_vendas,
    ROUND(AVG(sales)::NUMERIC, 2) AS ticket_medio
FROM superstore_sales
GROUP BY region
ORDER BY receita_total DESC;


-- 3) Sazonalidade mensal (receita por ano/mês)
-- Insight: janeiro/fevereiro são os meses mais fracos;
-- novembro/dezembro apresentam picos de receita.
SELECT 
    order_year,
    order_month,
    order_month_name,
    ROUND(SUM(sales)::NUMERIC, 2) AS receita_total
FROM superstore_sales
GROUP BY order_year, order_month, order_month_name
ORDER BY order_year, order_month;


-- 4) Top 10 clientes por valor total comprado
-- Insight: maior gasto total nem sempre corresponde a maior
-- frequência de compra — perfis de compra distintos.
SELECT 
    customer_name,
    segment,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_comprado,
    COUNT(DISTINCT order_id) AS qtd_pedidos
FROM superstore_sales
GROUP BY customer_name, segment
ORDER BY total_comprado DESC
LIMIT 10;
