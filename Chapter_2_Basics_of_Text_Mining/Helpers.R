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

e <- new.env()
e$custom.stopwords <- c(stopwords("en"), 'lol', 'smh', 'delta')

clean.corpus <- function(corp) {
  corp <- corp %>%
    tm_map(content_transformer(tryTolower)) %>%
    tm_map(removeWords, e$custom.stopwords) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(removeNumbers)
  return(corp)
}


e$clean.vec <- function(text.vec, stop_words = NULL) {
  if (is.null(stop_words)) {
    stopWords <- e$custom.stopwords # part of the binding environment
  }
  else {
    stopWords <- stop_words
  }
  return(text.vec %>% tryTolower() %>%
    removeWords(stopWords) %>%
    removePunctuation() %>%
    stripWhitespace() %>%
    removeNumbers())
}

