from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from numpy.typing import ArrayLike
from scipy.stats import t

class RegresionCuadratica:
    def __init__(self, variable: str, x: ArrayLike, y: ArrayLike):
        self.variable = variable
        self.x = np.asarray(x, dtype=float)
        self.y = np.asarray(y, dtype=float)
        
        if self.x.ndim != 1 or self.y.ndim != 1 or len(self.x) != len(self.y):
            raise ValueError("x e y deben ser vectores unidimensionales de igual longitud")
        
        if len(self.x) < 4:
            raise ValueError("Se necesitan al menos cuatro observaciones")
        
        if not np.isfinite(self.x).all() or not np.isfinite(self.y).all():
            raise ValueError("x e y deben contener solo valores finitos")

        self.matriz = np.column_stack((np.ones(len(self.x)), self.x, self.x**2))
        self.beta, _, rango, _ = np.linalg.lstsq(self.matriz, self.y, rcond=None)

        if rango < 3:
            raise ValueError("x debe contener al menos tres valores distintos")
        
        self.xtx = self.matriz.T @ self.matriz
        self.xtx_inv = np.linalg.solve(self.xtx, np.eye(3))
        self.beta0, self.beta1, self.beta2 = self.beta
        self.sce = float(np.sum((self.y - self(self.x)) ** 2))
        self.scr = float(np.sum((self(self.x) - self.y.mean()) ** 2))
        self.stc = float(np.sum((self.y - self.y.mean()) ** 2))

        if self.stc == 0:
            raise ValueError("No se puede calcular R² si y no tiene variación")
        
        self.r2 = 1 - self.sce / self.stc
        self.sigma2 = self.sce / (len(self) - 3)

    def __call__(self, x: ArrayLike) -> np.ndarray:
        valores = np.asarray(x, dtype=float)
        return self.beta0 + self.beta1 * valores + self.beta2 * valores**2

    def __len__(self) -> int:
        return len(self.y)

    def derivada(self, x: ArrayLike) -> np.ndarray:
        return self.beta1 + 2 * self.beta2 * np.asarray(x, dtype=float)

    @property
    def derivada_segunda(self) -> float:
        return 2 * self.beta2

    @property
    def x_critico(self) -> float:
        if self.beta2 == 0:
            raise ValueError("El modelo no tiene curvatura y no posee punto crítico")
        return -self.beta1 / (2 * self.beta2)

    @property
    def rango_x(self) -> tuple[float, float]:
        return float(self.x.min()), float(self.x.max())

    @property
    def x_critico_en_rango(self) -> bool:
        minimo, maximo = self.rango_x
        return minimo <= self.x_critico <= maximo

    def _ic_beta(self, indice: int, alpha: float) -> tuple[float, float]:
        std = np.sqrt(self.sigma2 * self.xtx_inv[indice, indice])
        return t.interval(
            1 - alpha, df=len(self) - 3, loc=self.beta[indice], scale=std
        )

    def ic_beta0(self, alpha: float = 0.05) -> tuple[float, float]:
        return self._ic_beta(0, alpha)

    def ic_beta1(self, alpha: float = 0.05) -> tuple[float, float]:
        return self._ic_beta(1, alpha)

    def ic_beta2(self, alpha: float = 0.05) -> tuple[float, float]:
        return self._ic_beta(2, alpha)

    def _error_estandar(self, x_estrella: float, prediccion: bool) -> float:
        vector = np.array([1.0, x_estrella, x_estrella**2])
        varianza = self.sigma2 * (vector @ self.xtx_inv @ vector)
        if prediccion:
            varianza += self.sigma2
        return float(np.sqrt(varianza))

    def ic_media(
        self, x_estrella: float, alpha: float = 0.05
    ) -> tuple[float, float]:
        return t.interval(
            1 - alpha,
            df=len(self) - 3,
            loc=float(self(x_estrella)),
            scale=self._error_estandar(x_estrella, prediccion=False),
        )

    def ic_prediccion(
        self, x_estrella: float, alpha: float = 0.05
    ) -> tuple[float, float]:
        return t.interval(
            1 - alpha,
            df=len(self) - 3,
            loc=float(self(x_estrella)),
            scale=self._error_estandar(x_estrella, prediccion=True),
        )

    def to_row(self):
        return {
            "variable": self.variable,
            "beta0": self.beta0,
            "beta1": self.beta1,
            "beta2": self.beta2,
            "sigma2": self.sigma2,
            "sce": self.sce,
            "scr": self.scr,
            "stc": self.stc,
            "r2": self.r2,
            "n": len(self),
            "x_min": self.x.min(),
            "x_max": self.x.max(),
            "x_critico": self.x_critico,
            "x_critico_en_rango": self.x_critico_en_rango,
        }

    def graficar(self, destino: Path) -> None:
        rango_min, rango_max = self.rango_x
        x_grid = np.linspace(rango_min, rango_max, 250)
        fig, ax = plt.subplots(figsize=(8, 5))
        ax.scatter(self.x, self.y, alpha=0.25, color="steelblue", label="Datos observados")
        ax.plot(
            x_grid,
            self(x_grid),
            color="crimson",
            lw=2.5,
            label="Ajuste cuadrático ŷ(x)",
        )
        ax.axvline(
            self.x_critico,
            color="black",
            linestyle="--",
            label=f"Óptimo x*={self.x_critico:.2f} ({self.x_critico * 41:.1f} °C)",
        )
        ax.set_xlabel(self.variable)
        ax.set_ylabel("Cantidad de alquileres (cnt)")
        ax.set_title("A.1: Relación cuadrática entre demanda y temperatura")
        ax.legend()
        ax.grid(True, alpha=0.3)
        fig.tight_layout()
        fig.savefig(destino, dpi=150)
        plt.close(fig)