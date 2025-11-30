# 🎬 R – Sistema de recomendación de pelis (Content-Based Filtering with TF-IDF)

This repository contains a **content-based recommender system** for movies built in R, using TF-IDF (Term Frequency-Inverse Document Frequency) and cosine similarity to recommend films based on plot synopses and user ratings.

Este repositorio contiene un **sistema de recomendación basado en contenido** para películas desarrollado en R, utilizando TF-IDF (Term Frequency-Inverse Document Frequency) y similitud del coseno para recomendar películas en función de sinopsis y valoraciones de usuario.

---

## 📄 Files / Archivos

- `scripts/Sistema_reco_pelis.R` – Main R script implementing the recommender system.  
- `data/dataset_Peliculas.csv` – Movie dataset with titles, synopses and metadata (sample).  
- `results/` – CSV files with recommendation outputs (love campaign, similar movies, personalized recommendations).  
---

## 🎯 Objectives / Objetivos

ENG:
- Build **Item Profiles** for each movie using TF-IDF on plot synopses.  
- Implement **content-based filtering** to recommend similar movies based on cosine similarity.  
- Create **User Profiles** by weighting Item Profiles with user ratings.  
- Support **keyword-driven campaigns** (e.g., Valentine's Day movie recommendations).  
- Compare recommendation strategies for **platform vs newsletter**.

ESPAÑOL:
- Construir **Item Profiles** para cada película usando TF-IDF sobre las sinopsis.  
- Implementar **filtrado basado en contenido** para recomendar películas similares usando similitud del coseno.  
- Crear **User Profiles** ponderando Item Profiles con valoraciones de usuario.  
- Apoyar **campañas temáticas** (ej. recomendaciones de San Valentín).  
- Comparar estrategias de recomendación para **plataforma vs newsletter**.

---

## 🛠️ Tech stack / Tecnologías utilizadas

- **R 4.x**  
- **tm** – Text mining, corpus creation and preprocessing.  
- **SnowballC** – Stemming (reducing words to their root form in Spanish).  
- **dplyr** – Data manipulation.  
- **readr** – CSV file handling.  
- **TF-IDF weighting** – To create Item Profiles.  
- **Cosine similarity** – To measure similarity between movies and user profiles.

---

## 🧹 Workflow / Flujo de trabajo

### 1. Text preprocessing / Preprocesamiento del texto

- Convert synopses to lowercase, remove punctuation, numbers and stopwords.  
- Apply **stemming** to reduce words to their root (e.g., "amores" → "amor").  
- Remove irrelevant words: "película", "género", "minutos", etc.

### 2. Item Profile creation / Creación del Item Profile

- Build a **Document-Term Matrix** (DTM) where rows = movies, columns = unique stemmed words.  
- Apply **TF-IDF weighting** to highlight important words that are frequent in one movie but rare across all movies.  
- Each row becomes the **Item Profile** for that movie (numeric vector capturing its semantic essence).

### 3. Content-based recommendations / Recomendaciones basadas en contenido

- **Query:** User selects a movie (e.g., "Indiana Jones: Raiders of the Lost Ark").  
- **Process:** Compute **cosine similarity** between the query movie's profile and all other movies.  
- **Output:** Top 10 most similar movies ranked by similarity score.

Example output for "En busca del arca perdida":
1. Indiana Jones y la última cruzada  
2. Las aventuras del joven Indiana Jones  
3. Indiana Jones y el reino de la calavera de cristal  
...

### 4. Keyword-driven campaigns / Campañas por palabras clave

- Define keywords (e.g., amor, pareja, beso, boda for Valentine's Day).  
- Score each movie by summing TF-IDF weights for those keywords.  
- Return top movies ranked by keyword relevance.

Example: Top movies for "love" campaign:
1. Ahora o nunca  
2. El arte de amar  
3. Te querré siempre  
...

### 5. User Profile recommendations / Recomendaciones por perfil de usuario

- **Input:** User has rated 5 movies with scores (e.g., 4, 9, 2, 8, 8).  
- **Process:**  
  - Extract Item Profiles for rated movies.  
  - Weight each profile by its rating and sum → **User Profile** (single vector).  
  - Compute cosine similarity between User Profile and all movies.  
  - Exclude already-rated movies.  
- **Output:** Top 10 personalized recommendations.

Example: Recommendations for a user who liked action/thriller movies:
1. El padrino  
2. El Padrino. Parte III  
3. La jungla: Un buen día para morir  
...

---

## 📊 Use cases / Casos de uso

### Platform recommendations (real-time personalization)

Use a **hybrid system** (collaborative + content-based):  
- **Collaborative filtering** leverages patterns from users with similar tastes.  
- **Content-based filtering** ensures personalized recommendations even for new or niche content.  
- Best for: In-app discovery, homepage carousels, "Because you watched X" sections.

### Newsletter recommendations (themed campaigns)

Use **content-based filtering** with keyword campaigns:  
- Easier to explain in email: "Top romance movies for Valentine's Day".  
- More visual and narrative-driven.  
- Allows for timely, event-driven recommendations (holidays, awards season, trending topics).

---

## 🔍 Key insights / Hallazgos principales

- **TF-IDF effectively captures movie semantics**: Words like "espía", "mafia", "amor" distinguish genres and themes.  
- **Content-based filtering works well for cold-start**: New users or niche content can still get relevant recommendations.  
- **User Profile approach is powerful**: Weighting by ratings allows personalized recommendations that reflect user taste evolution.  
- **Keyword campaigns drive engagement**: Thematic recommendations (e.g., Valentine's Day) have higher open rates in newsletters than generic suggestions.

---

## 🚀 How to run / Cómo ejecutar

1. Clone this repository:  
git clone https://github.com/JM-specialist-network/r-movie-recommender-tfidf.git
cd r-movie-recommender-tfidf

2. Install dependencies:  
install.packages(c("tm", "SnowballC", "dplyr", "readr"))


3. Set working directory and run the script:  
setwd("path/to/r-movie-recommender-tfidf/scripts")
source("Sistema_reco_pelis.R")


4. Check the `results/` folder for output CSV files with recommendations.

---

## 📚 Business queries answered / Consultas de negocio respondidas

1. **Item Profile construction**: Step-by-step process from raw synopsis to TF-IDF vector.  
2. **Representative words**: Top 10 keywords for "Infiltrados" (e.g., "Costello", "policia", "topo").  
3. **Love campaign**: 10 movies matching Valentine's Day keywords (amor, beso, pareja).  
4. **Similar movie recommendations**: 10 films similar to "Indiana Jones: Raiders of the Lost Ark".  
5. **Personalized recommendations**: 10 movies tailored to a user's rating history.  
6. **Recommendation strategy**: Hybrid (platform) vs content-based (newsletter) approaches.

---

## 👤 Author / Autor

Created by **Jose Miguel Artiles** – Data Scientist & Economist-in-training.  
- GitHub: [JM-specialist-network](https://github.com/JM-specialist-network)  
- Email: joseartiles@gmail.com
