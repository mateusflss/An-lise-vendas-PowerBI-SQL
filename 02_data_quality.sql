-- ============================================================
-- 02 - VALIDAÇÃO DE QUALIDADE DOS DADOS
-- ============================================================

-- Checagem de valores nulos em colunas-chave
-- Resultado obtido: 0 nulos em todas as colunas verificadas
SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulos,
    COUNT(*) FILTER (WHERE sales IS NULL) AS sales_nulos,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulos
FROM superstore_sales;


-- Checagem de possíveis duplicatas (mesmo pedido + mesmo produto)
-- Resultado obtido: 8 casos encontrados
SELECT order_id, product_id, COUNT(*)
FROM superstore_sales
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;


-- Investigação de um dos casos de "duplicata"
-- Conclusão: os valores de venda (sales) eram diferentes entre as
-- linhas, indicando que são itens de pedido distintos para o
-- mesmo produto dentro do mesmo pedido — não duplicatas reais.
-- Nenhuma linha foi removida da base.
SELECT row_id, order_id, product_id, sales
FROM superstore_sales
WHERE order_id = 'CA-2017-137043' AND product_id = 'FUR-FU-10003664';
