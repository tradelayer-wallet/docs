### Fees

The basic fee in TradeLayer is 0.5 bps total, though on-chain token trades have a rebate value that takers pay to makers in order to make wash-trading and manipulation of price data prohibitively expensive.

| Trade Type | Taker Fee | Maker Fee | 
|--------------------------------- |--------|--------| 
| Channel Token                 | 0.25 | 0.25  | 
| Channel Oracle Contract | 0.25 | 0.25 |
| Channel Native Contract  | 0.125|0.125|
| On-chain Token                | -3.5  | 4      |
| On-chain Contract           | -0.5   |  1     |

A quarter of the fees in oracle contracts go to buy back the $TL (Litecoin), $TD(Dogecoin) and $TB (Bitcoin) native tokens and deposit them in the insurance fund for the native TL/LTC contract, which backs synthetic Litecoin.A quarter is cached until a minimum threshold is reached and then distributed to holders of the TLI token or equivalent on other chains.The other half goes to the administrator publishing the oracle feed, as revenue.

Half of the fees from native contracts and tokens goes to buyback the TL token or its cousins on other chains and the other half goes to cache until a threshold is met and then is distributed to TLI token holders.

More on that in the next article.

_Last updated: [10*8*2024]_

