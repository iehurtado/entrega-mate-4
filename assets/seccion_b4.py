from assets.regresion_simple import RegresionSimple


def ejecutar(modelo: RegresionSimple, x_estrella: float = 0.65) -> None:
    intervalo_media = modelo.ic_media(x_estrella)
    intervalo_prediccion = modelo.ic_prediccion(x_estrella)

    print("\n=== B.4: Intervalos del 95 % ===")
    print(f"Variable={modelo.variable}; x*={x_estrella:.2f}")
    print(
        f"Respuesta media: [{intervalo_media[0]:.2f}, "
        f"{intervalo_media[1]:.2f}]"
    )
    print(
        f"Predicción individual: [{intervalo_prediccion[0]:.2f}, "
        f"{intervalo_prediccion[1]:.2f}]"
    )
