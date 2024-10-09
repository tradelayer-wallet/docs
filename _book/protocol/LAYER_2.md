###Layer 2 Model

The brilliant thing about the Lightning Network is that two signatures on a 2-of-2 multisig becomes an immediately binding consensus lock of a transaction, and that transaction doesn’t need to be published immediately.The limiting factor of the Lightning Network is that the UTXO model, which very memory efficient to track with Merkelization, is a nightmare to route.Account-based tokens can simply be debited from address A and credited to address B with logic, whether a smart contract like on Ethereum or inline logic like in TradeLayer.Combining the two models means you can get fast consensus in a Bitcoin-like environment without relying on slow block confirmation, and it also means routing can be painless.

And so, we built Trade Channels.Trade Channels are a Layer 2 model based on the following 4 transaction types:

##Commit

Commiting tokens takes them out of the spendable model that they live in on-chain by default, and puts them into Layer 2 mode.The principle differences follow:

Tokens move from the Available column in the tally map to Channel
Tokens can be pledged to an address controlled by the user or a 2-of-2 multisig they share with a counterparty
Channels are recorded as having commit addresses and columns, A and B, which column a commiter is assigned is deterministic based on the sequence of the last letter of the address or the second to last in case of a tie and the third to last character in case of a rare double-tie.

##Withdraw

Withdraw transactions are issued from the address that originally Committed them to the layer 2 system, pulling them back, but only after a 7 block waiting period.This period gives time for a counterparty to detect the pending Withdraw and publish any co-signed trades or transfers that have already been agreed to, this prevents welching on trades.

The other major benefit of the Withdraw model is it decouples custody keys from trading keys.In other words, you can Commit tokens by building a transaction and signing it on an airgapped computer, copy the PBST string between screens to maintain the gap, and then later issue a Withdraw to pull the tokens back.Just like how centralized exchanges work, having various controls and the ability to shut-off API keys while the underlying funds are kept in something like Fireblocks, with a separate protocol for ordering withdrawals, TradeLayer brings this requirement for professional money management and better retail security to DeFi.

##Transfer 

Transfer is how the Layer 2 becomes flexible enough to hot-route capital around between any two channel addresses.Since it’s relatively fast to spin up a new channel with a new counterparty, it’s possible to also quickly build and present a valid Transfer tx to that new counterparty, either signed from your own wallet’s address or pinging a counterparty to liberate funds.

##PNL Settle

Ok so we can put funds onto the layer 2 model, which is relevant because you hold this string ot withdraw it, freeing you to co-sign trades and overrule the withdrawal assuming you haven’t published the trade immediately.And, you can flexibly transfer capital between channels to make this system work like an orderbook.What’s left? To really make a layer 2 scale, you want to save on publishing transactions, just signing them is enough! You can zip trades around, opening and closing positions, booking profits and losses, all day long, just keep signing, your counterparty may be a market maker who is hedging as they sign with you, relying on the option of paying miner fees to publish the trade, but you’re both happy to basically save lots of money and trade **almost for free**.That’s scaling.

The PNL Settle transaction makes this possible.The Token and Contract Channel Trade transactions have an expiration block, usually a few blocks ahead of when they are made, this is to prevent abuse of Counterparty Value Adjustment, where the party holding the partially-signed trade might wait for seconds or minutes to co-sign, the partial signature is like a free option.Filtering against abusive traders can help, binding to a smart contract and enforcing a tighter time-limit based on NEAR’s 300ms block interval could overkill the problem, but TradeLayer by default has the expiration parameter as a base.The PNL Settle includes as a parameter the txid of the transaction you *would* have published, if you publish the PNL Settle then that transaction would be invalid in TradeLayer’s consensus logic, it’s like txid blacklisting.

Therefore it’s possible to refresh a transaction every few blocks by pinging back and forth and producing a PNL Settle and a new trade.You can ping pong like that all day long, keeping a position alive, or you can do a settle based on the price of a closing trade.Imagine you signed a long trade with a market maker, the market goes down, a few blocks pass, you PNL Settle a loss and make a new long trade at the mark price matching the PNL Settle’s value, then the market keeps dumping, you dump the long, you make another PNL Settle neutralizing that 2nd trade and neglect to make a new trade.

By using base 94 ASCII encoding it’s possible to crunch txid’s down to 30 bytes and pack 2 of them in the OP_Return, meaning it’s possible to neutralize the previous PNL Settle and the previous trade update.Don’t want to keep trading, don’t make a new transaction, instead add in to the OP_Return a mark price and an update flag to update the first txid of the latest trade and only invalidate the txid of the last PNL Settlement; this way each PNL Settlement is final and you don’t need to hold on to tons of these to publish later.

This flexibility seems a bit complicated if you were keeping track of it by hand but it can all fit into wallet code and run seamlessly.In this way, we can potentially achieve insane levels of transaction throughput at ultra-low latencies with average protocol and miner fees approaching 0 as market makers do more flow with high frequency liquidity takers.It’s a unique approach compared to the rest of DeFi with radical potential to provide market structure for global transactions, millions a day, even hundreds of millions.

And when you do publish, the fee is 0.5 bps.


_Last updated: [10*7*2024]_
