from pathlib import Path

import numpy as np
import pandas as pd

from assets.regresion_simple import RegresionSimple
from assets.seccion_a3 import FEATURES


def ejecutar(
    data: pd.DataFrame,
    modelo_simple: RegresionSimple,
    output_dir: Path,
) -> pd.DataFrame:
    x = np.column_stack(
        (np.ones(len(data)), data[FEATURES].to_numpy(dtype=float))
    )
    y = data["cnt"].to_numpy(dtype=float)
    coeficientes = np.linalg.lstsq(x, y, rcond=None)[0]
    predicciones = x @ coeficientes
    ssr = np.sum((y - predicciones) ** 2)
    stc = np.sum((y - y.mean()) ** 2)
    r2 = 1 - ssr / stc
    n, p = x.shape[0], len(FEATURES)
    r2_ajustado = 1 - (1 - r2) * (n - 1) / (n - p - 1)

    tabla = pd.DataFrame(
        {
            "variable": ["Ordenada al origen"] + FEATURES,
            "coeficiente": coeficientes
        }
    ).set_index("variable")
    tabla.to_csv(output_dir / "b5_regresion_multiple.csv")

    print("\n=== B.5: Regresión lineal múltiple ===")
    print(tabla.to_string(float_format=lambda valor: f"{valor:.4f}"))
    print(
        f"SSr={ssr}; "
        f"STC={stc}; "
        f"R² múltiple={r2:.4f} ({r2:.2%}); "
        f"R² ajustado={r2_ajustado:.4f} ({r2_ajustado:.2%})"
    )
    print(
        f"R² del modelo simple ({modelo_simple.variable})="
        f"{modelo_simple.r2:.4f} ({modelo_simple.r2:.2%})"
    )
    print(
        f"Diferencia de R² ajustado frente al modelo simple: "
        f"{(r2_ajustado - modelo_simple.r2) * 100:.2f} puntos porcentuales."
    )
    return tabla
