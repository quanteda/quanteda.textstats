# Submission notes

- Fixes breaking tests on r-oldrel-macos-x86_64 and r-oldrel-windows-ix86+x86_64, caused by the changes to R in the default treatment of characters as factors when creating a data.frame.


errors on Solaris and on r-oldrel-windows, only discovered after the initial publication on CRAN.

## Test environments

* local macOS 10.15.7, R 4.0.4
* Ubuntu 20.04 LTS, R 4.0.4
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs produced.

## Downstream dependencies

I ran revdepcheck::revdep_check() to verify that this update breaks none of the package's four reverse dependencies.
