# %%
import pandas as pd
import sqlalchemy
import sqlite3

from sklearn import model_selection
from sklearn import tree, ensemble
from sklearn import pipeline
from sklearn import metrics

import matplotlib.pyplot as plt
import scikitplot as skplt

import mlflow

from feature_engine import imputation

pd.set_option('display.max_rows', 1000)
# %%
# SAMPLE
engine = sqlalchemy.create_engine("sqlite:///../../data/olist.db")
conn = sqlite3.connect("../../data/olist.db")
query = "SELECT * FROM ABT"
df = pd.read_sql_query(query, conn)

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
# Define experimento

mlflow.set_tracking_uri("http://localhost:5000/")
mlflow.set_experiment('olist')
# %%
# Transform
## Var para imputar

missing_minus_1 = ['avgIntervaloVendas',
                              'maxVolume',                            
                              'minVolume',                             
                              'avgVolume',
                              'qtdDiasPedidoEngtrega',
                              'qtdDiasAprovadoEngtrega',
                              'pctPedidoAtraso']

missing_0 = ['maxQtdParcelas', 
                        'medianaQtdParcelas', 
                        'avgQtdParcelas', 
                        'minQtdParcelas',
                        'avgQtdFotos']
# %%
with mlflow.start_run():
    mlflow.sklearn.autolog()
    
    mlflow.autolog()
    
    imputer_minus_1 = imputation.ArbitraryNumberImputer(arbitrary_number=-1, variables=missing_minus_1)
    imputer_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=missing_0)

    model = ensemble.RandomForestClassifier(random_state=42,
                                            n_jobs=-1)
    
    paramns = {"min_samples_leaf":[5,10],
            "n_estimators":[300,500]}
    
    grid = model_selection.GridSearchCV(model, 
                                        paramns, 
                                        cv=3, 
                                        verbose=3,
                                        scoring='roc_auc')

    model_pipe = pipeline.Pipeline([("Imputer -1", imputer_minus_1),
                                ("Imputer 0", imputer_0),
                                ("GridSearch", grid)])

    model_pipe.fit(X_train, y_train)
    
    auc_train = metrics.roc_auc_score(y_train, model_pipe.predict_proba(X_train)[:,1])
    auc_test = metrics.roc_auc_score(y_test, model_pipe.predict_proba(X_test)[:,1])
    auc_oot = metrics.roc_auc_score(dt_oot[target], model_pipe.predict_proba(dt_oot[features])[:,1])
    
    metrics_model = {"auc_train":auc_train,
                      "auc_test":auc_test,
                      "auc_oot":auc_oot}
    
    mlflow.log_metrics(metrics_model)
