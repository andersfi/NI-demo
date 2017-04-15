## Demonstration on transparent data-flow into the Norwegian Nature Index

This is a proof-of-concept on providing an transparent and reproducible workflow from raw data into the [Norwegian Nature Index](http://www.nina.no/english/Environmental-monitoring/The-Norwegian-Nature-Index) decition support tool. The workflow fuels on the Darwin Core standard and the [GBIF](http://www.gbif.org/) infrastructure for making data available according to the FAIR principles. At the moment, the data are read from [IPT installations](http://www.gbif.org/ipt) since the GBIF API does not return measurement and fact tables, containing additional terms needed for indicator calculations. Mapping of data to [Darwin Core](http://rs.tdwg.org/dwc/terms/) (DwC) and uploading to IPT are described elsewhere. See e.g. the [GBIF Publishing Data section](http://www.gbif.org/publishing-data/quality) for introduction. 

The workflow consist of three sections, all written in R. 

1. [A general function for downloading and parsing DwC archives](https://github.com/andersfi/NI-demo/blob/master/func_download_and_parse.R)
2. [NI index specific scripts for assigning data to relevant geographic area (currently using county level) and calculating the index](https://github.com/andersfi/NI-demo/blob/master/calculateNI.R). At the moment the indicator calculated is only for technical demonstration and does not contain real values. 
3. [A NI specific Shiny app for visualization of results](https://github.com/andersfi/NI-demo/blob/master/app.R), awailable [online](https://shiny.vm.ntnu.no/users/andersfi/ni_demo/)

The repository is under development.
