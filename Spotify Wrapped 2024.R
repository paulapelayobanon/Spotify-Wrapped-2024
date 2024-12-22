### SPOTIFY WRAPPED 2024 - AN ANALYSIS ###

# The goal of this project is to perform an analysis on Spotify's raw data
# to check on another end the data displayed officially by Spotify and get
# advanced insights from the file

# 1. Import the required libraries

library(rjson)
library(jsonlite)
library(lubridate)
library(gghighlight)
library(tidyverse)
library(knitr)
library(ggplot2)
library(ggdark)
library(plotly)

# 2. Import the files

## We have two spotify json files, one until August and another until December
## Import the files separately with the needed adjustments
file.exists("~/Just for fun - R/Spotify Data/my_spotify_data/Spotify Account Data/StreamingHistory_music_0.json")
file_content1 <- readLines("~/Just for fun - R/Spotify Data/my_spotify_data/Spotify Account Data/StreamingHistory_music_0.json")
parsed_data1 <- fromJSON(paste(file_content1, collapse = " "))
streaminghistory1 <- parsed_data1 %>% bind_rows()

file.exists("~/Just for fun - R/Spotify Data/my_spotify_data/Spotify Account Data/StreamingHistory_music_1.json")
file_content2 <- readLines("~/Just for fun - R/Spotify Data/my_spotify_data/Spotify Account Data/StreamingHistory_music_1.json")
parsed_data2 <- fromJSON(paste(file_content2, collapse = " "))
streaminghistory2 <- parsed_data2 %>% bind_rows()

## Merge the files and check how it looks
streaminghistorymerged <- bind_rows(streaminghistory1, streaminghistory2)
View(streaminghistorymerged)
str(streaminghistorymerged)

# 3. Clean data

## Transform the first column into a date column
## Remove data prior to 2024-01-01 and after 2024-10-31
## Create columns seconds and minutes
streaminghistorymerged <- streaminghistorymerged %>%
  rename(date = endTime) %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= "2024-01-01" & date <= "2024-10-31") %>%
  mutate(Seconds = msPlayed/1000, Minutes = Seconds/60)
mySpotify <- streaminghistorymerged
str(mySpotify)

# 4. Retrieve activity per week and hours

## Group by week
## Summarize by hours
## Reorder by date
streaminghours <- mySpotify %>%
  group_by(week = floor_date(date, "week")) %>%
  summarize(hours = sum(Minutes, na.rm = TRUE)/60) %>%
  arrange(week)

## Create a basic plot with some aesthetics 
print(streaminghours <- mySpotify %>%
  group_by(week = floor_date(date, "week")) %>%
  summarize(hours = sum(Minutes, na.rm = TRUE)/60) %>%
  arrange(week) %>%
  ggplot(aes(x = week, y = hours)) + geom_col(aes(fill = hours)) +
  theme_minimal() +
  labs(x = "Week", y = "Hours", title = "Hours listened per week") +
  scale_fill_gradient(low = "#1db954", high = "#1db954"))  

# 5. Retrieve activity per artist

## Group by artist
## Summarize by hours
hoursartist <- mySpotify %>%
  group_by(artistName, date = floor_date(date, "month")) %>%
  summarize(hours = sum(Minutes, na.rm = TRUE)/60, .groups = "drop") 
View(hoursartist)

## Summarize total hours and arrange in descending order
total_hours_artist <- hoursartist %>%
  group_by(artistName) %>%
  summarize(totalhours = sum(hours), .groups = "drop") %>%
  arrange(-totalhours)

## Create the artist top 10 and arrange in descending order
top10artists <- total_hours_artist %>%
  top_n(10, totalhours) %>%
  arrange(-totalhours)
View(top10artists)


##Plot the top 10 in a bar chart
top10artistsplot <- top10artists %>%
  ggplot(aes(x = reorder(artistName, -totalhours),
             y = totalhours, group = artistName, fill = artistName)) +
  geom_bar(stat = "identity", show.legend = FALSE) + theme_minimal() +
  labs(title = "Top 10 artists", x = "Artist", y = "Hours") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
top10artistsplot

# 6. Retrieve most listened songs

## Group by songs
## Summarize by minutes
topminuteslistened <- mySpotify %>%
  filter(!is.na(trackName) &  !is.na(artistName)) %>%
  group_by(trackName, artistName) %>%
  summarize(minutesListened = sum(Minutes, na.rm = TRUE))
View(topminuteslistened)

## topminuteslistened is a good measurement but it doesn't tell the whole story
## as it doesn't consider song length. Let's consider top plays

## filter out NA values, group by song and artist
## summarize by plays and arrange in descending order
topplays <- mySpotify %>%
  filter(trackName != "Unknown Track" & artistName != "Unknown Artist" &
           !is.na(trackName) & !is.na(artistName)) %>%
  group_by(trackName, artistName) %>%
  summarise(plays = n(), .groups = "drop") %>%
  arrange(-plays)
View(topplays)

## Create the songlengths variable
songlengths <- mySpotify %>%
  group_by(trackName, artistName) %>%
  summarise(MaxPlayed = max(Seconds), .groups = "drop") %>%
  arrange(-MaxPlayed)

## Integrate songlengths into topplays
## Arrange in descending order
topsongs <- topplays %>%
  left_join(songlengths, by = c("trackName", "artistName")) %>%
  arrange(-plays)

## Create the song top 10 considering song length
top10songs <- topsongs %>% top_n(10, plays) %>%
  select(trackName, artistName, plays, MaxPlayed)
View(top10songs)

## Plot the top 10 in a bar chart
top10songsplot <- top10songs %>%
  ggplot(aes(x = reorder(trackName, plays), y = plays)) +
  geom_col(aes(fill = trackName)) + theme_minimal() +
  labs(x = "Song", y = "Plays", title = "Top 10 most listened songs") +
  coord_flip() +
  theme(legend.position = "none") +
  theme(plot.margin = margin(0.5,0.5,0.5,0.5, "cm"))
top10songsplot
