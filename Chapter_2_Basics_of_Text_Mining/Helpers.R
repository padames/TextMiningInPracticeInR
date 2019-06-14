# Exercises from the book Text Mining In Practice In R
# Chapter 2: Text Mining Basics
# Helpers for main script
library(magrittr)
library(tm)

tryTolower <- function(s) {
  s_lowered <- tryCatch( tolower(s),
                         error = function(e) e ) # this is the only time `tolower` is called
  if (inherits(s_lowered, 'error')) {
    s_lowered <- NA
  }
  return(s_lowered)
}



custom.stopwords <- c(stopwords("en"), 'lol', 'smh', 'delta')

clean.corpus <- function(corp) {
  corp <- corp %>%
    tm_map(content_transformer(tryTolower)) %>%
    tm_map(removeWords, custom.stopwords) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(removeNumbers)
  return(corp)
}


clean.vec <- function(text.vec) {
  return(text.vec %>% tryTolower() %>%
    removeWords(custom.stopwords) %>%
    removePunctuation() %>%
    stripWhitespace() %>%
    removeNumbers())
}

