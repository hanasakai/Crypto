################################################################################
# RBitcoin
# rbit_check_for_discrepencies.r
# June 2017
# This code reads in the order books for independent reserve and poloniex
# and checks for discrepancies to identify opportunities for getting in or out
################################################################################


# ENVIRON SETUP -----------------------------------------------------------

setwd("E:\\Career\\PersonalProjects\\RBitcoin")

source("code/rbit_functions.r")

options(digits=20)

################################################################################
# POLONIEX ----------------------------------------------------------------

# Enter the number of Bitcoins that you want to buy and get avg USD cost on Poloniex
p1 <- fPoloniexBuy(totvol=20)

# Get the USD to AUD exchange rate
# http://api.fixer.io/latest?base=USD&symbols=AUD
USD_AUD_rate <- fromJSON(rawToChar(getURLContent(url = "http://api.fixer.io/latest?base=USD&symbols=AUD",
                                                 binary = TRUE)))

# Convert USD to AUD and add it to the pol_sum table
p1$pol_sum$avg_cost_aud <- p1$pol_sum$avg_cost * USD_AUD_rate$rates

p1$pol_sum

################################################################################
# INDEPENDENT RESERVE -----------------------------------------------------

i1 <- fIndResBuy(totvol = 20)

print(i1$ind_sum)
print(p1$pol_sum)

print("The Independent Reserve price / Poloniex price is:")
print(paste0(as.character(round((i1$ind_sum$avg_cost_aud / p1$pol_sum$avg_cost_aud - 1) * 100, digits = 2)), "%" ))

