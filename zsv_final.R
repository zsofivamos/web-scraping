library(tidyverse)
library(rvest)
library(jsonlite)
library(data.table)

### 1. Create function for pulling data

# let's create a function to get data from one page
# input argument is the URL 

get_one_page <-  function(url) {
  json_response <- fromJSON(url)
  
  # the JSON response is a list but we only need the first element '$result'
  df <- json_response$result
  return(df)
}

### 2. Create input argument

# the URL has to parts we need to amend - number of results and page number
# let's make a function for the first part

create_first_part_of_url <- function(n_results) {
  url_1 <- paste0('https://search.api.cnn.io/content?q=mount%20everest&size=10&from=',n_results,'&page=')
  return(url_1)
}

# then define a sequence - the logic was pulled from the website
results <- seq(from = 0, to = 50, by = 10)

# and use lapply to create the first part of the URL we need
url_1 <- unlist(lapply(results, create_first_part_of_url))

# generate final URLs
# first, an empty list we can append
urls <- NULL

# create variable for page numbers
n_page <- c(1:6)

# then loop through them
for (i in n_page){
  
  # select ith part of url_1 to paste only to avoid 6 repetitions per URL
  url <- paste0(url_1[i], i)
  
  # append existing URL vector
  urls <- c(urls, url)
}

### 3. Get actual data

# let's get everything to one list
list_of_dfs <-lapply(urls, get_one_page) 

# create raw dataset 
raw_df <- rbindlist(list_of_dfs, fill = TRUE)

### 4. Clean data

# check column names so we can decide which ones to drop
colnames(raw_df)

# keep selected columns only
final_df <- select(raw_df, "headline", "body", "type", "url" , "firstPublishDate", "byLine",)

# Voilá!
saveRDS(final_df, "final.rds")


