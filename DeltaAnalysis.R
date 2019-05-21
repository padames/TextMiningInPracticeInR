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
library(tm)

# STEP 0: read the csv file (already cleand up by Ted Kwartler)
# https://stackoverflow.com/a/31178716/1585486
text.df <- read.csv(curl("https://raw.githubusercontent.com/padames/text_mining/master/oct_delta.csv"), header = T, stringsAsFactors = F)
# > str(text.df)
# 'data.frame':	1377 obs. of  5 variables:
#   $ weekday: chr  "Thu" "Thu" "Thu" "Thu" ...
# $ month  : chr  "Oct" "Oct" "Oct" "Oct" ...
# $ date   : int  1 1 1 1 1 1 1 1 1 1 ...
# $ year   : int  2015 2015 2015 2015 2015 2015 2015 2015 2015 2015 ...
# $ text   : chr  "@mjdout I know that can be frustrating..we hope to have you parked and deplaned shortly. Thanks for your patience.  *AA" ...

df <- data.frame(doc_id = seq(1:nrow(text.df)), # a numeric index
                 text = text.df$text) # the vector of 1377 tweets

# STEP 1: Create a corpus

corpus <- VCorpus(DataframeSource(df))

# STEP 2: Clean up the corpus

source("Helpers.R")

corpus <- clean.corpus(corpus)


