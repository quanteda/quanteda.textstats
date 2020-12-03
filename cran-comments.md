# Submission notes

- Creates a new package to enable us to modularise quanteda, for managing its size and for making maintenance easier.

# RE-SUBMISSION NOTES

We made the following changes following requests by Gregor Seyer on 3 December 2020:

- Removed unexported function calls using `:::` from examples.

- Eliminated the use of `options(warn = -1)` from a funciton in one of our tests.

- With respect to the note about Meik Michalke, we feel that the most appropriate acknowledgement here is that which we have provided: a citation to his package.  While we used the same names for the measures as from that package, we did not use any of the code from koRpus.  Instead, we wrote original code that implemented the same readability functions, and checked each according to the original sources provided in our bibliography.  

  To verify this, however, I contacted Meik and asked him how he wished to be acknowledged.  He suggested a slightly revised bibliographic entry for each of `textstat_readability()` and `textstat_lexdiv()`, but was otherwise happy with the level of our acknowledgement.


## Test environments

* local macOS 10.15.7, R 4.0.3
* Ubuntu 18.04 LTS and 18.10, R 4.0.3
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs produced.

## Downstream dependencies

This package currently has no reverse dependences.
