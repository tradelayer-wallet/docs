
### Vesting Tokens

## TL and TLVEST

There is a supply of 500,000 TL tokens which is the exclusive form of native collateral that can be used to mint synthetic currency.Of this, 100,000 are instantiated inside the insurance fund for the contractId 1, the native TL/LTC contract, 150,000 are loose and 250,000 are tied to TLVEST tokens that vest based on the cumulative LTC spot volume in the protocol, on a linear scale starting from 1000 LTC to 100,000,000.At 1M LTC cumulative volume ~0.999% of those TLVEST tokens will yield liquid vesting tokens, at 10M LTC the number will be close to 10% and at 100M LTC all of the 250k TLVEST tokens will have yielded the TL tokens associated.TLVEST cannot be traded in the protocol but it can be sent.

50,000 TL will be sold initially to get liquidity going.

50,000 TL will be used to mint synthetic LTC against the Native TL/LTC Perpetual Swap settling off of the liquidity of the above 50k.

150,000 TL will be auto-deposited on initialization of the protocol to the insurance fund for the TL/LTC perpetual swap. 

This insurance fund accumulates buybacks with half of the fee revenue.

250,000 TL are reserved in Vesting Tokens that will be 50% vested when the cumulative spot volume of the protocol is around 500 million LTC
100% will be vested when the cumulative LTC spot volume reaches 1 billion LTC.

Different ratios will apply to $TB and $TD on Bitcoin and Dogecoin. 

The Doge tokenomics will be more inflationary and the BTC tokenomics will be focused on a fair launch with no initial liquid supply.

## TLI and TLIVEST

## Farming and Airdrops

It’s important that a DEx protocol has a reward for traders who make the DEx liquid and useful with their participation, especially in the early days of going from 0 liquidity to 1 liquidity.Like Homer Simpson said, I have 3 kids and 0 money, I wish I had 0 kids and 3 money.The early market makers who enable a DEx to have 3 money are very valuable and deserve a stake in the success of the DEx for that participation, but also this idea has been played out since DeFi summer 2020 to the effect usually of extreme token inflation, perp markets that price in huge negative funding for the dividend effect, unsophisticated retail buyers who can’t price in all these variables, and eventually a massive dumping of the token as cynical farmers insta-stell their earned tokens.

After a cycle of that showed us a series of charts with massive spiked to multi-billion dollar valuations (fully diluted) followed by massive dilution and 98% drawdowns, followed by maybe 300% pumps, this market cycle has given us the **airdrop event**.This builds FOMO in users who come try out the new pre-token product, producing a lot of numbers such as volume or Total Value Locked that seem like real traction, and then the **event** happens, people often isnta-sell and move on to the next anticipated airdrop.Sometimes the token pumps for a 2-5x afterwards but since they debut at something like 1B FDV the real revenue of the product, maybe an impressive >10M a year, can’t justify those valuations and the same result happens.

## Rebate Programs

Some DExes that are fee competitive and reasonably fast have offered tokens that yield to trades based on measured programs, rather than a built-in perpetual algorithm, and these distribute much or all of the revenue of the DEx to holders and/or stakers, but the dilution causes quick dumping as traders try to recover a fraction of their monthly trading fee expenditure.The result is a market cap that goes mostly sideways while the token price sags.

This last incarnation isn’t so bad, the yield from the revenues off-sets the price drops and eventually the dilution slows down and the thing bottoms, and then the combined price recovery and yield makes it an attractive hold.Meanwhile it has the effect of subsidizing trade activity in part.One problem is that the managed promotional periods are not predictable for users and involve the centralized administration of what seems to be a common enterprise, a truly decentralized protocol should replace that with a more elegant mathematical formula that anyone can predict and anticipate both the dilution and the effect at-the-market discount to fees that the token rebate represents.

## Long-term Vesting

Now a wrinkle: what if people can’t easily dump the rebate? You make the rebate a Vesting Token that involves a future expectation.This offsets the immediate dilution, people can try to OTC sell their VTs at a discount of they’re major MMs and hold size, or broker an OTC buy and reach out to scoop lots of modest positions from medium-sized traders, but then flipping those still involves a long-term expectation of revenue growth or at least stability.This market effect offsets the immediacy of selling and encourages collection of the income interests in stronger hands.

Therefore our approach is to rebate trades on two levels: one based on whitelisting for the early program to create Sybil resistance, wash traders will be revoked.This rebate will be higher than the fee rate in terms of expected current market value.The baseline rebate will be initially equal to the fee and decline logarithmically as the cumulative volume on the DEx increases through orders of magnitude in LTC equivalent, eventually resting at about 10% of the fee rate after years of scale volume.This makes wash trading still expensive and is economically Sybil resistant.

The TLIVEST tokens will vest on a logarithmic scale from 10M LTC cumulative volume to 1T LTC cumulative volume, unlike the TLVEST tokens that are linear up to 100M LTC, 20% of the TLIVEST tokens will vest by 100M LTC, another 20% by 1B, another 20% by 10B, then another 20% by 100B and the last 20% approaching 1T.The rebates will come pre-vested proportionate to the total historical volume of the DEx at these times.


## Why two tokens?

While it adds some confusion and dilutes brand value, the choice of decoupling native collateral from trade incentives is necessary to make the collateral backing deflationary while enabling calibrated inflation for the dilutive incentives.It’s like how central banks hold gold and issue liabilities, one is there to keep the system stable in emergencies and keep the central bank operational, the other is there to juice the growth of the economy and earn out over time.

Having the native coin be the core collateral for synthetic currency that is meant to reduce-risk and be useful collateral in ways that UTXO money cannot currently serve.If an exchange’s deposits are all risky liabilities backed by the discounted cashflows of the exchange, like say FTX when their books were based on FTT margin and internal loans to their captive hedge fund, there’s a horrible correlation between the decline in those liabilities market value and the decline in the expected future cashflows of the venue.In other words, scheme make crash worse, kill everything, super bad.Another terrifying example of this was the LUNA/UST model.TradeLayer’s design has gone through iterations since 2017 and learned the lessons from the deca-billion sized failures of the past.

More on this in the next article.

