
###Trading Types

TradeLayer supports several types of trade transactions:

On-chain token for token
On-chain contract

Channel token-for-token
Channel contract
UTXO-for token

##AMM

 The on-chain trades create an orderbook based on confirmed transactions, this is quite slow and requires an additional transaction to cancel, but it’s useful as a final liquidity backstop.There is an AMM that enables pool of tokens to trade against other tokens or as contract collateral, and provide a buyer-of-last resort for contract liquidations, this is useful as the AMM can update its contribution to the orderbook based on oracle prices or relevant token prices without needing to cancel and replace orders, somewhat improving the problems with a slow on-chain orderbook.To compensate for the risk of data manipulation by wash traders and the general adverse selection risk, the AMM will generally quote wide and broadly with a higher fee going as a rebate to the pool, and will earn half of liquidation fees with the other half going to insurance funds.

##Channels

Channel trading solves the problem of slow trade settlement by creating a way to execute trades quickly.Traders agree on price, make a multisig address, fund it with a Commit or Transfer transaction (one uses Available balance tokens that are freely move-able, the other uses Channel balance tokens that have already been Commit-ed) and then build the trade and co-sign it.This enables trading of tokens or derivatives via OP_Return, involving funding with the relevant token amounts as trade principal or as initial margin, and also enables UTXO-for-token trades to engage securely.

Channel trading by default is much faster than on-chain trading, potentially hundreds of times faster, with clear price execution.However compared to the fasted DExes, the default latency involving multiple pings across the world can verge on 1-2 seconds.When trading again with a counterparty, a channel address can be re-used, saving 2 of 5 steps up to the co-sign, this shaves about 30% of the latency.Funds can be pooled between top channels and easily transferred, if there is UTXO available to build a trade tx then transfers don’t need to be published to have an output to build from, they can be briefly held like cheques and published later, this can shave another 30% of the latency.

Colocating can further reduce latency.In the future it may be possible to pre-pledge to a trade in a smart contract and holding a tx that can bind stake on that smart contract becomes as good as the subsequent trade, that could enable the most extreme low latency, possibly breaking new records for the industry.The legos are so flexible here, you can have total flexibility and get decent latency for the naked eye, or cluster activity among top counterparties and optimize towards the computational limits of trading algorithms.Best of all, it’s just people signing transactions and publishing them to censorship-resistant proof of work chains, if colocation servers become problematic due to regulatory capture, move servers.Decentralized sequencing is the realization of Satoshi’s Vision, even if he didn’t specifically anticipate it.

_Last updated: [10*7*2024]_
