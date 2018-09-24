# Script that transform the training and testing data sets into a format
# appropiate for machine learning algorithms.
library(dplyr)


training.data <-
  read.csv(file = "./data/pml-training.csv", row.names = 1) %>%
  as.tbl() %>%
  arrange(user_name, classe)
