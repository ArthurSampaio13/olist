# %%
from math import pi
import pandas as pd
import sqlalchemy
import sqlite3

from sklearn import model_selection, tree
from sklearn import tree
from sklearn import pipeline

from feature_engine import imputation


pd.set_option('display.max_rows', 1000)
# %%
# SAMPLE
print("Importando ABT...")
engine = sqlalchemy.create_engine("sqlite:///../../data/olist.db")
conn = sqlite3.connect("../../data/olist.db")
query = "SELECT * FROM ABT"
df = pd.read_sql_query(query, conn)
print("OK.")

# %%
# Sample - Back Test (OOT)

dt_oot = df[df['dtReferencia']=='2018-01-01']
# %%

df_train = df[df['dtReferencia']!='2018-01-01']
# %%
# Definindo variaveis
target = 'flChurn'

identificadores = ['dtReferencia', 'seller_id']

features = df.columns.tolist()
features = list(set(features) - set(identificadores + [target]))
# %%

X_train, X_test, y_train, y_test = model_selection.train_test_split(df_train[features], df_train[target],
                                                                                        test_size=0.2, random_state=42)  

print("Proporcao respota treino", y_train.mean())
print("Proporcao respota teste", y_test.mean())

# %%
# Explore
X_train.describe()

# %%
X_train.isna().sum().sort_values(ascending=False)

# %%
# Transform
## Var para imputar

missing_minus_1 = ['avgIntervaloVendas',
                              'maxVolume',                            
                              'minVolume',                             
                              'avgVolume',
                              'qtdDiasPedidoEngtrega',
                              'qtdDiasAprovadoEngtrega']

missing_0 = ['maxQtdParcelas', 
                        'medianaQtdParcelas', 
                        'avgQtdParcelas', 
                        'minQtdParcelas',
                        'avgQtdFotos',
                        'pctPedidoAtraso']

# %%
## Imputer

imputer_minus_1 = imputation.ArbitraryNumberImputer(arbitrary_number=-1, variables=missing_minus_1)
imputer_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=missing_0)

# %%
# Modeling
model = tree.DecisionTreeClassifier()

# %%
model_pipe = pipeline.Pipeline([("Imputer -1", imputer_minus_1),
                               "Imputer 0", imputer_0,
                               "Decision Tree", model])
# %%
model_pipe.fit(X_train, y_train)
# %%
