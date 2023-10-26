# Submission notes

Purpose:

* To fix packageVersion() calling a numeric instead of character, following a note from Kurt Hornik.

## Test environments

* local macOS 13.5, R 4.3.1
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()
* Windows old-release via devtools::check_win_oldrelease()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs.

## Downstream dependencies

No new breaking downstream dependencies.
