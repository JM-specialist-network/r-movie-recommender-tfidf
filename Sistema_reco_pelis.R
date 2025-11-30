## -------------------------------------------------------------------------
## SCRIPT: Sistema de Recomendación.R
##  JM Artiles
## -------------------------------------------------------------------------

##### 1. Cargar librerías #####

if (!require("tm")) {
  install.packages("tm")
  library("tm")
}

if (!require("SnowballC")) {
  install.packages("SnowballC")
  library("SnowballC")
}

if (!require("dplyr")) {
  install.packages("dplyr")
  library("dplyr")
}

if (!require("readr")) {
  install.packages("readr")
  library("readr")
}

## -------------------------------------------------------------------------

##### Bloque de parámetros iniciales #####

setwd("ruta") 

## -------------------------------------------------------------------------

##### Bloque de carga de información #####

# Cargar el dataset
Peliculas <- read.csv2("dataset Peliculas.csv", stringsAsFactors = FALSE, fileEncoding = "Windows-1252")

# Ver primeros registros
head(Peliculas)
str(Peliculas)

# Guardar lista de títulos
ListadoPeliculas <- Peliculas$Titulo

## -------------------------------------------------------------------------

#####  Bloque de análisis del dataset #####

# Mostrar ejemplos que se piden a continuación
cat("Película 57:", Peliculas$Titulo[57], "\n")  # Es "Infiltrados"
cat("Película 61:", Peliculas$Titulo[61], "\n")  # Es "En busca del arca perdida"

# Ver sinopsis de ejemplo
cat("Sinopsis 57:\n", Peliculas$Sinopsis[57], "\n\n")

# Comprobar si hay valores faltantes y vacíos
sum(is.na(Peliculas))

## -------------------------------------------------------------------------

#####  Bloque de tratamiento de la información #####

# Crear el corpus
corpus <- VCorpus(VectorSource(Peliculas$Sinopsis))

# Limpieza del texto de caracteres y espacios
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords("spanish"))

# Eliminar palabras irrelevantes
palabras_extra <- c(
  "película", "film", "cine", "director", "actor", "actriz", "género",
  "minutos", "año", "trama", "basado", "historia"
)
corpus <- tm_map(corpus, removeWords, palabras_extra)

# Stemming (raíz de palabras en español)
corpus <- tm_map(corpus, stemDocument, language = "spanish")
corpus <- tm_map(corpus, stripWhitespace)

# Eliminar palabras de 1-2 letras (opcional, ya que también lo hace wordLengths)
corpus <- tm_map(corpus, content_transformer(function(x) {
  gsub("\\b\\w{1,2}\\b", "", x)
}))

## -------------------------------------------------------------------------

#####  Bloque de creación de matrices TF-IDF #####

# Creación Document-Term Matrix con TF-IDF
dtm_tfidf <- DocumentTermMatrix(corpus, control = list(
  weighting = weightTfIdf,
  wordLengths = c(3, Inf)  # Solo palabras de 3+ letras
))

# Asignar y define los títulos como nombres de documentos
dtm_tfidf$dimnames$Docs <- ListadoPeliculas

# Convertir a matriz densa: se crea el Item Profile
item_profiles <- as.matrix(dtm_tfidf)

# Para evitar error despúes, asegurar de que las filas tienen nombres numéricos (1, 2, 3, ..., 1000)
rownames(item_profiles) <- NULL  # Elimina nombres si son extraños
rownames(item_profiles) <- 1:nrow(item_profiles)  # Asigna 1, 2, 3, ...

## -------------------------------------------------------------------------

#####  Consulta 2: Palabras Representativas (Registro 57: "Infiltrados") #####

perfil_57 <- item_profiles[57, ]
palabras_57 <- sort(perfil_57, decreasing = TRUE)

cat("Top 10 palabras del contenido 57 (Infiltrados):\n")
print(head(palabras_57[palabras_57 > 0], 10))

## -------------------------------------------------------------------------

#####  Consulta 3: Campaña de San Valentín ("amor") #####

# Palabras en español (tras stemming)
palabras_amor <- c("amor", "parej", "relacion", "novi", "bod", "matrimon", 
                   "romant", "corazon", "sentimient", "beso", "pasión")

# Buscar columnas que coincidan
columnas_amor <- grep(paste(palabras_amor, collapse = "|"), colnames(item_profiles))

# Calculamos la  puntuación
score_amor <- rowSums(item_profiles[, columnas_amor, drop = FALSE])

# Top 10
top_amor <- order(score_amor, decreasing = TRUE)[1:10]
peliculas_amor <- ListadoPeliculas[top_amor]

cat("Top 10 contenidos para campaña de San Valentín:\n")
print(peliculas_amor)

## -------------------------------------------------------------------------

#####  Consulta 4: Recomendaciones para usuario fan de "En busca del arca perdida" (Registro 61) #####

# Buscar registro
registro_arca <- which(grepl("En busca del arca perdida", ListadoPeliculas, ignore.case = TRUE))

# Verificar que esta OK
if (length(registro_arca) == 0) {
  stop("No se encontró 'En busca del arca perdida'")
}
cat("Película encontrada en el registro:", registro_arca, "\n")

# Extraer perfil
perfil_arca <- item_profiles[registro_arca, , drop = FALSE]

# Calcular similitud coseno manual  #Nota: librería proxy facilita con comando cosine (a mi me da muchos errores)
producto_punto <- item_profiles %*% t(perfil_arca)
normas_docs <- sqrt(rowSums(item_profiles^2))
norma_arca <- sqrt(sum(perfil_arca^2))

# Evitar división por cero
normas_docs[normas_docs == 0] <- 1
norma_arca <- ifelse(norma_arca == 0, 1, norma_arca)

similitud_arca <- producto_punto / (normas_docs * norma_arca)
similitud_arca <- similitud_arca[, 1]

# Ordenar y excluir él titulo de referencia
sim_ordenado <- sort(similitud_arca, decreasing = TRUE)
top_similares <- as.numeric(names(sim_ordenado))[2:11]

cat("Top 10 de recomendaciones para 'En busca del arca perdida':\n")

print(ListadoPeliculas[top_similares])

## -------------------------------------------------------------------------

#####  Consulta 5: Recomendación Personalizada #####

# Suponemos que el usuario valoró:
# - 50: Dos tontos muy tontos → 4
# - 51: El padrino.Parte II → 9
# - 63: Mystic River → 2
# - 82: Jungla de cristal → 8
# - 108: Indiana Jones y el templo maldito → 8

#Por si acaso, vamos a comprobar que los registros coinciden con nuestro dataset

# Definir los registros que mencionas
registros_propuestos <- c(50, 51, 63, 82, 108)

cat("Películas en los registros propuestos:\n")
for (i in registros_propuestos) {
  if (i <= nrow(Peliculas)) {
    cat(i, ": ", Peliculas$Titulo[i], "\n")
  } else {
    cat(i, ": [Fuera de rango]\n")
  }
}



## Valoraciones del usuario (registros verificados)
valoraciones <- data.frame(
  registro = c(50, 51, 63, 82, 108),
  rating = c(4, 9, 2, 8, 8)
)

cat("Dimensión de item_profiles:", dim(item_profiles), "\n")
cat("Longitud del perfil_usuario:", length(perfil_usuario), "\n")

# Comprobar de que los registros existen
if (any(valoraciones$registro > nrow(Peliculas)) || any(valoraciones$registro < 1)) {
  stop("Alguno de los registros está fuera de rango.")
}

# Sacamos los perfiles de las películas valoradas
perfiles_val <- item_profiles[valoraciones$registro, , drop = FALSE]  # ¡Mantener como matriz!


# Problema dimensión
cat("Dimensión de perfiles_val:", dim(perfiles_val), "\n")  # Debe ser 5 x 38620

# Calcular perfil ponderando por su valoración (Una sola fila producto de 38260 columnas)
perfil_usuario <- colSums(perfiles_val * valoraciones$rating)

# Verificar longitud
cat("Longitud del perfil_usuario:", length(perfil_usuario), "\n")

# Asegurarse que el perfil_usuario tiene los mismos nombres de columna
if (!identical(names(perfil_usuario), colnames(item_profiles))) {
  cat("Ajustando nombres de perfil_usuario...\n")
  perfil_usuario <- perfil_usuario[colnames(item_profiles)]  # Reordenar
  perfil_usuario[is.na(perfil_usuario)] <- 0                 # Rellenar con 0
}


## Ahora Calcular similitud coseno manual con todas las películas

#Condiciones
#Normas para todos los perfiles
normas_docs <- sqrt(rowSums(item_profiles^2))

#Normas para el perfil de usuario (1 Valor)
norma_user <- sqrt(sum(perfil_usuario^2))

#Evitar división por cero (por si hay perfiles vacíos)
normas_docs[normas_docs == 0] <- 1
if (norma_user == 0) norma_user <- 1

#Calcular similitud coseno de manera manual #Más sencillo con librería proxy y función cosine
producto_punto_u <- item_profiles %*% matrix(perfil_usuario, ncol = 1)  # 1000 x 1
sim_usuario <- producto_punto_u / (normas_docs * norma_user)            # Similitud
sim_usuario <- sim_usuario[, 1]  # Convertir a vector


# Excluir las películas ya valoradas
sim_usuario[valoraciones$registro] <- 0

# Top 10 recomendaciones
top_usuario <- order(sim_usuario, decreasing = TRUE)[1:10]
recomendaciones_usuario <- ListadoPeliculas[top_usuario]

# Mostrar resultados
cat("Top 10 recomendaciones personalizadas:\n")
print(recomendaciones_usuario)



##### Final. Guardar resultados #####

# Asegurar que los objetos existen
if (exists("top_similares")) {
  write.csv2(data.frame(Recomendaciones = ListadoPeliculas[top_similares]),
             "recomendaciones_arca_perdida.csv", row.names = FALSE)
}

if (exists("peliculas_amor")) {
  write.csv2(data.frame(Recomendaciones = peliculas_amor),
             "recomendaciones_amor.csv", row.names = FALSE)
}

if (exists("top_usuario")) {
  write.csv2(data.frame(Recomendaciones = ListadoPeliculas[top_usuario]),
             "recomendaciones_usuario.csv", row.names = FALSE)
}

cat("\n✅ Todos los resultados generados correctamente.\n")