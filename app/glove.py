"""GloVe-based text similarity (lazy-loaded model)."""
import numpy as np
from gensim.models import KeyedVectors
from typing import cast
import gensim.downloader as api

_glove_model: KeyedVectors | None = None


def _get_model() -> KeyedVectors:
    global _glove_model
    if _glove_model is None:
        print("Loading GloVe model... (first time only)")
        _glove_model = cast(KeyedVectors, api.load("glove-wiki-gigaword-50"))
        print("GloVe model loaded.")
    return _glove_model


def glove_similarity(text1: str, text2: str) -> float:
    model = _get_model()

    def embed(text: str) -> np.ndarray:
        tokens = [t for t in text.lower().split() if t in model]
        if not tokens:
            return np.zeros(50)
        vectors: list[np.ndarray] = [np.array(model[t]) for t in tokens]
        return np.mean(vectors, axis=0)

    vec1, vec2 = embed(text1), embed(text2)
    norm = np.linalg.norm(vec1) * np.linalg.norm(vec2)
    if norm == 0:
        return 0.0
    return float(np.dot(vec1, vec2) / norm)
