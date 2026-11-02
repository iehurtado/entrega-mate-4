from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


FEATURES = ["temp", "atemp", "hum", "windspeed"]


def _perdida(beta: np.ndarray, x: np.ndarray, y: np.ndarray) -> float:
    residuos = y - x @ beta
    return float(np.mean(residuos**2))


def _gradiente(beta: np.ndarray, x: np.ndarray, y: np.ndarray) -> np.ndarray:
    return -2 * (x.T @ (y - x @ beta)) / len(y)


def _descenso_gradiente(
    x: np.ndarray,
    y: np.ndarray,
    alpha: float,
    max_iters: int = 250,
    tol: float = 1e-2,
) -> tuple[np.ndarray, list[float]]:
    beta = np.zeros(x.shape[1])
    historial = [_perdida(beta, x, y)]

    for _ in range(max_iters):
        beta_siguiente = beta - alpha * _gradiente(beta, x, y)
        perdida = _perdida(beta_siguiente, x, y)
        historial.append(perdida)
        if not np.isfinite(perdida) or perdida > 1e16:
            break
        if abs(historial[-2] - perdida) < tol:
            beta = beta_siguiente
            break
        beta = beta_siguiente

    return beta, historial


def ejecutar(data: pd.DataFrame, output_dir: Path) -> None:
    x = np.column_stack(
        (np.ones(len(data)), data[FEATURES].to_numpy(dtype=float))
    )
    y = data["cnt"].to_numpy(dtype=float)

    # La pérdida media mantiene tasas de aprendizaje manejables para el dataset completo.
    tasas = {
        "pequeña": (0.01, "blue"),
        "adecuada": (0.10, "green"),
        "excesiva": (0.60, "red"),
    }
    resultados = {
        nombre: _descenso_gradiente(x, y, alpha)
        for nombre, (alpha, _) in tasas.items()
    }
    beta_exacto = np.linalg.lstsq(x, y, rcond=None)[0]

    print("\n=== A.3: Descenso del gradiente ===")
    for nombre, (alpha, _) in tasas.items():
        beta, historial = resultados[nombre]
        print(
            f"Tasa {nombre} (α={alpha}): "
            f"pérdida inicial={historial[0]:.2f}, "
            f"final={historial[-1]:.2f}, iteraciones={len(historial) - 1}"
        )
    print("Comparación con mínimos cuadrados (tasa adecuada):")
    for nombre, beta_gradiente, beta_mco in zip(
        ["Intercepto"] + [f"β_{feature}" for feature in FEATURES],
        resultados["adecuada"][0],
        beta_exacto,
    ):
        print(
            f"  {nombre:16s} gradiente={beta_gradiente:11.4f} "
            f"MCO={beta_mco:11.4f}"
        )

    fig, ax = plt.subplots(figsize=(9, 5))
    for nombre, (alpha, color) in tasas.items():
        historial = resultados[nombre][1]
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
