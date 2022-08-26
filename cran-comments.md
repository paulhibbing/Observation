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


## Other comments

The package remains largely interactive, so many examples are 
    wrapped in `if (interactive()) ...`


## Reverse dependencies

There are no reverse dependencies.
