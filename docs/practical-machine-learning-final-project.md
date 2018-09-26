Practical Machine Learning Final Project
================
Ahmed Elborolosy
September 26, 2018

Load Libraries
--------------

Dplyr is used to simplify data cleaning and manipulation. ranger contains a speed optimized implementation of Random Forests made for data with high dimensionality (Many features/variables).

``` r
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
library(ranger)
```

Load and Clean Data Sets
------------------------

### Read CSV Files

I read the csv files as tibbles and arranged them by user\_name (user\_name & classe for the training data) for ease of viewing.

``` r
training.data <-
  read.csv(file = "./data/pml-training.csv", row.names = 1, stringsAsFactors = FALSE) %>%
  as.tbl() %>%
  arrange(user_name, classe)

test.data <-
  read.csv(file = "./data/pml-testing.csv", row.names = 1, stringsAsFactors = FALSE) %>%
  as.tbl() %>%
  arrange(user_name)
```

### Normalize Columns

To simplify removing null values, I moved the classe and problem\_id variables into seperate vectors so the training and test data sets have identical columns.

``` r
train.classe <- training.data$classe
test.problem_id <- test.data$problem_id

training.data <- select(training.data, -classe)
test.data <- select(test.data, -problem_id)
```

### Exploratory Analysis of Missing Values

Conduct a column by column count of missing values in both the test and training sets and then view the results.

``` r
# Count NAs per feature in each set
training.na.count <- sapply(X = training.data, FUN = function(x) sum(is.na(x)))
test.na.count <- sapply(X = test.data, FUN = function(x) sum(is.na(x)))

summary(training.na.count)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
          0       0       0    8149   19216   19216 

``` r
summary(test.na.count)
```

       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
       0.00    0.00   20.00   12.66   20.00   20.00 

### Removal of Missing Data

Based on training.na.count, it appears about 75% of our features have no missing data The other 25% are almost completely missing data. The test data has a similar issue. We shall remove those columns from our data set and then train our Random Forest classifier.

Imputing the data would be preferred if those columns had a larger proportion of data available. Some of the trainging.data sets had ~19200 NA values and ~400 actual values.

Another issue is my personal lack of domain knowledge. The data is already scaled and my understanding of how the sensors work is limited. It appears that most users did not create the motion neccesary to trigger the sensors and record an actual value.

For the sake of accuracy, I will disregard these columns and reduce our dataset to 58 of the original 158 features.

``` r
# Element wise addition. If there is a NA in the column in either the test or train data,
# The matching element in column.selector will evaluate to FALSE.
total.na.count <- training.na.count + test.na.count
column.selector <- sapply(X = total.na.count, FUN = function(x) if_else(x > 0, FALSE, TRUE))

# The data sets now only contain the columns whose selector is TRUE
# Those are the columns with 0 na values.
training.data <- training.data[,column.selector]
test.data <- test.data[,column.selector]
```

Train and Use a Random Forest Classifier
----------------------------------------

### Fit the Models

I mostly used default parameters and found I had a very low OOB (Out of Bag) Error rate ranging between 0.15% and 0.05% when I tested the script.

CROSS-VALIDAITON: By default, Random Forests utilize cross-validation. A portion of the trainging data is used to train and a portion is used for validation.

I believe the split is 2/3 trainging, 1/3 validation in this implimentation. Note, the library you use and the parameters you set can impact that split.

``` r
decision.ranger <- ranger::ranger(formula = train.classe ~ .,
                                  data = training.data,
                                  num.trees = 500,
                                  mtry = NULL, # Defaults to the sqrt(number_of_features)
                                  probability = FALSE,
                                  min.node.size = 1) # 1 is for classification

decision.ranger
```

    Ranger result

    Call:
     ranger::ranger(formula = train.classe ~ ., data = training.data,      num.trees = 500, mtry = NULL, probability = FALSE, min.node.size = 1) 

    Type:                             Classification 
    Number of trees:                  500 
    Sample size:                      19622 
    Number of independent variables:  58 
    Mtry:                             7 
    Target node size:                 1 
    Variable importance mode:         none 
    Splitrule:                        gini 
    OOB prediction error:             0.06 % 

### Predict classe for the test set

I arrange by the problem number to make answering the quiz easier. I received a 100% on the quiz using these answers.

``` r
predictions <- predict(decision.ranger, test.data)

quiz.answers <-
  data.frame("Problem" = test.problem_id,
             "Classe" = predictions$predictions,
             row.names = "Problem")

quiz.answers <- arrange(quiz.answers, rownames(quiz.answers))

quiz.answers
```

       Classe
    1       B
    2       A
    3       B
    4       C
    5       B
    6       A
    7       E
    8       E
    9       A
    10      B
    11      B
    12      A
    13      B
    14      B
    15      A
    16      A
    17      E
    18      D
    19      B
    20      A
