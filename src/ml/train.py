# %%
import pandas as pd
import sqlalchemy
import sqlite3

from sklearn import model_selection
from sklearn import tree
from sklearn import pipeline
from sklearn import metrics
import matplotlib.pyplot as plt
import scikitplot as skplt

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

dt_oot = df[df['dtReferencia'] == '2018-01-01']
# %%

df_train = df[df['dtReferencia'] != '2018-01-01']
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
model = tree.DecisionTreeClassifier(min_samples_leaf=50)

# %%
# Pipeline
model_pipe = pipeline.Pipeline([("Imputer -1", imputer_minus_1),
                               ("Imputer 0", imputer_0),
                               ("Decision Tree", model)])
# %%
model_pipe.fit(X_train, y_train)
# %%
predict = model_pipe.predict(X_train)
# %%
probas = model_pipe.predict_proba(X_train)
proba = probas[:,1]
# %%
skplt.metrics.plot_roc(y_train, probas)
plt.show()
# %%
skplt.metrics.plot_ks_statistic(y_train, probas)
plt.show()

# %%
probas_test = model_pipe.predict_proba(X_test)
# %%
skplt.metrics.plot_roc(y_test, probas_test)
plt.show()
# %%
skplt.metrics.plot_ks_statistic(y_test, probas_test)
plt.show()
# %%
probas_oot = model_pipe.predict_proba(X=dt_oot[features])

# %%
skplt.metrics.plot_roc(dt_oot[target], y_probas=probas_oot)
plt.show()
# %%
skplt.metrics.plot_ks_statistic(dt_oot[target], probas_oot)
plt.show()
# %%
fs_importance = model_pipe[-1].feature_importances_
fs_cols = model_pipe[:-1].transform(X_train.head(1)).columns.tolist()

pd.Series(fs_importance, index=fs_cols).sort_values(ascending=False)

# %%
skplt.metrics.plot_lift_curve(y_train, probas)
plt.show()