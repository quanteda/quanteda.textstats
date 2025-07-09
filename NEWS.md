# quanteda.textstats 1.0

* Fix `textstat_summary()` to avoid errors when `x` has no documents.

# quanteda.textstats 0.97

* Fixes Rd link issues and other issues causing warnings under the new and improved CRAN checks.

# quanteda.textstats 0.96

* Fixes for C++ header compatibility for existing **quanteda** 3.x and the forthcoming 4.0 version.
* Fixes for compatibility with Matrix >= 1.5. (#54)
* Fixed how subsetting (`[`) works for textstat outputs, to fix #50.
* Updated the C++ code generally and for better calling the tbb library for multi-threading.

# quanteda.textstats 0.95

* Updated `textstat_simil()` for new **proxyC** version v0.2.2, which affects how similarities are returned for `NA` values.  See #45.
* Fixed a bug in the computation of Yule's K. (#46)
* Corrected the name of similarity method "hamann" to its correct spelling (formerly "hamman", which still works too). (#44)

# quanteda.textstats 0.94.1

* Updated `textstat_simil()` for new **proxyC** version v-0.2.0.
* Now returns emoji counts as `NA`, without failure, for ICU versions older than 9 (#35 and #24).

# quanteda.textstats 0.94

* Move the S4 definitions for simil, dist, and proxy textstat classes from **quanteda** to **quanteda.textstats**.
* Changes the operation of `groups` in `textstat_frequency()` to operate as in **quanteda** v3.

# quanteda.textstats 0.93

* Minor changes to ensure compatibility with **quanteda** v3.
* Changes to avoid breaking tests on older releases, caused by changes to the default for `stringsAsFactors` in `data.frame()`.

# quanteda.textstats 0.92

* Removed **data.table** dependency (#5).
* Removed older non-C++ keyness methods (#4).
* Removed code that was breaking the Solaris build on CRAN.
* Removed **digest** Import not used.


# quanteda.textstats 0.91

* Fixes some issues causing errors on Solaris and on tests for the older R release on Windows.
* Removes problematic cacheing of results from `textstat_summary()` and associated functions and tests.

# quanteda.textstats 0.90

First version, split from **quanteda** 2.2.  This is a transitional version
designed to get the package on CRAN, so that we can shift existing reverse
dependencies to the new package, before we update **quanteda** with a new
version without the `textstat_*()` functions.
