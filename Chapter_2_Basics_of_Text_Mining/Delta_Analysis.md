---
title: "Text Mining Delta Airlines Tweets from 2015"
author: "P. Adames"
date: "May 21, 2019"
output: html_document
---




# Analysis from a clean data file of Delta Airlines

This text mining exercise of a curated sample of 15 days of Tweets from October 2015 
from the Delta Airlines Customer Service team 
looks to answer a few relevant questions:

1. What is the average length of the customer service reply in this social media platform?
2. What links were referenced most often?
3. How many social media responses per customer service representative are reasonable?
4. How many team members are needed for a similar size of operation?

Some of these can be addressed without the full data mining preprocessing, actually
the dates are useful for identifying weekly patterns for the user interaction load through
this platform. This could be the case if one wanted to go deeper into question 3 to assess
the workforce required for weekends in contrast to weekdays.
These questions can be answered before doing the preparation and cleaning steps, however,
for the sake of completeness and comparison, those steps are shown below first.

# Preparing and Cleaning the data

The data for these exercises in text mining can be found in [Ted Kwartler's Github repo](https://github.com/kwartler/text_mining).
The tweets are curated by carefully filtering those for the month of October, 2015. Their date is part of the information collected.
It's a good idea to fork the original repo and use the forked version in case the original author takes his repo down.

## Step 1

The most straight forward approach to fetching the data directly from a Github repository 
and reading it into a comma separated text file, is to use the curl library through R.
The main advantage is that curl identifies the type of content and parses it correctly without
much intervention from the user.
Care should be taken to reference the **raw** version of the text file, instead of the html rendition
of it that the hosting website provides to display the information in a human readable form through web browsers.



```r
text.df <- read.csv(curl("https://raw.githubusercontent.com/padames/text_mining/master/oct_delta.csv"),
                    header = T, stringsAsFactors = F)
```

```
## [1] "Size of data frame read in KB: 256.2"
```

```
## [1] "Number of rows and columns in data frame: (1377,5)"
```
The columns in this data frame are five: weekday, month, date, year, text. Only the last one is required to continue doing the
text mining of the tweets. 
Thus, a data frame with only the columns `doc_id` and `text` is created to use as input for the
functions in the `tm` package.


```r
df <- data.frame(doc_id = seq(1:nrow(text.df)), # a numeric index
                 text = text.df$text) # the vector of 1377 tweets
```

## Step 2

The latest version of `tm`, 0.7-6, changed the way the virtual corpus is created by eliminating the 
need for a reader closure to be provided with information on the columns to be parsed as the index and the actual text.
Now, provided the data frame has the names `doc_id` and `text`, the function will be able to extarct the 
information correctly.


```r
corpus <- VCorpus(DataframeSource(df))
```

## Step 3

The corpus is cleaned up using auxiliary functions found in the 
external file `Helpers.R` which is sourced at the beginning of this file.


```r
corpus.clean <- clean.corpus(corpus)
```

To test that we really clean the corpus a simple test is run, you can try different values of `tweet_number` between 1 and 1377:


```r
tweet_number = 1045
not_cleaned <- corpus[tweet_number][[1]]$content
cleaned <- corpus.clean[tweet_number][[1]]$content
test_of_equality <- !(identical( cleaned, not_cleaned))
```
The tests give the following results for tweet number 1045:

```
## [1] "Tweet '1045' was cleaned: TRUE"
```

```
## [1] "tweet['1045'] original; @Kyrrie_Twin Kyrrie, what will the compensation be for? *VM"
```

```
## [1] "tweet['1045'] cleaned; kyrrietwin kyrrie will compensation vm"
```

# Analysis 

Here are answers from doing some text digging.

## What is the average length of the customer service reply in this social media platform?

Assuming that each tweet represents one single interaction with a customer then the average length of each 
represents the answer to this question. Tweet limits the length of each response to a maximum of 280 characters ([Tweeter increases length][ref1]).

Working on the original Tweets, inspection of the data frame shows that the column named `text` has all the tweets.
Since it is a vector of strings the vectorized funcion `nchar` can be used to read the length in characters of each
tweet and return a vector of those values. After that calculating their mean is straight forward:


```r
round(x = mean(nchar(text.df$text)), digits = 0)
```

```
## [1] 92
```

Now for comparison let's look at the average number of characters after cleaning the tweets for bag of words text mining:


```r
clean.dataframe <- data.frame(text = unlist(sapply(corpus.clean, `[`, "content")))
round(mean(nchar(clean.dataframe[,1])), digits = 0)
```

```
## [1] 60
```
A substantial reduction in verbosity but not as good an indicator of how much it is needed to communicate with humans using Tweeter.


## What links were referenced most often?

Ted Kwartler suggests on page 35 of his [book][ref2] that references encompass a phone number or a web site.
These would be ways to refer a customer to contact the Customer Service at Delta directly, or to visit a FAQ
page on the Delta Airlines website.


```r
tweets.with.phone.numbers <- sum(grepl('[0-9]{3}|[0-9]{4}', text.df$text, ignore.case = T))
rounded.phone.number.freq <- round(tweets.with.phone.numbers / nrow(text.df) * 100L, digits = 2)
paste0("Phone number frequency (%): ", rounded.phone.number.freq)
```

```
## [1] "Phone number frequency (%): 14.45"
```

```r
tweets.with.web.sites <- sum(grepl('http', text.df$text, ignore.case = T))
rounded.web.site.freq <- round(tweets.with.web.sites / nrow(text.df) * 100L, digits = 2)
paste0("Web site frequency (%): ", rounded.web.site.freq)
```

```
## [1] "Web site frequency (%): 4.28"
```

```r
ratio.phone.to.web <- round(rounded.phone.number.freq / rounded.web.site.freq, digits = 1)
paste0("Phone number to web site ratio: ", ratio.phone.to.web) 
```

```
## [1] "Phone number to web site ratio: 3.4"
```

This customer service agent cohort is 3.4 times more likely to give clients a phone number to address or follow up their concerns than to refer them to a web site page to do the same.


## How many social media responses per customer service representative are reasonable?

For this Ted Kwartler suggests on page 32 of his [book][ref2], using a function to detect the last two characters of every tweet, hoping to capture the initials used for each agent. Here his code to extract the last two letters of the tweet but used over the entire cleaned data frame:

```r
last.chars <- function(text, num) {
  last <- substr(text, nchar(text) - num + 1, nchar(text))
  return(last)
}
tbl1 <- table(Filter(x = last.chars(clean.dataframe[,1], 2), min = 2))
tbl1[order(-tbl1)]
```

```
## 
##      pl  ng  aa  wg  ml  dd  mr  rd  vm  kc  ab  rs  sb  rb  ls  km  ec 
## 368  95  81  62  58  56  55  52  52  50  49  42  40  39  29  28  27  26 
##  md  sd  bb  cm  hw  jh  ad  jj  ck  vi  dr  tp  qb  cs  th 
##  23  22  21  18  14  13  12  10   8   8   7   6   4   1   1
```

Here the last word of the whole tweet is extracted using `stri_extract_last_words` from the `stringi` package.
This hopefully covers the case of variable number of letters or non-standard initials. 


```r
initials <- stri_extract_last_words(clean.dataframe[,1])
tbl2 <- table(Filter(x = initials, min = 2, max = 2))
tbl2[order(-tbl2)]
```

```
## 
##      pl  ng  aa  rs  vm  wg  dd  ml  rd  mr  kc  sb  jh  ab  md  rb  ec 
## 208 104  95  74  65  59  59  57  56  55  53  50  47  45  43  37  36  33 
##  ls  km  sd  bb  cm  hw  ad  jj  ck  vi  dr  tp  qb  cs  us  am  dm  mi 
##  28  27  26  24  18  14  12  10   8   8   7   7   4   2   2   1   1   1 
##  th 
##   1
```

The average response per agent over 15 days is 42 with Kwartler's function and 37 with the new code using library `stringi`'s function. Either way agent `pl` seems to be the hardest working in the group with 104 responses over this period. If especific work loads needed to be analyzed on particular peridos of time like weekends then the original data frame needs to be subset based on the time window to be considered. 

Some tweets are continuations of previous ones and they end with `\2` or `\3` to indicate the sequence after the agent's two-letter signature, this would require further examination to see how it affects the averages computed here. Numbers and other symbols are removed in the clean up procedure so this would have to be done on the original tweets.


## How many team members are needed for a similar size of operation?

According to Kwartler calculations there are 33 agents to process 1009 interactions through Tweeter. The new code indicated 37 agents processing 1169 interactions over the 15 days of data availble.


# Term frequency analysis

The term document matrix contains the incidence of each individual word on each document, in this case each Tweet.


```r
tdm <- TermDocumentMatrix(corpus.clean)
inspect(tdm)
```

```
## <<TermDocumentMatrix (terms: 2626, documents: 1377)>>
## Non-/sparse entries: 10362/3605640
## Sparsity           : 100%
## Maximal term length: 24
## Weighting          : term frequency (tf)
## Sample             :
##               Docs
## Terms          110 113 129 287 306 308 373 507 89 91
##   can            0   0   1   0   0   0   0   0  0  0
##   confirmation   0   0   0   0   0   0   0   1  0  0
##   flight         0   0   0   0   0   0   1   0  0  0
##   hear           1   0   0   0   0   0   0   0  0  1
##   number         0   0   0   0   0   0   0   0  0  0
##   please         0   0   0   0   0   0   0   0  0  0
##   pls            1   1   1   0   1   0   0   1  0  1
##   sorry          1   0   0   0   0   0   0   0  0  0
##   team           0   0   0   0   0   0   0   0  0  1
##   will           0   0   0   0   0   0   0   0  0  1
```

Now the TDM is turned into a matrix and each row is summed to obtain a vector with the number of times each term appears in all of the documents.
From this vector a data frame can be built to make a graphical representation of the most common terms.


```r
tdm.m <- as.matrix(tdm)
frequency <- rowSums(tdm.m)
frequencies.df <- data.frame( name = names(frequency), frequency = frequency)
frequencies.df <- frequencies.df[order(frequency, decreasing = T), ]
frequencies.df[1:20,]
```

```
##                      name frequency
## please             please       221
## can                   can       190
## sorry               sorry       182
## will                 will       159
## pls                   pls       153
## hear                 hear       151
## team                 team       137
## confirmation confirmation       127
## flight             flight       106
## number             number       100
## assistance     assistance        91
## thanks             thanks        90
## let                   let        88
## apologies       apologies        87
## know                 know        86
## happy               happy        79
## follow             follow        78
## followdm         followdm        76
## look                 look        76
## amp                   amp        72
```

The mean term frequency is 4. Considering the 20 most
frequent words reveals nothing alien to the context of an airline customer service operation.
However it can be inferred that many of the interactions on the platform are related to correcting
or acknowledging errors or inconveniences for the customers as the words *sorry* and *apology*
 appears so prominently. 

[ref1]: https://bgr.com/2018/02/08/twitter-character-limit-280-vs-140-user-engagement/ "Tweeter increases length"
[ref2]: https://www.amazon.com/Text-Mining-Practice-Ted-Kwartler/dp/1119282012 
