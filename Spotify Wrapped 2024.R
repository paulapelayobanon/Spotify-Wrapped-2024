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
View(streaminghistory1)

file.exists("~/Just for fun - R/Spotify Data/my_spotify_data/Spotify Account Data/StreamingHistory_music_1.json")
file_content2 <- readLines("~/Just for fun - R/Spotify Data/my_spotify_data/Spotify Account Data/StreamingHistory_music_0.json")
parsed_data2 <- fromJSON(paste(file_content2, collapse = " "))
streaminghistory2 <- parsed_data2 %>% bind_rows()
View(streaminghistory2)

## Merge the files and check how it looks
streaminghistorymerged <- bind_rows(streaminghistory1, streaminghistory2)
View(streaminghistorymerged)
str(streaminghistorymerged)

# 3. Clean data

## Transform the first column into a date column
## Remove data prior to 2024-01-01 and after 2024-08-31
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
## Create a basic plot with some aesthetics
streaminghours <- mySpotify %>%
  group_by(week = floor_date(date, "week")) %>%
  summarize(hours = sum(Minutes, na.rm = TRUE)/60) %>%
  arrange(week) %>%
  ggplot(aes(x = week, y = hours)) + geom_col(aes(fill = hours)) +
  theme_minimal() +
  labs(x = "Week", y = "Hours", title = "Hours listened per week") +
  scale_fill_gradient(low = "#1db954", high = "#1db954")
 
  
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
topartists <- total_hours_artist %>% top_n(10, totalhours)
topartists <- topartists %>% arrange(-totalhours)
topartists

##Plot the top 10 in a bar chart
topartistsplot <- topartists %>%
  ggplot(aes(x = reorder(artistName, -totalhours), y = totalhours, group = artistName, fill = artistName)) +
  geom_bar(stat = "identity", show.legend = FALSE) + theme_minimal() +
  labs(title = "Top 10 artists", x = "Artist", y = "Hours") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
topartistsplot

# 6. Retrieve most listened songs

## Group by songs
## Summarize by minutes
topminuteslistened <- mySpotify %>%
  filter(!is.na(trackName)) %>%
  group_by(trackName) %>%
  summarize(minutesListened = sum(Minutes, na.rm = TRUE))
View(topminuteslistened)

## Create the song top 10 and arrange in descending order
topsongs <- topminuteslistened %>% top_n(10, minutesListened)
topsongs <- topsongs %>% arrange(-minutesListened)
topsongs

## Plot the top 10 in a bar chart
topsongsplot <- topsongs %>%
  ggplot(aes(x = reorder(trackName, minutesListened), y = minutesListened)) +
  geom_col(aes(fill = trackName)) + theme_minimal() +
  labs(x = "Song", y = "Minutes", Title = "Top 10 most listened songs") +
   theme(plot.margin = margin(0.5,0.5,-1,0.5, "cm"))
topsongsplot



  