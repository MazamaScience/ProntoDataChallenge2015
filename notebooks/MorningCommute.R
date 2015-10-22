#' ---
#' title: "Morning Commute"
#' author: "Jonathan Callahan"
#' output: 
#'  html_document: 
#'    theme: spacelab
#'    toc: true
#' ---

#+ note, include=FALSE
# [[[--->>> SEE http://yihui.name/knitr/options FOR COMPREHENSIVE LIST OF KNITR OPTIONS <<<---]]]
#' ----------------------------------------------------------------------------

#+ setup, include=FALSE
# [[[--->>> THIS CHUNK MUST EXIST TO SET GLOBAL CHUNK OPTIONS <<<---]]]
rm(list=ls())
library(knitr)
opts_chunk$set(warning=FALSE, message=FALSE, tidy=FALSE)

#' This notebook uses the Mazama_station and Mazama_trip datasets created 
#' with the following scripts:
#' 
#' * createStationDF.R
#' * createTripDF.R
#' 
#' These datasets augment the original 2015 Pronto Data Challenge data with
#' numerous additional columns so that we can ask more interesting questions.
#' 
#' Throughout this analysis we will make use of a variety of R packages including:
#' 
#' * dplyr
#' * reshape2
#' * ggplot2
#' 
#' *R cognoscenti will recognize these as all coming from Hadley Wickham.*
#' 
#' 

#+ station.csv

# Read station data and take a quick look
station <- readr::read_csv('./data/2015_station_data.csv')
head(station)

# Convert dates using the *lubridate* package
station$online <- lubridate::mdy(station$online,tz="America/Los_Angeles")
head(station)


#' ----


