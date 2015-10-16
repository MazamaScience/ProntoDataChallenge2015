#' ---
#' title: "Reading in Data"
#' author: "Mazama Science"
#' output: 
#'  html_document: 
#'    theme: spacelab
#'    toc: true
#' ---

#+ note, include=FALSE
# [[[--->>> SEE http://yihui.name/knitr/options FOR COMPREHENSIVE LIST OF KNITR OPTIONS <<<---]]]
#' -------------------------------------------------------------------------------------------------

#+ setup, include=FALSE
# [[[--->>> THIS CHUNK MUST EXIST TO SET GLOBAL CHUNK OPTIONS <<<---]]]
rm(list=ls())
library(knitr)
opts_chunk$set(warning=FALSE, message=FALSE, tidy=FALSE)

#' This notebook describes how to read in CSV data for the Pronto 2015 Data Challenge.
#' 
#' # Reading in CSV data #
#' 
#' We use Hadley Wickham's readr package which must be installed.

#+ station.csv

# Read station data and take a quick look
station <- readr::read_csv('../data/2015_station_data.csv')
head(station)

# Convert dates using the *lubridate* package
station$online <- lubridate::mdy(station$online,tz="America/Los_Angeles")
head(station)


#' ----


