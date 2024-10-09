
##OP_Return Transactions

Every since the Mastercoin and Counterparty protocols launched in 2014, there have been people stuffing data into Bitcoin transactions in order to read them and come up with the state of tokens moving around the chain.While the original design document for Mastercoin (later rebranded as OmniLayer) included bi-lateral derivatives without a clearing system, the feature was never implemented, nor did spot trading despite the issuance of almost a billion USDT on the chain, due to problems with slow block times and high miner fees.The OP_Return field is a catch-all null op_code in the Bitcoin protocol where up to 80 bytes can be reliable stored, relayed by other nodes, and pruned when calculating the UTXO set (which shows who owns how much BTC).Likewise, TradeLayer starts fresh by parsing transactions from a genesis height (much later than the Bitcoin or Litecoin genesis block, defined when the protocol first activates) and logs which OP_Return transactions include a special marker.

##Tx Index and Consensus

The Tx Index accumulates all the possible transactions that might be valid or invalid TradeLayer transactions, and hashes them, which is useful as a foundation for consensus checking.Then the protocol’s core application loops through the tx index in sequence and checks the tx type, there are 36 types of transactions in TradeLayer, fitting neatly within 1 byte in base 36 encoding.Based on the tx type, the payload is decoded and the parameters are checked for validity, for instance sending tokens (tx type 2) requires that the sender address has tokens of propertyId N <= amount.The distinct parameters in a payload are separated by commas, or in the case of e.g.sending multiple types of tokens, the array of propertyIds are separated by semicolons.If the transaction is valid then it is passed to Logic, where changes to the protocol state are calculated and written to the local database.The contents of the data-base are hashed to produce a consensus state hash.The contents of the core files used to compute these changes of state are also hashed and can be referenced historically from the admin address that activates new transactions.There are a finite amount of upgrades possible in the protocol.

##Run-time

If there is no transaction index in the protocol the app will go into tx indexing mode and this can take half an hour or several hours depending on the length of history.Once the tx index is build, or if it’s already built up to some block, then the protocol will loop through to build consensus up to that block, and then enter block-lag mode, where recent transactions will be parsed and indexed, then processed into consensus.Once chain-tip is reached, real-time mode begins, catching new transactions, indexing and processing them.Sequence priority is given to some transactions for logic reasons, if they are in a single block with potentially competing transactions, this is particularly relevant for layer 2 functionality.

If there is a data corruption or a re-org, the protocol will fall back to the last persistence checkpoint which are logged very 1000 blocks, and rebuild consensus from that point.If there is an internet outage or the application is otherwise interrupted, it will be able to pick up from the last processed block.

How does TradeLayer have such low 0.5 bps fees? It factors out the hosting, compliance and routing costs of exchange operation to running full nodes, decentralized sequencers and whitelists, what’s left is pure software, open-sourced as a tool for humanity.


_Last updated: [10*7*2024]_
