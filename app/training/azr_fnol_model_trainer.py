#!/usr/bin/env python
# coding: utf-8
#######
# task: 
# train the model (data from 'azureml://datastores/ds_pilot_uploads/paths/fnol_training_dataset.parquet')
# produce metric: r2_adj
# produce model: "./outputs/fnol_model.pkl"
#######
import os
import joblib
import pandas as pd
import mlflow
import mlflow.sklearn  # Explicitly import the sub-module
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, root_mean_squared_error, mean_absolute_error, r2_score

# 1. Start MLflow Autologging
# This captures coefficients, intercept, and standard metrics automatically!
mlflow.sklearn.autolog() # type: ignore

def train_model():
    # 1/2. Determine the environment and LOAD data
    # 'AZUREML_RUN_ID' only exists when running as an official Azure Job
    if os.environ.get('AZUREML_RUN_ID'):
        print("Running in Azure ML Cloud...")
        data_path = 'azureml://datastores/ds_pilot_uploads/paths/fnol_training_dataset.parquet'
    else:
        print("Running locally...")
        data_path = 'fnol_training_dataset.parquet' # The file on your laptop
        
    
    # NOTE: If you are running this in a local test, keep your local filename.
    # If running in an Azure Job, ensure your 'train_config.yml' inputs point here.
    df = pd.read_parquet(data_path)
    
    # 3. SPLIT DATA
    X = df.drop('risk_score', axis=1)
    y = df['risk_score']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # 4. TRAIN (The OLS Math)
    with mlflow.start_run(): # creates a digital bucket=context manager where everything is saved
        model = LinearRegression()
        model.fit(X_train, y_train)

        # 5. PREDICT & LOG CUSTOM METRICS
        y_pred = model.predict(X_test)
        
        # Calculate Adjusted R2
        n = len(y_test)
        p = X_test.shape[1]
        r2 = r2_score(y_test, y_pred)
        r2_adj = 1 - (1 - r2) * (n - 1) / (n - p - 1)
        
        # Manually log the Adjusted R2 (as Autolog doesn't do the 'Adjusted' version)
        mlflow.log_metric("r2_adj", r2_adj)
        
        # 6. SAVE MODEL TO ./outputs 
        # Azure ML will automatically pick this up from this specific folder name
        os.makedirs('./outputs', exist_ok=True) # temporary path inside a temporary VM's hard drive
                                                # Azure automatically moves the contents of ./outputs 
                                                # into a dedicated storage account associated with ml Workspace
                                                # once this script finishes on the VM
        model_path = "./outputs/fnol_model.pkl"
        joblib.dump(model, model_path)
        
        print(f"Model saved to {model_path}")
        print(f"Final Adjusted R2: {r2_adj}")

if __name__ == "__main__":
    train_model()


# In[ ]:




