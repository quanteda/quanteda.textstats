# Submission notes

Purpose:

* To fix changes related to the quanteda v4.0 release and its move to relying on a version of TBB that is different from that provided in RcppParallel.

## Test environments

* local macOS 14.4.1, R 4.3.3
* macOS release via devtools::check_mac_release()
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs.

## Downstream dependencies

No new breaking downstream dependencies.
