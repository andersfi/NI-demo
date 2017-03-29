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
    popup3 <- paste0("<strong>Dataposter brukt i indikator: </strong><br>",popup2)
    
    
    leaflet(data = plotdata) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(fillColor = ~pal(NI), 
                  fillOpacity = 0.8, 
                  color = "#BDBDC3", 
                  weight = 1, 
                  popup = popup3) %>%
    addLegend("bottomright", pal = pal, values = ~NI,title = "Indikator Aure", labFormat = labelFormat(prefix = ""),
              opacity = 1)
    
  })

}

# user interface
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      includeMarkdown("text_ni_demo.md"),
      br(),
      img(src="ntnu-vm.png", width = 100),
      img(src="nina_logo.png", width = 100)
      
    ),
    mainPanel(
      tags$style(type = "text/css", "#NImap {height: calc(90vh - 70px) !important;}"),
      leafletOutput("NImap")
    )
  )
)

shinyApp(ui = ui, server = server)
