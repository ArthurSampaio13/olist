WITH
    tb_pedido AS (
        SELECT DISTINCT
            t1.order_id,
            t2.seller_id
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items AS t2 ON t1.order_id = t2.order_id
        WHERE
            t1.order_purchase_timestamp < '2018-01-01'
            AND t1.order_purchase_timestamp >= DATE ('2018-01-01', '-6 months')
            AND seller_id IS NOT NULL
    ),
    tb_join AS (
        SELECT
            t1.*,
            t2.review_score
        FROM
            tb_pedido AS t1
            LEFT JOIN tb_order_reviews AS t2 ON t1.order_id = t2.order_id
    ),
    tb_summary as (
        SELECT
            seller_id,
            avg(review_score) as avgNota,
            1.0 * min(review_score) as minNota,
            1.0 * max(review_score) as maxNota,
            count(review_score) / count(order_id) as pctAvaliacao
        FROM
            tb_join
        GROUP BY
            seller_id
    )
SELECT
    '2018-01-01' AS dtReferencia,
    *
FROM
    tb_summary;