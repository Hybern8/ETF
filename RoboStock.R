#new R script for stocks scraping and trading
#install.packages('tidyverse')
library(quantmod)
library(dplyr)
library(caret)
library(tidyverse)
library(randomForest)

#install.packages('plotly')

#set my ticker
ticker <- 'NVDA'
n <- 50

#download stock price data
getSymbols(ticker, src = 'yahoo')

#Calculate moving averages (SMA and EMA)
SMA <- SMA(Cl(get(ticker)), n = n)
EMA <- EMA(Cl(get(ticker)), n = n)

#Calculate RSI (Relative Strength Index)
RSI <- RSI(Cl(get(ticker)))

#Calculate MACD (Moving Average Convergence Divergence)
MACD <- MACD(Cl(get(ticker)))

#Calculate volatility (using standard deviation)
Volatility <- runSD(Cl(get(ticker)), n = n)

#Calculate volume
Volume <- get(ticker)$Volume

#Calculate ROC (Price Rate of Change)
ROC <- ROC(Cl(get(ticker)), n = n)

#Calculate Bollinger Bands
BollingerBands <- BBands(Cl(get(ticker)), n = n)

#combine all calculated rows of the data with the engineered features
binded_ticker <- (cbind(get(ticker), SMA, EMA, RSI, MACD, Volatility, Volume, ROC, BollingerBands))
#remove NAs
binded_ticker <- na.omit(binded_ticker)

#Min-max scaling of entire dataset
ScaledDataset <- apply(binded_ticker, 2, function(x) (x - min(x)) / (max(x) - min(x)))
#make it a dataframe
ScaledDataset <- data.frame(ScaledDataset)

#setting up the data for split and for ML model
#split train & test set
set.seed(1123)
trainIndex <- createDataPartition(ScaledDataset$NVDA.Close, p = 0.8, list = F)
trainset <- ScaledDataset[trainIndex, ]
testset <- ScaledDataset[-trainIndex, ]

#make predictor and response sets from training sets
predictor <- trainset[, -4]
response <- trainset[, 4]

#Define cross-validation scheme
cv <- trainControl(method = "cv", number = 10)  # Example: 5-fold cross-validation

#feature selection - building the model & selecting most relevant and promising features of the dataframe
stockModel <- train(x = predictor,
                    y = response,
                    data = trainset, 
                    method = 'ridge', 
                    trControl = cv)

#extract selected features
selectedFeatures <- names(coef(stockModel$finalModel))

#now train a model based on the selectred features
model <- lm(NVDA.Close ~., data = trainset[, selectedFeatures])


#Assuming 'NVDA.Close' is your target variable
# Split data into predictors (X) and target variable (y)
X <- ScaledDataset[, -which(names(ScaledDataset) == "NVDA.Close")]
y <- ifelse(ScaledDataset$NVDA.Close > lag(ScaledDataset$NVDA.Close), 1, 0)  # Label '1' for buy, '0' for sell

# Train Random Forest model
rf_model <- randomForest(X, y)

# Step 4: Model Evaluation (Optional)
# Evaluate model performance using cross-validation or holdout set
# For example:
# cross_val <- cv.randomForest(X, y, mtry = ...)
# print(cross_val)

# Step 5: Prediction
# Predict buy/sell decisions on new data
# Assuming 'new_data' is your new dataset
new_X <- new_data[, -which(names(new_data) == "NVDA.Close")]
predictions <- predict(rf_model, newdata = new_X)

# Convert predictions to buy/sell decisions
buy_sell_decisions <- ifelse(predictions == 1, "Buy", "Sell")

# Output buy/sell decisions
print(buy_sell_decisions)