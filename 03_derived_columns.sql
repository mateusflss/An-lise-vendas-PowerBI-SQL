-- ============================================================
-- 03 - CRIAÇÃO DE COLUNAS DERIVADAS
-- Colunas de data desmembradas para facilitar análises
-- de sazonalidade e ordenação cronológica no Power BI
-- ============================================================

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

-- Conferência
SELECT order_date, order_year, order_month, order_month_name, order_weekday
FROM superstore_sales
LIMIT 5;
