# Submission notes

UPDATE: Minor bug fix for old ICU/Unicode versions, as well as changes a breaking test in preparation for proxyC v2.0.

## Test environments

* local macOS 10.15.7, R 4.0.5
* Ubuntu 20.04 LTS, R 4.0.5
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs, except:

As per the existing CRAN checks, installation fails on r-oldrel-windows-ix86+x86_64, but this is apparently not a fault of quanteda.textstats, but rather a problem with RcppParallel, which fails on that platform.

## Downstream dependencies

No new breaking downstream dependencies.
