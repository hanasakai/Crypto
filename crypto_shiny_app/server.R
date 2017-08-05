library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # Source the functions
  source("rbit_functions.r")
  
  # Change number of digits to display to loads
  options(digits=20)
  
  ## Calculate Poloniex Costs to by Bitcoin
  output$p1 <- renderTable({
    
    p1 <- fPoloniexBuy(totvol = input$totvol)
    
    # Get the USD to AUD exchange rate
    # http://api.fixer.io/latest?base=USD&symbols=AUD
    AUD_USD_rate <- fromJSON(rawToChar(getURLContent(url = "http://api.fixer.io/latest?base=USD&symbols=AUD",
                                                     binary = TRUE)))
    
    # Convert USD to AUD and add it to the pol_sum table
    p1$pol_sum$avg_cost_aud <- p1$pol_sum$avg_cost * AUD_USD_rate$rates
    
    p1$pol_sum
    
  })
  
  ## Calculate Independent Reserve Costs to by Bitcoin
  output$i1 <- renderTable({
    
    i1 <- fIndResBuy(totvol = input$totvol)
    
    i1$ind_sum
    
  })
  
  # Calculate the ratio of independent reserve to poloniex
  output$perc <- renderText({

    p1 <- fPoloniexBuy(totvol = input$totvol)

    # Get the USD to AUD exchange rate
    # http://api.fixer.io/latest?base=USD&symbols=AUD
    AUD_USD_rate <- fromJSON(rawToChar(getURLContent(url = "http://api.fixer.io/latest?base=USD&symbols=AUD",
                                                     binary = TRUE)))

    # Convert USD to AUD and add it to the pol_sum table
    p1$pol_sum$avg_cost_aud <- p1$pol_sum$avg_cost * AUD_USD_rate$rates

    i1 <- fIndResBuy(totvol = input$totvol)

    paste0(as.character(round((i1$ind_sum$avg_cost_aud / p1$pol_sum$avg_cost_aud - 1) * 100,
                              digits = 2)), "%" )

  })
  
})