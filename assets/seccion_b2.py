from pathlib import Path

from assets.regresion_simple import RegresionSimple, graficar_modelo, tabular_modelos


def ejecutar(
    modelos: list[RegresionSimple], output_dir: Path
) -> None:
    tabla = tabular_modelos(modelos)
    tabla.to_csv(output_dir / "b2_regresiones_simples.csv")
    print("\n=== B.2: Regresiones lineales simples ===")
    print(tabla.to_string(float_format=lambda valor: f"{valor:.4f}"))

    mejor_modelo = modelos[1]
    print(
        f"Mayor correlación absoluta entre las variables: "
        f"{mejor_modelo.variable} (r={mejor_modelo.r:.4f}, R²={mejor_modelo.r2:.4f})."
    )
    graficar_modelo(
        mejor_modelo,
        nombre_x="atemp",
        nombre_y="cnt",
        destino=str(output_dir / "b2_regresion_atemp.png"),
    )
