### Vision

Run the wallet on an airgap computer, never connected to the internet, and build transactions in the multisig editor, commit tokens to the Layer 2 for an address on your internet-connected computer.Then run the wallet on your connected machine and route funds to channels rapidly for fast execution.Most DEx protocols require using an insecure browser-extension wallet and having trading and custody managed by the same key, this is not appropriate for large sums of money or institutional capital.

Every DEx has components of: 

**Consensus Logic**
**Trade Execution**
**Deposit/Withdrawal**

        Most DEx protocols utilize their own app chain or a bridged rollup and a centralized smart contract address to process trading logic, usually on a Proof-of-Stake blockchain.

        For speed, most DEx protocols rely on a centralized off-chain sequencer run by the project team to rapidly process trades.

        Most DEx protocols rely on centralized stablecoins as the main source of liquidity and deposit/withdrawal of these tokens into the smart contract acts as a black box.

        TradeLayer replaces these with:

         **OP_Return tokens** parsed on a Proof of Work blockchain.Anyone can run a full node and verify state, and refer the rules of parsing OP_Return data to a historical hash of the code base.

         **Multisig channels**, it’s possible to achieve even lower latencies by re-using a channel and further by co-locating with counterparties.Most-inefficient execution (6 pings across continents) takes about 1.5 seconds, distant channel re-use takes ~1 second, regional counterparties shaves another half second, co-location can bring latencies under 100ms, with further optimizations this could be brought to 10-20ms.**Anyone can run an orderbook** and route capital to any channel.

        **Decentralized Collateral** - to get around the programmability limitations of UTXO money like BTC, LTC and Doge it’s possible to atomically trade for tokens, paying the token-seller in the same transaction as the OP_Return guarantees delivery of the tokens to the UTXO spender.These transactions form on-chain data that removes the need for oracles, settling native perpetual swaps.The native perps then enable minting of synthetic BTC, LTC and Doge.Chain abstraction enables smart contracts that govern transaction signing to automate market making of e.g.LTC for synthetic LTC.This enables a decentralize on/off-ramp for funds in and out of TradeLayer.

       It’s also possible and probably important to have liquid centralized stablecoins and oracle-based derivatives on TradeLayer, these create a liquidity backstop and alternative revenue flow for the decentralized stablecoin system.

      It’s very common for DEx documentation to nest the fee information in its own page but here we’re going to end each page with a reminder that the fees are 0.5 basis points total.If you keep co-signing unpublished trades with a counterparty in a channel and then erase them by signing a PNL update transaction, you can get that even lower.We’re competing with Wall St.and regulatory exchange fee minimums.

Browser-extension trading and other wallet integrations coming in the future.

[Start Trading](https://tradelayer.org/downloads)

_Last updated: [10*7*2024]_
