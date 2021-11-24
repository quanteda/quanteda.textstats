# Submission notes

Purpose:
* To fix errors happening on the checks for 0.94.1 related to empty dfms.
* To implement other minor bug fixes detailed in NEWS.md.

## Test environments

* local macOS 11.6, R 4.1.2
* Ubuntu 20.04 LTS, R 4.1.2
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs, except:

Found the following (possibly) invalid URLs:
  URL: https://doi.org/10.1037/h0043254
    From: man/textstat_readability.Rd
    Status: 400
    Message: Bad Request
  URL: https://doi.org/10.1037/h0057532
    From: man/textstat_readability.Rd
    Status: 400
    Message: Bad Request
  URL: https://doi.org/10.1037/h0076540
    From: man/textstat_readability.Rd
    Status: 400
    Message: Bad Request
    
These seem to be an issue with CRAN checks, not with the URLs, since I used \doi{} for these.  I contacted Uwe Ligges before submitting, and he advised me to ignore these.

## Downstream dependencies

No new breaking downstream dependencies.
