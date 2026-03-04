# 1. INSTALL AND LOAD LIBRARIES (Run install once if needed)
###############################################################

# install.packages(c("tidyverse","caret","randomForest","class","corrplot"))

library(tidyverse)
library(caret)
library(randomForest)
library(class)
library(corrplot)

###############################################################
# 2. LOAD DATA
###############################################################

auto <- read.csv("Auto.csv", stringsAsFactors = FALSE)

str(auto)
summary(auto)

###############################################################
# 3. DATA CLEANING
###############################################################

# Replace "?" with NA in horsepower
auto$horsepower[auto$horsepower == "?"] <- NA

# Convert horsepower to numeric
auto$horsepower <- as.numeric(auto$horsepower)

# Remove rows with missing values
auto <- na.omit(auto)

# Convert origin to factor
auto$origin <- as.factor(auto$origin)

# Create MPG category for classification
auto$mpg_category <- ifelse(auto$mpg > median(auto$mpg), "High", "Low")
auto$mpg_category <- as.factor(auto$mpg_category)

###############################################################
# 4. CORRELATION MATRIX
###############################################################

numeric_vars <- auto[,c("mpg","cylinders","displacement",
                        "horsepower","weight","acceleration","year")]

cor_matrix <- cor(numeric_vars)

corrplot(cor_matrix, method="circle")

###############################################################
# 5. SCATTER PLOTS
###############################################################

plot(auto$weight, auto$mpg,
     xlab="Weight",
     ylab="MPG",
     main="Weight vs Fuel Efficiency")

plot(auto$horsepower, auto$mpg,
     xlab="Horsepower",
     ylab="MPG",
     main="Horsepower vs Fuel Efficiency")

###############################################################
# 6. TIME TREND ANALYSIS
###############################################################

plot(auto$year, auto$mpg,
     xlab="Year",
     ylab="MPG",
     main="Fuel Efficiency Trend Over Time")

abline(lm(mpg ~ year, data=auto), col="red")

###############################################################
# 7. BOXPLOTS (GROUP COMPARISON)
###############################################################

boxplot(mpg ~ cylinders,
        data=auto,
        main="Fuel Efficiency by Cylinders",
        xlab="Cylinders",
        ylab="MPG")

boxplot(mpg ~ origin,
        data=auto,
        main="Fuel Efficiency by Region",
        xlab="Origin",
        ylab="MPG")

###############################################################
# 8. ANOVA TEST
###############################################################

anova_model <- aov(mpg ~ cylinders, data=auto)

summary(anova_model)

###############################################################
# 9. LINEAR REGRESSION MODEL
###############################################################

lm_model <- lm(mpg ~ cylinders + displacement +
                 horsepower + weight +
                 acceleration + year + origin,
               data=auto)

summary(lm_model)

###############################################################
# 10. TRAIN TEST SPLIT
###############################################################

set.seed(123)

train_index <- createDataPartition(auto$mpg_category,
                                   p=0.7,
                                   list=FALSE)

train <- auto[train_index, ]
test <- auto[-train_index, ]

###############################################################
# 11. PREPARE DATA FOR KNN (SCALING REQUIRED)
###############################################################

train_x <- train[,c("cylinders","displacement",
                    "horsepower","weight",
                    "acceleration","year")]

test_x <- test[,c("cylinders","displacement",
                  "horsepower","weight",
                  "acceleration","year")]

# Scale numeric variables
train_x <- scale(train_x)
test_x <- scale(test_x)

train_y <- train$mpg_category
test_y <- test$mpg_category

###############################################################
# 12. KNN MODEL
###############################################################

knn_pred <- knn(train_x,
                test_x,
                train_y,
                k=5)

###############################################################
# 13. CONFUSION MATRIX FOR KNN
###############################################################

confusionMatrix(as.factor(knn_pred), test_y)

###############################################################
# 14. RANDOM FOREST MODEL
###############################################################

rf_model <- randomForest(mpg_category ~ cylinders +
                           displacement + horsepower +
                           weight + acceleration +
                           year + origin,
                         data=train,
                         ntree=500)

rf_pred <- predict(rf_model, test)

###############################################################
# 15. CONFUSION MATRIX FOR RANDOM FOREST
###############################################################

confusionMatrix(rf_pred, test_y)

###############################################################
# 16. VARIABLE IMPORTANCE
###############################################################

varImpPlot(rf_model)

###############################################################
# END OF SCRIPT
###############################################################