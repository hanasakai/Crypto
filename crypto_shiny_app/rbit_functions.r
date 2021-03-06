################################################################################
library(data.table)
################################################################################

market.api.query.hs <- function (url, key, secret, req = list(), 
                               verbose = getOption("Rbitcoin.verbose", 0)) 
{
  require(RJSONIO)
  require(RCurl)
  require(Rbitcoin)
  
  fun_name <- "market.api.query.poloniex"
  if (length(req) > 0 | (!missing(key) & !missing(secret))) {
    if (verbose > 0) 
      cat("\n", as.character(Sys.time()), ": ", fun_name, 
          ": request param or auth keys provided", sep = "")
    tonce <- as.character(as.integer(Sys.time()))
    post_data <- paste0("tonce=", tonce)
    if (verbose > 0) 
      cat("\n", as.character(Sys.time()), ": ", fun_name, 
          ": tonce calculated", sep = "")
    if (length(req) > 0) 
      post_data <- paste(post_data, paste(paste(names(req), 
                                                req, sep = "="), collapse = "&"), sep = "&")
    if (verbose > 0) 
      cat("\n", as.character(Sys.time()), ": ", fun_name, 
          ": post data prepared", sep = "")
    if (!missing(key) & !missing(secret)) {
      sign <- hmac(key = secret, object = post_data, algo = "sha512")
      httpheader <- c(`API-Key` = key, `API-Hash` = sign)
      if (verbose > 0) 
        cat("\n", as.character(Sys.time()), ": ", fun_name, 
            ": api call signed with sha512", sep = "")
    }
  }
  if (verbose > 0) 
    cat("\n", as.character(Sys.time()), ": ", fun_name, ": launching api call on url='", 
        url, "'", sep = "")
  curl <- getCurlHandle(useragent = paste("Rbitcoin", packageVersion("Rbitcoin")))
  if (missing(key) | missing(secret)) 
    query_result_json <- rawToChar(getURLContent(curl = curl, 
                                                 url = url, binary = TRUE))
  else if (length(post_data) > 0 & !missing(key) & !missing(secret)) 
    query_result_json <- rawToChar(getURLContent(curl = curl, 
                                                 url = url, binary = TRUE, postfields = post_data, 
                                                 httpheader = httpheader))
  else stop(paste0("unhandled case on Rcurl functions calling in ", 
                   fun_name), call. = FALSE)
  if (verbose > 0) 
    cat("\n", as.character(Sys.time()), ": ", fun_name, ": api call successfully completed", 
        sep = "")
  query_result <- fromJSON(query_result_json)
  if (verbose > 0) 
    cat("\n", as.character(Sys.time()), ": ", fun_name, ": api call results processed from JSON to R object", 
        sep = "")
  return(query_result)
}

################################################################################
# fPoloniexBuy2 ------------------------------------------------------------
# fPoloniexBuy - Use this function when you want to buy BTC with USD and it
# will examine the sell orders on Poloniex and for what volumes
# and calculate the avg price
# totvol  - is the volume of bitcoins that you want to buy (that others are selling)
# returns a list of two data.tables: pol_trans - the transactions
# and pol_sum - the summary of the avg costs
# coin2buy - specify the crypto coin that you wish to buy with usd
# xbt for Bitcoin
# eth for ethereum

fPoloniexBuy <- function(totvol, coin2buy){
  
  # vol is the volume of bitcoins that you want to buy (that others are selling)
  # totvol= 6
  
  if(coin2buy=='xbt'){ pair = "USDT_BTC" }
  
  if(coin2buy=='eth'){ pair = "USDT_ETH" }
  
  # First get the sell orders from poloniex
  api_url <- paste0("https://poloniex.com/public?command=returnOrderBook&currencyPair=", 
                    pair, "&depth=50")
  pol_orders <- market.api.query.hs(url=api_url)
  
  # Before we do anything, Is the market frozen?
  if(pol_orders$isFrozen==1){
    
    print("This currency pair is frozen")
    
  } else {
    
    # Get number of ask orders
    # ask_num <- length(pol_orders$ask)
    # At the moment I am getting depth of 50 it is in the url
    
    # Initiate i
    i=1
    
    # The remaining volume to buy is the total volume minus the volume bought so far
    # At the start have not bought any yet so remaining volume = total volume
    remvol <- totvol
    
    # Loop through until  volume is met
    repeat{
      
      # Get the asking price
      ask_price <- as.numeric(pol_orders$asks[[i]][[1]])
      ask_price
      
      
      # Get the asking volume
      ask_vol <- pol_orders$asks[[i]][[2]]
      ask_vol
      
      # How much of this order am I going to buy
      vol_buy <- min(ask_vol, remvol)
      vol_buy
      
      # The updated remaining volume to buy is the previous remaining volume minus the volume bought
      remvol <- remvol - vol_buy
      
      # Add to a table how much I am buying
      if(i==1){
        pol_trans <- data.table(ID=i, ask_price=ask_price, vol_avail=ask_vol, vol_bought=vol_buy, vol_remain=remvol)  
      } else {
        pol_trans <- rbind(pol_trans, 
                           data.table(ID=i, 
                                      ask_price=ask_price, 
                                      vol_avail=ask_vol, 
                                      vol_bought=vol_buy, 
                                      vol_remain=remvol))
        
      } # end if
      
      i <- i+1
      
      # If the remaining volume is 0 then stop the loop
      if(remvol<=0){
        
        break
        
      } # end if
      
    } # end repeat
    
    # Calculate the price of each transaction in the trade
    pol_trans[, price := ask_price * vol_bought]
    
    # Now calulate the avg buy price for this trade
    pol_sum <- pol_trans[, .(vol_bought = sum(vol_bought), 
                             cost_bought_usd = sum(price), 
                             num_trans = max(ID))]
    
    pol_sum[, avg_cost_usd := cost_bought_usd / vol_bought]
    
    return(list(pol_trans=pol_trans, pol_sum=pol_sum))
    
  } # end isFrozen if
  
} # end fPoloniexBuy function

################################################################################
# fIndResBuy2 ------------------------------------------------------------
# fIndResBuy2 - Use this function when you want to buy BTC with AUD and it
# will examine the sell orders on Independent Reserve and for what volumes
# and calculate the avg price
# totvol  - is the volume of bitcoins that you want to buy (that others are selling)
# returns a list of two data.tables: pol_trans - the transactions
# and pol_sum - the summary of the avg costs
# coin2buy - this is the code of the coin that you want to buy with AUD

fIndResBuy <- function(totvol, coin2buy){
  
  # vol is the volume of bitcoins that you want to buy (that others are selling)
  # totvol= 6
  
  # First get the sell orders from poloniex
  api_url <- paste0("https://api.independentreserve.com/Public/GetOrderBook?primaryCurrencyCode=", 
                    coin2buy, 
                    "&secondaryCurrencyCode=aud")
  ind_orders <- market.api.query.hs(url=api_url)
  
  
  # Get number of SellOrders orders
  # ask_num <- length(ind_orders$SellOrders)
  
  # Initiate i
  i=1
  
  # The remaining volume to buy is the total volume minus the volume bought so far
  # At the start have not bought any yet so remaining volume = total volume
  remvol <- totvol
  
  # Loop through until  volume is met
  repeat{
    
    # Get the asking price
    ask_price <- as.numeric(ind_orders$SellOrders[[i]]$Price)
    ask_price
    
    
    # Get the asking volume
    ask_vol <- ind_orders$SellOrders[[i]]$Volume
    ask_vol
    
    # How much of this order am I going to buy
    vol_buy <- min(ask_vol, remvol)
    vol_buy
    
    # The updated remaining volume to buy is the previous remaining volume minus the volume bought
    remvol <- remvol - vol_buy
    
    # Add to a table how much I am buying
    if(i==1){
      ind_trans <- data.table(ID=i, 
                              ask_price_aud=ask_price, 
                              vol_avail=ask_vol, 
                              vol_bought=vol_buy, 
                              vol_remain=remvol)
    } else {
      ind_trans <- rbind(ind_trans, 
                         data.table(ID=i, 
                                    ask_price_aud=ask_price, 
                                    vol_avail=ask_vol, 
                                    vol_bought=vol_buy, 
                                    vol_remain=remvol))
      
    } # end if
    
    
    i <- i+1
    
    # If the remaining volume is 0 then stop the loop
    if(remvol<=0){
      
      break
      
    } # end if
    
  } # end repeat
  
  # Calculate the price of each transaction in the trade
  ind_trans[, price_aud := ask_price_aud * vol_bought]
  
  # Now calulate the avg buy price for this trade
  ind_sum <- ind_trans[, .(vol_bought = sum(vol_bought), 
                           cost_bought_aud = sum(price_aud), 
                           num_trans = max(ID))]
  
  ind_sum[, avg_cost_aud := cost_bought_aud / vol_bought]
  
  # Rename the columns to be a little more descriptive
  # Create a vector of column names for the table
  colnames <- c("ID", "ask_price_aud", paste0("vol_avail_", coin2buy),
                paste0("vol_bought_", coin2buy),
                paste0("vol_remain_", coin2buy), 
                "price_aud")


  setnames(ind_trans, names(ind_trans), colnames)
                
  return(list(ind_trans=ind_trans, ind_sum=ind_sum))
  
} # end fIndResBuy2 function