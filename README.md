## Demonstration on transparent dataflow into the Norwegian Nature Index

Proof-of-consept on the workflow from raw data to the [Norwegian Nature Index](http://www.nina.no/english/Environmental-monitoring/The-Norwegian-Nature-Index). The worklfow utilizes the [GBIF](http://www.gbif.org/) infratstructure for making data awailable according to the FAIR principles. At the moment, the data are read from [IPT installations](http://www.gbif.org/ipt) since the GBIF API does not return measurment and fact tables, containing additional terms needed for indicator calculations. Mapping of data to [Darwin Core](http://rs.tdwg.org/dwc/terms/) (DwC) and uploading to IPT is not covered here. 

The workflow consist of three sections, all written in R. 

1. [A function for downloading and parsing DwC archives](https://github.com/andersfi/NI-demo/blob/master/func_download_and_parse.R)
2. [A script for assigning data to relevant geographic area (currently using county level) and calculating the NI indicator](https://github.com/andersfi/NI-demo/blob/master/calculateNI.R). At the moment the indicator calculated is only for technical demonstration and does not contain real values. 
3. [A Shiny app for visualization of results](https://github.com/andersfi/NI-demo/blob/master/app.R), awailable [online](https://shiny.vm.ntnu.no/users/andersfi/ni_demo/)

The repository is under developement.
