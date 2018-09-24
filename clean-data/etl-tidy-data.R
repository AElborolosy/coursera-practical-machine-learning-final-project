# Script that transform the training and testing data sets into a format
# appropiate for machine learning algorithms.
library(dplyr)
library(rpart)

training.data <-
  read.csv(file = "./data/pml-training.csv", row.names = 1) %>%
  as.tbl() %>%
  arrange(user_name, classe)

# Hyperparameters still need to be optimized. See documentation.
decision.tree <- rpart::rpart(formula = classe ~ .,
                              data = training.data,
                              model = "class")

print(decision.tree)
print(summary(decision.tree))
rpart::printcp(decision.tree)	