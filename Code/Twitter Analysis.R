# Twitter Analysis 
setup_twitter_oauth('jNjVkpRdmRceYEiZyO33t8CXu', # api key
                    'HdIKY3YgNRxNLVwEK4Qz4gX0YdmpoWKUUrnICXcfxhmPCFEJl1',
                    '1051535732777648129-YUDQFUzojiCNl2iQ3xPpyAIOmDM3bB',
                    'r2u3LMszcp2fWu7NtDBIFsJim19i10MvzHC8CX9HQp9Bv')
sanangelo <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized',
                           geocode = "31.4638,-100.4370,127mi", include_rts = FALSE)
sanangelo$place <- 'San Angelo'
amarillo <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized',
                          geocode = "35.2220,-101.8313,73mi", include_rts = FALSE)
amarillo$place <- 'Amarillo'
Lubbock <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized', 
                         geocode = "33.5779,-101.8552,49mi", n=1000, include_rts = FALSE)
Lubbock$place <- 'Lubbock'
Austin <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized',
                        geocode = "30.2672,-97.7431,57mi", n=1000, include_rts = FALSE)
Austin$place <- 'Austin'
Houston <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized',
                         geocode = "29.7604,-95.3698,62mi", n=20000, include_rts = FALSE)
Houston$place <- 'Houston'
SevenSisters <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized',
                              geocode = "28.0106,-98.5392,104mi", n=1000, include_rts = FALSE)
SevenSisters$place <- 'Seven Sisters'
Athens <- search_tweets('vax OR vaccine OR vaccinated OR vaccination OR immunization OR immunized',
                        geocode = "32.2049,-95.8555,104mi", n=2000, include_rts = FALSE)
Athens$place <- 'Athens'
combineddataframe <- rbind(Athens,SevenSisters,Houston,Austin,Lubbock,amarillo,sanangelo)
combineddataframe$text<- na.omit(combineddataframe$text)
combineddataframe = combineddataframe[!duplicated(combineddataframe$text),]

sp_sanangelo <- search_tweets('vacuna', geocode = "31.4638,-100.4370,127mi", include_rts = FALSE)
sp_sanangelo$place <- 'San Angelo'
sp_amarillo <- search_tweets('vacuna', geocode = "35.2220,-101.8313,73mi", include_rts = FALSE)
sp_amarillo$place <- 'Amarillo'
sp_Lubbock <- search_tweets('vacuna', geocode = "33.5779,-101.8552,49mi", n=1000, include_rts = FALSE)
sp_Lubbock$place <- 'Lubbock'
sp_Austin <- search_tweets('vacuna', geocode = "30.2672,-97.7431,57mi", n=1000, include_rts = FALSE)
sp_Austin$place <- 'Austin'
sp_Houston <- search_tweets('vacuna', geocode = "29.7604,-95.3698,62mi", n=20000, include_rts = FALSE)
sp_Houston$place <- 'Houston'
sp_SevenSisters <- search_tweets('vacuna', geocode = "28.0106,-98.5392,104mi", n=1000, include_rts = FALSE)
sp_SevenSisters$place <- 'Seven Sisters'
sp_Athens <- search_tweets('vacuna', geocode = "32.2049,-95.8555,104mi", n=2000, include_rts = FALSE)
sp_Athens$place <- 'Athens'
spanish_tweets <- rbind(sp_Athens, sp_SevenSisters, sp_Houston, sp_Austin,
                        sp_Lubbock, sp_amarillo, sp_sanangelo)
spanish_tweets <- spanish_tweets[!duplicated(spanish_tweets$text),]
spanish_tweets$text<- na.omit(spanish_tweets$text)
spanish_tweets[,5, drop = FALSE]

# translate spanish tweets
translated <- translate(dataset = spanish_tweets, content.field = 'text',
                        google.api.key = "AIzaSyAGMlOFArvFwjFJOcbRY5JVNdq8jAoQLj0", 
                        source.lang = 'es', target.lang = 'en')
colnames(combineddataframe)
colnames(translated)
comb <- combineddataframe[ ,c(3, 13, 14, 17, 32, 91, 5)]
tTweets <- translated[ ,c(3, 13, 14, 17, 32, 91, 92)]
colnames(tTweets)
colnames(comb)
tTweets[ ,7, drop = FALSE]

colnames(tTweets)[7] <- "text"
final_texas_tweets <- rbind(tTweets, comb)
head(final_texas_tweets)

# convert to dataframe with all characters to write to csv
texas_tweets_df <- final_texas_tweets
texas_tweets_df2 = data.frame(lapply(texas_tweets_df, as.character), stringsAsFactors=FALSE)
setwd("D:\\1 Masters\\Dataset\\Project Datasets")
todays_date <- Sys.Date()
output_name <- paste("Twitter ", todays_date,".csv", sep="")
write.csv(texas_tweets_df2, file = output_name)

# from https://rtweet.info/ 
p <- final_texas_tweets %>%
  ts_plot("3 hours") +
  ggplot2::theme_minimal() +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = "Date", y = "Number of Tweets",
    title = "Volume of Vaccine Related Tweets By Date")
w <- p + theme(axis.text=element_text(size=18),
               axis.title=element_text(size=18))
q <- w + theme(plot.title = element_text(size=20, face="bold"))
Texas_Tweets_Plot <- q + theme(plot.title = element_text(hjust = 0.5))
Texas_Tweets_Plot

# Change column names and classes
colnames(final_texas_tweets)
texasdf <- final_texas_tweets %>% dplyr::select(Date = created_at, Text = text,
                                                Favourite_Count = favorite_count, Number_of_Retweets = retweet_count,
                                                Language = lang, Hashtags = hashtags, Location = place)
selected <- c("Date", "Text", "Location", "Language", "Hashtags")
texasdf[selected] <- lapply(texasdf[selected], as.character)
sapply(texasdf, class)

# remove special characters
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]", " ", x)
texasdf$Text <- sapply(texasdf$Text, removeSpecialChars)
texasdf$Date <- as.Date(texasdf$Date)
texasdf$Text <- sapply(texasdf$Text, tolower)
fix.contractions <- function(doc) { 
  doc <- gsub("won't", "will not", doc)
  doc <- gsub("can't", "can not", doc)
  doc <- gsub("n't", "not", doc)
  doc <- gsub("'ll", "will", doc)
  doc <- gsub("'re", "are", doc)
  doc <- gsub("'ve", "have", doc)
  doc <- gsub("'m", "am", doc)
  doc <- gsub("'d", "would", doc)
  doc <- gsub("'s", "", doc)
  return(doc)}
texasdf$Text <- sapply(texasdf$Text, fix.contractions)
str(texasdf[50, ]$Text, nchr.max = 300)

#define some colors to use throughout
twitter_hue <- c("#AA4371", "#c00000", "#37004D", "#000080", "#008000")

theme_project <- function() 
{theme(plot.title = element_text(hjust = 0.5),
       axis.text.x = element_blank(), 
       axis.ticks = element_blank(),
       panel.grid.major = element_blank(),
       panel.grid.minor = element_blank(),
       legend.position = "none")}

final_tweet_filtered <- texasdf %>%
  unnest_tokens(word, Text) %>%
  anti_join(stop_words) %>%
  distinct() %>%
  dplyr::filter(nchar(word) > 3)
p <- final_tweet_filtered %>%
  dplyr::count(word, sort = TRUE) %>%
  top_n(15) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot() +
  geom_col(aes(word, n), fill = twitter_hue[4]) +
  theme(legend.position = "none", 
        plot.title = element_text(hjust = 0.5),
        panel.grid.major = element_blank()) +
  xlab("Word") + 
  ylab("Word Count") +
  ggtitle("Most Common Words in Texas Tweets") +
  coord_flip()
p + theme(axis.text=element_text(size=10),
          axis.title=element_text(size=10))

undesirable_words <- c("https", "vaccine", "time",
                       "news", "vaccinated", "vaccines",
                       "vaccination", "doesn", "months", "anti",
                       "stop", "ready", "world", "people")

final_tweet_filtered <- texasdf %>%
  unnest_tokens(word, Text) %>%
  anti_join(stop_words) %>%
  dplyr::distinct() %>%
  dplyr::filter(!word %in% undesirable_words) %>%
  dplyr::filter(nchar(word) > 3)
r <- final_tweet_filtered %>%
  dplyr::count(word, sort = TRUE) %>%
  top_n(25) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot() +
  geom_col(aes(word, n), fill = twitter_hue[4]) +
  theme(legend.position = "none", 
        plot.title = element_text(hjust = 0.5),
        panel.grid.major = element_blank()) +
  xlab("Word") + 
  ylab("Word Count") +
  ggtitle("Most Common Words In Vaccine Related Texas Tweets") +
  coord_flip()
z <- r + theme(axis.text=element_text(size=18),
               axis.title=element_text(size=18))
z + theme(plot.title = element_text(size=20, face="bold"))

new_sentiments <- get_sentiments("afinn")
names(new_sentiments)[names(new_sentiments) == 'value'] <- 'score'
new_sentiments <- new_sentiments %>% mutate(lexicon = "afinn", 
                                            sentiment = ifelse(score >= 0, "positive", "negative"),
                                            words_in_lexicon = n_distinct((word)))

tweets_words_counts <- final_tweet_filtered %>% dplyr::count(word, sort = TRUE)
wordcloud2(tweets_words_counts[1:13000, ], size = .5)

texas_nrc <- final_tweet_filtered %>%
  inner_join(get_sentiments("nrc")) %>%
  dplyr::filter(!sentiment %in% c("positive", "negative"))

syuzhet_vector <- get_sentiment(final_tweet_filtered$word, method="nrc")
nrc_plot <- texas_nrc %>%
  group_by(sentiment) %>%
  dplyr::summarise(word_count = dplyr::n()) %>%
  ungroup() %>%
  mutate(sentiment = reorder(sentiment, word_count)) %>%
  ggplot(aes(sentiment, word_count, fill = -word_count)) +
  geom_col() +
  guides(fill = FALSE) + 
  theme_project() +
  labs(x = "Emotion", y = "Word Count") +
  scale_y_continuous(limits = c(0, 25000)) +
  ggtitle("Sentiment Of Vaccine Related Tweets In Texas") +
  coord_flip()
nrc_plot <- nrc_plot + theme(axis.text=element_text(size=18),
                             axis.title=element_text(size=18))
nrc_plot + theme(plot.title = element_text(size=20, face="bold"))

# Overall sentiment (positive or negative)
vaccine_bing <- final_tweet_filtered %>% inner_join(get_sentiments("bing"))
sent_texas <- vaccine_bing %>% group_by(sentiment) %>%
  dplyr::summarise(word_count = dplyr::n()) %>%
  ungroup() %>% mutate(sentiment = reorder(sentiment, word_count)) %>% 
  ggplot(aes(sentiment, word_count, fill = sentiment)) +
  geom_col() + guides(fill = FALSE) + theme_project() + 
  labs(x = NULL, y = "Word Count") + scale_y_continuous(limits = c(0, 15000)) +
  ggtitle("Sentiment of Vaccine Related Tweets") + coord_flip()
sent_texas
#Get the count of words per sentiment for each area in Texas 
texas_sentiment_nrc <- texas_nrc %>%
  dplyr::group_by(Location, sentiment) %>%
  dplyr::count(Location, sentiment) %>%
  dplyr::select(Location, sentiment, sentiment_city_count = n)
texas_sentiment <- texas_nrc %>%
  dplyr::count(Location) %>%
  dplyr::select(Location, city_total = n)

#Join the two and create a percent field
city_radar_chart <- texas_sentiment_nrc %>%
  inner_join(texas_sentiment, by = "Location") %>%
  mutate(percent = sentiment_city_count / city_total * 100 ) %>%
  dplyr::filter(Location %in% c("Austin","Houston","San Angelo")) %>%
  dplyr::select(-sentiment_city_count, -city_total) %>%
  spread(Location, percent) %>%
  chartJSRadar(showToolTipLabel = TRUE,
               main = "Vaccine Related Texas Tweets Radar")
city_radar_chart

vaccine_bigrams <- texasdf %>%
  unnest_tokens(bigram, Text, token = "ngrams", n = 2)
bigrams_separated <- vaccine_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")
bigrams_filtered <- bigrams_separated %>%
  dplyr::filter(!word1 %in% stop_words$word) %>%
  dplyr::filter(!word2 %in% stop_words$word) %>%
  dplyr::filter(!word1 %in% undesirable_words) %>%
  dplyr::filter(!word2 %in% undesirable_words)

bigram_texas <- bigrams_filtered %>%
  dplyr::filter(word1 != word2) %>%
  dplyr::filter(Location != "NA") %>%
  unite(bigram, word1, word2, sep = " ") %>%
  inner_join(texasdf) %>%
  count(bigram, Location, sort = TRUE) %>%
  group_by(Location) %>%
  slice(seq_len(7)) %>%
  ungroup() %>%
  arrange(Location, n) %>%
  mutate(row = row_number())

bigram_texas %>%
  ggplot(aes(row, n, fill = Location)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Location, scales = "free_y") +
  xlab(NULL) + ylab(NULL) +
  scale_x_continuous(
    breaks = bigram_texas$row,
    labels = bigram_texas$bigram) +
  theme_project() +
  theme(panel.grid.major.x = element_blank()) +
  ggtitle("Bigrams Per Region of Texas") +
  coord_flip()

# Sentiment of most comonly occuring words
texas_nrc <- final_tweet_filtered %>%
  inner_join(get_sentiments("nrc"))

texas_sentiment <- texas_nrc %>%
  group_by(sentiment) %>%
  count(word, sort = TRUE) %>%
  arrange(desc(n)) %>%
  slice(seq_len(10)) %>%
  ungroup()
w <- texas_sentiment %>%
  ggplot(aes(word, 1, label = word, fill = sentiment )) +
  geom_point(color = "transparent") +
  geom_label_repel(force = 1,nudge_y = .5,  
                   direction = "y",
                   box.padding = 0.05,
                   segment.color = "transparent",
                   size = 9) +
  facet_grid(~sentiment) +
  theme_project() +
  theme(axis.text.y = element_blank(), axis.text.x = element_blank(),
        axis.title.x = element_text(size = 6),
        panel.grid = element_blank(), panel.background = element_blank(),
        panel.border = element_rect("lightgray", fill = NA),
        strip.text.x = element_text(size = 20)) +
  xlab(NULL) + ylab(NULL) +
  ggtitle("Sentiment of Most Commonly Occuring Words") +
  coord_flip()
w  + theme(plot.title = element_text(size=24, face="bold"))

year_sentiment_nrc <- texas_nrc %>%
  group_by(Location, sentiment) %>%
  dplyr::count(Location, sentiment) %>%
  dplyr::select(Location, sentiment, sentiment_city_count = n)
year_sentiment_nrc
#Get the total count of sentiment words per year (not distinct)
total_sentiment_year <- texas_nrc %>%
  dplyr::count(Location) %>%
  dplyr::select(Location, city_total = n)
# Tweets by location
texas_location <- final_tweet_filtered %>%
  inner_join(get_sentiments("nrc")) %>%
  dplyr::filter(!sentiment %in% c("positive", "negative"))
tweets_by_location <- texas_location %>%
  dplyr::count(Location) %>%
  dplyr::select(Location, city_total = n)

tweets_by_location$Location <- factor(total_sentiment_year$Location, 
                                      levels=c("Lubbock", "San Angelo", "Amarillo",
                                               "Seven Sisters", "Austin", "Houston", "Athens"))
tweets_by_location <- tweets_by_location[!grepl("NA", tweets_by_location$Location),]
p <- ggplot(data = tweets_by_location, aes(x = Location, y = city_total, fill = Location)) +
  geom_bar(stat="identity") + xlab("Tweet Count") + ggtitle("Number of Vaccine Related Tweets By Location") +
  labs(x = "Location", y = "Number of Tweets")
q <- p + coord_flip()
q <- q + theme(legend.position = "none")
q <- q + theme(axis.text=element_text(size=18), axis.title=element_text(size=18))
q + theme(plot.title = element_text(size=20, face="bold"))

