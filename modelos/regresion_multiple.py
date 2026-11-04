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
