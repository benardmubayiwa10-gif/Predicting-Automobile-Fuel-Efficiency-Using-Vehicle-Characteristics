# auto.R — Vehicle Fuel Efficiency Analysis

An end-to-end R pipeline for analysing and predicting vehicle fuel efficiency using the Auto MPG dataset. Covers exploratory data analysis, statistical testing, linear regression, and two classification models (KNN and Random Forest).

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Pipeline Steps](#pipeline-steps)
- [Variables & Features](#variables--features)
- [Models](#models)
- [Output](#output)
- [Configuration](#configuration)

---

## Overview

This script takes a raw `Auto.csv` file and runs it through a complete machine learning workflow:

1. Cleans and prepares the data
2. Explores relationships via correlation, scatter plots, boxplots, and time trends
3. Tests group differences with ANOVA
4. Fits a linear regression model for MPG prediction
5. Trains and evaluates KNN and Random Forest classifiers to predict whether a vehicle's fuel efficiency is **High** or **Low**

---

## Requirements

| Package | Purpose |
|---|---|
| `tidyverse` | Data manipulation |
| `caret` | Train/test splitting and confusion matrix |
| `randomForest` | Random Forest classifier |
| `class` | K-Nearest Neighbours classifier |
| `corrplot` | Correlation matrix visualisation |

**R version 4.0 or higher** is recommended.

---

## Installation

Packages are installed automatically on first run via the commented line at the top of the script. To install manually:

```r
install.packages(c("tidyverse", "caret", "randomForest", "class", "corrplot"))
```

---

## Usage

1. Place `Auto.csv` in your R working directory.
2. Source the script:

```r
setwd("/path/to/your/data")
source("auto.R")
```

All plots render to the active R graphics device. Model summaries and evaluation metrics print to the console.

> **Input:** `Auto.csv` must contain columns for `mpg`, `cylinders`, `displacement`, `horsepower`, `weight`, `acceleration`, `year`, and `origin`. Raw `horsepower` values of `"?"` are handled automatically during cleaning.

---

## Pipeline Steps

| Step | Description |
|---|---|
| 1. Load Libraries | Loads tidyverse, caret, randomForest, class, corrplot |
| 2. Load Data | Reads `Auto.csv`; prints structure and summary |
| 3. Data Cleaning | Replaces `"?"` in horsepower with `NA`, converts to numeric, removes missing rows, casts `origin` as factor, creates binary `mpg_category` (High/Low at median) |
| 4. Correlation Matrix | Pearson correlations across 7 numeric variables; rendered as a circle corrplot |
| 5. Scatter Plots | Weight vs MPG and Horsepower vs MPG |
| 6. Time Trend | Year vs MPG with a fitted OLS trend line |
| 7. Boxplots | MPG grouped by cylinder count and by region of origin |
| 8. ANOVA | One-way ANOVA testing mean MPG differences across cylinder groups |
| 9. Linear Regression | OLS regression of `mpg` on all 7 predictors |
| 10. Train/Test Split | Stratified 70/30 split on `mpg_category`; `set.seed(123)` |
| 11. KNN Prep | Z-score scaling of 6 numeric features |
| 12. KNN Model | KNN with `k = 5`; predicts High/Low MPG |
| 13. KNN Evaluation | Confusion matrix with accuracy, sensitivity, specificity |
| 14. Random Forest | 500-tree Random Forest on all 7 predictors including `origin` |
| 15. RF Evaluation | Confusion matrix with accuracy, sensitivity, specificity |
| 16. Variable Importance | `varImpPlot()` showing MeanDecreaseGini per feature |

---

## Variables & Features

| Variable | Type | Role |
|---|---|---|
| `mpg` | numeric | Regression target |
| `cylinders` | numeric | Predictor |
| `displacement` | numeric | Predictor |
| `horsepower` | numeric* | Predictor |
| `weight` | numeric | Predictor |
| `acceleration` | numeric | Predictor |
| `year` | numeric | Predictor |
| `origin` | factor | Predictor (RF & regression only) |
| `mpg_category` | factor | Classification target (High / Low) |

\* Raw data contains `"?"` entries which are coerced to `NA` and removed during cleaning.

---

## Models

### Linear Regression

Predicts continuous `mpg` from all 7 predictors. Outputs a coefficient table, adjusted R², and F-statistic.

```r
lm(mpg ~ cylinders + displacement + horsepower +
         weight + acceleration + year + origin,
   data = auto)
```

### K-Nearest Neighbours

Classifies `mpg_category` (High/Low) using 6 scaled numeric features. `origin` is excluded as KNN requires numeric input.

```r
knn(train_x, test_x, train_y, k = 5)
```

### Random Forest

Classifies `mpg_category` using all 7 predictors including the `origin` factor. Produces a variable importance plot.

```r
randomForest(mpg_category ~ cylinders + displacement + horsepower +
               weight + acceleration + year + origin,
             data = train, ntree = 500)
```

---

## Output

| Output | Format | Description |
|---|---|---|
| `str()` / `summary()` | Console | Dataset structure and descriptive statistics |
| Correlation plot | Plot | Circle corrplot of 7 numeric variables |
| Weight vs MPG | Plot | Scatter plot |
| Horsepower vs MPG | Plot | Scatter plot |
| Time trend | Plot | Year vs MPG with OLS line |
| Boxplot — Cylinders | Plot | MPG distribution per cylinder count |
| Boxplot — Origin | Plot | MPG distribution per region |
| ANOVA summary | Console | F-statistic and p-value |
| Linear model summary | Console | Coefficients, R², p-values |
| KNN confusion matrix | Console | Accuracy, sensitivity, specificity |
| RF confusion matrix | Console | Accuracy, sensitivity, specificity |
| Variable importance plot | Plot | MeanDecreaseGini per feature |

---

## Configuration

To tune key parameters, edit these lines in the script:

| Parameter | Default | Location | Effect |
|---|---|---|---|
| Train/test ratio | `0.7` | Step 10 | Proportion used for training |
| Random seed | `123` | Step 10 | Reproducibility of the split |
| KNN neighbours | `5` | Step 12 | Number of neighbours |
| RF trees | `500` | Step 14 | Number of trees in the forest |
| MPG threshold | `median(mpg)` | Step 3 | Boundary for High/Low classification |
