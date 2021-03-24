
******************************
* Project : Stata-Python Integration
* Author: R. Shyaam Prasadh Ph.D 
* Last version : 24/3/2021
*******************************



clear

python
import yfinance as yf
import pandas as pd
import sfi as sfi
from sfi import Frame, Data
from pandas import Series, DataFrame
import matplotlib.pyplot as plt 

# Download Dow Jones data from Yahoo Finance !
dowjones = yf.download("^DJI", start="2010-01-01", end="2019-12-31")
dowjones.columns
dowjones.index.name 
dowjones.index



# Convert the dowdate to string and create a dataframe
dowjones['dowdate'] = dowjones.index.astype(str) 
data = dowjones[['dowdate','Adj Close', 'Volume']]
ds = pd.DataFrame(data)

# Compute the returns
prices = pd.DataFrame(dowjones['Adj Close'])
returns =pd.DataFrame(prices.pct_change())
returns
ds['returns'] = returns
plt.plot(returns)
plt.show()
plt.legend()

# Set the size for stata dataset
Data.setObsTotal(len(ds))


# Create the variables for the stata dataset
Data.addVarStr('dowdate', 10)
Data.addVarDouble('close')
Data.addVarDouble('volume')
Data.addVarDouble('returns')

# Store the data in list
Data.store(None, None, ds.values.tolist())
end

# Format to display the data in a familiar date format,Volume rounded to the nearest 10,000
replace volume = volume/10000
generate date = date(dowdate,"YMD")
format %tdCCYY-NN-DD date

list in 1/5, abbreviate(9)

# Plot the graph
twoway (line close date, lcolor(red) lwidth(medium))         ///
       (bar  volume date, fcolor(black) lcolor(black) yaxis(2)),  ///
       title("  Dow Jones Industrial Average data(2010 - 2019)")        ///
       xtitle("") ytitle("") ytitle("", axis(2))                  ///
       xlabel(, labsize(small) angle(horizontal))                 ///
       ylabel(5000(5000)30000,                                    ///
              labsize(small) labcolor(green)                      ///
              angle(horizontal) format(%9.0fc))                   ///
       ylabel(0(500)3000,                                         ///
              labsize(small) labcolor(black)                       ///
              angle(horizontal) axis(2))                          ///
       legend(order(1 "Close Price" 2 "Volume (mill)")      ///
              cols(1) position(10) ring(0))
