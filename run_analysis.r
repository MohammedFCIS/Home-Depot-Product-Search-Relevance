library(reader)
library(dplyr)
library(tidyr)
# Read training data
products_training <- tbl_df(read.csv("data/train.csv",stringsAsFactors = FALSE))
# Read product description
product_description <- tbl_df(read.csv("data/product_descriptions.csv",stringsAsFactors = FALSE))
# Read test data
products_test <- tbl_df(read.csv("data/test.csv",stringsAsFactors = FALSE))

#combine training and test data, Joining by: "product_uid"
product_training_test<- full_join(products_training,products_test)

#combine test data and data combined at the previous steps,Joining by: c("product_uid")
product_all <- right_join(product_training_test, product_description)

#Read the attributes of products
products_attributes <- tbl_df(read.csv("data/attributes.csv",stringsAsFactors = FALSE, na.strings = 'N/A'))


products_attributes <- products_attributes  %>%
                       filter(product_uid != 'NA') %>% #revmove null rows
                       distinct(product_uid, name) #remove duplicates