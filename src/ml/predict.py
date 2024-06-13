# %%
import mlflow
import pandas as pd
import sqlalchemy
import sqlite3
import datetime
# %%
# Set MLflow tracking URI and load the model
mlflow.set_tracking_uri('http://localhost:5000/')
model = mlflow.sklearn.load_model("models:/olistt@olist")
# %%
# Prediction
engine = sqlalchemy.create_engine("sqlite:///../../data/olist.db")
conn = sqlite3.connect("../../data/olist.db")
query = "SELECT * FROM fs_join"
df = pd.read_sql_query(query, conn)
# %%
# ETL
predict = model.predict_proba(df[model.feature_names_in_])
predict_0 = predict[:,0]
predict_1 = predict[:,1]

df_extract = df[['seller_id']].copy()
df_extract['0'] = predict_0
df_extract['1'] = predict_1

df_extract = (df_extract.set_index('seller_id')
                        .stack()
                        .reset_index())

df_extract.columns = ['seller_id', 'descClass', 'Score']
df_extract['descModel'] = 'Churn Vendedor'
df_extract['dtScore'] = datetime.datetime.now()
# %%

# %%
