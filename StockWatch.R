# Set working directory
setwd('C:/Users/hyber/Documents/Stocks')

# Set Library path
library.path <- .libPaths()[1]

# Install the quantmod package
install.packages('quantmod', repos = 'http://cran.us.r-project.org', lib = library.path)
require('quantmod')

# Install the dplyr package
install.packages('dplyr', repos = 'http://cran.us.r-project.org', lib = library.path)
require('dplyr')

cat('Now getting data..\n')
# Get ETFs
ETF = getSymbols(src = 'yahoo', Symbols = c('VUSA.AS', 'EUNL.DE', 'VWCE.DE', 'ISFU.L'),
                 from = '2000-01-01', to = Sys.Date(), auto.assign = T)

cat('Now merging closing price columns...\n')
# Use merge() from the library(xts) to keep the 'adjusted close' columns into one data frame
ETF_Analysis <- merge(VUSA.AS$VUSA.AS.Adjusted, 
                      EUNL.DE$EUNL.DE.Adjusted, 
                      join = 'inner')
ETF_Analysis <- merge(ETF_Analysis, 
                      VWCE.DE$VWCE.DE.Adjusted,
                      join = 'inner')
ETF_Analysis <- merge(ETF_Analysis,
                      ISFU.L$ISFU.L.Adjusted, 
                      join = 'inner')

# Set new column names
newNames <-  c('Vang_S&P_500_Acc', 'iShares_World_Acc', 'Vang_FTSE_World_Acc', 'iShares_FTSE_Dist')

# Rename the dataframe's columns
colnames(ETF_Analysis) <- newNames

# Write file into csv
write.zoo(ETF_Analysis, file = 'C:/Users/hyber/Documents/Stocks/ETF.csv', sep = ',')

cat('Done\n')  