# ProntoDataChallenge2015
Mazama Science and friends working on the Pronto 2015 Data Challenge.

## Data Challenge

The Pronto cycle share [data challenge](http://www.prontocycleshare.com/datachallenge) provides [year 1 data](https://s3.amazonaws.com/pronto-data/open_data_year_one.zip) as well as links to wining entries in [Chicago](https://www.divvybikes.com/datachallenge) and the [Bay Area](https://www.divvybikes.com/datachallenge)

## Focus

This project will be focused on station characteristics and usage with a goal of better understanding the use of individual stations and creating metrics that can be used to site new stations and monitor their performance. These metrics will be presented in an interactive dashboard that updates based on user selections of datat subsets.

Dashboard elements will include:

 * [clickable map of stations](http://willleahy.info/ng-maps/#/)
 * [d3 migration plots](http://www.global-migration.info)
 * pie and barcharts

## Data Preparation

See R/snippets.R for example code.

Data preparation is described in notebooks/ReadInData.R.

## Exploratory Analysis

Exploratory analysis will be performed on the augmented Trip dataset and will be created as a set of R and iPython notebooks. (See Jake Vanderplas [python code](https://github.com/jakevdp/ProntoData).) 

## Databrowser


