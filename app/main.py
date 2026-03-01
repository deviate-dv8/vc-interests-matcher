"""FastAPI app for GloVe text similarity."""
from fastapi import FastAPI, Query
from fastapi.responses import Response
from pydantic import BaseModel

from app.glove import glove_similarity

app = FastAPI(
    title="GloVe Interests Matcher",
    description="Stateless word similarity comparison using GloVe embeddings",
    version="0.1.0",
)


class SimilarityResponse(BaseModel):
    similarity: float
    text1: str
    text2: str


@app.get("/")
def root() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/favicon.ico", include_in_schema=False)
def favicon() -> Response:
    return Response(status_code=204)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/similarity", response_model=SimilarityResponse)
def similarity(
    text1: str = Query(..., min_length=1, description="First text"),
    text2: str = Query(..., min_length=1, description="Second text"),
) -> SimilarityResponse:
    sim = glove_similarity(text1, text2)
    return SimilarityResponse(similarity=sim, text1=text1, text2=text2)

