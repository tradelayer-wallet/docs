###Derivatives

The default derivative is a perpetual swap, which is the base of what the protocol calls a *Contract Series*, each new contract series gets a contractId which corresponds to the perpetual.

#Futures

Based on the parameters of the series, there is a block interval N where a number of futures contracts Y will be settling, the bigger Y is the more N*Y intervals in the future there exist live futures contracts.A reasonable value for N is the number of Litecoin blocks in a week (4032) or month (17280), but since a month is uneven (leaving 5 days off the year and thus slipping over the years) it’s also recommendable to choose 52560 for a quarterly futures contract.Once a futures contract expires a new futures contract is generated.The contractId for futures starts with the Id of the parent perpetual swap, followed by a hyphen, followed by the blockheight of its expiry.

#Perpetual Funding

There is no built-in interest rate in the funding formula for futures, there is a clamp where +/- 5 bps is ignored and given a 0 funding rate.Any average contract VWAP above the average oracle value or underlying token index will produce a funding rate of that difference minus the 5 bps clamp, and likewise an average VWAP that is discounted more than 5 bps will produce negative funding equal to the discount plus 5 bps.Funding settles hourly, which creates lots of arbitrage opportunities against other contracts.Additionally, the clamp makes it easier for the contract to swing in the 10bps range around the index and TradeLayer’s low fee makes basis trading effective in that range.

# Options

Later, options will be activated and are based on the contract series numbering:

{% hint style="info" %}
**n-expiry-P-strike**
{% endhint %}

With N as the underlying contractId of the original perp swap, the expiry block like with futures (it can be a block height other than futures) the Call or Put code C or P added after a hyphen, then the strike price.The protocol rounds strikes to the latest round number based on a 1% increment or a 2.5% increment for expirations >1 month.Trades are all based on channel execution and assumed to be bilateral, thus the payloads can be customized even though the rounding rules standardize strikes to some extent. 

An option series can be European or American style, American delivers into the nearest-expiry future that is existent in the original contract series (expirations can be different) and that is closer to or equal to the expiration of the American style option. American options tend to be more expensive to price in the time value of money from possibly taking delivery and liquidating/reinvesting/cash-carry-hedging the underlying. If there are no futures with expiry block <= the expory of the option, the option exercises into perp positions.

#Cross-margin

TradeLayer does not support universal portfolio margin across multiple forms of collateral as this creates complex systemic risks based on correlation between collateral assets and covariance in different mis-matched collaterals and contract denominations.It does support automatic cross-margin within single collateral properties, thus perps, futures and options can all offset each other based on block-by-block settlement automatically.Even if contracts are illiquid in terms of trading volume each block they are marked to model based on time to expiry, recent premium and the mark price of the perp, which is the TWAP of the last few oracle publications or the VWAP of the underlying token index for native contracts.

#Expiration

Futures expire into Perps if native or cash-settle if oracle based.Options are European style and likewise settle into Perps if native or cash if oracle.

_Last updated: [10*7*2024]_
