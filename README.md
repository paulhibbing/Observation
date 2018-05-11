
[![Project Status: Active ? The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Travis-CI Build
Status](https://travis-ci.org/paulhibbing/Observation.svg?branch=master)](https://travis-ci.org/paulhibbing/Observation)
[![License](https://img.shields.io/badge/license-GPL-blue.svg)](http://www.gnu.org/licenses/gpl-3.0.html)

-----

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/Observation)](https://cran.r-project.org/package=Observation)
[![packageversion](https://img.shields.io/badge/Package%20version-0.2.0.9000-orange.svg?style=flat-square)](commits/master)

-----

[![Last-changedate](https://img.shields.io/badge/last%20change-2018--05--11-yellowgreen.svg)](/commits/master)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# Observation

The goal of Observation is to provide a free and convenient way of
collecting and processing physical activity-specific direct observation
data.

## Installation

You can install Observation from GitHub with:

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
