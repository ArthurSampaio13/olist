--1:36:08
WITH
    tb_pedido_item as (
        SELECT
            t1.order_purchase_timestamp,
            t2.*
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items as t2 ON t1.order_id = t2.order_id
        WHERE
            t1.order_purchase_timestamp < '2018-01-01'
            AND t1.order_purchase_timestamp >= date ('2018-01-01', '-6 months')
            AND seller_id IS NOT NULL
    ),
    tb_summary as (
        SELECT
            seller_id,
            count(DISTINCT order_id) as qtdPedidos,
            count(DISTINCT DATE (order_purchase_timestamp)) as qtdDias,
            count(DISTINCT product_id) as qtdItens,
            (
                JULIANDAY ('2018-01-01') - JULIANDAY (order_purchase_timestamp)
            ) as qtdRecencia,
            sum(price) / count(DISTINCT order_id) as avgTicket,
            avg(price) as avgValorProduto,
            min(price) as minValorProduto,
            max(price) as maxValorProduto,
            count(product_id) / count(DISTINCT order_id) as avgProdutoPedido
        from
            tb_pedido_item
        GROUP BY
            seller_id
    ),
    tb_pedido_summary as (
        select
            seller_id,
            order_id,
            sum(price) as vlPreco
        from
            tb_pedido_item
        GROUP BY
            seller_id,
            order_id
    ),
    tb_min_max as (
        SELECT
            seller_id,
            min(vlPreco) as minVlPedido,
            max(vlPreco) as maxVlPedido
        from
            tb_pedido_summary
        GROUP BY
            seller_id
    ),
    tb_life AS (
        SELECT
            t1.order_purchase_timestamp,
            t2.seller_id,
            sum(price) as LTV,
            max(
                (
                    JULIANDAY ('2018-01-01') - JULIANDAY (order_purchase_timestamp)
                )
            ) as qtdDiasBase
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items as t2 ON t1.order_id = t2.order_id
        WHERE
            t1.order_purchase_timestamp < '2018-01-01'
            AND seller_id IS NOT NULL
        GROUP BY
            t2.seller_id
    ),
    tb_dtpedido as (
        SELECT DISTINCT
            seller_id,
            date (order_purchase_timestamp) as dtPedido
        FROM
            tb_pedido_item
        ORDER BY
            1,
            2
    ),
    tb_lag AS (
        select
            *,
            LAG (dtPedido) OVER (
                PARTITION BY
                    seller_id
                ORDER BY
                    dtPedido
            ) as lag1
        from
            tb_dtpedido
    ),
    tb_invervalo as (
        SELECT
            seller_id,
            avg(JULIANDAY (dtPedido) - JULIANDAY (lag1)) as avgIntervaloVendas
        FROM
            tb_lag
        GROUP BY
            seller_id
    )
SELECT
    '2018-01-01' as dtReferencia,
    t1.*,
    t2.minVlPedido,
    t2.maxVlPedido,
    t3.LTV,
    t3.qtdDiasBase,
    t4.avgIntervaloVendas


FROM
    tb_summary AS t1
    LEFT JOIN tb_min_max AS t2 ON t1.seller_id = t2.seller_id

    LEFT JOIN tb_life as t3 ON t1.seller_id = t3.seller_id

    LEFT JOIN tb_invervalo as t4 ON t1.seller_id = t4.seller_id