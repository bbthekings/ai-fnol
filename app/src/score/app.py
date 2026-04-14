from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Fnol(BaseModel):
    claim_id: str
    vehicle_age: float
    airbags_deployed: bool
    impact_speed: float
    impact_type: str

class FnolScore(BaseModel):
    claim_id: str
    score: float
    category: str
    model_version: str

@app.get("/")
async def root():
    return {"message": "This is the inference webservice endpoint on aks/pod/container"}

@app.post("/score", response_model=FnolScore)
async def score_claim(item: Fnol):
    score = FnolScore(
    claim_id = item.claim_id,
    score = 0.92,
    category = "TOTAL_LOSS",
    model_version = "v1")

    return score