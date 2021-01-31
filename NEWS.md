# quanteda.textstats 0.92

* removed older non-C++ keyness methods (#4)

# quanteda.textstats 0.91

* Fixes some issues causing errors on Solaris and on tests for the older R release on Windows.
* Removes problematic cacheing of results from `textstat_summary()` and associated functions and tests.

# quanteda.textstats 0.90

First version, split from **quanteda** 2.2.  This is a transitional version
designed to get the package on CRAN, so that we can shift existing reverse
dependencies to the new package, before we update **quanteda** with a new
version without the `textstat_*()` functions.
