#title([ Informe Trabajo Práctico Mate 4 ])

= Parte A — Complementos de Análisis Matemático

== A.1 Derivación

=== Parte 1 del A.1: Ajuste del Modelo Cuadrático

#let temp_celsius = (norm) => calc.round(norm * 41, digits: 1)

/**
 * Modelo cuadrático
 **/
#let q = (
  beta0: -1901.9557,
  beta1: 21406.9313,
  beta2: -15055.0254,
)

#q.insert("f", x => q.beta0 + q.beta1 * x + q.beta2 * calc.pow(x, 2))
#q.insert("df", x => q.beta1 + 2 * q.beta2 * x)
#q.insert("max", q.beta1/(-2*q.beta2)) // <- punto crítico de la df

/**
 * Modelo lineal basado en `temp`
 **/
#let ltemp = (
  beta0: 1214.642119,
  beta1: 6640.709999,
  xmean: 0.4954,
  ymean: 4504.3488,
  sxx: 24.4606,
  sxy: 162435.7313,
  scr: 1078688585.1695404,
  sce: 1660846806.8769715,
  n: 731
)

#ltemp.insert("f", x => ltemp.beta0 + ltemp.beta1 * x)
#ltemp.insert("df", x => ltemp.beta1)
#ltemp.insert("stc", ltemp.scr + ltemp.sce)

Ajustar un modelo cuadrático para estimar la cantidad de alquileres diarios (`cnt`, `y`) en función de la temperatura normalizada (`temp`, `x`):

$ hat(y) = β_0 + β_1 x + β_2 x^2 $

La recta de regresión lineal simple asume que por cada grado de aumento en la temperatura, la demanda sube en una proporción fija e indefinida. En el uso urbano de bicicletas esto no describe el comportamiento real: pedalear con un clima templado es agradable y estimula el uso, pero hacerlo bajo una ola de calor excesivo genera agotamiento y desincentiva los viajes. Formulamos un polinomio de segundo grado porque su término de curvatura ($β_2$) modela rendimientos decrecientes y permite la existencia de un valor óptimo. Ajustando por mínimos cuadrados sobre el dataset (np.polyfit(temp, cnt, 2)), se obtienen los coeficientes muestrales: $β_0 = #q.beta0$, $β_1 = #q.beta1$, $β_2 = #q.beta2$

Dando la ecuación estimada:

$ hat(y) = #q.beta0 + #q.beta1 x + (#q.beta2) x^2 $

$β_0 = #q.beta0$: Ordenada al origen teórica (demanda cuando x=0, es decir a 0 °C de referencia). Al ser negativa, indica que a temperaturas de congelación el modelo analítico predice nula actividad ciclista.

$β_1 = #q.beta1 > 0$: Coeficiente lineal positivo que refleja el fuerte impulso inicial que produce el aumento térmico en los días frescos.

$β_2 = #q.beta2 < 0$: Coeficiente cuadrático negativo que le confiere a la curva su concavidad hacia abajo, modelando el freno y posterior descenso en el alquiler ante temperaturas elevadas.


=== A.1 — Parte 2: Primera Derivada y Evaluación Numérica

Calcular analíticamente $partial hat(y) slash partial x$, evaluarla en dos valores de $x$ que cubran el rango observado e interpretar el resultado en las unidades físicas del problema.

La derivada representa la tasa instantánea de cambio en la demanda ante variaciones infinitesimales de temperatura. En el modelo viene expresada en bicicletas/unidad norm. Para convertirla a unidades del mundo real (bicicletas/°C), aplicamos la regla de la cadena sabiendo que $T = 41 x$:

$ (partial y) / (partial T) = (partial y) / (partial x) * 1/41 $

Derivando la función cuadrática ajustada:

$ (partial y) / (partial x) = β_1 + 2β_2x = #q.beta1 + 2(#q.beta2)x = #q.beta1 + (#{2*q.beta2})x $

Evaluamos en dos puntos dentro del rango observado $[0.0591; 0.8617]$:

1. *Día fresco* ($x = 0.20$; ó 8.2 °C):

$ (partial y) / (partial x) = #q.beta1 + (#{2*q.beta2}) (0.2) = #{q.df}(0.2) "bicicletas" / "unidad norm." $

Dividiendo por 41:

$ (partial y) / (partial T) = #{q.df}(0.2) / 41 ≈ #{q.df}(0.2) / 41} "bicicletas/°C" $

Es decir, a 8.2 °C, se espera que los alquileres diarios aumenten en aproximadamente 375 bicicletas por cada grado Celsius que sube la temperatura.

2. *Día caluroso* ($x = 0.70$; ó 28.7 °C):

$ (partial y)/(partial x) = #q.beta1 + (#{2*q.beta2}) (0.7) = #{q.df}(0.7) "bicicletas/unidad norm." $

Dividiendo por 41:

$ (partial y)/(partial T) = #(q.df)(0.7) / 41 approx #{(q.df)(0.7) / 41} "bicicletas/°C" $

De esta manera vemos que, a 28.7 °C, la tasa cae a solo 8 bicicletas por grado Celsius.


=== A.1 — Parte 3: Contraste Conceptual entre Modelos

Comparar con la derivada del modelo lineal ($y = β_0 + β_1 x$) y explicar qué supone cada uno sobre el fenómeno.

Contrastamos analíticamente el comportamiento de ambas derivadas:

- Recta: $(partial hat(y))/(partial x) = β_1 = #ltemp.beta1$ (constante en todo el dominio).
- Parábola: $(partial hat(y))/(partial x) = #q.beta1 + (#{2*q.beta2}) x$ (función lineal decreciente de $x$).

El modelo lineal asume un efecto monotónico e infinito: postula que subir de 8 °C a 9 °C produce el mismo incremento de viajes que subir de 35 °C a 36 °C (+162 bicis/°C, calculado como #ltemp.beta1 / 41\), ignorando la fatiga por calor. El modelo cuadrático incorpora rendimientos decrecientes y confort térmico: el beneficio del calor se agota conforme sube la temperatura, hasta volverse perjudicial superado cierto umbral.


=== A.1 — Parte 4: Punto Crítico y Clasificación

Hallar el punto crítico resolviendo $(partial y)/(partial x) \= 0$, clasificarlo con la derivada segunda y verificar si cae dentro de las temperaturas reales registradas, interpretando el resultado en el contexto del negocio.

1. Cálculo del punto crítico: Buscamos la condición de primer orden:

$ (partial y)/(partial x) = 0  =>  #q.beta1 - (#{2*q.beta2})x^* = 0  =>  x^* = #q.beta1 / #{-2*q.beta2} approx #{q.max} $

2. Clasificación con la derivada segunda:

$ (partial^2 y) / (partial^2 x) = 2β_2 = 2(#q.beta2) = #{2*q.beta2} < 0 $

Al ser estrictamente negativa para todo x, se confirma que $x^*$ corresponde a un máximo absoluto de demanda esperada.s

3. Verificación e interpretación en el dominio: Pasando a grados Celsius:

$ T^* = #q.max * 41 °C ≈ #temp_celsius(q.max) °C $

Como las temperaturas del dataset oscilan entre $x \= 0.0591$ (2.4 °C) y $x \= 0.8617$ (35.3 °C), se comprueba que:

$ 0.0591 <= #q.max <= 0.8617 $

El punto crítico cae dentro del rango efectivamente observado. Interpretación operativa: Alrededor de los #temp_celsius(q.max) °C se alcanza la temperatura de confort óptimo del sistema; en esos días la empresa debe prever el despliegue máximo de bicicletas disponibles en las estaciones para atender el pico de demanda.

Conclusión de A.1: A diferencia del modelo lineal (que asume un crecimiento infinito e irreal de la demanda a tasa constante), el modelo cuadrático captura la existencia de rendimientos decrecientes y un óptimo térmico. Dado que el punto crítico (T\* ≈ #temp_celsius(q.max) °C) pertenece al rango térmico registrado, se confirma que el límite de saturación de la demanda no constituye una extrapolación matemática, sino un fenómeno real del servicio en el período analizado.


== A.2 Derivadas parciales y ecuaciones normales

=== Parte 1 del A.2: Planteo de la Función de Desviaciones y Cálculo Manual de Derivadas Parciales

Para la regresión lineal simple de cnt sobre temp, la suma de los cuadrados de las desviaciones verticales es una función de dos variables, los parámetros de la recta:

$ f(b_0, b_1) = sum_(i=1)^n [y_i - (b_0 + b_1x_i)]^2 $

Cada punto observado $(x_i, y_i)$ presenta un residuo vertical respecto a la recta tentativa: $e_i = y_i - (b_0 + b_1 x_i)$. Para evitar que las diferencias positivas y negativas se cancelen mutuamente y para penalizar con mayor peso las desviaciones grandes, se define la función objetivo sumando los residuos al cuadrado (criterio de mínimos cuadrados). Geométricamente, $f(b_0, b_1)$ es una superficie convexa (un paraboloide) con un único mínimo global. Por cálculo en varias variables, para hallar el punto donde se minimiza la suma de errores, el vector gradiente debe anularse $(nabla f \= 0)$, lo que exige calcular analíticamente las derivadas parciales con respecto a $b_0$ y $b_1$ aplicando la regla de la cadena $\[u^2\]' \= 2*u*u'$:

Respecto a $b_0$:

$ (partial f)/(partial b_0) &= sum_(i=1)^n 2*(y_i - b_0 - b_1x_i) * (partial f) /(partial b_0)(y_i - b_0 - b_1x_i) \
  &= sum_(i=1)^n 2(y_i - b_0 - b_1x_i) * (-1) \
  &= -2 sum_(i=1)^n (y_i - b_0 - b_1x_i) $

Respecto a $b_1$:

$ (partial f)/(partial b_1) &= sum_(i=1)^n 2*(y_i - b_0 - b_1x_i) * (partial f) /(partial b_1)(y_i - b_0 - b_1x_i) \
  &= sum_(i=1)^n 2*(y_i - b_0 - b_1x_i) (-x_i) \
  &= -2 sum_(i=1)^n x_i (y_i - b_0 - b_1x_i) $


=== Parte 2 del A.2: Deducción del Sistema de Ecuaciones Normales

Igualar ambas derivadas parciales a cero y armar el sistema algebraico conocido como Ecuaciones Normales.

Al imponer la condición de punto estacionario ($(partial f)/(partial b_0) = 0$ y $(partial f)/(partial b_1) = 0$), se divide por \-2 y se distribuye el operador de sumatoria:

Para la primera derivada:

$ sum_(i=1)^n (y_i - b_0 - b_1x_i) = 0  =>  sum_(i=1)^n y_i - sum_(i=1)^n b_0 - b_1 sum_(i=1)^n x_i = 0 $

Como sumar una constante $b_0$ un total de n veces equivale a $n b_0$, reordenamos:

$ n b_0 + b_1 sum_(i=1)^n x_i = sum_(i=1)^n y_i  &  "--- (Ecuación 1)" $

Sentido geométrico: Esta condición equivale a que la suma total de los residuos sea cero ($sum_(i=1)^n e_i \= 0$), lo que obliga a la recta ajustada a atravesar siempre el centro de masa de la nube de datos $(macron(x), macron(y))$.

Para la segunda derivada:

$ sum_(i=1)^n x_i (y_i - b_0 - b_1 x_i) = 0  =>  sum_(i=1)^n x_i y_i - b_0 sum_(i=1)^n x_i - b_1 sum_(i=1)^n x_i^2 = 0 $

Reordenando:

$ b_0 sum_(i=1)^n x_i + b_1 sum_(i=1)^n x_i^2 = sum_(i=1)^n x_i y_i    "--- (Ecuación 2)" $

Sentido estadístico: Esta condición asegura que los residuos resultantes no presenten correlación lineal con la variable predictora x.


=== Parte 3 del A.2: Resolución Algebraica y Deducción de $β_1$ y $β_0$

Resolver algebraicamente el sistema de ecuaciones normales hasta llegar a las expresiones de mínimos cuadrados: $β_1 \= S_"xy" / S_"xx"$ y $β_0 \= macron(y) - β_1 macron(x)$.

Se resuelve el sistema lineal de 2x2 por el método de sustitución:

1. De la (Ecuación 1) despejamos $b_0$ dividiendo por $n$:

$ b_0 = (sum y_i / n) - b_1 (sum x_i / n)  =>  β_0 = macron(y) - β_1 macron(x) $

2. Sustituimos esta expresión en la (Ecuación 2):

$ (macron(y) - b_1 macron(x)) sum x_i + b_1 sum x_i^2 = sum x_i y_i $

$ macron(y) sum x_i - b_1 macron(x) sum x_i + b_1 sum x_i^2 = sum x_i y_i $

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

Calcular $β_0$ y $β_1$ con esas fórmulas sobre los datos del dataset, contrastar que coincidan con la función de ajuste de Python (`np.polyfit`) e informar la recta final del modelo.

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

Ajuste por librería (np.polyfit(x, y, 1)):

- $β_"1,lib" = 6640.709999$
- $β_"0,lib" = 1214.642119$

La discrepancia numérica es nula ($< 10^(-6)$), confirmando que las herramientas computacionales resuelven este mismo sistema analítico de derivadas parciales. Asimismo, coincide con los valores reportados en la tabla de regresión simple de la Parte B.2.

Dando la recta estimada final:

$ y = #ltemp.beta0 + #ltemp.beta1 x $

- $β_0 = #ltemp.beta0$: Alquiler esperado base cuando la variable normalizada de temperatura es cero (0 °C de referencia).  
- $β_1 = #ltemp.beta1$ \> 0: Pendiente de la recta que indica que, según la aproximación lineal global, por cada unidad de incremento en la escala normalizada de temperatura, la demanda total estimada se incrementa en aproximadamente 6641 alquileres diarios (o unos 162 alquileres por cada grado Celsius real al dividir por 41).

Conclusión de A.2: La deducción de las ecuaciones normales confirma que la recta de regresión lineal simple no se define mediante una aproximación visual o empírica, sino como la solución exacta a un problema de optimización continua multivariable que consiste en minimizar la suma de errores cuadráticos anulando el gradiente ($nabla f = 0$) mediante derivadas parciales. Al imponer esta condición, la anulación de la derivada respecto a $b_0$ obliga algebraicamente a que la suma total de residuos sea cero ($sum_(i=1)^n e_i = 0$), forzando a la recta a pasar de manera exacta por el baricentro de los datos $(macron(x), macron(y))$.


== A.3 Descenso del gradiente

=== Parte 1 del A.3: Modelo Multivariable y Justificación de la Dirección Opuesta al Gradiente

Estimar la ecuación de regresión múltiple de la sección B.5 para predecir la demanda de alquileres `cnt` ($y$) a partir de las cuatro variables climáticas: `temp` ($x_1$), `atemp` ($x_2$), `hum` ($x_3$) y `windspeed` ($x_4$):

$ y = b_0 + b_1 x_1 + b_2 x_2 + b_3 x_3 + b_4 x_4 = x^T b $

La suma de los errores al cuadrado define la función de costo en varias variables:

$ f(b) = sum_(i=1)^n [y_i - x_i^T * b]^2 = ||y - X b||^2 $

donde cada fila $x_i^T \= \[1, x_(i 1), x_(i 2), x_(i 3), x_(i 4)\]$ incorpora un 1 para el término independiente $b_0$. El vector gradiente $nabla f(b)$ apunta por definición geométrica en la dirección de máximo crecimiento local de la función con respecto al vector de pesos $b$. Dado que el objetivo es hallar el mínimo de error, desplazarse en sentido opuesto ($-nabla f(b)$) garantiza la mayor tasa de descenso instantáneo en la superficie de pérdida, guiando los parámetros iterativamente hacia el valor óptimo según la regla:

$ b^(k+1) = b^(k) - alpha * nabla f(b^(k)) $

donde derivando analíticamente respecto a cada parámetro bj se obtiene el gradiente matricial compacto:

$ nabla f(b) = -2 X^T (y - X b) $


=== Parte 2 del A.3: Comportamiento según la Tasa de Aprendizaje ($alpha$)

Ejecutar el algoritmo con tres tasas de aprendizaje: una demasiado pequeña, una adecuada y una que provoque divergencia; graficar la función de pérdida $f$ en función del número de iteración en un mismo par de ejes y explicar qué ocurre en cada caso. El tamaño de paso $alpha$ modula la magnitud del desplazamiento en cada iteración. Al evaluar su desempeño en el dataset se distinguen tres dinámicas:

#image("outputs/a3_descenso_gradiente.png")

==== 1. Tasa demasiado pequeña ($alpha = 0.0001$ \- Curva Azul)

El paso vectorial es diminuto. La función de pérdida desciende de forma regular pero extremadamente lenta, requiriendo cientos de pasos para aproximarse al valle del mínimo y quedando lejos de la solución óptima en pocas iteraciones.

==== 2. Tasa adecuada ($alpha = 0.0007$ \- Curva Verde)

El paso se encuentra balanceado con la curvatura de la superficie cuadrática. La pérdida se reduce de manera pronunciada y estable en las primeras iteraciones hasta estabilizarse suavemente en el mínimo sin oscilaciones erráticas.

==== 3. Tasa excesiva / divergente ($alpha = 0.0015$ \- Línea Discontinua Roja)

El paso es mayor al radio de estabilidad del gradiente, lo que hace que la actualización sobrepase el fondo del valle y caiga en una pared opuesta más alta. Esto genera oscilaciones explosivas que incrementan la pérdida exponencialmente ($10^10$) en las primeras iteraciones hasta provocar desbordamiento numérico (overflow).


=== Parte 3 del A.3: Criterios de Detención

Indicar el criterio de detención utilizado para finalizar la ejecución iterativa del descenso del gradiente. Siguiendo las pautas de los métodos numéricos de optimización de la cátedra, el algoritmo evalúa dos condiciones de corte concurrentes:

==== 1. Condición de tolerancia de mejora:

$ |f(b^(k+1)) - f(b^(k))| < epsilon $

Cuando la diferencia absoluta en el valor de la función de costo entre dos pasos sucesivos es menor a un umbral prefijado (ej. $epsilon = 10^(-2)$ o menor), se concluye que la actualización de parámetros es despreciable y el algoritmo se encuentra en la planicie del mínimo estacionario.

==== 2. Límite de iteraciones máximas (`max_iters = 40`)

Funciona como salvaguarda algorítmica para interrumpir el bucle en caso de convergencia excesivamente lenta o para detener de forma segura la ejecución cuando una tasa sobredimensionada genera divergencia y valores no numéricos (`NaN` o infinitos).


=== Parte 4 del A.3: Comparación con Mínimos Cuadrados (MCO de B.5) y Modelo Final

#let grad = (
  beta0:  3303.3959,
  beta1:  3584.6384,
  beta2:  3620.3500,
  beta3: -2731.7566,
  beta4: -3050.2941,
)

#let mco = (
  beta0:  3860.3685,
  beta1:  2111.8136,
  beta2:  5139.1524,
  beta3: -3149.1098,
  beta4: -4528.6748,
)

Comparar la solución obtenida mediante el descenso del gradiente con la solución analítica exacta de mínimos cuadrados:

$ beta = (X^T X)^(-1) X^T Y $

correspondiente a la sección B.5. Al contrastar los coeficientes del descenso del gradiente (con tasa adecuada; $alpha = 0.0007$) contra la solución matricial exacta sobre las 731 observaciones de cnt con las cuatro variables climáticas, se obtienen los siguientes valores:

#show table.cell.where(x: 0): set align(left)

#table(
  columns: 4, align: right,
  [*Variable*],                                [*Gradiente*], [*MCO Exacto*], [*Diferencia*],
  [Ordenada al origen ($β_0$)],                [#grad.beta0],  [#mco.beta0],  [#calc.abs(mco.beta0 - grad.beta0)],
  [Temperatura (`temp`, $β_1$)],               [#grad.beta1],  [#mco.beta1],  [#calc.abs(mco.beta1 - grad.beta1)],
  [Sensación térmica (`atemp`, $β_2$)],        [#grad.beta2],  [#mco.beta2],  [#calc.abs(mco.beta2 - grad.beta2)],
  [Humedad (`hum`, $β_3$)],                    [#grad.beta3],  [#mco.beta3],  [#calc.abs(mco.beta3 - grad.beta3)],
  [Velocidad del viento (`windspeed`, $β_4$)], [#grad.beta4],  [#mco.beta4],  [#calc.abs(mco.beta4 - grad.beta4)],
)

==== Interpretación de la comparación:

1. Coincidencia unívoca en los signos e impacto físico: Ambos métodos coinciden plenamente en la estructura causal: la temperatura y la sensación térmica poseen coeficientes positivos ($β > 0$), indicando que el buen clima estimula los alquileres; mientras que la humedad y la velocidad del viento poseen coeficientes negativos ($β < 0$), demostrando que el exceso de humedad o vientos fuertes reducen el confort y desincentivan los viajes en bicicleta.

2. Explicación de la diferencia numérica: La discrepancia observada entre el gradiente y el MCO exacto se debe a que el algoritmo se ejecutó con un corte en 40 iteraciones (para poder visualizar las tres tasas de aprendizaje en una misma escala gráfica). Como se aprecia en la curva verde, la función de costo continuaba en trayectoria descendente; al tratarse de un método iterativo sobre datos sin estandarizar, con un mayor número de iteraciones los coeficientes convergen asintóticamente a la solución matricial exacta de mínimos cuadrados.

==== Conclusión de A.3
Se estableció el puente práctico para escenarios multivariables donde la inversión matricial analítica resulta computacionalmente restrictiva. Mediante el descenso del gradiente en sentido opuesto a la máxima variación local ($-nabla f(b)$), se evidenció la sensibilidad del método ante la tasa de aprendizaje ($alpha$) y la eficacia de los criterios de detención. La convergencia de los coeficientes iterativos hacia la solución matricial exacta de mínimos cuadrados ($beta = (X^T X)^(-1) X^T Y$) ratifica la robustez de los algoritmos de aproximación numérica para el entrenamiento de modelos de regresión múltiple.

= Parte B - Complementos de Estadística

== B.1 - Varianza

La estimación $sigma^2$ de la varianza para el modelo de regresión lineal simple sobre `temp` la obtenemos a partir de la suma de cuadrados de error:

$
sigma^2 &= "SCE"/(n - 2) = (sum_(i=1)^n (y_i - hat(y)_i)^2) / (n - 2) = #ltemp.sce / #{ltemp.n - 2} = #{ltemp.sce / (ltemp.n - 2)}
$

Exponemos la descomposición de la variabilidad en la siguiente tabla:

#let anova = csv("outputs/b1_tabla_anova.csv")

#table(
  columns: 5,
  table.header(..anova.first().map(cell => [*#cell*])),
  ..anova.slice(1).flatten(),
)

A continuación calculamos el coeficiente de determinación, a partir de las sumas de cuadrados de error y total:

#let r2 = 1 - ltemp.sce / ltemp.stc

$
R^2 = 1 - "SCE" / "STC" = 1 - #ltemp.sce / #ltemp.stc = #r2 approx #{calc.round(r2 * 100, digits: 2)} %
$

Este coeficiente indica qué proporción de la variabilidad se "explica" por el modelo de regresión. Esto es, en qué medida el uso de una recta de regresión para hacer las predicciones disminuye el error frente al uso de la media muestral como predicción para la variable dependiente. Es importante destacar que un valor alto de R² no significa que exista una relación causal entre las variables, ni que el modelo sea adecuado para realizar predicciones sobre nuevos datos.


== B.2 - Regresión Lineal Simple

Realizamos un análisis de regresión lineal simple entre cnt y diferentes variables. Presentamos la comparación en la tabla:

#let regresiones = csv("outputs/b2_regresiones_simples.csv")

#text(size: 7pt)[
  #table(
    columns: regresiones.first().len(),
    align: center,
    inset: 3pt,
    stroke: 0.5pt,
    table.header(
      [Variable],
      [$beta_1$],
      [$beta_0$],
      [$sigma^2$],
      [$R^2$],
      [$R$],
      [$"IC"(beta_1)$],
      [$"IC"(beta_0)$],
      [$"ICM"(Y|x^*=0.65)$],
      [$"IP"(Y|x^*=0.65)$]
    ),
    ..regresiones.slice(1).flatten(),
  )
]

Observando la tabla encontramos que la regresión sobre la variable `atemp` muestra el mejor valor para $R^2$. Tomamos esto como un indicio de que esta regresión explica mejor la variabilidad de la muestra. Además, la utilización de la sensación térmica como predictor parecería tener más relación con el problema presentado.

A continuación presentamos el gráfico de dispersión, junto con la recta de regresión del modelo:

#image("outputs/b2_regresion_atemp.png")


== B.3 - Test de Hipótesis

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

#let t_critico = 1.9632234465207086

El valor crítico $t(alpha/2, n-2)$ para $alpha=0.05$ según la tabla es: $#t_critico$

Siguiendo la regla de decisión planteada:


$
  "Rechazar" space H_0 space "si" space |T| > t(alpha/2, n-2)
$

vemos como es $abs(T)$ respecto al valor crítico obtenido:

#let beta1 = 7501.8339
#let s2 = 2261360.8852
#let sxx = 19.386132332570277
#let T = calc.abs(beta1 / calc.sqrt(s2 / sxx))

$
  abs(T) = abs(hat(beta)_1 / sqrt(hat(sigma)^2 / S_(x x)))
    = abs(#beta1 / sqrt(#s2 / #sxx))
    = #T > #t_critico = t(alpha/2, n-2)
$

Al rechazar $H_0$ estamos diciendo que la pendiente no es nula; esto quiere decir que existe algún grado de relación lineal entre la sensación térmica observada (`atemp`) y la cantidad bicicletas alquiladas (`cnt`).


== B.4 - Intervalos para la respuesta media y predicción

#let x_estrella = 0.65
#let y_media = (ltemp.f)(x_estrella)
#let ic_media_inf = 5387.597333429889
#let ic_media_sup = 5674.609902742142
#let ic_pred_inf = 2564.363958593135
#let ic_pred_sup = 8497.843277578897

Para el modelo de regresión lineal simple con la variable `temp`, se desea cuantificar la incertidumbre en la estimación de la demanda esperada cuando la temperatura normalizada toma el valor fijo $x^* = #x_estrella$.

El valor puntual estimado de la respuesta media es:

$
  hat(y) = hat(beta)_0 + hat(beta)_1 x^* = #ltemp.beta0 + #ltemp.beta1 times #x_estrella = #y_media
$

=== Intervalo de confianza para la respuesta media

La respuesta media tiene un intervalo de confianza al 95 % dado por:

$
  hat(y)(x^*) plus.minus t_(alpha/2, n - 2) sqrt(hat(sigma)^2 (1 / n + ((x^* - macron(x))^2) / S_(x x)))
$

Con $n = 731$, $alpha = 0.05$ y $x^* = #x_estrella$ se obtiene:

$
  "IC"(E(Y | x^*)) = [#ic_media_inf, #ic_media_sup]
$

Es decir, para una temperatura normalizada de 0.65, la cantidad esperada de alquileres se encuentra, con un 95 % de probabilidad, entre #ic_media_inf y #ic_media_sup bicicletas.

=== Intervalo de predicción para valores futuros

Además, si se quiere predecir un valor individual futuro de $Y$ para el mismo nivel de temperatura, se utiliza el intervalo de predicción:

$
  hat(y)(x^*) plus.minus t_(alpha/2, n - 2) sqrt(hat(sigma)^2 (1 + 1 / n + ((x^* - macron(x))^2) / S_(x x)))
$

Con la misma elección de $x^*$, resulta:

$
  "IP"(Y | x^*) = [#ic_pred_inf, #ic_pred_sup]
$

Este intervalo es más ancho que el anterior, porque incorpora no solo la incertidumbre en la media esperada, sino también la variabilidad aleatoria propia de una observación individual. En consecuencia, para una temperatura de 0.65 la predicción puntual de alquileres es de #y_media bicicletas, pero un valor futuro individual podría caer entre #ic_pred_inf y #ic_pred_sup en aproximadamente el 95 % de los casos.

== B.5 - Regresión Lineal Múltiple

Se estimó por mínimos cuadrados el modelo de regresión múltiple para `cnt` sobre las variables `temp`, `atemp`, `hum` y `windspeed`. Presentamos los coeficientes obtenidos luego de resolver el sistema de ecuaciones en forma matricial con numpy:

#let data = csv("outputs/b5_regresion_multiple.csv", row-type: dictionary)

#let b = ()

#for (i, row) in data.enumerate() {
  b.push(float(row.coeficiente))
  [- $beta_(#i) = #row.coeficiente$ (#row.variable)]
}

De esta manera, el modelo nos queda:

#let sign(x) = if x < 0 [ $-$ ] else [ $+$ ]

$
  hat(y) = #b.at(0)
    #for (i, bb) in b.slice(1).enumerate(start: 1) {
      $&#sign(bb) #calc.abs(bb) dot x_(#i) $
      if i == 2 { $\ $ }
    }
$

Calculamos la variabilidad y coeficientes de determinación del modelo:

#let ssr=1468850901.4568558
#let stc=2739535392.0465117
#let n = 731
#let k = 4
#let r2 = 1 - ssr/stc
#let r2adj = 1 - ((1 - r2) * (n - k) / (n - k - 1))

$ "SS"_r = "SCE" = sum (y_i - hat(y)_i)^2 = #ssr $
$ sigma^2 = "SS"_r / (n-k-1) = #ssr / (#n - #k - 1) = #{ssr / (n - k - 1)} $
$ R^2 = 1 - "SCE" / "STC" = 1 - #ssr / #stc = #r2 $
$ R^2_"adj" = 1 - (1 - R^2) (n-k) / (n-k-1) = 1 - (1 - #r2) (#n - #k) / (#n - #k - 1) = #r2adj $

Vemos que el valor ajustado de $R^2$ ronda el 46.3%. Si comparamos este valor con el $R^2$ obtenido para el modelo lineal de B.2, vemos que aquél es menor. Esto sugiere que el modelo múltiple se ajusta mejor.

Considerando, que la variable utilizada en el modelo simple es la sensación térmica, que se calcula en base a temperatura, humedad y velocidad del viento, no era previsible que el uso de estas tres variables agregara nueva información al modelo.