from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


def ejecutar(data: pd.DataFrame, output_dir: Path) -> None:
    x = data["temp"].to_numpy()
    y = data["cnt"].to_numpy()
    n = len(x)

    x_bar, y_bar = x.mean(), y.mean()
    sxy = np.sum((x - x_bar) * (y - y_bar))
    sxx = np.sum((x - x_bar) ** 2)
    beta1 = sxy / sxx
    beta0 = y_bar - beta1 * x_bar
    beta1_lib, beta0_lib = np.polyfit(x, y, 1)

    print("\n=== A.2: Ecuaciones normales de regresión simple ===")
    print(f"N={n}; media(temp)={x_bar:.4f}; media(cnt)={y_bar:.4f}")
    print(f"Sxy={sxy:.4f}; Sxx={sxx:.4f}")
    print(f"Fórmula analítica: β̂₁={beta1:.6f}, β̂₀={beta0:.6f}")
    print(f"np.polyfit:        β̂₁={beta1_lib:.6f}, β̂₀={beta0_lib:.6f}")
    if not np.allclose([beta1, beta0], [beta1_lib, beta0_lib], atol=1e-6):
        raise ArithmeticError("Las dos estimaciones de regresión lineal no coinciden")
    print(f"Recta estimada: ŷ = {beta0:.2f} + {beta1:.2f}·x")

    fig, ax = plt.subplots(figsize=(8, 4.8))
    ax.scatter(x, y, alpha=0.25, color="royalblue", label="Observaciones diarias")
    ax.plot(
        x,
        beta0 + beta1 * x,
        color="darkorange",
        lw=2.5,
        label=f"Recta estimada: ŷ = {beta0:.2f} + {beta1:.2f}x",
    )
    ax.set_xlabel("Temperatura normalizada (temp)")
    ax.set_ylabel("Cantidad de alquileres (cnt)")
    ax.set_title("A.2: Regresión lineal simple de cnt sobre temp")
    ax.grid(True, alpha=0.3)
    ax.legend()
    fig.tight_layout()
    fig.savefig(output_dir / "a2_regresion_simple.png", dpi=150)
    plt.close(fig)
