WITH
    tb_activate as (
        SELECT DISTINCT
            seller_id,
            min(date (order_purchase_timestamp)) as dtAtivacao
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items AS t2 ON t1.order_id = t2.order_id
        WHERE
            t1.order_purchase_timestamp >= '2018-01-01'
            AND t1.order_purchase_timestamp <= DATE ('2018-01-01', '45 days')
            AND seller_id IS NOT NULL
        GROUP BY
            1
    )
SELECT
    t1.*,
    t2.*,
    t3.*,
    t4.*,
    t5.*,
    t6.*,
    t7.*,
    case
        when t7.seller_id IS NOT NULL THEN 1
        ELSE 0
    END as flChurn
FROM
    fs_vendedor_vendas as t1
    LEFT JOIN fs_vendedor_entrega as t2 ON t1.seller_id = t2.seller_id
    AND t1.dtReferencia = t2.dtReferencia
    LEFT JOIN fs_vendedor_avaliacao as t3 ON t1.seller_id = t3.seller_id
    AND t1.dtReferencia = t3.dtReferencia
    LEFT JOIN fs_vendedor_cliente as t4 ON t1.seller_id = t4.seller_id
    AND t1.dtReferencia = t4.dtReferencia
    LEFT JOIN fs_vendedor_pagamentos as t5 ON t1.seller_id = t5.seller_id
    AND t1.dtReferencia = t5.dtReferencia
    LEFT JOIN fs_vendedor_produto as t6 ON t1.seller_id = t6.seller_id
    AND t1.dtReferencia = t6.dtReferencia
    LEFT JOIN tb_activate AS t7 ON t1.seller_id = t7.seller_id
    AND (
        JULIANDAY (t7.dtAtivacao) - JULIANDAY (t1.dtReferencia)
    ) + t1.qtdRecencia <= 45
WHERE
    t1.qtdRecencia <= 45
