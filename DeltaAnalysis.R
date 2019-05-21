# Exercises from the book Text Mining In Practice In R
# Chapter 2: Text Mining Basics
# Data source: https://github.com/padames/text_mining/blob/master/oct_delta.csv

# Set Options
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL', 'C')

library(stringi)
library(stringr)
library(qdap)
library(curl)

text.df2 <- read.csv(curl("https://raw.githubusercontent.com/padames/text_mining/master/oct_delta.csv"), header = T, stringsAsFactors = F)


