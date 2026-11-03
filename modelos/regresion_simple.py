import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from numpy.typing import ArrayLike
from scipy.stats import f, t


class RegresionSimple:
    def __init__(self, variable: str, x: ArrayLike, y: ArrayLike):
        self.variable = variable
        self.x = np.asarray(x, dtype=float)
        self.y = np.asarray(y, dtype=float)
        if self.x.ndim != 1 or self.y.ndim != 1 or len(self.x) != len(self.y):
            raise ValueError("x e y deben ser vectores unidimensionales de igual longitud")
        if len(self.x) < 3:
            raise ValueError("Se necesitan al menos tres observaciones")

        self.sxx = np.sum((self.x - self.x.mean()) ** 2)
        if self.sxx == 0:
            raise ValueError(f"La variable {variable!r} no tiene variación")
        self.sxy = np.sum((self.x - self.x.mean()) * (self.y - self.y.mean()))
        self.syy = np.sum((self.y - self.y.mean()) ** 2)

        self.beta1 = self.sxy / self.sxx
        self.beta0 = self.y.mean() - self.beta1 * self.x.mean()
        self.beta1_lib, self.beta0_lib = np.polyfit(self.x, self.y, 1)

        self.sce = np.sum((self.y - self(self.x)) ** 2)
        self.scr = np.sum((self(self.x) - self.y.mean()) ** 2)
        self.stc = self.scr + self.sce
        self.r2 = 1 - self.sce / self.stc
        self.r = np.sqrt(self.r2) * np.sign(self.beta1)
        self.sigma2 = self.sce / (len(self) - 2)

    def __call__(self, x: ArrayLike) -> np.ndarray:
        return self.beta1 * np.asarray(x) + self.beta0

    def __len__(self) -> int:
        return len(self.y)

    def ic_beta1(self, alpha: float = 0.05) -> tuple[float, float]:
        std = np.sqrt(self.sigma2 / self.sxx)
        return t.interval(1 - alpha, df=len(self) - 2, loc=self.beta1, scale=std)

    def ic_beta0(self, alpha: float = 0.05) -> tuple[float, float]:
        n = len(self)
        std = np.sqrt(self.sigma2 * (1 / n + self.x.mean() ** 2 / self.sxx))
        return t.interval(1 - alpha, df=n - 2, loc=self.beta0, scale=std)

    def ic_media(self, x_estrella: float, alpha: float = 0.05) -> tuple[float, float]:
        n = len(self)
        std = np.sqrt(
            self.sigma2
            * (1 / n + (x_estrella - self.x.mean()) ** 2 / self.sxx)
        )
        return t.interval(1 - alpha, df=n - 2, loc=self(x_estrella), scale=std)

    def ic_prediccion(
        self, x_estrella: float, alpha: float = 0.05
    ) -> tuple[float, float]:
        n = len(self)
        std = np.sqrt(
            self.sigma2
            * (1 + 1 / n + (x_estrella - self.x.mean()) ** 2 / self.sxx)
        )
        return t.interval(1 - alpha, df=n - 2, loc=self(x_estrella), scale=std)

    def anova(self: RegresionSimple) -> pd.DataFrame:
        n = len(self)
        gl_reg, gl_res, gl_tot = 1, n - 2, n - 1
        ss_reg, ss_res, ss_tot = self.scr, self.sce, self.stc
        cm_reg, cm_res = ss_reg / gl_reg, ss_res / gl_res
        f_stat = cm_reg / cm_res
        p_valor = f.sf(f_stat, gl_reg, gl_res)

        return pd.DataFrame(
            {
                "Grados de libertad": [gl_reg, gl_res, gl_tot],
                "Suma de cuadrados": [ss_reg, ss_res, ss_tot],
                "Cuadrados medios": [cm_reg, cm_res, None],
                "Estadístico F": [f_stat, None, None],
                "p-valor": [p_valor, None, None],
            },
            index=["Regresión", "Residuos", "Total"],
        )

    def graficar(
        self,
        nombre_x: str = "x",
        nombre_y: str = "y",
        destino: str | None = None,
    ) -> None:
        x_linea = np.linspace(self.x.min(), self.x.max(), 200)
        fig, ax = plt.subplots(figsize=(8, 5))
        ax.scatter(self.x, self.y, alpha=0.5, s=15, label="Observado")
        ax.plot(
            x_linea,
            self(x_linea),
            color="red",
            linewidth=2,
            label="Recta de regresión estimada",
        )
        ax.set_xlabel(nombre_x)
        ax.set_ylabel(nombre_y)
        ax.set_title(f"Regresión simple: {nombre_y} vs {nombre_x}")
        ax.legend()
        ax.grid(True, alpha=0.3)
        fig.tight_layout()
        if destino is not None:
            fig.savefig(destino, dpi=150)
        plt.close(fig)

    def to_row(self, x_estrella):
        ic_beta0 = self.ic_beta0()
        ic_beta1 = self.ic_beta1()
        ic_media = self.ic_media(x_estrella)
        ic_pred = self.ic_prediccion(x_estrella)
        
        return {
            "variable": self.variable,
            "beta0": self.beta0,
            "beta1": self.beta1,
            "beta0_lib": self.beta0_lib,
            "beta1_lib": self.beta1_lib,
            "xmean": self.x.mean(),
            "ymean": self.y.mean(),
            "sxx": self.sxx,
            "sxy": self.sxy,
            "syy": self.syy,
            "scr": self.scr,
            "sce": self.sce,
            "stc": self.stc,
            "r2": self.r2,
            "r": self.r,
            "sigma2": self.sigma2,
            "n": len(self),
            "icb0_inf": ic_beta0[0],
            "icb0_sup": ic_beta0[1],
            "icb1_inf": ic_beta1[0],
            "icb1_sup": ic_beta1[1],
            "icm_inf": ic_media[0],
            "icm_sup": ic_media[1],
            "ip_inf": ic_pred[0],
            "ip_sup": ic_pred[1],
        }


def tabular_modelos(
    modelos: list[RegresionSimple], x_estrella: float = 0.65
) -> pd.DataFrame:
    def fmt_ic(intervalo: tuple[float, float]) -> str:
        return f"[{intervalo[0]:.4f}; {intervalo[1]:.4f}]"

    filas = []
    for modelo in modelos:
        filas.append(
            {
                "variable": modelo.variable,
                "beta1": round(modelo.beta1, 4),
                "beta0": round(modelo.beta0, 4),
                "sigma2": round(modelo.sigma2, 4),
                "r2": round(modelo.r2, 4),
                "r": round(modelo.r, 4),
                "IC(beta1)": fmt_ic(modelo.ic_beta1()),
                "IC(beta0)": fmt_ic(modelo.ic_beta0()),
                f"IC media(Y|x*={x_estrella})": fmt_ic(
                    modelo.ic_media(x_estrella)
                ),
                f"IC predicción(Y|x*={x_estrella})": fmt_ic(
                    modelo.ic_prediccion(x_estrella)
                ),
            }
        )
    return pd.DataFrame(filas).set_index("variable")

