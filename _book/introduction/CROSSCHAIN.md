

### TradeLayer Cross

Utilizing the power of Chain Signatures on NEAR, it’s possible to do a number of interesting things with UTXOs and token transactions on TradeLayer, one of these is enabling cross-chain swaps.Because TradeLayer runs off of synced nodes for Proof of Work blockchains, it would be possible to have native cross-chain swaps if running full Bitcoin, Litecoin and Dogecoin nodes were required, because this is prohibitively memory intensive there’s a simpler solution: NEAR smart contracts that bind Send and Transfer transactions on both chains.This enables easy transfer of similar assets between chains.

## Cross-Chain Swaps

A NEAR smart contract participant binds an amount of USDC on NEAR or NEAR native currency, a multisig address is created with a key from the user sending on e.g.Litecoin and a key controlled by the Chain Signatures MPC confederation on NEAR, and the sender’s address on the delivery chain, such as Bitcoin, is submitted to the smart contract.A market maker listens for request-for-quotes from that relayer smart contract and responds by creating a channel on e.g.Bitcoin with the MPC confederation holding the second key.Then the user sends their asset on Litecoin to the channel address, the market maker sends their asset on Bitcoin to the other channel address, and the MPC confederation fulfills their bonded pledge by producing and signing the send transactions to the respective delivery addresses on each chain.

It’s possible to do this with Transfer instead of Sends, moving Commited tokens on the L2 between channels across the 3 chains that TradeLayer supports.This makes it possible to have a unified orderbook across all chains and orderbook servers, de-fragmenting liquidity, at a modest routing cost… as long as miner fees are low.

While not available at launch the power to route things across the Proof of Work ecosystem is exciting.

## Cross-chain Bridging

Back in 2015 USDT was first issued on the OmniLayer protocol, the ancestor of the TradeLayer protocol, using an administrative address where tokens could be minted and redeemed.Using a similar transaction type, it’s possible to manage centralized stablecoin and security tokens on TradeLayer, but what if this could be somewhat decentralized? Using Chain Signatures it’s possible to build cross-chain bridge contracts from NEAR to Litecoin, Bitcoin and Dogecoin, with the redemption of tokens being taken as a proof to unlock the redemption of bridged tokens on the smart contract chain.

While the early stage of TradeLayer’s launch will seek to have native issuance of smaller stablecoin contenders, the bridge application potential means that the wider DeFi galaxy can interact with TradeLayer in the future.To properly have an oracle that can guarantee the redemption of tokens based on valid balances, it will require that the current .js or future Rust implementation of TradeLayer be deployed on NEAR, but it’s a feasible solution when combined with an attestation of code version and tx index state to extrapolate from, with the matching txindex logged on the NEAR DA layer.

## UTXO AMM

Millions have been spent and the best minds in Bitcoin have wept over the challenge of doing more with raw BTC UTXOs without compromising the underlying Bitcoin protocol with a risky new hard fork.BitVM, Stacks and Botanix-like multisig models, ZK proofs of chain headers, Lightning Network virtual private channel factories and nested Taproot DLC contracts have all been tried, but since they’re navigating around a rigid structure they run into contortions, high costs and limited modularity.With Chain abstraction, it’s in theory possible to have TradeLayer’s synthetic model be automated with smart contracts that sign off on trades in an automated-market-maker, keeping a price near 1:1 for LTC to sLTC and so forth.AMMs like Curve that are providing raw liquidity on things like USDT/USDC, taking only credit and liquidity risk in the underlying instruments,the same idea applies for LTC/sLTC or BTC/sBTC market making.The challenge is in bringing the state of TradeLayer token balances to the smart contract environment.

## Virtualizing PoW Chains in WASM

The ZeroSync project shows a promising way of using ZK proofs to verify block headers and getting the last mile with cheaper-to-compute Merkel proofs such as UTreeXO, but the complications of ZK proving Scrypt leave the Chain Signature model on NEAR as an easier way to virtualize chain-state and make TradeLayer provably interactive with smart contracts.NEAR also brings advantages in having a very cost efficient Data Availabilty service and reasonable gas costs.

In order to make all of the above possible, the roadmap involves modifying Aurora’s Bitcoin Light Client relayer app for NEAR to Litecoin, integrating that with our wallet, and having relayers collate a tx index on NEAR as decentralized oracle.This approach distributes attack surface but is still subject to Sybil attacks, so ultimately we need to move towards a semi-full node implementation of Litecoin for NEAR, involving smart contract verification of Scrypto proof-of-work.In the mean-time we’ll have a quorum of privileged key-holders attest to the TradeLayer persistence checkpoint that is every 1000 blocks (approximately every 42 hours) to cross-check the distributed light-client submissions of TradeLayer tx.Later when we complete the larger task of virtualizing the recent chain history on NEAR, the process will become fully decentralized and the consensus of Scrypt miners will become binding for verifying transactions reviewed by NEAR smart contracts in considering when to push UTXOs on Litecoin.

While baseline protocol fees in TradeLayer are very low, there may be some additional fee routed as UTXO to addresses linked to smart contracts to compensate stakers for running this service and offset the cost of gas in virtualizing contracts.With current Litecoin activity and NEAR prices the cost of fully virtualizing the whole chain would be about $700-800 USD a year, with full blocks and higher NEAR prices the cost could balloon to 15k-50k a year, but the added fee shouldn’t need to be much higher than $1 per transaction as these scale together.

_Last updated: [10*7*2024]_

