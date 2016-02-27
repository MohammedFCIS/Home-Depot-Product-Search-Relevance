library(qualV)
library(stringi)

#-----------------------------------------------------------------

# LONGEST COMMON SUBSEQUENCE
longestCommonSubsequence <- function(a, b) {
  ## convert from strings to character vectors (required by qualV::LCS())
  a <- unlist(strsplit(a, split = ""))
  b <- unlist(strsplit(b, split = ""))
  
  ## obtain the longest common subsequence
  result <- paste(LCS(a, b)$LCS, collapse = "")
  
  result
}

#-----------------------------------------------------------------

# LONGEST COMMON SUBSTRING
longestCommonSubstring <- function(a, b) {
  ## get all forward substrings of 'b'
  sb <- stri_sub(b, 1, 1:nchar(b))

  ## extract them from 'a' if they exist
  sstr <- na.omit(stri_extract_all_coll(a, sb, simplify=TRUE))

  ## match the longest one
  result <- sstr[which.max(nchar(sstr))]

  result
}

#-----------------------------------------------------------------

# Example
# > a <- "hello"
# > b <- "hel123l5678o"
# > longestCommonSubsequence(a, b)
# [1] "hello"
# > longestCommonSubstring(a, b)
# [1] "hel"

#-----------------------------------------------------------------

# MATCH SCORE
wordsMatchScore <- function(a, b) {
  ## obtain longest common subseqeunce
  lc_subseq <- longestCommonSubsequence(a, b)

  ratio1 <- nchar(lc_subseq) / nchar(a)   ## amount of match with first word
  ratio2 <- nchar(lc_subseq) / nchar(b)   ## amount of match with second word
  result <- max(ratio1, ratio2)

  result
}

#-----------------------------------------------------------------

# Example
# > a <- "seqncer"    # typo!
# > b <- "sequencer"
# > matchScore(a, b)
# [1] 1

#-----------------------------------------------------------------

# REMOVE LEADING/TRAILING WHITESPACES
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#-----------------------------------------------------------------

# MATCH SCORE
phrasesMatchScore <- function(query, target) {
  if (is.na(query) || is.na(target)) {
    #print(print(paste("query", query)))
    #print(print(paste("target", target)))
    result <- 0
  }
  else if (trim(query) == "" || trim(target) == "") {
    #print(print(paste("query", query)))
    #print(print(paste("target", target)))
    result <- 0
  }
  else {
    ## TRIM!
    query <- trim(query)
    target <- trim(target)

    ## split words of 'query' into a vector of words
    query <- unlist(strsplit(query, split = " "))
    query <- query[is.na(match(query, ""))]     # remove empty strings
  
    ## split words of 'target' into a vector of words
    target <- unlist(strsplit(target, split = " "))
    target <- target[is.na(match(target, ""))]  # remove empty strings
    
    ## loop over query words and get their match scores
    queryMatchScores <- replicate(expr = 0, n = length(query))
    for (i in 1:length(query)) {
      ## current query word
      currentQueryWord <- query[i]
      
      ## record maximum match score for 'currentQueryWord':  
      ## loop over target words and get the one that gives the maximum match score with 'currentQueryWord'
      queryMatchScores[i] <- max(sapply(target, function(x){wordsMatchScore(currentQueryWord, x)}))

#       ## verbose & slower equivalent of above line
#       maxScore <- -1
#       for (j in 1:length(target)) {
#         ## current target word
#         currentTargetWord <- target[j]
#   
#         ## compute match score and store it if higher than what is currently stored in 'maxScore'
#         maxScore <- max(maxScore, wordsMatchScore(currentQueryWord, currentTargetWord))
#       }
#       queryMatchScores[i] <- maxScore
    }
    
    ## compute the final matching score between query and target as an aggregation of the values in 'queryMatchScores'
    result <- mean(queryMatchScores)            # average of scores of the query words
    #result <- 1 - prod(1 - queryMatchScores)    # assumes the scores of the query words are in the range [0,1]
  }
  
  result
}

#-----------------------------------------------------------------

# Example
# > A <- "apple pie"
# > B <- "half-dozen apple pies"
# > phrasesMatchScore(A, B)
# [1] 1

