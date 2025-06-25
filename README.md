# R interface to the oracle-db python PoC

The R package {ROracle} requires oracle drivers to be installed in order to interface with an Oracle database. However, the oracle-db package in Python does not require any drivers to be installed in order to work i.e. it operates on a "thin" mode that can directly connect to an Oracle DB.

This repository contains an example function `fetch_data`. This function relies on the {reticulate} package to interface with Python and pull data into R from an Oracle DB, without the need for drivers.