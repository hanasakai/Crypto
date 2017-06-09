################################################################################
# RBitcoin
# rbit_investigation.r
# June 2017
################################################################################

library(Rbitcoin)

# The core functionality of Rbitcoin is to communicate with cryptocurrency exchanges API directly from R, and to unify the structure of market API response across the different markets.
# Lets see the full process.
# We will start by picking the market and currency pairs on which we will operate
market <- "kraken"
currency_pair <- c("BTC","EUR")

# Public API calls do not require any authentication and you can query it without having an account on market.
# At the beginning we might be interested to see top level price data using ticker API method
ticker <- market.api.process(market, currency_pair, "ticker")
ticker

market.api.query(market = 'bitstamp',
                 url = 'https://www.bitstamp.net/api/ticker/')

market.api.query("poloniex", url="https://poloniex.com/public?command=returnTicker")

market = 'bitstamp'

poltick <- market.api.query2(url="https://poloniex.com/public?command=returnTicker")
poltick$USDT_BTC


# https://poloniex.com/public?command=returnOrderBook&currencyPair=USDT_BTC&depth=10

indtick <- market.api.query2(url="https://api.independentreserve.com/Public/GetMarketSummary?primaryCurrencyCode=xbt&secondaryCurrencyCode=usd")


ind_orders <- market.api.query2(url="https://api.independentreserve.com/Public/GetOrderBook?primaryCurrencyCode=xbt&secondaryCurrencyCode=usd")

ind_orders$SellOrders  
################################################################################
For poloniex
Loop down sell orders from poloniex until volume
check for is frozen

What is the conversion from USD to AUD?
http://api.fixer.io/latest?base=USD&symbols=AUD

Loop down sell orders from ind res until volume reached
Calc avg rate on vol


  