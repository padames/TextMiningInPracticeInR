# Exercises from the book Text Mining In Practice In R
# Chapter 2: Text Mining Basics
# Helpers for main script
library(magrittr) # to use the forward-pipe operator %>%
library(tm)

tryTolower <- function(s) {
  s_lowered <- tryCatch( tolower(s),
                         error = function(e) e )
  if (inherits(s_lowered, 'error')) {
    s_lowered <- NA
  }
  return(s_lowered)
}



custom.stopwords <- c(stopwords("en"), 'lol', 'smh', 'delta')

clean.corpus <- function(corp) {
  corp %>% 
    tm_map(content_transformer(tryTolower)) %>% 
    tm_map(removeWords, custom.stopwords) %>% 
    tm_map(removePunctuation) %>% 
    tm_map(stripWhitespace) %>% 
    tm_map(removeNumbers)  
  return(corp)
}