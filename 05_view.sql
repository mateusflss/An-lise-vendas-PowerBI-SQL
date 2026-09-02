-- ============================================================
-- 05 - VIEW CONSOLIDADA
-- Fonte de dados única utilizada pelo Power BI (conexão ao vivo)
-- ============================================================

CREATE VIEW vw_vendas_resumo AS
SELECT 
    order_id,
    order_date,
    order_year,
    order_month,
    order_month_name,
    order_weekday,
    customer_id,
    customer_name,
    segment,
    region,
    state,
    city,
    category,
    sub_category,
    product_name,
    sales
FROM superstore_sales;

-- Conferência
SELECT * FROM vw_vendas_resumo LIMIT 5;
