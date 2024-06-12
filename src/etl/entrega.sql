WITH
    tb_pedido as (
        SELECT
            t1.order_id,
            t2.seller_id,
            t1.order_status,
            t1.order_approved_at,
            t1.order_delivered_carrier_date,
            t1.order_purchase_timestamp,
            t1.order_estimated_delivery_date,
            sum(freight_value) as totalFrete
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items as t2 ON t1.order_id = t2.order_id
        WHERE
            t1.order_purchase_timestamp < '{date}'
            AND t1.order_purchase_timestamp >= date ('{date}', '-6 months')
            AND seller_id IS NOT NULL
        GROUP BY
            t1.order_id,
            t2.seller_id,
            t1.order_status,
            t1.order_approved_at,
            t1.order_delivered_carrier_date,
            t1.order_purchase_timestamp,
            t1.order_estimated_delivery_date
    )
INSERT INTO fs_vendedor_entrega
SELECT
    '{date}' as dtReferencia,
    date('now') as dtIngestao,
    seller_id,
    (
        COUNT(
            DISTINCT CASE
                WHEN DATE (
                    coalesce(order_purchase_timestamp, '{date}')
                ) < DATE (order_estimated_delivery_date) THEN order_id
            END
        ) * 1.0 / COUNT(
            DISTINCT CASE
                WHEN order_status = 'delivered' THEN order_id
            END
        )
    ) AS pctPedidoAtraso,
    COUNT(
        CASE
            WHEN order_status = 'canceled' THEN order_id
        END
    ) * 1.0 / COUNT(DISTINCT order_id) AS pctPedidoCancelado,
    avg(totalFrete) as avgFrete,
    max(totalFrete) maxFrete,
    min(totalFrete) as minFrete,
    avg(
        JULIANDAY (
            coalesce(order_purchase_timestamp, '{date}')
        ) - JULIANDAY (order_approved_at)
    ) as qtdDiasAprovadoEngtrega,
    avg(
        JULIANDAY (
            coalesce(order_purchase_timestamp, '{date}')
        ) - JULIANDAY (order_delivered_carrier_date)
    ) as qtdDiasPedidoEngtrega,
    avg(
        JULIANDAY (order_estimated_delivery_date) - JULIANDAY (
            coalesce(order_purchase_timestamp, '{date}')
        )
    ) as qtdDiasPromessaEngtrega
FROM
    tb_pedido
GROUP BY
    seller_id