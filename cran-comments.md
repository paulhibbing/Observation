## Resubmission  
This is a resubmission in response to the `binaryLogic` package being archived,
which was an upstream dependency of one of this package's dependencies
(`AGread`). The dependency on `AGread` has been removed, along with other minor
changes in the package.


## Test environments  
* local Windows 10 install, R 4.0.5
* Debian Linux, R-devel, GCC ASAN/UBSAN (on R-Hub)
* win-builder (devel and release)


## R CMD check results  

There were no ERRORs or WARNINGs.

There was 1 NOTE:

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Paul R. Hibbing <paulhibbing@gmail.com>'

New submission

Package was archived on CRAN

Possibly misspelled words in DESCRIPTION:
  Ellingson (9:51)
  GJ (10:22)
  Hibbing (9:39)
  LD (9:61)
  Welk (10:17)

CRAN repository db overrides:
  X-CRAN-Comment: Archived on 2022-04-26 as requires archived package
    "binaryLogic'.


## Comments on the NOTE

- The package was previously archived due to dependency on one of my
  other packages(`AGread`), which depended on `binaryLogic`. The
  dependency on `AGread` has been circumvented in this resubmission.
  
- The possibly misspelled words are false positives.


## Other comments

The package remains largely interactive, so many examples are 
    wrapped in `if (interactive()) ...`


## Reverse dependencies

There are no reverse dependencies.
