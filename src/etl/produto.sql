WITH
    tb_join as (
        SELECT DISTINCT
            t2.seller_id,
            t3.*
        FROM
            tb_orders AS t1
            LEFT JOIN tb_order_items AS t2 ON t1.order_id = t2.order_id
            LEFT JOIN tb_products as t3 ON t2.product_id = t3.product_id
        WHERE
            t1.order_purchase_timestamp < '2018-01-01'
            AND t1.order_purchase_timestamp >= date ('2018-01-01', '-6 months')
            AND t2.seller_id IS NOT NULL
    ),
    tb_summary as (
        SELECT
            seller_id,
            avg(coalesce(product_photos_qty, 0)) as avgFotos,
            1.0 * avg(product_photos_qty) as avgQtdFotos,
            1.0 * avg(
                product_length_cm * product_height_cm * product_width_cm
            ) as avgVolume,
            1.0 * min(
                product_length_cm * product_height_cm * product_width_cm
            ) as minVolume,
            1.0 * max(
                product_length_cm * product_height_cm * product_width_cm
            ) as maxVolume,
            count(
                distinct case
                    when product_category_name = 'cama_mesa_banho' then product_id
                end
            ) / count(distinct product_id) as pctCategoriacama_mesa_banho,
            1.0 * count(
                distinct case
                    when product_category_name = 'beleza_saude' then product_id
                end
            ) / count(distinct product_id) as pctCategoriabeleza_saude,
            1.0 * count(
                distinct case
                    when product_category_name = 'esporte_lazer' then product_id
                end
            ) / count(distinct product_id) as pctCategoriaesporte_lazer,
            1.0 * count(
                distinct case
                    when product_category_name = 'informatica_acessorios' then product_id
                end
            ) / count(distinct product_id) as pctCategoriainformatica_acessorios,
            1.0 * count(
                distinct case
                    when product_category_name = 'moveis_decoracao' then product_id
                end
            ) / count(distinct product_id) as pctCategoriamoveis_decoracao,
            1.0 * count(
                distinct case
                    when product_category_name = 'utilidades_domesticas' then product_id
                end
            ) / count(distinct product_id) as pctCategoriautilidades_domesticas,
            1.0 * count(
                distinct case
                    when product_category_name = 'relogios_presentes' then product_id
                end
            ) / count(distinct product_id) as pctCategoriarelogios_presentes,
            1.0 * count(
                distinct case
                    when product_category_name = 'telefonia' then product_id
                end
            ) / count(distinct product_id) as pctCategoriatelefonia,
            1.0 * count(
                distinct case
                    when product_category_name = 'automotivo' then product_id
                end
            ) / count(distinct product_id) as pctCategoriaautomotivo,
            1.0 * count(
                distinct case
                    when product_category_name = 'brinquedos' then product_id
                end
            ) / count(distinct product_id) as pctCategoriabrinquedos,
            1.0 * count(
                distinct case
                    when product_category_name = 'cool_stuff' then product_id
                end
            ) / count(distinct product_id) as pctCategoriacool_stuff,
            1.0 * count(
                distinct case
                    when product_category_name = 'ferramentas_jardim' then product_id
                end
            ) / count(distinct product_id) as pctCategoriaferramentas_jardim,
            1.0 * count(
                distinct case
                    when product_category_name = 'perfumaria' then product_id
                end
            ) / count(distinct product_id) as pctCategoriaperfumaria,
            1.0 * count(
                distinct case
                    when product_category_name = 'bebes' then product_id
                end
            ) / count(distinct product_id) as pctCategoriabebes,
            1.0 * count(
                distinct case
                    when product_category_name = 'eletronicos' then product_id
                end
            ) / count(distinct product_id) as pctCategoriaeletronicos
        FROM
            tb_join
        GROUP BY
            seller_id
    )

SELECT
    '2018-01-01' as dtReferencia,
    *
FROM
    tb_summary