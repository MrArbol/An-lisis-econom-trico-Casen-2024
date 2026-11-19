# Impacto de la Cantidad de Hijos en la Pobreza Multidimensional en Chile

Este repositorio contiene el código y la metodología econométrica utilizada para evaluar el impacto de la carga demográfica intradomiciliaria (cantidad de hijos) sobre la probabilidad de que un hogar se encuentre en situación de **pobreza multidimensional**, a partir de los microdatos de la encuesta **CASEN 2024**.

---

## 📌 Resumen del Estudio

A partir de una muestra depurada de **176.299 observaciones** a nivel de jefatura de hogar, se evalúa si una mayor densidad de dependientes infantiles eleva el riesgo de vulnerabilidad multidimensional, y en qué medida este impacto puede ser neutralizado por el capital humano y la inserción laboral.

### Principales Hallazgos:
1. **Efecto de la carga familiar:** Un hijo adicional en el hogar incrementa de forma estadísticamente significativa en **6 puntos porcentuales** la probabilidad de caer en pobreza multidimensional (convergencia unánime entre el Modelo de Probabilidad Lineal y el Efecto Marginal Promedio del modelo Probit). En el modelo Logit, esto equivale a un incremento del **58,4% en los Odds de riesgo**.
2. **El capital humano como factor protector:** Cada año adicional de educación formal completado por la jefatura reduce la probabilidad de pobreza en **2 puntos porcentuales**. La educación superior actúa como un escudo estructural, capaz de amortiguar sustancialmente el impacto de familias numerosas.
3. **Límites de la intensidad laboral:** Si bien más horas de trabajo semanales reducen el riesgo, su magnitud marginal resulta insuficiente frente a cargas familiares elevadas en contextos de empleo no calificado.

---

## 🛠️ Metodología y Modelos

El análisis compara tres especificaciones econométricas de respuesta binaria:

- **Modelo de Probabilidad Lineal (MPL / MCO):** Estimación secuencial incorporando controles y verificación de multicolinealidad con el Factor de Inflación de la Varianza (VIF < 10).
- **Modelo Logit:** Estimación por Máxima Verosimilitud con cálculo de **Odds Ratios** y cambios porcentuales relativos.
- **Modelo Probit:** Cálculo de **Efectos Marginales Promedio (AME)** mediante el paquete `mfx` y simulación de probabilidades predichas bajo perfiles y escenarios hipotéticos.
- **Inferencia estadística:** Uso de errores estándar robustos a heterocedasticidad (tipo HC1).

---

## 📂 Estructura del Repositorio

- `Casen_2024.R`: Script principal en R que realiza la carga de datos, limpieza, recodificación de variables, cálculo de correlaciones, estimación de modelos (MPL, Logit, Probit) y exportación de tablas de resultados.
- `README.md`: Descripción general del proyecto e instrucciones de replicación.

---

## 🚀 Replicación del Código

### 1. Requisitos previos
Tener instalado **R** (versión ≥ 4.0) y los siguientes paquetes:

```r
install.packages(c(
  "haven",
  "dplyr",
  "stargazer",
  "corrplot",
  "ISLR",
  "modelsummary",
  "flextable",
  "pandoc",
  "lmtest",
  "sandwich",
  "mfx",
  "car"
))
```

### 2. Base de datos
1. Descargar la base oficial de la encuesta **CASEN 2024** en formato SPSS (`.sav`) desde el portal del [Ministerio de Desarrollo Social y Familia de Chile](https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen).
2. Renombrar el archivo a `casen_2024.sav` (o mantener su nombre) y colocarlo en la misma carpeta del script `Casen_2024.R`.

### 3. Ejecución
Abrir y ejecutar el script `Casen_2024.R` en RStudio, VS Code o tu entorno preferido.

---

## 👥 Autores
- Davis Oliverbeson
- Brandon Villegas
