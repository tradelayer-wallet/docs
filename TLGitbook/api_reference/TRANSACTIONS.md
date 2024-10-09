
###Transaction Types


### Activation 

- **Description**: Sets up and activates various functionalities within the TradeLayer ecosystem.There are multiple activations, each enabling a specific set of transactions. Once the finite activations are expended this transaction loses all power.

- **Parameters**: 
- `txTypeToActivate`: The transaction type to be activated.
- `block`: The block at which the activation takes place.
--- 

### Send 
- **Description**: Allows users to send tokens from one address to another.
- **Parameters**: 
- `sendAll`: Boolean indicating if all tokens should be sent.
- `senderAddress`: The address initiating the transaction.
- `recipientAddresses`: Array of recipient addresses.
- `propertyIds`: Array of token property IDs to be sent.
- `amounts`: Array of amounts to be sent for each property.
- `block`: The block in which the transaction occurs.
--- ### Token Issue 
- **Description**: Issues a new token, which can be managed, fixed, or non-fungible.
- **Parameters**: 
- `sender`: The address of the token issuer.
- `initialAmount`: The total amount of the token at issuance.
- `ticker`: The symbol of the token.
- `url`: URL related to the token (optional).
- `whitelistId`: The whitelist ID associated with the token.
- `isManaged`: Boolean indicating if the token is managed.
- `backupAddress`: An alternate address for token management.
- `isNFT`: Boolean indicating if the token is non-fungible.
- `block`: The block in which the transaction occurs.

--- 
### Trade Token for UTXO 
- **Description**: Facilitates trading of a token in exchange for UTXOs.
- **Parameters**: 
- `senderAddress`: The address sending the token.
- `satsPaymentAddress`: The address receiving the Litecoin.
- `propertyId`: The ID of the token being traded.
- `amount`: The amount of tokens to be traded.
- `columnA`: Boolean indicating which column is involved in the trade.
- `satsExpected`: The expected amount in satoshis.
- `tokenDeliveryAddress`: The address receiving the tokens.
- `satsReceived`: The actual amount received in satoshis.
- `price`: Price per token.
- `paymentPercent`: The percentage of the payment.
- `block`: The block number of the transaction.
- `txid`: Transaction ID for reference.
--- 
### Commit Token 
- **Description**: Commits tokens to a specific purpose, such as creating a reserve.
- **Parameters**: 
- `senderAddress`: The address committing the tokens.
- `channelAddress`: The address of the channel where tokens are committed.
- `propertyId`: The ID of the property/token being committed.
- `amount`: The amount being committed.
--- 
### On-Chain Token-to-Token Trade 
- **Description**: Executes a token-to-token trade directly on-chain.
- **Parameters**: 
- `fromAddress`: The address initiating the trade.
- `offeredPropertyId`: The property ID being offered.
- `desiredPropertyId`: The property ID desired in exchange.
- `amountOffered`: The amount of the offered property.
- `amountExpected`: The amount expected in return.
- `stop`: Boolean indicating if this is a stop order.
- `post`: Boolean indicating if this is a post-only order.

--- 
### Cancel Order 
- **Description**: Cancels an existing order in the order book.
- **Parameters**: 
- `fromAddress`: The address requesting the cancellation.
- `isContract`: Boolean indicating if the order is for a contract.
- `offeredPropertyId`: The offered property ID.
- `desiredPropertyId`: The desired property ID.
- `cancelAll`: Boolean indicating if all orders should be canceled.
- `cancelParams`: Parameters for specific order cancellation.
--- 
### Create Clear List 
- **Description**: Creates a new clear list with specific criteria.
- **Parameters**: 
- `adminAddress`: The address of the admin managing the clear list.
- `name`: The name of the clear list.- `url`: URL associated with the clear list.
- `description`: Description of the clear list.
- `backupAddress`: Backup admin address.
--- 
### Update Admin 
- **Description**: Updates the admin address for tokens, oracles, or other entities.
- **Parameters**: 
- `whitelist`: Boolean for updating a whitelist admin.
- `token`: Boolean for updating a token admin.
- `oracle`: Boolean for updating an oracle admin.
- `id`: The ID of the entity to update.
- `newAddress`: The new admin address.
- `updateBackup`: Boolean indicating if the backup admin should also be updated.
--- 
### Issue or Revoke Attestation 
- **Description**: Issues or revokes an attestation for an address.
- **Parameters**: 
- `clearlistId`: The clear list ID.
- `targetAddress`: The address for the attestation.
- `clearlistRegistry`: The clear list registry.
- `metaData`: Metadata for the attestation.
- `revoke`: Boolean indicating if this is a revocation.
--- 
### AMM Pool - 
**Description**: Handles AMM (Automated Market Maker) pool actions like adding or redeeming capital.
- **Parameters**: 
- `sender`: The sender's address.
- `block`: The block number.
- `isRedeem`: Boolean indicating if it's a redeem action.
- `isContract`: Boolean indicating if the transaction involves a contract.
- `id`: ID of the property or contract involved.
- `amount`: Amount for the transaction.
- `id2`: Secondary ID for pairs (optional).
- `amount2`: Secondary amount (optional).

--- 

### Grant Managed Token 
- **Description**: Grants managed tokens to a recipient.
- **Parameters**: 
- `propertyId`: ID of the token property.
- `amount`: The amount to grant.
- `recipientAddress`: The recipient's address.
- `propertyManager`: The property manager instance.
--- 

### Redeem Managed Token 

- **Description**: Redeems managed tokens from an address.
- **Parameters**: - `propertyId`: The property ID.
- `amount`: Amount to redeem.
- `address`: The address initiating the redemption.
--- 

### Create Oracle 
- **Description**: Creates a new oracle with specific parameters.
- **Parameters**: 
- `adminAddress`: Admin address for the oracle.
- `ticker`: Ticker symbol for the oracle.- `url`: URL for the oracle.
- `backupAddress`: Backup admin address.
- `clearlists`: Clearlists associated with the oracle.
- `lag`: Oracle data lag time.
- `oracleRegistry`: Registry for oracles.
---


### Publish Oracle Data
- **Description**: Publishes data to an existing oracle.
- **Parameters**:
  - `oracleId`: The ID of the oracle to publish data to.
  - `price`: The price data to publish.
  - `high`: The high value for the data period.
  - `low`: The low value for the data period.
  - `close`: The close value for the data period.

---

### Close Oracle
- **Description**: Closes an existing oracle, stopping further data publishing.
- **Parameters**:
  - `oracleId`: The ID of the oracle to close.

---

### Create Contract Series
- **Description**: Creates a new futures contract series with parameters like leverage, collateral, and expiry.
- **Parameters**:
  - `sender`: Address creating the series.
  - `native`: Boolean indicating if the contract is native.
  - `underlyingOracleId`: The ID of the underlying oracle for the contract.
  - `onChainData`: Data required for on-chain execution.
  - `notionalPropertyId`: Property ID for notional value.
  - `notionalValue`: The value for notional amount.
  - `collateralPropertyId`: Collateral property ID.
  - `leverage`: Leverage factor for the contract.
  - `expiryPeriod`: Expiry period of the contract.
  - `series`: Series identifier.
  - `inverse`: Boolean indicating if the contract is inverse.
  - `fee`: The transaction fee for the series.
  - `block`: The block when the series is created.
  - `whitelist`: Whitelist associated with the series.

---

### Exercise Derivative
- **Description**: Exercises an existing derivative contract.
- **Parameters**:
  - `contractId`: The ID of the contract to exercise.
  - `amount`: The amount to exercise.
  - `contractsRegistry`: Registry instance for contracts.

---

### Trade Contract On-Chain
- **Description**: Executes an on-chain trade for a futures contract.
- **Parameters**:
  - `contractId`: The ID of the contract being traded.
  - `price`: The price for the contract.
  - `amount`: The amount of the contract.
  - `sell`: Boolean indicating if the trade is a sell order.
  - `insurance`: Insurance details for the trade.
  - `blockTime`: Block timestamp.
  - `txid`: Transaction ID.
  - `sender`: Address executing the trade.
  - `reduce`: Boolean indicating if this is a reduce-only order.
  - `post`: Boolean indicating if this is a post-only order.
  - `stop`: Boolean indicating if this is a stop order.

---

### Trade Contract Channel
- **Description**: Executes a trade for a contract within a specified channel.
- **Parameters**:
  - `contractId`: The ID of the contract being traded.
  - `price`: The price at which the contract is traded.
  - `amount`: The amount being traded.
  - `columnAIsSeller`: Boolean indicating if Column A is the seller.
  - `expiryBlock`: Expiry block for the contract.
  - `insurance`: Insurance details for the contract.
  - `channelAddress`: Address of the trading channel.

---

### Trade Tokens Channel
- **Description**: Facilitates token-to-token trade within a specific channel.
- **Parameters**:
  - `offeredPropertyId`: The ID of the token being offered.
  - `desiredPropertyId`: The ID of the token being requested.
  - `amountOffered`: Amount of the offered token.
  - `amountDesired`: Amount of the desired token.
  - `expiryBlock`: Expiry block for the trade.
  - `columnAIsOfferer`: Boolean indicating if Column A is the offerer.
  - `channelAddress`: The address of the trading channel.

---

### Withdrawal
- **Description**: Withdraws a specified amount of tokens from a channel.
- **Parameters**:
  - `withdrawAll`: Boolean indicating if all tokens should be withdrawn.
  - `channelAddress`: Address of the channel.
  - `propertyId`: The property ID for the tokens being withdrawn.
  - `amount`: The amount to withdraw.
  - `sender`: The address initiating the withdrawal.
  - `block`: The block number when the withdrawal occurs.
  - `columnIsB`: Boolean indicating if Column B is involved in the withdrawal.

---

### Transfer
- **Description**: Transfers tokens from one channel to another.
- **Parameters**:
  - `fromChannelAddress`: The channel address initiating the transfer.
  - `toChannelAddress`: The destination channel address.
  - `propertyId`: The ID of the property being transferred.
  - `amount`: The amount to transfer.
  - `isColumnA`: Boolean indicating if Column A is the source column.
  - `block`: The block number when the transfer occurs.

---

### Settle Channel PNL
- **Description**: Settles profit and loss for a specific trading channel.
- **Parameters**:
  - propertyId
  - amount
  - keepingTrade (boolean)
  - txId negated (base 94 encoded)
  - txId negated (if keepingTrade is false)
  - mark price (if keepingTrade is true)

---

### Mint Synthetic
- **Description**: Mints new synthetic tokens based on an existing property and contract.
- **Parameters**:
  - `address`: Address to receive the synthetic tokens.
  - `propertyId`: The collateral property ID.
  - `contractId`: The contract ID.
  - `amount`: Amount of synthetic tokens to mint.
  - `grossRequired`: Gross amount required as collateral.
  - `contracts`: Number of contracts.
  - `margin`: Margin required for the transaction.

---

### Redeem Synthetic
- **Description**: Redeems synthetic tokens for the underlying collateral.
- **Parameters**:
  - `address`: Address initiating the redemption.
  - `propertyId`: The ID of the synthetic token.
  - `contractId`: The associated contract ID.
  - `amount`: The amount to redeem.

---

### Pay To Tokens
- **Description**: Distributes one type of token to holders of another.
- **Parameters**:
  - `propertyIdTarget`: ID of the target property.
  - `propertyIdUsed`: ID of the property used for payment.
  - `amount`: The total amount for distribution.
  - `address`: Address initiating the distribution.

---

### Create Option Chain
- **Description**: Creates an options chain with specified strike intervals and style.
- **Parameters**:
  - `seriesId`: ID of the options series.
  - `strikePercentInterval`: Interval for strike prices.
  - `expiryNumber`: number of contracts in the series
  - `expiryInterval`: blocks between expirations for contracts in the series
  - `isEuropeanStyle`: Boolean indicating if the options are European style.

---

### Trade Bai Urbun
- **Description**: Facilitates an Islamic Bai Urbun trade within a channel.
- **Parameters**:
  - `channelAddress`: Address of the trading channel.
  - `propertyIdDownPayment`: Property ID for the down payment.
  - `propertyIdToBeSold`: Property ID for the item to be sold.
  - `downPaymentPercent`: Down payment percentage.
  - `amount`: Total amount for the trade.
  - `expiryBlock`: Expiry block for the trade.
  - `tradeExpiryBlock`: Trade expiry block.

---

### Trade Murabaha
- **Description**: Executes a Murabaha trade where the cost and profit margin are predefined.
- **Parameters**:
  - `channelAddress`: Address of the trading channel.
  - `buyerAddress`: Address of the buyer.
  - `sellerAddress`: Address of the seller.
  - `propertyId`: Property ID for the trade.
  - `costPrice`: Cost price for the goods.
  - `profitMargin`: Profit margin for the seller.
  - `paymentBlockHeight`: Block height for payment.

---

### Issue Invoice
- **Description**: Issues an invoice for a specified amount and due date.
- **Parameters**:
  - `propertyManager`: The property manager instance.
  - `invoiceRegistry`: Registry instance for invoices.
  - `propertyIdToReceivePayment`: Property ID to receive payment.
  - `amount`: Amount for the invoice.
  - `dueDateBlock`: Due date block.
  - `propertyIdCollateral`: Collateral property ID (optional).
  - `receivesPayToToken`: Boolean for pay-to-token collateral.
  - `issuerNonce`: Nonce for the issuer.

---

### Batch Move ZK Rollup
- **Description**: Processes a batch of transactions using zero-knowledge rollups.
- **Parameters**:
  - `zkVerifier`: Verifier for zero-knowledge proofs.
  - `rollupData`: Data for the rollup batch.
  - `zkProof`: Zero-knowledge proof for the rollup batch.

---

### Publish New Tx
- **Description**: Publishes a new transaction type with accompanying code.
- **Parameters**:
  - `ordinalRevealJSON`: JSON data for the ordinal reveal.
  - `jsCode`: JavaScript code associated with the transaction.

---

### Bind Smart Contract
- **Description**: Tags the sender address as having keys controlled by 
- **Parameters**: 
  - `contractHash`: identifier for the contract address on the foreign chain
  - `controlledKeys`: number of keys on the address controlled by the contract
  - `thresholdKeys`: number of signatures needed to sign a tx from this address (if multisig)
  - `maximumKeys`: maximum number of keys on the address (if multisig)
  - `ordinalRevealCode`: Code for the contract can be found in the witness data 
---

### Register and Redeem OP_CTV Covenant
- **Description**: Registers or redeems an OP_CTV Covenant transaction.
- **Parameters**: To be defined based on specific use case requirements.

---

### Mint Colored Coin
- **Description**: Mints a new colored coin with specific properties.
- **Parameters**: To be defined based on specific use case requirements.

---

_Last updated: [10*8*2024]_
