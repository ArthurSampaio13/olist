CREATE TABLE fs_vendedor_cliente as
WITH
    tb_join AS (
        SELECT DISTINCT
            t1.order_id,
            t1.customer_id,
            t2.seller_id,
            t3.customer_state
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items as t2 on t1.order_id = t2.order_id
            LEFT JOIN tb_customers as t3 on t1.customer_id = t3.customer_id
        WHERE
            t1.order_purchase_timestamp < '2018-01-01'
            AND t1.order_purchase_timestamp >= date ('2018-01-01', '-6 months')
            AND seller_id IS NOT NULL
    ),
    tb_group AS (
        SELECT DISTINCT
            seller_id,

            1.0 * count(DISTINCT customer_state) as qtdEstadosPedidos,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'AC' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoAC,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'AL' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoAL,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'AM' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoAM,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'AP' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoAP,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'BA' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoBA,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'CE' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoCE,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'DF' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoDF,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'ES' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoES,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'GO' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoGO,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'MA' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoMA,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'MG' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoMG,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'MS' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoMS,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'MT' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoMT,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'PA' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoPA,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'PB' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoPB,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'PE' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoPE,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'PI' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoPI,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'PR' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoPR,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'RJ' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoRJ,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'RN' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoRN,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'RO' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoRO,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'RR' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoRR,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'RS' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoRS,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'SC' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoSC,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'SE' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoSE,
            1.0 * count(
                DISTINCT case
                    when customer_state = 'SP' then order_id
                end
            ) / count(DISTINCT order_id) as pctPedidoSP
        FROM
            tb_join
        GROUP BY
            seller_id
    )
SELECT
    '2018-01-01' as dtReferencia,
    *
from
    tb_group

