WITH
    tb_features as (
        SELECT
            t1.dtReferencia,
            t1.seller_id,
            t1.qtdPedidos,
            t1.qtdDias,
            t1.qtdItens,
            t1.qtdRecencia,
            t1.avgTicket,
            t1.avgValorProduto,
            t1.minValorProduto,
            t1.maxValorProduto,
            t1.avgProdutoPedido,
            t1.minVlPedido,
            t1.maxVlPedido,
            t1.LTV,
            t1.qtdDiasBase,
            t1.avgIntervaloVendas,
            t2.pctPedidoAtraso,
            t2.pctPedidoCancelado,
            t2.avgFrete,
            t2.maxFrete,
            t2.minFrete,
            t2.qtdDiasAprovadoEngtrega,
            t2.qtdDiasPedidoEngtrega,
            t2.qtdDiasPromessaEngtrega,
            t3.avgNota,
            t3.minNota,
            t3.maxNota,
            t3.pctAvaliacao,
            t4.qtdEstadosPedidos,
            t4.pctPedidoAC,
            t4.pctPedidoAL,
            t4.pctPedidoAM,
            t4.pctPedidoAP,
            t4.pctPedidoBA,
            t4.pctPedidoCE,
            t4.pctPedidoDF,
            t4.pctPedidoES,
            t4.pctPedidoGO,
            t4.pctPedidoMA,
            t4.pctPedidoMG,
            t4.pctPedidoMS,
            t4.pctPedidoMT,
            t4.pctPedidoPA,
            t4.pctPedidoPB,
            t4.pctPedidoPE,
            t4.pctPedidoPI,
            t4.pctPedidoPR,
            t4.pctPedidoRJ,
            t4.pctPedidoRN,
            t4.pctPedidoRO,
            t4.pctPedidoRR,
            t4.pctPedidoRS,
            t4.pctPedidoSC,
            t4.pctPedidoSE,
            t4.pctPedidoSP,
            t5.qt_credit_card,
            t5.qt_boleto,
            t5.qt_debit_card,
            t5.qt_voucher,
            t5.vl_credit_card,
            t5.vl_boleto,
            t5.vl_debit_card,
            t5.vl_voucher,
            t5.pct_qtd_credit_card,
            t5.pct_qtd_boleto,
            t5.pct_qtd_debit_card,
            t5.pct_qtd_voucher,
            t5.pct_vl_credit_card,
            t5.pct_vl_boleto,
            t5.pct_vl_debit_card,
            t5.pct_vl_voucher,
            t5.avgQtdParcelas,
            t5.medianaQtdParcelas,
            t5.maxQtdParcelas,
            t5.minQtdParcelas,
            t6.avgFotos,
            t6.avgQtdFotos,
            t6.avgVolume,
            t6.minVolume,
            t6.maxVolume,
            t6.pctCategoriacama_mesa_banho,
            t6.pctCategoriabeleza_saude,
            t6.pctCategoriaesporte_lazer,
            t6.pctCategoriainformatica_acessorios,
            t6.pctCategoriamoveis_decoracao,
            t6.pctCategoriautilidades_domesticas,
            t6.pctCategoriarelogios_presentes,
            t6.pctCategoriatelefonia,
            t6.pctCategoriaautomotivo,
            t6.pctCategoriabrinquedos,
            t6.pctCategoriacool_stuff,
            t6.pctCategoriaferramentas_jardim,
            t6.pctCategoriaperfumaria,
            t6.pctCategoriabebes,
            t6.pctCategoriaeletronicos
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
        WHERE
            t1.qtdRecencia <= 45
    ),
    tb_event AS (
        SELECT DISTINCT
            seller_id,
            DATE (order_purchase_timestamp) as dtPedido
        FROM
            tb_order_items AS t1
            LEFT JOIN tb_orders AS t2 ON t1.order_id = t2.order_id
        WHERE
            seller_id IS NOT NULL
    ),
    tb_flag as (
        SELECT
            t1.dtReferencia,
            t1.seller_id,
            min(t2.dtPedido) as dtProxPedido
        FROM
            tb_features as t1
            LEFT JOIN tb_event as t2 ON t1.seller_id = t2.seller_id
            AND t1.dtReferencia <= t2.dtPedido
            AND (JULIANDAY (dtReferencia) - JULIANDAY (dtPedido)) <= (45 - qtdRecencia)
        GROUP BY
            1,
            2
    )
SELECT
    t1.*,
    case
        when dtProxPedido IS NULL THEN 1
        ELSE 0
    END as flChurn
FROM
    tb_features as t1
    LEFT JOIN tb_flag AS t2 ON t1.seller_id = t2.seller_id
    AND t1.dtReferencia = t2.dtReferencia
ORDER BY
    t1.seller_id,
    t2.dtReferencia