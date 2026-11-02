from pathlib import Path

import pandas as pd

from assets.regresion_simple import RegresionSimple
from assets.seccion_a1 import ejecutar as ejecutar_a1
from assets.seccion_a2 import ejecutar as ejecutar_a2
from assets.seccion_a3 import ejecutar as ejecutar_a3
from assets.seccion_b1 import ejecutar as ejecutar_b1
from assets.seccion_b2 import ejecutar as ejecutar_b2
from assets.seccion_b3 import ejecutar as ejecutar_b3
from assets.seccion_b4 import ejecutar as ejecutar_b4
from assets.seccion_b5 import ejecutar as ejecutar_b5


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

    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Dataset: {data_path} ({len(data)} observaciones)")
    print(f"Resultados: {output_dir}")

    modelos = [
        RegresionSimple(variable, data[variable].to_numpy(), data["cnt"].to_numpy())
        for variable in ("temp", "atemp", "hum", "windspeed")
    ]

    ejecutar_a1(data, output_dir)
    ejecutar_a2(data, output_dir)
    ejecutar_a3(data, output_dir)
    ejecutar_b1(modelos[0], output_dir)
    ejecutar_b2(modelos, output_dir)
    ejecutar_b3(modelos[1])
    ejecutar_b4(modelos[0])
    ejecutar_b5(data, modelos[1], output_dir)

    print("\nAnálisis finalizado. Los gráficos y tablas están en outputs/.")


if __name__ == "__main__":
    main()
