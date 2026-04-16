#!/usr/bin/env python
# coding: utf-8
#######
# task: 
# train the model (data from 'azureml://datastores/ds_pilot_uploads/paths/fnol_training_dataset.parquet')
# produce metric: r2_adj
# produce model: "./outputs/fnol_model.pkl"
#######

import argparse
import os
import joblib
import pandas as pd
import mlflow
import mlflow.sklearn
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from azureml.core import Run

mlflow.sklearn.autolog() # type: ignore

def train_model(data_path: str):
    df = pd.read_parquet(data_path)

    X = df.drop('risk_score', axis=1)
    y = df['risk_score']

    X = pd.get_dummies(X, columns=['impact_type'], drop_first=True)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    with mlflow.start_run():
        model = LinearRegression()
        model.fit(X_train, y_train)

        y_pred = model.predict(X_test)

        n = len(y_test)
        p = X_test.shape[1]
        r2 = r2_score(y_test, y_pred)
        r2_adj = 1 - (1 - r2) * (n - 1) / (n - p - 1)

        mlflow.log_metric("r2_adj", r2_adj)

        # temporary path inside a temporary VM's hard drive
        # Azure automatically moves the contents of ./outputs 
        # into a dedicated storage account associated with ml Workspace
        # once this script finishes on the VM
        os.makedirs("./outputs", exist_ok=True) 
        model_path = "./outputs/fnol_model.pkl"
        joblib.dump(model, model_path)

        mlflow.set_tag("r2_adj", str(r2_adj)) # -> for gh wf

        print(f"Model saved to {model_path}")
        print(f"Final Adjusted R2: {r2_adj}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data_path", type=str, required=True)
    args = parser.parse_args()
    train_model(args.data_path)



