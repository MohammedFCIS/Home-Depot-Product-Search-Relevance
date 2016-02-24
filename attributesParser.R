library(dplyr)
library(gdata)

#-----------------------------------------------------------------

## Parses attributes & generate new attribute fields for all products
allProductsAttributesParser <- function(all_products_attributes) {
  
  ## change input column to data frame
  all_products_attributes <- as.data.frame(all_products_attributes)

  ## generate new fields for all the rows & stack them on top of each other in order
  df <- NULL
  for (i in 1:nrow(all_products_attributes)) {
    currRow <- singleProductAttributesParser(as.character(all_products_attributes[i,]))
    df <- rbind(df, currRow)
  }
  
  df

}

#-----------------------------------------------------------------

## Obtains the values for the new attribute fields for single product
singleProductAttributesParser <- function(single_product_attributes) {
  
  ## split attributes from one another
  single_product_attributes <- single_product_attributes %>%  ## a single string containing all attributes for a single product
                               strsplit(split = "@@@@") %>%   ## a list where each element is a an attribute of the product
                               as.data.frame()                ## a column vector (of type 'dataframe')

  ## give the only column in the data frame a name for later access
  colnames(single_product_attributes) <- "attr_key_val"

  ## separate the only column in the data frame into 2 columns: "key" & "value"
  single_product_attributes <- separate(single_product_attributes, col = "attr_key_val", remove = TRUE, sep = ";;", into = c('key','value'))

  ## BULLETS
  bullets_rows <- single_product_attributes[startsWith(single_product_attributes$key, "Bullet", ignore.case = TRUE, trim = TRUE),]
  bullets <- paste(bullets_rows$value, collapse = " ")

  ## YES
  yeses_rows <- single_product_attributes[startsWith(single_product_attributes$value, "Yes", ignore.case = TRUE, trim = TRUE),]
  yeses <- paste(yeses_rows$key, collapse = " ")

  ## NO
  nos_rows <- single_product_attributes[startsWith(single_product_attributes$value, "No", ignore.case = TRUE, trim = TRUE),]
  nos <- paste(nos_rows$key, collapse = " ")
  
  ## REMAINING
  remaining_rows <- subset(single_product_attributes, !(key %in% rbind(bullets_rows, yeses_rows, nos_rows)$key))
  keys <- paste(remaining_rows$key, collapse = " ")
  values <- paste(remaining_rows$value, collapse = " ")

  result <- data.frame(bullets, yeses, nos, keys, values)

  result

}

#-----------------------------------------------------------------
  
# Example of attributes:
# attribs <- "Built-in flange$@$Yes @@@@            # examples of 
#             Caulkless$@$No @@@@                   # yes/no
#             Slip-resistant tub floor$@$No @@@@    # attributes
#
#             Bullet01$@$Slightly narrower for tighter spaces @@@@                                                #
#             Bullet02$@$Designed with an 18 in. apron @@@@                                                       # examples of 
#             Bullet03$@$Durable high-gloss finish provides a smooth, shiny surface that is easy to clean @@@@    # bullet-style
#             Bullet04$@$Conforms to ANSI Z124.1.2 and CSA B45.1 national consensus standards @@@@                # attributes
#             Bullet05$@$Curve wall with a smooth, contemporary look, featuring integrated storage shelves @@@@   #
#
#             Certifications and Listings$@$ANSI Certified,ASTM Compliant,CSA Certified @@@@    # examples of 
#             Color Family$@$White @@@@                                                         # key/value
#             Color/Finish$@$White @@@@                                                         # attributes
#             Construction$@$Four piece @@@@                                                    #
#             ...
#             ...
#             ..."

