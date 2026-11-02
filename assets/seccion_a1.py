from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def ejecutar(data: pd.DataFrame, output_dir: Path) -> None:
    x = data["temp"].to_numpy()
    y = data["cnt"].to_numpy()
    beta2, beta1, beta0 = np.polyfit(x, y, 2)

    def f(valor: float | np.ndarray) -> float | np.ndarray:
        return beta0 + beta1 * valor + beta2 * valor**2

    def dy_dx(valor: float) -> float:
        return beta1 + 2 * beta2 * valor

    print("\n=== A.1: Modelo cuadrático ===")
    print(f"ŷ(x) = {beta0:.4f} + ({beta1:.4f})·x + ({beta2:.4f})·x²")
    for x_val in (0.20, 0.70):
        print(
            f"x={x_val:.2f} ({x_val * 41:.1f} °C): "
            f"dŷ/dx={dy_dx(x_val):.2f}, "
            f"dŷ/d°C={dy_dx(x_val) / 41:.2f}"
        )

    x_critico = -beta1 / (2 * beta2)
    temp_opt_c = x_critico * 41
    rango_min, rango_max = float(x.min()), float(x.max())
    print(
        f"Óptimo x*={x_critico:.4f} (~{temp_opt_c:.2f} °C); "
        f"segunda derivada={2 * beta2:.2f}"
    )
    print(
        f"Rango observado=[{rango_min:.4f}, {rango_max:.4f}] "
        f"(el óptimo {'está' if rango_min <= x_critico <= rango_max else 'no está'} "
        "dentro del rango)."
    )

    sce = np.sum((y - f(x)) ** 2)
    stc = np.sum((y - y.mean()) ** 2)
    print(f"R² del ajuste cuadrático: {1 - sce / stc:.4f}")

    x_grid = np.linspace(rango_min, rango_max, 250)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.scatter(x, y, alpha=0.25, color="steelblue", label="Datos observados")
    ax.plot(x_grid, f(x_grid), color="crimson", lw=2.5, label="Ajuste cuadrático ŷ(x)")
    ax.axvline(
        x_critico,
        color="black",
        linestyle="--",
        label=f"Óptimo x*={x_critico:.2f} ({temp_opt_c:.1f} °C)",
    )
    ax.set_xlabel("Temperatura normalizada (temp)")
    ax.set_ylabel("Cantidad de alquileres (cnt)")
    ax.set_title("A.1: Relación cuadrática entre demanda y temperatura")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output_dir / "a1_modelo_cuadratico.png", dpi=150)
    plt.close(fig)
