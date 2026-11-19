################# MODELO ECONOMETRICO #################
#¿la cantidad de hijos influye en la pobreza?-----

#paquetes----
install.packages("ISLR", dependencies = T)
install.packages(c("modelsummary", "flextable"), dependencies = T)
install.packages("pandoc", dependencies = T)
install.packages(c("sandwich", "mfx"), dependencies = T)
library(haven)  #para importar y exportar bases
library(dplyr)  #para trabajar de forma sencilla
library(stargazer) #para crear tablas comparativas  
library(corrplot) #graficos de correlacion 
library(ISLR) # para trabjar con modelos econometricose
library(modelsummary) #tablas comparativas de modelos
library(flextable) #paquete dependiente de modelsummary
library(pandoc)   #paquete dependiente de modelsummary
library(lmtest)     # coeftest (pruebas de coeficientes)
library(sandwich)   # errores estándar robustos (vcovHC)
library(mfx)        # efectos marginales en logit/probit

options(scipen = 999) #quita la notacion cientifica


#base----- 
#https://observatorio.ministeriodesarrollosocial.gob.cl/encuesta-casen
#se puede obtener atraves de este link
# Nota: Colocar el archivo 'casen_2024.sav' en el directorio de trabajo
casen_2024 <- read_sav("casen_2024.sav")

# 1. Aseguramos que folio sea un carácter o número limpio para evitar conflictos de haven
casen_2024 <- casen_2024 %>% 
  mutate(folio = as.character(folio))

# 2. Creamos la variable en la base original
casen_2024 <- casen_2024 %>%
  # Pasamos pco1_b a numérico limpio
  mutate(pco1_b_limpia = as.numeric(as.vector(pco1_b))) %>%  #pco1_b = relacion con jefatura del hogar
  
  # Agrupamos por hogar
  group_by(folio) %>%
  
  # Calculamos el total de hijos por hogar sin eliminar filas
  # Sumamos 1 cada vez que pco1_b_limpia esté entre 4 y 6
  mutate(total_hijos = sum(pco1_b_limpia %in% c(4, 5, 6), na.rm = TRUE)) %>%
  ungroup()

# Verificación
print(head(casen_2024$total_hijos, 10))


#creamos una base nueva con las variables que estimamos que tienen importancia para el estudio-----
casen_2024 <- casen_2024 %>% 
  mutate(o10 = coalesce(o10, 0)) #Esto hace que todos los NA se conviertan en ceros
                                 #de esta manera dejamos de considerar solo a los que si
                                 #hayan trabajado una hora la semana anterior y tomamos 
                                 #tambien a los desempleados.


casen_import <- casen_2024 %>% 
 dplyr::select(pobreza_multi, esc, total_hijos, sexo, o10, o1, region) %>% 
  mutate(sexo = ifelse(sexo == 2,0, sexo), #convierte a las mujeres en ceros.
         o1 = ifelse(o1 == 2, 0, o1),   #deja como ceros a aquellos que no trabajaron al menos 1 hora la semana pasada
         region = ifelse(region == 13, 1, 0)) %>% #hacemos que la region metropolitana sea igual a 1 
                                                  # y todas las demas 0, para que la region metropolitana sea la variable de control
   na.omit() %>%                                 
  rename("horas_tr" = o10,
         "anhour" = o1,
          "RM" = region)
#Al aplicar los filtros y limpiar la base con "na.omit(), la 
# base disminuyo en numero de observaciones, aun asi sigue siendo un 
# numero bastante grande como para poder trabajar.


#analisis descriptivo de la base ----

summary(casen_import)
str(casen_import)
head(casen_import)
#correlacion entre las variables explicativas  
correlacion <- cor(casen_import)

print(correlacion)

#grafico de la correlacion
corrplot(correlacion, 
         method = "color", 
         type = "upper", 
         tl.col = "blue", 
         tl.srt = 45, 
         addCoef.col = "red", 
         number.cex = 0.8)

#NOTA----
#se decide por eliminar la variable anhour dado que tiene demasiada correlacion 
# con hora_tr 

################## EVALUAR MODELOS ##################

#1) modelo 1. solo hijos------

modelo_1 <- lm(pobreza_multi ~ total_hijos, data = casen_import)

summary(modelo_1)

# 2) modelo 2. agrega años de educ-----
modelo_2 <- lm(pobreza_multi ~ total_hijos + esc, data = casen_import)

summary(modelo_2)

# 3) modelo 3. agrega sexo ----

modelo_3 <- lm(pobreza_multi ~ total_hijos + esc + sexo, data = casen_import)

summary(modelo_3)

#H0: sexo = 0 H1: sexo ! 0 
#t value (sexo) = -0.925 /  nivel.significancia = 10%
# resultado: no hay evidencia suficiente para rechazar hipotesis nula 

# nota:------
#se elimina la variable sexo ya que no tiene significancia estadistica 
#ni economica en el modelo 

# 4) modelo 4. agrega horas trabajas por semana----

modelo_4 <- lm(pobreza_multi ~ total_hijos + esc + horas_tr, data = casen_import)

summary(modelo_4)

# 5) modelo 5. incluye si trabajo una hora la semana pasada o no----
modelo_5 <- lm(pobreza_multi ~ total_hijos + esc + horas_tr + RM, data = casen_import)

summary(modelo_5)



#evaluar VIF-----

car::vif(modelo_5)

#tudo bom :)


# tabla_comparativa todos los modelos----

mis_modelos <- list( 
  "Modelo 1" = modelo_1,  
  "Modelo 2" = modelo_2,
   "modelo 3" = modelo_3,                      
  "Modelo 4" = modelo_4, 
  "Modelo 5" = modelo_5
)

# Creamos la tabla directamente en un archivo de Word (.docx)
tabla_modelosMPL <- modelsummary(mis_modelos, 
              gof_omit = "BIC|AIC|RMSE",
             output = "estimacion_de_modelos_sex.docx",
             title = "Resultados de la Estimación: Modelo de Probabilidad Lineal (Pobreza Multidimensional)") 
tabla_modelosMPL


################ MODELOS ESTIMABLES (logit) ################

#estimar modelo logit----
modelo_logit <- glm(pobreza_multi ~ total_hijos + esc + horas_tr + RM, 
                    family = binomial(link = "logit"), data = casen_import
                    )

#errores estandar robustos

coeftest(modelo_logit, vcov = vcovHC(modelo_logit, type = "HC1"))

#ponemos el modelo logit en una tabla 
tabla_modelosLOGIT <- modelsummary(modelo_logit, 
                                 gof_omit = "BIC|AIC|RMSE",
                                 output = "estimacion_modelo_logit.docx",
                                 title = "Resultados de la Estimación: Modelo Logit (Pobreza Multidimensional)") 
tabla_modelosLOGIT


#sacamos odd-ratios 

odd_ratio <- exp(coef(modelo_logit))

#cambio porcentual para que sea mas facil estimar 

cambio_porcent <- ifelse(odd_ratio < 1, (1 - odd_ratio), odd_ratio - 1)

#tabla linda----

tabla_linda <- data.frame(
    "VARIABLES" = names(odd_ratio),
   "Coeficientes" = round(coef(modelo_logit), 4),
   "ODDS-RATIOS" = round(odd_ratio, 4),
   "CAMBIO %" = round(cambio_porcent * 100, 4), 
   check.names = F
)

#tabla 
datasummary_df(
  tabla_linda,
  title = "Resultados del Modelo Logit: Odds Ratios y Cambio Porcentual",
  #output = "tabla_odds_ratios_%.docx"
)

#prediccion de escenario hipotetico----

hipotetic1 <- data.frame(
     "total_hijos" = c(2, 5, 8),
   "esc" = c(12, 18, 14),
   "horas_tr" = c(8, 20, 44),
   "RM" = 0
)


hipotetic1$prob_probreza <- predict(modelo_logit, newdata = hipotetic1, type = "response")
hipotetic1

############# MODELOS ESTIMABLE (PROBIT) #############

modelo_probit <- glm(pobreza_multi ~ total_hijos + esc + horas_tr + RM, 
                    family = binomial(link = "probit"), data = casen_import
)

summary(modelo_probit)
summary(modelo_logit)

#errores estandar robustos

coeftest(modelo_probit, vcov = vcovHC(modelo_probit, type = "HC1"))

#hacemos una tabla del modelo probit 
tabla_modelosPROBIT <- modelsummary(modelo_probit, 
                                   gof_omit = "BIC|AIC|RMSE",
                                   output = "estimacion_modelo_porbit.docx",
                                   title = "Resultados de la Estimación: Modelo Probit (Pobreza Multidimensional)") 
tabla_modelosPROBIT



# Efecto marginal promedio (AME) con mfx----
Probit_mfx <- probitmfx(
  formula = pobreza_multi ~ total_hijos + esc + horas_tr + RM,
  data    = casen_import,
  atmean  = FALSE
)
Probit_mfx

#esto sirve para interpretacion
##Efectos marginales: forma manual (a partir de la densidad)
#Índice lineal X*beta para cada observación
eta <- predict(modelo_probit, type = "link")
head(eta)
dens <- dnorm(eta)

ame_manual <- mean(dens) * coef(modelo_probit)[c("total_hijos", "esc")]
round(ame_manual, 5)


names(coef(modelo_probit))
predict(modelo_probit, newdata = hipotetic1, type = "response")

#Comparación: MPL, Logit y Probit----
#modelo 5
efectos_probit <- Probit_mfx$mfxest[, "dF/dx"]
efectos_probit_completos <- c("Intercept" = NA , efectos_probit)

comp_avanzada <- data.frame(
  Variable      = names(coef(modelo_logit)),
  MPL_MCO       = round(coef(modelo_5), 4),
  Logit_Coef    = round(coef(modelo_logit), 4),
  Probit_Coef   = round(coef(modelo_probit), 4),
  Probit_AME    = round(efectos_probit_completos, 4)
)


datasummary_df(comp_avanzada,
               title = "Resultados comparativos: MPL, LOGIT y PROBIT
               (Pobreza multidimensional)",
               output = "Resultados.finales.docx"
               )




