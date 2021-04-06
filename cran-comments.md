# Submission notes

UPDATE: Fixes three deprecation warnings from the earlier submission of v0.94.

This package must accompany the quanteda v3 release, which we have submitted today at the same time.  Tested with that submission, it passes.  Tested against the existing quanteda 2.1.2, it fails because the S4 classes are multiply defined, and quanteda.textstats has to import quanteda.

This is the only change versus the recently updated v0.93 of quanteda.textstats, which the CRAN results report as OK on all platforms.

## Test environments

* local macOS 10.15.7, R 4.0.4
* Ubuntu 20.04 LTS, R 4.0.4
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs produced when tested with quanteda v3.

Fails because of conflicting S4 class definitions if tested with quanteda v2.1.2.

## Downstream dependencies

This will not break downstream dependencies as we have changed nothing except the S4 headers versus the existing CRAN v0.93, which is OK on all platforms.
