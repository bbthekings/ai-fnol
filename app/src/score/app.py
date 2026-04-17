from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
import os

# --- Load the model ONCE at startup ---
# --- stays in the RAM so predictions take milliseconds ---
loaded_model = joblib.load('model.pkl')
model_version = os.getenv("MODEL_VERSION", "0")

app = FastAPI()



# input payload: dummy
class Fnol(BaseModel):
    claim_id: str
    vehicle_age: float
    airbags_deployed: bool
    impact_speed: float
    impact_type: str
# response payload: dummy
class FnolScore(BaseModel):
    claim_id: str
    score: float
    category: str
    model_version: str

# input payload: model
class model_Fnol(BaseModel):
      claim_id:  str
      feature_1: float
      feature_2: float
      feature_3: float 
      feature_4: float
      feature_5: float
      feature_6: float
      feature_7: float
      feature_8: float
      feature_9: float
      feature_10: float
      feature_11: float
      feature_12: float
      feature_13: float
      feature_14: float
      feature_15: float
      feature_16: float
      feature_17: float
      feature_18: float
      feature_19: float
      feature_20: float
# response payload: model
class model_FnolScore(BaseModel):
    claim_id: str
    score: float
    category = str
    model_version: str   


@app.get("/")
async def root():
    return {"message": "This is the inference webservice endpoint on aks/pod/container"}

@app.post("/score_dummy", response_model=FnolScore)
async def score_claim_dummy(item: Fnol):
    score = FnolScore(
    claim_id = item.claim_id,
    score = 0.92,
    category = "TOTAL_LOSS",
    model_version = "v1")

    return score

@app.post("/score", response_model=model_FnolScore)
async def score_claim(item: model_Fnol):

    # prepare data input
    # -> list
    list = item.model_dump()
    # -> DataFrame
    df = pd.DataFrame([list])
    # drop col=claim_id
    x = df.drop(columns=['claim_id'])

    # predict the score
    y = loaded_model.predict(x)
    y_score = float(y[0])
    y_category = "Red" if y_score > 0.82 else "Green"
    
    # response payload
    model_FnolScore = FnolScore(
    claim_id = item.claim_id,
    score = y_score,  
    category = y_category,
    model_version = model_version)

    return model_FnolScore  