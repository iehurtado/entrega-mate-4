# Informe de Matemática IV

## Requisitos

* Python 3
* `uv`: [Installing UV](https://docs.astral.sh/uv/getting-started/installation/)
* `typst`: [Install the Compiler](https://typst.app/open-source#download)

## Compilación

El análisis está dividido en módulos por sección del notebook. Para ejecutarlo
desde la raíz del proyecto:

```bash
uv run python main.py
```

`main.py` carga `data/day.csv` y guarda los resultados en `outputs/`: gráficos
PNG para A.1, A.2, A.3 y B.2, y tablas CSV para B.1, B.2 y B.5. Las dependencias
del proyecto se instalan con `uv sync`.

Luego compilar el informe usando `typst`:

```bash
typst compile informe.typ
```
