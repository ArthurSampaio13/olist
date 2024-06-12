with
    tb_pedidos as (
        SELECT DISTINCT
            t1.order_id,
            t2.seller_id
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items AS t2 ON t1.order_id = t2.order_id
        WHERE
            t1.order_purchase_timestamp < '{date}'
            AND t1.order_purchase_timestamp >= date ('{date}', '-6 months')
            AND seller_id is not null
    ),
    tb_join as (
        SELECT
            t1.seller_id,
            t2.*
        FROM
            tb_pedidos as t1
            left join tb_order_payments as t2 on t1.order_id = t2.order_id
    ),
    tb_group as (
        select
            seller_id,
            payment_type,
            payment_value,
            count(DISTINCT order_id) as qtdPedidoMeioPagamento,
            sum(payment_value) as vlPedidoMeioPagamento
        from
            tb_join
        GROUP BY
            seller_id,
            payment_type
        ORDER BY
            seller_id,
            payment_type
    ),
    tb_summary as (
        select
            seller_id,
            1.0 * sum(
                case
                    when payment_type = 'credit_card' then qtdPedidoMeioPagamento
                    else 0
                end
            ) as qt_credit_card,
            1.0 * sum(
                case
                    when payment_type = 'boleto' then qtdPedidoMeioPagamento
                    else 0
                end
            ) as qt_boleto,
            1.0 * sum(
                case
                    when payment_type = 'debit_card' then qtdPedidoMeioPagamento
                    else 0
                end
            ) as qt_debit_card,
            1.0 * sum(
                case
                    when payment_type = 'voucher' then qtdPedidoMeioPagamento
                    else 0
                end
            ) as qt_voucher,
            1.0 * sum(
                case
                    when payment_type = 'credit_card' then payment_value
                    else 0
                end
            ) as vl_credit_card,
            1.0 * sum(
                case
                    when payment_type = 'boleto' then payment_value
                    else 0
                end
            ) as vl_boleto,
            1.0 * sum(
                case
                    when payment_type = 'debit_card' then payment_value
                    else 0
                end
            ) as vl_debit_card,
            1.0 * sum(
                case
                    when payment_type = 'voucher' then payment_value
                    else 0
                end
            ) as vl_voucher,
            1.0 * sum(
                case
                    when payment_type = 'credit_card' then qtdPedidoMeioPagamento
                    else 0
                end
            ) / sum(qtdPedidoMeioPagamento) as pct_qtd_credit_card,
            1.0 * sum(
                case
                    when payment_type = 'boleto' then qtdPedidoMeioPagamento
                    else 0
                end
            ) / sum(qtdPedidoMeioPagamento) as pct_qtd_boleto,
            1.0 * sum(
                case
                    when payment_type = 'debit_card' then qtdPedidoMeioPagamento
                    else 0
                end
            ) / sum(qtdPedidoMeioPagamento) as pct_qtd_debit_card,
            1.0 * sum(
                case
                    when payment_type = 'voucher' then qtdPedidoMeioPagamento
                    else 0
                end
            ) / sum(qtdPedidoMeioPagamento) as pct_qtd_voucher,
            1.0 * sum(
                case
                    when payment_type = 'credit_card' then payment_value
                    else 0
                end
            ) / sum(payment_value) as pct_vl_credit_card,
            1.0 * sum(
                case
                    when payment_type = 'boleto' then payment_value
                    else 0
                end
            ) / sum(payment_value) as pct_vl_boleto,
            1.0 * sum(
                case
                    when payment_type = 'debit_card' then payment_value
                    else 0
                end
            ) / sum(payment_value) as pct_vl_debit_card,
            1.0 * sum(
                case
                    when payment_type = 'voucher' then payment_value
                    else 0
                end
            ) / sum(payment_value) as pct_vl_voucher
        from
            tb_group
        GROUP BY
            seller_id
    ),
    OrderedPayments AS (
        SELECT
            seller_id,
            payment_installments,
            ROW_NUMBER() OVER (
                PARTITION BY
                    seller_id
                ORDER BY
                    payment_installments
            ) AS row_num,
            COUNT(*) OVER (
                PARTITION BY
                    seller_id
            ) AS total_count
        FROM
            tb_join
        WHERE
            payment_type = 'credit_card'
    ),
    MedianCalc AS (
        SELECT
            seller_id,
            payment_installments,
            row_num,
            total_count,
            (total_count + 1) / 2 AS mid_point1,
            (total_count + 2) / 2 AS mid_point2
        FROM
            OrderedPayments
    ),
    tb_cartao as (
        SELECT
            seller_id,
            AVG(payment_installments) AS avgQtdParcelas,
            AVG(
                CASE
                    WHEN row_num IN (mid_point1, mid_point2) THEN payment_installments
                END
            ) AS medianaQtdParcelas,
            max(payment_installments) as maxQtdParcelas,
            min(payment_installments) as minQtdParcelas
        FROM
            MedianCalc
        GROUP BY
            seller_id
    )
INSERT INTO fs_vendedor_pagamentos
select
    '{date}' as dtReferencia,
    date('now') as dtIngestao,
    t1.*,
    t2.avgQtdParcelas,
    t2.medianaQtdParcelas,
    t2.maxQtdParcelas,
    t2.minQtdParcelas
from
    tb_summary as t1
left join tb_cartao as t2
on t1.seller_id = t2.seller_id
