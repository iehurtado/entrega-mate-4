from pathlib import Path
from typing import Dict, List, Mapping, Tuple

import matplotlib.pyplot as plt
import numpy as np
from numpy.typing import ArrayLike
import pandas as pd
from scipy.stats import t
import os
import pandas as pd
from modelos.descenso import ejecutar_descenso
from modelos.regresion_cuadratica import RegresionCuadratica
from modelos.regresion_multiple import RegresionMultiple
from modelos.regresion_simple import RegresionSimple

FEATURES = ["temp", "atemp", "hum", "windspeed"]

def main() -> None:
    root = Path(__file__).resolve().parent
    data_path = root / "data" / "day.csv"
    output_dir = root / "outputs"

    if not data_path.is_file():
        raise FileNotFoundError(f"No se encontró el dataset: {data_path}")

    data = pd.read_csv(data_path)
    required_columns = {"temp", "atemp", "hum", "windspeed", "cnt"}
    missing_columns = required_columns.difference(data.columns)
    if missing_columns:
        raise ValueError(
            f"Faltan columnas requeridas en {data_path}: "
            f"{', '.join(sorted(missing_columns))}"
        )

    if output_dir.exists():
        for entry in output_dir.glob('*'):
            entry.unlink(missing_ok=True)

    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Dataset: {data_path} ({len(data)} observaciones)")
    print(f"Resultados: {output_dir}")

    # Parte A
    regresion_cuadratica(data, output_dir)
    rl_temp = RegresionSimple('temp', data['temp'], data['cnt'])
    verificar_estimadores(rl_temp)
    descenso_gradiente(data, output_dir)

    # Parte B
    descomposicion_varianza(rl_temp, output_dir)
    simples = regresiones_simples(data, output_dir)

    rl_atemp = simples["atemp"]

    test_hipotesis(rl_atemp, output_dir)
    calcular_intervalos(rl_temp)
    rl_atemp.graficar("atemp", "cnt", destino=str(output_dir / "b2_regresion_atemp.png"))
    regresion_multiple(data, FEATURES, rl_atemp, output_dir)

    print(f"\nAnálisis finalizado. Gráficos y tablas: {output_dir}")


def regresion_cuadratica(data: pd.DataFrame, output_dir: Path) -> None:
    print("\n=== A.1: Modelo cuadrático ===")

    modelo = RegresionCuadratica("temp", data["temp"], data["cnt"])
    beta0, beta1, beta2 = modelo.beta
    rango_min, rango_max = modelo.rango_x

    print(f"ŷ(x) = {beta0:.4f} + ({beta1:.4f})·x + ({beta2:.4f})·x²")
    for x_val in (0.20, 0.70):
        print(
            f"x={x_val:.2f} ({x_val * 41:.1f} °C): "
            f"dŷ/dx={modelo.derivada(x_val):.2f}, "
            f"dŷ/d°C={modelo.derivada(x_val) / 41:.2f}"
        )

    print(
        f"Punto Crítico x*={modelo.x_critico:.4f} (~{modelo.x_critico * 41:.2f} °C); "
        f"segunda derivada={modelo.derivada_segunda:.2f}"
    )
    print(
        f"Rango observado=[{rango_min:.4f}, {rango_max:.4f}] "
        f"(el óptimo {'está' if modelo.x_critico_en_rango else 'no está'} "
        "dentro del rango)."
    )
    print(f"R² del ajuste cuadrático: {modelo.r2:.4f}")

    tabla = pd.DataFrame([ modelo.to_row() ])
    tabla.to_json(output_dir / "quadratic.json", index=False, orient='records', double_precision=4)

    modelo.graficar(output_dir / "a1_modelo_cuadratico.png")


def verificar_estimadores(modelo: RegresionSimple):
    print("\n=== A.2: Ecuaciones normales de regresión simple ===")

    x_bar, y_bar = modelo.x.mean(), modelo.y.mean()

    print(f"N={len(modelo)}; media(temp)={x_bar:.4f}; media(cnt)={y_bar:.4f}")
    print(f"Sxy={modelo.sxy:.4f}; Sxx={modelo.sxx:.4f}")
    print(f"Fórmula analítica: β̂₁={modelo.beta1:.6f}, β̂₀={modelo.beta0:.6f}")
    print(f"np.polyfit:        β̂₁={modelo.beta1_lib:.6f}, β̂₀={modelo.beta0_lib:.6f}")
    print(f"Recta estimada: ŷ = {modelo.beta0:.2f} + {modelo.beta1:.2f}·x")

    if not np.allclose([modelo.beta1, modelo.beta0], [modelo.beta1_lib, modelo.beta0_lib], atol=1e-6):
        print("WARN: Las estimaciones no coinciden!")


def descenso_gradiente(
    data: pd.DataFrame, output_dir: Path
) -> tuple[np.ndarray, np.ndarray]:
    print("\n=== A.3: Descenso del gradiente ===")

    x, y = data[FEATURES], data['cnt']
    modelo = RegresionMultiple(x, y) # Calcula beta en forma matricial

    # La pérdida media mantiene tasas de aprendizaje manejables para el dataset completo.
    tasas = {
        "pequeña": (0.0001, "blue"),
        "adecuada": (0.5, "green"),
        "excesiva": (0.6, "red"),
    }

    resultados = {}

    fig, ax = plt.subplots(figsize=(9, 5))

    for nombre, (alpha, color) in tasas.items():
        beta, historial = ejecutar_descenso(x, y, alpha, max_iters=10000)

        print(
            f"Tasa {nombre} (α={alpha}): "
            f"pérdida inicial={historial[0]:.2f}, "
            f"final={historial[-1]:.2f}, iteraciones={len(historial) - 1}"
        )

        resultados[nombre] = (beta, historial)

        ax.plot(
            range(len(historial)),
            historial,
            label=f"{nombre.capitalize()} (α={alpha})",
            color=color,
            linestyle="--" if nombre == "excesiva" else "-",
            lw=2,
        )

    ax.set_xlabel("Número de iteración (k)")
    ax.set_ylabel("Pérdida cuadrática media")
    ax.set_title("A.3: Evolución de la pérdida según la tasa de aprendizaje")
    ax.set_ylim(0, resultados["pequeña"][1][0] * 1.25)
    ax.grid(True, alpha=0.3)
    ax.legend()
    fig.tight_layout()
    fig.savefig(output_dir / "a3_descenso_gradiente.png", dpi=150)
    plt.close(fig)

    coefs = pd.DataFrame(
        {
            "coef": [f"beta{i}" for i in range(modelo.k + 1)],
            "gradiente": resultados["adecuada"][0],
            "matricial": modelo.beta,
        }
    )

    coefs['diferencia'] = np.abs(coefs['gradiente'] - coefs['matricial'])

    print("Comparación con mínimos cuadrados (tasa adecuada):")
    print(coefs.to_string(float_format=lambda v: f"{v:,.4f}"))

    coefs.to_json(output_dir / "coeficientes.json", index=False, orient='records', double_precision=4)
    return resultados["adecuada"][0], modelo.beta


def descomposicion_varianza(modelo: RegresionSimple, output_dir: Path) -> pd.DataFrame:
    print("\n=== B.1: Varianza y descomposición ANOVA ===")

    tabla = modelo.anova()
    tabla.to_csv(output_dir / "b1_tabla_anova.csv", float_format=lambda v: f"{v:.4f}")
    print(tabla.to_string(float_format=lambda valor: f"{valor:,.4f}"))

    print(f"σ̂²={modelo.sigma2:.4f}")
    print(f"R²={modelo.r2:.4f} = {modelo.r2:.2%}")
    print(f"STC = SCR + SCE: {modelo.stc:.4f}")

    return tabla


def regresiones_simples(data: pd.DataFrame, output_dir: Path):
    print("\n=== B.2: Regresión Lineal Simple")

    modelos = {
        variable: RegresionSimple(variable, data[variable], data["cnt"])
        for variable in ["temp", "atemp", "hum", "windspeed"]
    }

    x_estrella = 0.65
    filas_modelos = [
        modelo.to_row(x_estrella)
        for modelo in modelos.values()
    ]

    tabla = pd.DataFrame(filas_modelos)
    tabla.to_json(output_dir / "linear.json", index=False, orient='records', double_precision=4)

    print(
        tabla.to_string(
            columns=['variable', 'beta0', 'beta1', 'icb0_inf', 'icb0_sup', 'icb1_inf', 'icb1_sup'],
            float_format=lambda value: f"{value:,.4f}")
    )
    print()
    print(
        tabla.to_string(
            columns=['variable', 'sigma2', 'r2', 'r', 'icm_inf', 'icm_sup', 'ip_inf', 'ip_sup'],
            float_format=lambda value: f"{value:,.4f}")
    )

    return modelos


def test_hipotesis(modelo: RegresionSimple, output_dir: Path, alpha: float = 0.05) -> None:
    print("\n=== B.3: Test de hipótesis para la pendiente ===")

    grados_libertad = len(modelo) - 2
    error_std = (modelo.sigma2 / modelo.sxx) ** 0.5
    estadistico = modelo.beta1 / error_std
    critico = t.ppf(1 - alpha / 2, grados_libertad)
    rechaza = abs(estadistico) > critico

    print(f"H₀: β₁=0 vs. H₁: β₁≠0; variable={modelo.variable}, α={alpha:.2f}, gl={grados_libertad}")
    print(f"T={estadistico:.4f}; t crítico={critico:.4f}")
    print(
        "Se rechaza H₀: hay evidencia de relación lineal."
        if rechaza
        else "No se rechaza H₀: no hay evidencia suficiente de relación lineal."
    )

    tabla = pd.DataFrame([
        {
            "alpha": alpha,
            "gl": grados_libertad,
            "critico": critico,
            "estadistico": estadistico,
        }
    ])

    tabla.to_json(output_dir / "hipotesis.json", index=False, orient='records', double_precision=4)


def calcular_intervalos(modelo: RegresionSimple, x_estrella: float = 0.65) -> None:
    print("\n=== B.4: Intervalos del 95 % ===")

    intervalo_media = modelo.ic_media(x_estrella)
    intervalo_prediccion = modelo.ic_prediccion(x_estrella)

    print(f"Variable={modelo.variable}; x*={x_estrella:.2f}")
    print(
        f"Respuesta media: [{intervalo_media[0]:.2f}, "
        f"{intervalo_media[1]:.2f}]"
    )
    print(
        f"Predicción individual: [{intervalo_prediccion[0]:.2f}, "
        f"{intervalo_prediccion[1]:.2f}]"
    )


def regresion_multiple(
    data: pd.DataFrame,
    features: List[str],
    modelo_simple: RegresionSimple,
    output_dir: Path,
) -> pd.DataFrame:
    print("\n=== B.5: Regresión lineal múltiple ===")

    modelo = RegresionMultiple(data[features], data['cnt'])
    tabla = pd.DataFrame([modelo.to_row()])

    print(tabla.to_string(float_format=lambda valor: f"{valor:.4f}"))

    comparar(modelo, modelo_simple)

    tabla.to_json(output_dir / "multiple.json", index=False, orient='records', double_precision=4)
    return tabla


def comparar(modelo: RegresionMultiple, modelo_simple: RegresionSimple):
    print(
        f"SSr={modelo.ssr}; "
        f"STC={modelo.stc}; "
        f"R² múltiple={modelo.r2:.4f} ({modelo.r2:.2%}); "
        f"R² ajustado={modelo.r2_adj:.4f} ({modelo.r2_adj:.2%})"
    )
    print(
        f"R² del modelo simple ({modelo_simple.variable})="
        f"{modelo_simple.r2:.4f} ({modelo_simple.r2:.2%})"
    )
    print(
        f"Diferencia de R² ajustado frente al modelo simple: "
        f"{(modelo.r2_adj - modelo_simple.r2) * 100:.2f} puntos porcentuales."
    )


if __name__ == "__main__":
    main()
