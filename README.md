
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis-CI Build
Status](https://travis-ci.org/paulhibbing/Observation.svg?branch=master)](https://travis-ci.org/paulhibbing/Observation)

# Observation

The goal of Observation is to provide a free and convenient way of
collecting and processing physical activity-specific direct observation
data.

## Installation

You can install Observation from github with:

``` r
# install.packages("devtools")
devtools::install_github("paulhibbing/Observation")
```

## Example

You can run the program with:

``` r
observation_data <- data_collection_program()
```

This will collect direct observation data as you direct. It will also
pre-classify the intensity of each activity based on the decision tree
described by [Hibbing et
al.](https://www.ncbi.nlm.nih.gov/pubmed/29135657) You can then update
the classification by cross-referencing the [Compendium of Physical
Activities](https://sites.google.com/site/compendiumofphysicalactivities/)
using the following:

``` r
observation_data_complete <- compendium_reference(observation_data)
```
