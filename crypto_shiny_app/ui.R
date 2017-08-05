library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Bitcoin Exchange Discrepencies"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      numericInput("totvol", "Bitcoin Volume that you want to Buy", 1)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h3("Independent Reserve Costs:"),
      tableOutput("i1"),
      
      h3("Poloniex Costs:"),
      tableOutput("p1"),
      
      h3("The Independent Reserve price / Poloniex price is:"),
      
      textOutput("perc")
    )
  )
))