from pathlib import Path

import pandas as pd
from scipy.stats import f

from assets.regresion_simple import RegresionSimple


def ejecutar(modelo: RegresionSimple, output_dir: Path) -> pd.DataFrame:
    n = len(modelo)
    gl_reg, gl_res, gl_tot = 1, n - 2, n - 1
    ss_reg, ss_res, ss_tot = modelo.scr, modelo.sce, modelo.stc
    cm_reg, cm_res = ss_reg / gl_reg, ss_res / gl_res
    f_stat = cm_reg / cm_res
    p_valor = f.sf(f_stat, gl_reg, gl_res)

    tabla = pd.DataFrame(
        {
            "Grados de libertad": [gl_reg, gl_res, gl_tot],
            "Suma de cuadrados": [ss_reg, ss_res, ss_tot],
            "Cuadrados medios": [cm_reg, cm_res, None],
            "Estadístico F": [f_stat, None, None],
            # "p-valor": [p_valor, None, None],
        },
        index=["Regresión", "Residuos", "Total"],
    )
    tabla.to_csv(output_dir / "b1_tabla_anova.csv")

    print("\n=== B.1: Varianza y descomposición ANOVA ===")
    print(tabla.to_string(float_format=lambda valor: f"{valor:,.4f}"))
    print(f"Estimación de la varianza residual σ̂²={modelo.sigma2:.4f}")
    print(
        f"R²={modelo.r2:.4f}: el modelo lineal explica "
        f"{modelo.r2:.2%} de la variabilidad observada de cnt en esta muestra. "
        "No es el porcentaje de predicciones correctas ni implica causalidad."
    )
    print(f"Verificación SC total = SC regresión + SC residuos: {ss_tot:.4f}")
    return tabla
