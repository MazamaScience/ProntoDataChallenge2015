################################################################################
# The packages/ directory contains source code for packages used by a databrowser.
# These packages can be installed locally with the databrowser to avoid conflict
# with other R code that may depend upon different versions of the packages.
#
# Invoke this Makefile with a specific libPath argument:
#   make install libPath=__LIBRARY_PATH__

################################################################################
# Targets 

install: FORCE
	R CMD INSTALL --library=$(libPath) jsonlite_0.9.14.tar.gz
	R CMD INSTALL --library=$(libPath) stringr_0.6.2.tar.gz
	# requirements for dplyr
	R CMD INSTALL --library=$(libPath) assertthat_0.1.tar.gz
	R CMD INSTALL --library=$(libPath) R6_2.1.1.tar.gz
	R CMD INSTALL --library=$(libPath) Rcpp_0.11.4.tar.gz
	R CMD INSTALL --library=$(libPath) magrittr_1.5.tar.gz
	R CMD INSTALL --library=$(libPath) lazyeval_0.1.10.tar.gz
	R CMD INSTALL --library=$(libPath) DBI_0.3.1.tar.gz
	R CMD INSTALL --library=$(libPath) BH_1.55.0-3.tar.gz
	# dplyr
	R CMD INSTALL --library=$(libPath) dplyr_0.4.1.tar.gz

FORCE:

