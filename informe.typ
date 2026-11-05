#let temp_celsius = (x) => calc.round(x * 41, digits: 1)

#let cuadratica = json("outputs/quadratic.json")
#let lineales = json("outputs/linear.json")
#let multiple = json("outputs/multiple.json").at(0)

/**
 * Modelo cuadrático
 **/
#let qtemp = cuadratica.at(0)
#qtemp.insert("f", x => calc.round(qtemp.beta0 + qtemp.beta1 * x + qtemp.beta2 * calc.pow(x, 2), digits: 4))
#qtemp.insert("df", x => calc.round(qtemp.beta1 + 2 * qtemp.beta2 * x, digits: 4))

/**
 * Modelo lineal basado en `temp`
 **/
#let ltemp = lineales.find(x => x.variable == "temp")
#ltemp.insert("f", x => calc.round(ltemp.beta0 + ltemp.beta1 * x, digits: 4))
#ltemp.insert("df", x => ltemp.beta1)

/**
 * Modelo lineal basado en `atemp`
 **/
#let latemp = lineales.find(x => x.variable == "atemp")
#latemp.insert("f", x => calc.round(latemp.beta0 + latemp.beta1 * x, digits: 4))
#latemp.insert("df", x => latemp.beta1)

// ---------------------------------------------------------------------------

#let titulo = "Entrega Matemática IV — 2026"
#set document(title: titulo)
#show math.equation.where(block: true): set block(above: 1.2em, below: 1.8em)

#let azulito = rgb("#0f3d64")
#let blanco = luma(180)
#let celestito = rgb("#f2f5f8")

#show title: set text(fill: azulito)
#show heading: set text(fill: azulito)
#show heading: set block(above: 1.8em)
#show heading.where(level: 1): it => underline(it, offset: 0.15em)

#show table: set align(center)

#set table(
  stroke: (x, y) => if y == 0 { (bottom: 1.5pt + azulito) } else { 0.5pt + blanco },
  fill: (x, y) => {
    if y == 0 { azulito }
    else if calc.even(y) { celestito }
    else { none }
  }
)

#show table.cell.where(y: 0): set text(weight: "bold", fill: white, size: 8pt)

#show link: it => {
  set text(fill: azulito)
  underline(it)
}

// ---------------------------------------------------------------------------

#align(center)[
  #text(size: 1.4em)[
    Facultad de Informática - Universidad de La Plata
  ]

  #block(above: 1.2em, text(size: 1.6em, title(titulo)))

  Conjunto B - Sistema de bicicletas compartidas

  = Integrantes

  #list(marker: "",
    [César Rea (16289/8)],
    [Ignacio Hurtado (15571/3)],
    [Tiago López (21542/5)],
  )
]

#pagebreak()
#set page(footer: auto, numbering: "1")

= Referencia

  Los resultados presentados en este informe se computan utilizando un script. El script está disponible en #link("https://github.com/iehurtado/entrega-mate-4", [GitHub]) (#link("https://github.com/iehurtado/entrega-mate-4/blob/main/main.py", [enlace directo])) y se elaboró en base al #link("https://colab.research.google.com/drive/1ZxXnT_2MpfkWY3jrvXM5Yu-TZNRd4SRs", [notebook de Google Colab]) utilizado para realizar el análisis (puede contener código o valores desactualizados con respecto al script).

#pagebreak()

= Parte A — Complementos de Análisis Matemático

== A.1 Derivación

=== Parte 1 del A.1: Ajuste del Modelo Cuadrático

Ajustamos el modelo cuadrático $hat(y) = β_0 + β_1 x + β_2 x^2$ para estimar la cantidad de alquileres diarios (`cnt`, `y`) en función de la temperatura normalizada (`temp`, `x`). Para ello utilizamos la función `polyfit` de NumPy que plantea y resuelve en forma matricial el sistema de ecuaciones normales, obteniendo la recta de estimación:

$ hat(y) =  #qtemp.beta1 x - #calc.abs(qtemp.beta2) x^2 - #calc.abs(qtemp.beta0) $


=== A.1 — Parte 2: Primera Derivada y Evaluación Numérica

La derivada representa la tasa instantánea de cambio en la demanda ante variaciones infinitesimales de temperatura. En el modelo viene expresada en bicicletas/unidad norm. Para convertirla a unidades del mundo real (bicicletas/°C), aplicamos la regla de la cadena sabiendo que $T = 41 x$:

$ (partial y) / (partial T) = (partial y) / (partial x) * 1/41 $

Derivando la función cuadrática ajustada:

$ (partial y) / (partial x) = β_1 + 2β_2x = #qtemp.beta1 + 2(#qtemp.beta2)x = #qtemp.beta1 - #calc.abs(2*qtemp.beta2)x $

Evaluamos en dos puntos dentro del rango observado $[0.0591; 0.8617]$:


==== Día fresco ($x = 0.2$; ó 8.2 °C):

Evaluamos la derivada con $x = 0.2$, que corresponde a unos 8.2 ºC:

$ (partial y) / (partial x) = #qtemp.beta1 - #calc.abs(2*qtemp.beta2) (0.2) = #{qtemp.df}(0.2) "bicicletas" / "unidad norm." $

Dividiendo por 41:

$ (partial y) / (partial T) = #{qtemp.df}(0.2) / 41 ≈ #calc.round((qtemp.df)(0.2) / 41, digits: 4) "bicicletas/°C" $

Es decir, a 8.2 °C, se espera que los alquileres diarios aumenten en aproximadamente 375 bicicletas por cada grado Celsius que sube la temperatura.


==== Día caluroso ($x = 0.7$; ó 28.7 °C):

Evaluamos la derivada con $x = 0.7$, que corresponde a unos 28.7 ºC:
$ (partial y)/(partial x) = #qtemp.beta1 - #calc.abs(2*qtemp.beta2) (0.7) = #{qtemp.df}(0.7) "bicicletas/unidad norm." $

Dividiendo por 41:
$ (partial y)/(partial T) = #(qtemp.df)(0.7) / 41 approx #calc.round((qtemp.df)(0.7) / 41, digits: 4) "bicicletas/°C" $

De esta manera vemos que a 28.7 °C la tasa cae a solo 8 bicicletas por grado Celsius de incremento.


=== A.1 — Parte 3: Contraste Conceptual entre Modelos

Para el modelo lineal, tenemos que la derivada es la pendiente de la recta:

$ (partial hat(y))/(partial x) = β_1 = #ltemp.beta1 $

Esto quiere decir que la demanda crece en forma constante a medida que aumenta la temperatura; algo que resulta contraituitivo: para el modelo lineal, subir de 8 °C a 9 °C produce el mismo incremento de viajes que subir de 35 °C a 36 °C (+162 bicis/°C, calculado como #ltemp.beta1 / 41\), ignorando el efecto del calor en los ciclistas.

En el modelo cuadrático, en cambio, la derivada es una recta decreciente:

$ (partial hat(y))/(partial x) = beta_1 + 2 beta_2 = #qtemp.beta1 - #calc.abs(2*qtemp.beta2) x $

Esta recta decreciente indica que la demanda aumenta más suavemente a medida que se incrementa la temperatura, hasta darse vuelta por completo cuando la temperatura es demasiado alta. Un modelo como este luce más adecuado: pedalear con un clima templado es agradable y estimula el uso de la bicicleta, pero hacerlo bajo el calor excesivo resulta poco grato, de modo que es esperable que la demanda de bicicletas disminuya a partir de cierto punto.


=== A.1 — Parte 4: Punto Crítico y Clasificación

Igualamos la derivada a 0 para hallar el punto crítico:

$ (partial y)/(partial x) = 0  =>  #qtemp.beta1 - #calc.abs(2*qtemp.beta2)x^* = 0  =>  x^* = #qtemp.beta1 / #{-2*qtemp.beta2} approx #{qtemp.x_critico} $

Es decir, el punto crítico es $T^* = #qtemp.x_critico * 41 °C ≈ #temp_celsius(qtemp.x_critico) °C$. Como las temperaturas del dataset oscilan entre $x \= 0.0591$ (2.4 °C) y $x \= 0.8617$ (35.3 °C), se comprueba que:

$ 0.0591 <= #qtemp.x_critico <= 0.8617 $

Ahora queremos saber si se trata de un máximo. Para ello calculamos la derivada segunda:

$ (partial^2 y) / (partial^2 x) = 2β_2 = 2(#qtemp.beta2) = #{2*qtemp.beta2} $

Vemos que es negativa, lo que indica que la función es cóncava. Luego, el punto crítico hallado es un máximo global.

Respecto al punto hallado, observamos que se trata de una temperatura alta, de alrededor de #temp_celsius(qtemp.x_critico) °C y esto explica adecuadamente por qué se alcanza el máximo de demanda en este punto. Intuitivamente, es esperable que a partir de este punto la demanda decaiga debido al calor. Esta es una diferencia clave con respecto al modelo lineal, que supone que la demanda seguirá creciendo, pues al tratarse de una recta no posee máximos ni mínimos más allá de los impuestos por el rango de los datos.

== A.2 Derivadas parciales y ecuaciones normales

=== Parte 1 del A.2: Planteo de la Función de Desviaciones y Cálculo Manual de Derivadas Parciales

Desarrollamos a continuación las derivadas parciales de la suma de cuadrados de error

$ f(b_0, b_1) = sum_(i=1)^n [y_i - (b_0 + b_1x_i)]^2 = sum_(i=1)^n [y_i - b_0 - b_1x_i]^2 $

==== Derivada parcial con respecto a $b_0$

Comenzamos derivando el cuadrado, por regla de la cadena:

$ (partial f)/(partial b_0) &= sum_(i=1)^n 2(y_i - b_0 - b_1x_i) dot (partial f) /(partial b_0)(y_i - b_0 - b_1x_i) $

Como los términos $y_i$ y $b_1x_i$ son constantes con respecto a $b_0$, nos queda que:

$ (partial f) /(partial b_0)(y_i - b_0 - b_1x_i) = -1 => (partial f)/(partial b_0) &= sum_(i=1)^n 2(y_i - b_0 - b_1x_i) dot (-1) $

Y por último, sacamos los factores constantes y nos queda:

$ (partial f)/(partial b_0) = -2 sum_(i=1)^n (y_i - b_0 - b_1x_i) $

==== Derivada parcial con respecto a $b_1$:

Nuevamente, comenzamos derivando el cuadrado:

$ (partial f)/(partial b_1) &= sum_(i=1)^n 2 (y_i - b_0 - b_1x_i) dot (partial f) /(partial b_1)(y_i - b_0 - b_1x_i) $

Aquí $y_i$ y $b_0$ son constantes con respecto a $b_1$, de modo que:

$ (partial f) /(partial b_1)(y_i - b_0 - b_1x_i) = -x_i => (partial f)/(partial b_1) &= sum_(i=1)^n 2(y_i - b_0 - b_1x_i) dot (-x_i) $

Luego nos queda:

$ (partial f)/(partial b_1) = -2 sum_(i=1)^n x_i (y_i - b_0 - b_1x_i) $


=== Parte 2 del A.2: Deducción del Sistema de Ecuaciones Normales

1. Comenzamos igualando las derivadas a 0 para encontrar sus puntos críticos:

$
-2 sum_(i=1)^n (y_i - b_0 - b_1x_i) &= 0 \
-2 sum_(i=1)^n x_i (y_i - b_0 - b_1x_i) &= 0
$

2. Dividimos por $-2$ ambos lados en cada expresión y distribuimos sumatorias:

$
sum_(i=1)^n (y_i - b_0 - b_1x_i) &= 0 \
sum_(i=1)^n x_i (y_i - b_0 - b_1x_i) &= 0
$

3. Distribuimos las sumatorias:

$
sum_(i=1)^n (y_i - b_0 - b_1x_i) = 0  &=>  sum_(i=1)^n y_i - sum_(i=1)^n b_0 - b_1 sum_(i=1)^n x_i = 0 \
sum_(i=1)^n x_i (y_i - b_0 - b_1 x_i) = 0  &=>  sum_(i=1)^n x_i y_i - b_0 sum_(i=1)^n x_i - b_1 sum_(i=1)^n x_i^2 = 0
$

4. Reordenamos:

$
n b_0 + b_1 sum_(i=1)^n x_i &= sum_(i=1)^n y_i  &" (Ecuación 1)" \
b_0 sum_(i=1)^n x_i + b_1 sum_(i=1)^n x_i^2 &= sum_(i=1)^n x_i y_i    &" (Ecuación 2)"
$

=== Parte 3 del A.2: Resolución Algebraica y Deducción de $β_1$ y $β_0$

Resolver algebraicamente el sistema de ecuaciones normales hasta llegar a las expresiones de mínimos cuadrados: $β_1 \= S_"xy" / S_"xx"$ y $β_0 \= macron(y) - β_1 macron(x)$.

Se resuelve el sistema lineal de 2$times$2 por el método de sustitución:

1. De la (Ecuación 1) despejamos $b_0$ dividiendo por $n$:

$ b_0 = (sum y_i) / n - b_1 (sum x_i) / n  =>  b_0 = macron(y) - b_1 macron(x) $

2. Sustituimos esta expresión en la (Ecuación 2):

$
  (macron(y) - b_1 macron(x)) & sum x_i + b_1 sum x_i^2 = sum x_i y_i \
    &=> macron(y) sum x_i - b_1 macron(x) sum x_i + b_1 sum x_i^2 = sum x_i y_i \
    &=> b_1 sum x_i^2 - b_1 macron(x) sum x_i = sum x_i y_i - macron(y) sum x_i
$

3. Recordando que $sum x_i \= n macron(x)$, se cumple que $macron(y) sum x_i \= n macron(x) macron(y) \= (sum x_i) (sum y_i) / n$, y que $macron(x) sum x_i \= n macron(x)^2 \= (sum x_i)^2 / n$. Agrupando los términos con factor común $b_1$:

$
b_1 [sum_(i=1)^n x_i^2 - n macron(x)^2] &= sum_(i=1)^n x_i y_i - n macron(x) macron(y) \
b_1 [sum_(i=1)^n x_i^2 - (sum x_i)^2 / n] &= sum_(i=1)^n x_i y_i - (sum x_i sum y_i) / n
$

4. Utilizando las definiciones de sumas de cuadrados y productos cruzados centrados:

$
S_"xx" &= sum_(i=1)^n x_i^2 - (sum x_i)^2 / n = sum_(i=1)^n (x_i - macron(x))^2 \
S_"xy" &= sum_(i=1)^n x_i y_i - (sum x_i sum y_i) / n = sum_(i=1)^n (x_i - macron(x)) (y_i - macron(y))
$

Despejando finalmente los estimadores:

$
β_1 &= S_"xy" / S_"xx" \
β_0 &= macron(y) - β_1 macron(x) $


=== Parte 4 del A.2: Cálculo Numérico, Contrastación y Recta Obtenida

Evaluando las sumatorias sobre las $n \= 731$ observaciones de `temp` ($x$) y `cnt` ($y$) se obtienen los valores escalares:

==== Medias muestrales

  - $macron(x) \= #ltemp.xmean$
  - $macron(y) \= #ltemp.ymean$

==== Sumas de Variabilidad

  - $S_"xx" \= #ltemp.sxx$
  - $S_"xy" \= #ltemp.sxy$

==== Coeficientes analíticos

- $β_1 = S_(x y) / S_(x x) = #ltemp.sxy / #ltemp.sxx approx #ltemp.beta1$
- $β_0 = macron(y) - beta_1 macron(x) = #ltemp.ymean - #ltemp.beta1 * #ltemp.xmean approx #ltemp.beta0$

==== Ajuste por librería (`np.polyfit(x, y, 1)`):

- $β_"1,lib" = #ltemp.beta1_lib$
- $β_"0,lib" = #ltemp.beta0_lib$

Como se ve, la discrepancia numérica es nula. #footnote[
  Se aplica redondeo a 4 dígitos. Los valores _reales_ obtenidos en Python fueron: $beta_1 = beta_"1,lib" = 6640.709999$ y $beta_0 = beta_"0,lib" = 1214.642119$
]

La recta obtenida es:

$ y = #ltemp.beta0 + #ltemp.beta1 x $

- $β_0 = #ltemp.beta0$: Alquiler esperado base cuando la variable normalizada de temperatura es cero (0 °C de referencia; fuera del rango observado).
- $β_1 = #ltemp.beta1$ \> 0: Pendiente de la recta que indica que, según la aproximación lineal global, por cada unidad de incremento en la escala normalizada de temperatura, la demanda total estimada se incrementa en aproximadamente 6641 alquileres diarios (o unos 162 alquileres por cada grado Celsius real al dividir por 41).

== A.3 Descenso del gradiente

=== Parte 1 del A.3: Modelo Multivariable y Justificación de la Dirección Opuesta al Gradiente

Estimar la ecuación de regresión múltiple de la sección B.5 para predecir la demanda de alquileres `cnt` ($y$) a partir de las cuatro variables climáticas: `temp` ($x_1$), `atemp` ($x_2$), `hum` ($x_3$) y `windspeed` ($x_4$):

$ y = b_0 + b_1 x_1 + b_2 x_2 + b_3 x_3 + b_4 x_4 = x^T b $

La suma de los errores al cuadrado define la función de costo en varias variables:

$ f(b) = sum_(i=1)^n [y_i - x_i^T * b]^2 = ||y - X b||^2 $

donde cada fila $x_i^T \= \[1, x_(i 1), x_(i 2), x_(i 3), x_(i 4)\]$ incorpora un 1 para el término independiente $b_0$. El vector gradiente $nabla f(b)$ apunta por definición geométrica en la dirección de máximo crecimiento local de la función con respecto al vector de pesos $b$. Dado que el objetivo es hallar el mínimo de error, desplazarse en sentido opuesto ($-nabla f(b)$) garantiza la mayor tasa de decrecimiento de la función, guiando los parámetros iterativamente hacia el valor óptimo según la regla:

$ b^(k+1) = b^(k) - alpha * nabla f(b^(k)) $

Al derivar analíticamente respecto a cada parámetro $b_j$ se obtiene el gradiente matricial compacto:

$ nabla f(b) = -2 X^T (y - X b) $

=== Parte 2 del A.3: Comportamiento según la Tasa de Aprendizaje ($alpha$)

Ejecutar el algoritmo con tres tasas de aprendizaje: una demasiado pequeña, una adecuada y una que provoque divergencia; graficar la función de pérdida $f$ en función del número de iteración en un mismo par de ejes y explicar qué ocurre en cada caso. El tamaño de paso $alpha$ modula la magnitud del desplazamiento en cada iteración. Al evaluar su desempeño en el dataset se distinguen tres dinámicas:

#image("outputs/a3_descenso_gradiente.png")

==== 1. Tasa demasiado pequeña ($alpha = 0.0001$ \- Curva Azul)

El paso vectorial es diminuto. La función de pérdida desciende de forma regular pero extremadamente lenta, requiriendo miles de pasos para aproximarse al valle del mínimo y quedando lejos de la solución óptima en pocas iteraciones.

==== 2. Tasa adecuada ($alpha = 0.5$ \- Curva Verde)

El paso se encuentra balanceado con la curvatura de la superficie cuadrática. La pérdida se reduce de manera pronunciada y estable en las primeras iteraciones hasta estabilizarse suavemente en el mínimo sin oscilaciones erráticas.

==== 3. Tasa excesiva / divergente ($alpha = 0.6$ \- Línea Discontinua Roja)

El paso es mayor al radio de estabilidad del gradiente, lo que hace que la actualización sobrepase el fondo del valle y caiga en una pared opuesta más alta. Esto genera oscilaciones explosivas que incrementan la pérdida exponencialmente ($10^10$) en las primeras iteraciones hasta provocar desbordamiento numérico (overflow).


=== Parte 3 del A.3: Criterios de Detención

Indicar el criterio de detención utilizado para finalizar la ejecución iterativa del descenso del gradiente. Siguiendo las pautas de los métodos numéricos de optimización de la cátedra, el algoritmo evalúa dos condiciones de corte concurrentes:

==== 1. Condición de tolerancia de mejora:

$ |f(b^(k+1)) - f(b^(k))| < epsilon $

Cuando la diferencia absoluta en el valor de la función de costo entre dos pasos sucesivos es menor a un umbral prefijado (ej. $epsilon = 10^(-2)$ o menor), se concluye que la actualización de parámetros es despreciable y el algoritmo se encuentra en la planicie del mínimo estacionario.

==== 2. Límite de iteraciones máximas (`max_iters = 10000`)

Funciona como salvaguarda algorítmica para interrumpir el bucle en caso de convergencia excesivamente lenta o para detener de forma segura la ejecución cuando una tasa sobredimensionada genera divergencia y valores no numéricos (`NaN` o infinitos).


=== Parte 4 del A.3: Comparación con Mínimos Cuadrados (MCO de B.5) y Modelo Final

#let coeficientes = json("outputs/coeficientes.json")

#let grad = coeficientes.map(row => row.gradiente)
#let mco = coeficientes.map(row => row.matricial)
#let diff = coeficientes.map(row => row.diferencia)

Al contrastar los coeficientes del descenso del gradiente (con $alpha = 0.1$) contra la solución matricial exacta sobre las 731 observaciones de cnt con las cuatro variables climáticas, se obtienen los siguientes valores:

#show table.cell.where(x: 0): set align(left)

#table(
  columns: 4, align: right,
  [*Variable*],                                [*Gradiente*], [*MCO Exacto*], [*Diferencia*],
  [Ordenada al origen ($β_0$)],                [#grad.at(0)],  [#mco.at(0)],  [#diff.at(0)],
  [Temperatura (`temp`, $β_1$)],               [#grad.at(1)],  [#mco.at(1)],  [#diff.at(1)],
  [Sensación térmica (`atemp`, $β_2$)],        [#grad.at(2)],  [#mco.at(2)],  [#diff.at(2)],
  [Humedad (`hum`, $β_3$)],                    [#grad.at(3)],  [#mco.at(3)],  [#diff.at(3)],
  [Velocidad del viento (`windspeed`, $β_4$)], [#grad.at(4)],  [#mco.at(4)],  [#diff.at(4)],
)

A partir de esta comparación podemos observar:

1. Coincidencia en la correlación de variables: Ambos métodos coinciden plenamente en la estructura: la temperatura y la sensación térmica poseen coeficientes positivos ($β > 0$); mientras que la humedad y la velocidad del viento poseen coeficientes negativos ($β < 0$).

2. Explicación de la diferencia numérica: La discrepancia observada entre el gradiente y el MCO exacto se debe a que el algoritmo corta al alcanzar diferencias menores a la tolerancia configurada (0.01), luego de 8408 iteraciones. Al tratarse de un método iterativo, conforme aumenta el número de iteraciones los coeficientes convergen asintóticamente a la solución matricial exacta de mínimos cuadrados.

= Parte B - Complementos de Estadística

== B.1 - Varianza

La estimación $sigma^2$ de la varianza para el modelo de regresión lineal simple sobre `temp` la obtenemos a partir de la suma de cuadrados de error:

$
sigma^2 &= "SCE"/(n - 2) = (sum_(i=1)^n (y_i - hat(y)_i)^2) / (n - 2) = #ltemp.sce / #{ltemp.n - 2} = #ltemp.sigma2
$

Exponemos la descomposición de la variabilidad en la siguiente tabla:

#let anova = csv("outputs/b1_tabla_anova.csv")

#table(
  align: right,
  columns: 6,
  table.header(..anova.first().map(cell => [*#cell*])),
  ..anova.slice(1).flatten(),
)

A continuación calculamos el coeficiente de determinación, a partir de las sumas de cuadrados de error y total:

$
R^2 = 1 - "SCE" / "STC" = 1 - #ltemp.sce / #ltemp.stc = #ltemp.r2 approx #{calc.round(ltemp.r2 * 100, digits: 2)} %
$

Este coeficiente indica qué proporción de la variabilidad se "explica" por el modelo de regresión. Esto es, en qué medida el uso de una recta de regresión para hacer las predicciones disminuye el error frente al uso de la media muestral como predicción para la variable dependiente. Es importante destacar que un valor alto de R² no significa que exista una relación causal entre las variables, ni que el modelo sea adecuado para realizar predicciones sobre nuevos datos.


== B.2 - Regresión Lineal Simple

#let interval = (inf, sup) => [\[#inf ; #sup\]]

Realizamos un análisis de regresión lineal simple entre `cnt` y diferentes variables. Presentamos la comparación en las siguientes tablas:

// #text(size: 8pt)[
  #table(
    columns: 5,
    align: right,
    table.header(
      [],
      [$hat(beta)_1$],
      [$hat(beta)_0$],
      [$"IC"(beta_1)$],
      [$"IC"(beta_0)$],
    ),
    ..lineales
      .map(row => (
        row.variable, row.beta1, row.beta0,
        interval(row.icb1_inf, row.icb1_sup),
        interval(row.icb0_inf, row.icb0_sup)
      ))
      .flatten()
      .map(cell => [#cell]),
  )
// ]

// #text(size: 8pt)[
  #table(
    columns: 6,
    align: right,
    table.header(
      [],
      [$hat(sigma)^2$],
      [$R^2$],
      [$R$],
      [$"ICM"(Y|x^*=0.65)$],
      [$"IP"(Y|x^*=0.65)$],
    ),
    ..lineales
      .map(row => (
        row.variable,
        row.sigma2,
        row.r2,
        row.r,
        interval(row.icm_inf, row.icm_sup),
        interval(row.ip_inf, row.ip_sup),
      ))
      .flatten()
      .map(cell => [#cell]),
  )
// ]

Observando la tabla encontramos que la regresión sobre la variable `atemp` muestra el mejor valor para $R^2$. Tomamos esto como un indicio de que esta regresión explica mejor la variabilidad de la muestra. Además, la utilización de la sensación térmica como predictor parecería tener más relación con el problema presentado.

A continuación presentamos el gráfico de dispersión, junto con la recta de regresión del modelo:
#image("outputs/b2_regresion_atemp.png")


== B.3 - Test de Hipótesis

#let hipotesis = json("outputs/hipotesis.json").at(0)
#let t_critico = hipotesis.critico
#let T = hipotesis.estadistico

Se quiere verificar si la variable elegida tiene relación lineal con la cantidad de alquileres.

Se plantean hipótesis nula y alternativa:

$
H_0: beta_1 = 0 q "vs" q H_1: beta_1 != 0
$

Es decir, en caso de aceptación para $H_0$, implica que `atemp` no tiene relación lineal.

El estadístico de prueba es:

$
T = frac(hat(beta)_1 - 0, sqrt(frac(hat(sigma)^2, S_(x x))))
$

El valor crítico $t(alpha/2, n-2)$ para $alpha=0.05$ según la tabla es: $#t_critico$

Siguiendo la regla de decisión planteada:

$
  "Rechazar" space H_0 space "si" space |T| > t(alpha/2, n-2)
$

vemos como es $abs(T)$ respecto al valor crítico obtenido:

$
  abs(T) = abs(hat(beta)_1 / sqrt(hat(sigma)^2 / S_(x x)))
    = abs(#latemp.beta1 / sqrt(#latemp.sigma2 / #latemp.sxx))
    approx #T > #t_critico = t(alpha/2, n-2)
$

Al rechazar $H_0$ estamos diciendo que la pendiente no es nula; esto quiere decir que existe algún grado de relación lineal entre la sensación térmica observada (`atemp`) y la cantidad bicicletas alquiladas (`cnt`).


== B.4 - Intervalos para la respuesta media y predicción

#let y_media = (ltemp.f)(0.65)

Para el modelo de regresión lineal simple con la variable `temp`, se desea cuantificar la incertidumbre en la estimación de la demanda esperada cuando la temperatura normalizada toma el valor fijo $x^* = 0.65$.

El valor puntual estimado de la respuesta media es:

$
  hat(y) = hat(beta)_0 + hat(beta)_1 x^* = #ltemp.beta0 + #ltemp.beta1 times 0.65 = #y_media
$

=== Intervalo de confianza para la respuesta media

La respuesta media tiene un intervalo de confianza al 95 % dado por:

$
  hat(y)(x^*) plus.minus t_(alpha/2, n - 2) sqrt(hat(sigma)^2 (1 / n + ((x^* - macron(x))^2) / S_(x x)))
$

Con $n = 731$, $alpha = 0.05$ y $x^* = 0.65$ se obtiene:

$
  "IC"(E(Y | x^*)) = [#ltemp.icm_inf \; #ltemp.icm_sup]
$

Es decir, para una temperatura normalizada de 0.65, la cantidad esperada de alquileres se encuentra, con un 95 % de probabilidad, entre #ltemp.icm_inf y #ltemp.icm_sup bicicletas.

=== Intervalo de predicción para valores futuros

Además, si se quiere predecir un valor individual futuro de $Y$ para el mismo nivel de temperatura, se utiliza el intervalo de predicción:

$
  hat(y)(x^*) plus.minus t_(alpha/2, n - 2) sqrt(hat(sigma)^2 (1 + 1 / n + ((x^* - macron(x))^2) / S_(x x)))
$

Con la misma elección de $x^*$, resulta:

$
  "IP"(Y | x^*) = [#ltemp.ip_inf \; #ltemp.ip_sup]
$

Este intervalo es más ancho que el anterior, porque incorpora no solo la incertidumbre en la media esperada, sino también la variabilidad aleatoria propia de una observación individual. En consecuencia, para una temperatura de 0.65 la predicción puntual de alquileres es de #y_media bicicletas, pero un valor futuro individual podría caer entre #ltemp.ip_inf y #ltemp.ip_sup en aproximadamente el 95 % de los casos.

== B.5 - Regresión Lineal Múltiple

Se estimó por mínimos cuadrados el modelo de regresión múltiple para `cnt` sobre las variables `temp`, `atemp`, `hum` y `windspeed`. Presentamos los coeficientes obtenidos luego de resolver el sistema de ecuaciones en forma matricial con numpy:

#let betas = ( multiple.beta0, multiple.beta1, multiple.beta2, multiple.beta3, multiple.beta4 )

#for (i, bi) in betas.enumerate() {
  [- $beta_(#i) = #bi$]
}

De esta manera, el modelo nos queda:

#let sign(x) = if x < 0 [ $-$ ] else [ $+$ ]

$
  hat(y) = #betas.at(0)
    #for (i, bb) in betas.slice(1).enumerate(start: 1) {
      $&#sign(bb) #calc.abs(bb) dot x_(#i) $
      // if i == 2 { $\ $ }
    }
$

Calculamos la variabilidad y coeficientes de determinación del modelo:


$
  "SS"_r &= "SCE" = sum (y_i - hat(y)_i)^2 = #multiple.ssr \
  sigma^2 &= "SS"_r / (n-k-1) = #multiple.ssr / (#multiple.n - #multiple.k - 1) = #{multiple.sigma2} \
  R^2 &= 1 - "SCE" / "STC" = 1 - #multiple.ssr / #multiple.stc = #multiple.r2 \
  R^2_"adj" &= 1 - (1 - R^2) (n-k) / (n-k-1) = 1 - (1 - #multiple.r2) (#multiple.n - #multiple.k) / (#multiple.n - #multiple.k - 1) = #multiple.r2_adj
$

Vemos que el valor ajustado de $R^2$ ronda el 46.3%. Si comparamos este valor con el $R^2$ obtenido para el modelo lineal de B.2, vemos que aquél es menor. Esto sugiere que el modelo múltiple se ajusta mejor.



#pagebreak()

#set page(flipped: true, margin: 0.8cm)

= Anexo I — Bitácora de uso de inteligencia artificial

Obligatoria. Una fila por interacción; agregar tantas como sea necesario.

#let bitacora = csv("anexo_ia.csv", row-type: dictionary).sorted(key: x => x.Fecha)


#set text(size: 7pt)

#let cols = (
  "Fecha",
  "Herramienta",
  "Qué se le pidió",
  "Resumen de la respuesta",
  "¿Se aceptó?",
  "Cambios realizados y motivo",
  "Ítem afectado",
)

#table(
  columns: (0.9fr, 1.1fr, 1.8fr, 2.1fr, 0.9fr, 2fr, 0.9fr),
  align: (col, row) => {
    if row == 0 { center + horizon }
    else if col == 0 { center + horizon }
    else if col == 5 { center + horizon }
    else { left + horizon }
  },
  table.header(..cols.map(name => [*#name*])),
  ..bitacora.map(row => cols.map(col => [#row.at(col)])).flatten(),
)
