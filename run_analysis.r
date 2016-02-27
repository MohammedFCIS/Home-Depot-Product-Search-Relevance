library(reader)
library(dplyr)
library(tidyr)
# Read training data
products_training <- tbl_df(read.csv("data/train.csv",stringsAsFactors = FALSE))
# Read product description
product_description <- tbl_df(read.csv("data/product_descriptions.csv",stringsAsFactors = FALSE))
# Read test data
products_test <- tbl_df(read.csv("data/test.csv",stringsAsFactors = FALSE))

#combine training and test data, Joining by: c("id", "product_uid", "product_title", "search_term")
product_training_test<- full_join(products_training,products_test)

#combine test data and data combined at the previous steps,Joining by: c("product_uid")
product_all <- right_join(product_training_test, product_description)

#Read the attributes of products
products_attributes <- tbl_df(read.csv("data/attributes.csv",stringsAsFactors = FALSE, na.strings = 'N/A'))


products_attributes <- products_attributes  %>%
                       filter(product_uid != 'NA') %>% #revmove null rows
                       unite(property, c(name,value), sep = ';;')   #combine name and values columns
# group rows with the same id
products_attributes <- aggregate(products_attributes$property ~ products_attributes$property, by=list(products_attributes$product_uid), FUN=paste, collapse="@@@@")

#restore original names
products_attributes <- products_attributes %>% rename(product_uid = Group.1, property = `products_attributes$property`)

#---------------------------------

#generate new attribute fields and combine with 'product_all'
source('attributesParser.R')
products_attributes <- mutate(products_attributes, bullets = sapply(property, FUN = bulletsParser),
                                                   yeses = sapply(property, FUN = yesesParser),
                                                   nos = sapply(property, FUN = nosParser),
                                                   keys = sapply(property, FUN = keysParser),
                                                   values = sapply(property, FUN = valuesParser))

#merge attributes with the main dataset
product_all <- full_join(product_all, products_attributes)

#---------------------------------

#generate the features that will be used in linear regression later
source('matchScorer.R')
product_all <- mutate(product_all, bulletsScore = mapply(phrasesMatchScore, search_term, bullets),
                                   yesesScore   = mapply(phrasesMatchScore, search_term, yeses),
                                   nosScore     = mapply(phrasesMatchScore, search_term, nos),
                                   keysScore    = mapply(phrasesMatchScore, search_term, keys),
                                   valuesScore  = mapply(phrasesMatchScore, search_term, values))

# divide the data into training and test sets
product_all_train <- subset(product_all, !is.na(relevance))
product_all_test  <- subset(product_all, is.na(relevance))

#linear regression
RegModel = lm(relevance ~ bulletsScore + yesesScore + nosScore + keysScore + valuesScore, data = product_all_train)
TestPredictions = predict(RegModel, newdata = product_all_test)

summary(RegModel)

# write prediction to file
write.csv(TestPredictions, file = "test_set_predictions.csv")

