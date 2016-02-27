library(dplyr)

#-----------------------------------------------------------------

# REMOVE LEADING/TRAILING WHITESPACES
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#-----------------------------------------------------------------

attributesSplitter <- function(single_product_attributes) {
  
  ## split attributes from one another
  single_product_attributes <- single_product_attributes %>%  ## a single string containing all attributes for a single product
                               strsplit(split = "@@@@") %>%   ## a list where each element is a an attribute of the product
                               as.data.frame()                ## a column vector (of type 'dataframe')
  
  ## give the only column in the data frame a name for later access
  colnames(single_product_attributes) <- "attr_key_val"
  
  ## separate the only column in the data frame into 2 columns: "key" & "value"
  single_product_attributes <- separate(single_product_attributes, col = "attr_key_val", remove = TRUE, sep = ";;", into = c('key','value'))

  ## trim all attributes' keys and values
  single_product_attributes$key   <- sapply(single_product_attributes$key,   trim)
  single_product_attributes$value <- sapply(single_product_attributes$value, trim)

  single_product_attributes

}

#-----------------------------------------------------------------

bulletsParser <- function(single_product_attributes) {

  ## split attributes from one another
  single_product_attributes <- attributesSplitter(single_product_attributes)
  
  ## BULLETS
  bullets_rows <- single_product_attributes["Bullet" == substr(single_product_attributes$key, 1, 6),]
  bullets <- paste(bullets_rows$value, collapse = " ")

  bullets

}

#-----------------------------------------------------------------

yesesParser <- function(single_product_attributes) {
  
  ## split attributes from one another
  single_product_attributes <- attributesSplitter(single_product_attributes)
  
  ## YES
  yeses_rows <- single_product_attributes["Yes" == substr(single_product_attributes$value, 1, 3),]
  yeses <- paste(yeses_rows$key, collapse = " ")
  
  yeses
  
}

#-----------------------------------------------------------------

nosParser <- function(single_product_attributes) {
  
  ## split attributes from one another
  single_product_attributes <- attributesSplitter(single_product_attributes)
  
  ## NO
  nos_rows <- single_product_attributes["No" == substr(single_product_attributes$value, 1, 2),]
  nos <- paste(nos_rows$key, collapse = " ")
  
  nos
  
}

#-----------------------------------------------------------------

keysParser <- function(single_product_attributes) {
  
  ## split attributes from one another
  single_product_attributes <- attributesSplitter(single_product_attributes)
  
  ## all the rows that will be excluded
  bullets_rows <- single_product_attributes["Bullet" == substr(single_product_attributes$key,   1, 6),]
  yeses_rows   <- single_product_attributes["Yes"    == substr(single_product_attributes$value, 1, 3),]
  nos_rows     <- single_product_attributes["No"     == substr(single_product_attributes$value, 1, 2),]
  
  ## rows to be kept
  remaining_rows <- subset(single_product_attributes, !(key %in% rbind(bullets_rows, yeses_rows, nos_rows)$key))

  ## KEY
  keys <- paste(remaining_rows$key, collapse = " ")

}

#-----------------------------------------------------------------

valuesParser <- function(single_product_attributes) {
  
  ## split attributes from one another
  single_product_attributes <- attributesSplitter(single_product_attributes)
  
  ## all the rows that will be excluded
  bullets_rows <- single_product_attributes["Bullet" == substr(single_product_attributes$key,   1, 6),]
  yeses_rows   <- single_product_attributes["Yes"    == substr(single_product_attributes$value, 1, 3),]
  nos_rows     <- single_product_attributes["No"     == substr(single_product_attributes$value, 1, 2),]
  
  ## rows to be kept
  remaining_rows <- subset(single_product_attributes, !(key %in% rbind(bullets_rows, yeses_rows, nos_rows)$key))
  
  ## KEY
  values <- paste(remaining_rows$value, collapse = " ")
  
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

