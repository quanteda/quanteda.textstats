# Submission notes

- Creates a new package to enable us to modularise quanteda, for managing its size and for making maintenance easier.

# RE-SUBMISSION NOTES

We made the following changes following requests by Gregor Seyer on 3 December 2020:

- Removed unexported function calls using `:::` from examples.
- Eliminated the use of `options(warn = -1)` from a funciton in one of our tests.
- With respect to the note about Meik Michalke, we feel that the most appropriate acknowledgement here is that which we have provided: a citation to his package.  While we used the same names for the measures as from that package, we did not use any of the code from koRpus.  Instead, we wrote original code that implemented the same readability functions, and checked each according to the original sources provided in our bibliography.  Even had we used his code, our inclusion of the GPL-3 license does satisfy the license and copyright requirements.  We feel that our citation provides the attribution that Michalke deserves for his original work in this area, and that listing him as a contributor or author to the package would be inappropriate.

    I would add as well that this is how the **quanteda** package has acknowleded Meik's previous work in this area, and has been published for at least four years in this way with his knowledge, and we have received no complaints.  (This package will move the readability functions out of **quanteda**, once on CRAN.)
    
    However if you think that we have been doing this wrongly, I would be happy to write to Meik and ask if he thinks we should be acknowledging him differently.

## Test environments

* local macOS 10.15.7, R 4.0.3
* Ubuntu 18.04 LTS and 18.10, R 4.0.3
* Windows release via devtools::check_win_release()
* Windows devel via devtools::check_win_devel()

## R CMD check results

No ERRORs, NOTEs, or WARNINGs produced.

## Downstream dependencies

This package currently has no reverse dependences.
