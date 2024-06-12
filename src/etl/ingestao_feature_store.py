# %%
import sqlalchemy
import datetime

from tqdm import tqdm

# %%

def dates_to_list(dt_start, dt_stop):
    date_start = datetime.datetime.strptime(dt_start, "%Y-%m-%d")
    date_stop = datetime.datetime.strptime(dt_stop, "%Y-%m-%d")
    days = (date_stop - date_start).days
    dates = [(date_start + datetime.timedelta(i)).strftime("%Y-%m-%d") for i in range(days+1)]
    return dates

def backfill(query, engine, dt_start, dt_stop, holder):
    dates = dates_to_list(dt_start, dt_stop)
    for d in tqdm(dates):
        process_date(query, d, engine, holder)

def import_query(path):
    with open(path, "r") as open_file:
        query = open_file.read()
    return query

def process_date(query, date, engine, holder):
    with engine.connect() as connection:
        delete = sqlalchemy.text(f"DELETE FROM fs_vendedor_{holder} WHERE dtReferencia = :date")
        connection.execute(delete, {"date": date})
        
        query = query.format(date=date)
        connection.execute(sqlalchemy.text(query))

# %%

engine = sqlalchemy.create_engine("sqlite:///../../data/olist.db")

query = import_query("produto.sql")

dt_start = '2017-01-01'
dt_stop = '2018-01-01'

paths = ['pagamentos.sql', 'entrega.sql', 'cliente.sql', 'avaliacao.sql']
holders = ['pagamentos', 'entrega', 'cliente', 'avaliacao']

for path, holder in zip(paths, holders):
    query = import_query(path)
    backfill(query, engine, dt_start, dt_stop, holder)