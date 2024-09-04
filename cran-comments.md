# Submission notes

Purpose:

* Fixes issues related to the TBB libraries not being found on macOS platforms.  
  We now use pkgconfig to detect whether TBB is installed or not and to 
  generate the Makevars files using pkgconfig.

## Test environments

* local macOS 14.4.1, R 4.4.1
* macOS release via devtools::check_mac_release()
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs.

## Downstream dependencies

No new breaking downstream dependencies.
