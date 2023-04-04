# Submission notes

Purpose:

* To fix a S3 generic/method consistency WARNING in an extension of the nsyllable() function from the **nysyllable** package.
* Removed the C++ specification under SystemRequirements.

## Test environments

* local macOS 13.1, R 4.2.2
* Ubuntu 20.04 LTS, R 4.2.2
 Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
 Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs.

## Downstream dependencies

No new breaking downstream dependencies.
