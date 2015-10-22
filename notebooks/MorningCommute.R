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

#+ tips_by_hour

# Load augmeted data files
load('../data/Mazama_station.RData')
load('../data/Mazama_trip.RData')

# Set up some reusable colors
gnat002 <- adjustcolor('black',.002)
gnat005 <- adjustcolor('black',.005)
gnat01 <- adjustcolor('black',.01)
gnat02 <- adjustcolor('black',.02)
salmon <- adjustcolor('salmon',0.5)

plot(trip$elevationDiff ~ trip$hourOfDay, pch=15, col=gnat002)
abline(h=0,lwd=4,col=salmon)
title('Elevation Change vs. Hour of Day')

#'
#' What percentage of trips are taken each hour?
#' 

genderByHour <- table(trip$hourOfDay,trip$gender)
barplot(t(genderByHour),col=c('yellow','red','blue','green'))

barplot(genderByHour[,3],col=adjustcolor('royalblue',0.4))
barplot(genderByHour[,2],col=adjustcolor('red',0.4),add=TRUE)
barplot(genderByHour[,4],col=adjustcolor('green',0.4),add=TRUE)
barplot(genderByHour[,1],col=adjustcolor('yellow',0.4),add=TRUE)

# Experiments
#
# userTypeByHour <- table(trip$hourOfDay,trip$userType)
# barplot(t(userTypeByHour),col=c('purple','darkorange'))
# 
# barplot(userTypeByHour[,1],col=adjustcolor('purple',0.4))
# barplot(userTypeByHour[,2],col=adjustcolor('darkorange',0.4),add=TRUE)
# 
# 
# genderByDoW <- table(trip$dayOfWeek,trip$gender)
# # TODO:  Needs some stylistic improvements
# barplot(genderByDoW[,3],col=adjustcolor('royalblue',0.4))
# barplot(genderByDoW[,2],col=adjustcolor('red',0.4),add=TRUE)
# barplot(genderByDoW[,4],col=adjustcolor('green',0.4),add=TRUE)
# barplot(genderByDoW[,1],col=adjustcolor('yellow',0.4),add=TRUE)
# 
# genderByAge <- table(trip$age,trip$gender)
# barplot(t(genderByAge),col=c('yellow','red','blue','green'))
# barplot(genderByAge[,3],col=adjustcolor('royalblue',0.4))
# barplot(genderByAge[,2],col=adjustcolor('red',0.4),add=TRUE)
# barplot(genderByAge[,4],col=adjustcolor('green',0.4),add=TRUE)
# barplot(genderByAge[,1],col=adjustcolor('yellow',0.4),add=TRUE)
# 
#         


#' ----


