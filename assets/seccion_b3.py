from scipy.stats import t

from assets.regresion_simple import RegresionSimple


def ejecutar(modelo: RegresionSimple, alpha: float = 0.05) -> None:
    grados_libertad = len(modelo) - 2
    error_std = (modelo.sigma2 / modelo.sxx) ** 0.5
    estadistico = modelo.beta1 / error_std
    critico = t.ppf(1 - alpha / 2, grados_libertad)
    rechaza = abs(estadistico) > critico

    print("\n=== B.3: Test de hipótesis para la pendiente ===")
    print(
        f"H₀: β₁=0 vs. H₁: β₁≠0; variable={modelo.variable}, "
        f"α={alpha:.2f}, gl={grados_libertad}"
    )
    print(f"T={estadistico:.4f}; t crítico={critico:.4f}")
    print(
        "Se rechaza H₀: hay evidencia de relación lineal."
        if rechaza
        else "No se rechaza H₀: no hay evidencia suficiente de relación lineal."
    )
