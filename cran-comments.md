# Submission notes

Purpose:

* To fix a C++ issue with TBB that was causing an installation failure on 
  downstream packages on ubuntu-devel environments.
* To remove some C++ code for similarity computations that is not needed 
  because it is contained in the **proxy** library.

## Test environments

* local macOS 13.6, R 4.3.1
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs.

## Downstream dependencies

No new breaking downstream dependencies.
