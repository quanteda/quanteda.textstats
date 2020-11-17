# Submission notes

- Creates a new package to enable us to modularise quanteda, for managing its size and for making maintenance easier.

## Test environments

* local macOS 10.15.7, R 4.0.3
* Ubuntu 18.04 LTS and 18.10, R 4.0.3
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs produced.


## Downstream dependencies

This release causes no breaks in other packages, as checked via `revdepcheck::revdepcheck()`.
