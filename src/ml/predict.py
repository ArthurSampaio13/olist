# %%
import mlflow
import pandas as pd
import sqlalchemy
import sqlite3
# %%
model = mlflow.sklearn.load_model("models:/olist/latest")

# %%
engine = sqlalchemy.create_engine("sqlite:///../../data/olist.db")
conn = sqlite3.connect("../../data/olist.db")
query = "SELECT * FROM ABT"
df = pd.read_sql_query(query, conn)

# %%
predict = model.predict_proba(df[model.feature_names_in_])[:,1]
predict
# %%



# %%
