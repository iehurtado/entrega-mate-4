import numpy as np
from numpy.typing import ArrayLike


def ejecutar_descenso(x: ArrayLike, y: ArrayLike, alpha: float, max_iters: int = 200, tol: float = 0.01):
    def loss(beta: np.ndarray, x: np.ndarray, y: np.ndarray) -> float:
        residuos = y - x @ beta
        return float(np.mean(residuos**2))

    def gradiente(beta: np.ndarray, x: np.ndarray, y: np.ndarray) -> np.ndarray:
        return -2 * (x.T @ (y - x @ beta)) / len(y)

    x = np.asarray(x)
    x = np.column_stack((np.ones(x.shape[0]), x))
    y = np.asarray(y)

    beta = np.zeros(x.shape[1])

    history = []
    prev, curr = np.inf, loss(beta, x, y)

    i = 0
    while np.isfinite(curr) and curr < 1e16 and abs(prev - curr) > tol and i < max_iters:
        history.append(curr)
        beta = beta - alpha * gradiente(beta, x, y)
        prev, curr = curr, loss(beta, x, y)
        i += 1

    history.append(curr)

    return beta, history
