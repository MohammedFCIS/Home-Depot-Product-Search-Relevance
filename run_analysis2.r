library(reader)
library(dplyr)
library(tidyr)
library(tm)

############################################################
### Reading Data and Building Single Data Set
############################################################
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
  unite(property, c(name,value), sep = ' ')   #combine name and values columns
# group rows with the same id
products_attributes <- aggregate(products_attributes$property ~ products_attributes$property, by=list(products_attributes$product_uid), FUN=paste, collapse=" ")

#restore original names
products_attributes <- products_attributes %>% rename(product_uid = Group.1, property = `products_attributes$property`)
#merge attributes with the main dataset
product_all <- full_join(product_all, products_attributes)
#merge all text columns
product_all <- product_all %>% 
              unite(fullProperty, c(product_title, product_description, property), sep = ' ')

#######################################################
### Cleanining Data
#######################################################
#Cleaning full property
fullPropertyCorpus <- Corpus(VectorSource(product_all$fullProperty))
fullPropertyCorpus <- tm_map(fullPropertyCorpus, tolower)
fullPropertyCorpus <- tm_map(fullPropertyCorpus, removePunctuation)
fullPropertyCorpus <- tm_map(fullPropertyCorpus, removeWords,
                             stopwords('en'))
fullPropertyCorpus <- tm_map(fullPropertyCorpus, removeNumbers)
fullPropertyCorpus <- tm_map(fullPropertyCorpus, removeWords, c('x'))
fullPropertyCorpus <- tm_map(fullPropertyCorpus, stripWhitespace)
fullPropertyCorpus <- tm_map(fullPropertyCorpus, PlainTextDocument)  # Fix to avoid Error: inherits(doc, "TextDocument") is not TRUE
rm_extra_char <- content_transformer(function(x, pattern) gsub(pattern, "", x))
fullPropertyCorpus <- tm_map(fullPropertyCorpus, rm_extra_char, "[^[:alpha:][:space:]]")
fullPropertyCorpus <- tm_map(fullPropertyCorpus, PlainTextDocument)  # Fix to avoid Error: inherits(doc, "TextDocument") is not TRUE
fullPropertyCorpus <- tm_map(fullPropertyCorpus, stemDocument)# Must be after transforming into plain text document
fullPropertyCorpus <- DocumentTermMatrix(fullPropertyCorpus)
#product_all$fullProperty_cleaned <- fullPropertyCorpus$content

#Cleaninig Search Term
searchCorpus <- Corpus(VectorSource(product_all$search_term))
searchCorpus <- tm_map(searchCorpus, tolower)
searchCorpus <- tm_map(searchCorpus, removePunctuation)
searchCorpus <- tm_map(searchCorpus, removeWords, stopwords('en'))
searchCorpus <- tm_map(searchCorpus, removeWords, c('x', '|'))
searchCorpus <- tm_map(searchCorpus, removeNumbers)
searchCorpus <- tm_map(searchCorpus, stripWhitespace)
searchCorpus <- tm_map(searchCorpus, PlainTextDocument)  # Fix to avoid Error: inherits(doc, "TextDocument") is not TRUE
searchCorpus <- tm_map(searchCorpus, stemDocument)
searcFrequencies <- DocumentTermMatrix(searchCorpus)
#product_all$search_term_cleaned <- searchCorpus$content

##########################################################
### Adding Features
##########################################################

#write.csv(as.data.frame.matrix(products_training), file = "data/train_cleaned.csv")