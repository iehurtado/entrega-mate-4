import numpy as np
from numpy.typing import ArrayLike

class RegresionMultiple:
    def __init__(self, x: ArrayLike, y: ArrayLike):
        self.x = np.asarray(x)
        self.y = np.asarray(y)
        self.x_mat = np.column_stack((np.ones(self.x.shape[0]), x))

        self.beta = np.linalg.lstsq(self.x_mat, self.y, rcond=None)[0]
        predicciones = self.x_mat @ self.beta

        self.n, self.k = self.x.shape
        self.ssr = np.sum((self.y - predicciones) ** 2)
        self.stc = np.sum((self.y - self.y.mean()) ** 2)
        self.sigma2 = self.ssr / (self.n - self.k - 1)
        self.r2 = 1 - self.ssr / self.stc
        self.r2_adj = 1 - (1 - self.r2) * (self.n - 1) / (self.n - self.k - 1)

    def descenso_gradiente(self, alpha: float, max_iters: int = 250, tol: float = 1e-2):
        def _perdida(beta: np.ndarray, x: np.ndarray, y: np.ndarray) -> float:
            residuos = y - x @ beta
            return float(np.mean(residuos**2))


        def _gradiente(beta: np.ndarray, x: np.ndarray, y: np.ndarray) -> np.ndarray:
            return -2 * (x.T @ (y - x @ beta)) / len(y)

        beta = np.zeros(self.x_mat.shape[1])
        historial = [_perdida(beta, self.x_mat, self.y)]

        for _ in range(max_iters):
            beta_siguiente = beta - alpha * _gradiente(beta, self.x_mat, self.y)
            perdida = _perdida(beta_siguiente, self.x_mat, self.y)
            historial.append(perdida)
            if not np.isfinite(perdida) or perdida > 1e16:
                break
            if abs(historial[-2] - perdida) < tol:
                beta = beta_siguiente
                break
            beta = beta_siguiente

        return beta, historial

    def to_row(self):
        beta = {
            f"beta{i}": bi
            for i, bi in enumerate(self.beta)
        }

        return {
            **beta,
            "ssr": self.ssr,
            "stc": self.stc,
            "sigma2": self.sigma2,
            "r2": self.r2,
            "r2_adj": self.r2_adj,
            "n": self.n,
            "k": self.k,
        }
