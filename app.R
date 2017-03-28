# demo of dataflow into NI
library(shiny)
library(leaflet)

# import data
plotdata <- readRDS("county_sp2.RDS")

# server functions
server <- function(input, output) {
  
  output$NImap <- renderLeaflet({
    #plotdata <- munic_sp2
    pal <- colorNumeric("YlGn", NULL, n = 10)
    
    popup2 <- character()
    for(i in 1:dim(plotdata)[1]){
      popup2[i] <- paste0(paste("<a href=",unlist(strsplit(plotdata$dataused[i],"\\|")),">",
                                      unlist(strsplit(plotdata$occurrenceID[i],"\\|")),"</a>"),
                                collapse=" ")
      }
    
    
    
    leaflet(data = plotdata) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(fillColor = ~pal(NI), 
                  fillOpacity = 0.8, 
                  color = "#BDBDC3", 
                  weight = 1, 
                  popup = popup2) %>%
    addLegend("bottomright", pal = pal, values = ~NI,title = "Indikator Aure", labFormat = labelFormat(prefix = ""),
              opacity = 1)
    
  })

}

# user interface
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      h3("Eksempel på dataflyt: Naturindeks"),
      br(),
      p("Enkel demonstrasjon på dataflyt inn i NI."),
      br(),
      p("Kartet viser indikator Aure, hvor hver enkelt datapost bak den fylkesvise naturindeksen 
        er linket opp til GBIF sin portal. Dette muliggjøres ved å la data flyter inn til Naturindeks-
        beregninger via NINA sin IPT"),
      br(),
      a(href="https://github.com/andersfi/NI-demo",target="_blank","Kode på GitHub"),
      br(),
      img(src="ntnu-vm.png", width = 100),
      img(src="nina_logo.png", width = 100)
      
    ),
    mainPanel(
      tags$style(type = "text/css", "NImap {height: calc(90vh - 70px) !important;}"),
      leafletOutput("NImap")
    )
  )
)

shinyApp(ui = ui, server = server)
