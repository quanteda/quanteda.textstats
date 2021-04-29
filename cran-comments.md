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

In checking via devtools::check_win_oldrelease(), we see:

** checking whether the namespace can be loaded with stated dependencies ... NOTE
Warning in .recacheSubclasses(def@className, def, env) :
  undefined subclass "numericVector" of class "Mnumeric"; definition not updated

A namespace must be able to be loaded with just the base namespace
loaded: otherwise if the namespace gets loaded by a saved object, the
session will be unable to start.

Probably some imports need to be declared in the NAMESPACE file.

but are not sure where this is coming from.

## Downstream dependencies

No new breaking downstream dependencies.
