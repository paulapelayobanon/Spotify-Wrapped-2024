# Spotify-Wrapped-2024
Like many people, I was suspicious about the output of my Spotify Wrapped in early December 2024, so I decided to take matters into my own hands and get insights myself from my raw data using R.

I am by no means a developer and I was just curious whether Spotify was right or not regarding my top artists and songs (spoiler alert: it was wrong, at least partly).

My R analysis is very basic and should only provide a few insights. I'm pretty sure you guys can dig ten times deeper and find gold mines - feel free to do so, I'm just glad that my code worked for once :D


# Instructions before starting
**1. Request your Spotify data.** You can do this directly from your account settings (not on the mobile app or desktop app, but on the web version). Once done, it takes a few days until you receive an email with a downloadable zip folder called "My Spotify Data".

**2. Work on the zip folder.** Make sure to extract all files out of the zip folder before starting. The relevant .json file you should work on must bear the name StreamingHistory_music. Be careful, I got two .json files - one with my data from December 2023 to August 2024 and another one from August 2024 to December 2024. Some people received one single file, I have no idea why I got two but anyway I had to merge them into one and then filter the data until I was left with only the data from January 2024 to October 2024 (this is the time frame Spotify allegedly takes for the Wrapped creation). 

**3. Download R and RStudio.** I assume you are somewhat familiar with R and RStudio if you're reading this :D At the moment of writing these lines I don't master any other language or IDE so I have no idea how the analysis would look like in Python or so. If you are good at R and some other language, please feel free to "translate" the code if you like!

**4. Install the required libraries** Do this once at the beginning and not as you go. It saves headaches!
- library(rjson)
- library(jsonlite)
- library(lubridate)
- library(gghighlight)
- library(tidyverse)
- library(knitr)
- library(ggplot2)
- library(ggdark)
- library(plotly)

# Inspiration
I based my work on https://github.com/savannamw2/SpotifyWrapped24/tree/main

**_Hope you enjoy this little project and happy coding!!_**

