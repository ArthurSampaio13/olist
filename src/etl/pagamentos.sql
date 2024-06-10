with
    tb_join as (
        SELECT
            t2.*,
            t3.seller_id
        FROM
            tb_orders as t1
            left join tb_order_payments as t2 on t1.order_id = t2.order_id
            left join tb_order_items as t3 on t1.order_id = t3.order_id
        WHERE
            t1.order_purchase_timestamp <= '2018-01-01'
            AND t1.order_purchase_timestamp >= date ('2018-01-01', '-6 months')
            AND seller_id is not null
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
    )
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
    ) / sum (qtdPedidoMeioPagamento) as pct_qtd_credit_card,
    1.0 * sum(
        case
            when payment_type = 'boleto' then qtdPedidoMeioPagamento
            else 0
        end
    ) / sum (qtdPedidoMeioPagamento) as pct_qtd_boleto,
    1.0 * sum(
        case
            when payment_type = 'debit_card' then qtdPedidoMeioPagamento
            else 0
        end
    ) / sum (qtdPedidoMeioPagamento) as pct_qtd_debit_card,
    1.0 * sum(
        case
            when payment_type = 'voucher' then qtdPedidoMeioPagamento
            else 0
        end
    ) / sum (qtdPedidoMeioPagamento) as pct_qtd_voucher,

    1.0 * sum(
        case
            when payment_type = 'credit_card' then payment_value
            else 0
        end
    ) / sum (payment_value) as pct_vl_credit_card,

    1.0 * sum(
        case
            when payment_type = 'boleto' then payment_value
            else 0
        end
    ) / sum (payment_value) as pct_vl_boleto,
    1.0 * sum(
        case
            when payment_type = 'debit_card' then payment_value
            else 0
        end
    ) / sum (payment_value) as pct_vl_debit_card,
    1.0 * sum(
        case
            when payment_type = 'voucher' then payment_value
            else 0
        end
    ) / sum (payment_value) as pct_vl_voucher
from
    tb_group
GROUP BY
    1