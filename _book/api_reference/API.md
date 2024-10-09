
### Rest Endpoints

### `/tl_initmain`

**Description:** Initializes the main processor.

- **Parameters:**
  - `test` (boolean, optional) - For testing mode.
- **Response:**
  - Success: `Main process initialized successfully`
  - Error: Error message if initialization fails.

---

### `/tl_validateaddress`

**Description:** Validates a given address.

- **Parameters:**
  - `address` (string) - The address to validate.
- **Response:**
  - Success: Validation response object.
  - Error: Error message if validation fails.

---

### `/tl_getTransaction`

**Description:** Retrieves transaction parameters based on the transaction ID.

- **Parameters:**
  - `txid` (string) - The transaction ID.
- **Response:**
  - Success: Transaction information object.
  - Error: Error message if retrieval fails.

---

### `/tl_getChannelColumn`

**Description:** Determines the channel column based on the channel and counterparty addresses.

- **Parameters:**
  - `channelAddress` (string) - The channel address.
  - `cpAddress` (string) - The counterparty address.
- **Response:**
  - Success: Channel column information.
  - Error: Error message if retrieval fails.

---

### `/tl_loadWallet`

**Description:** Loads the wallet.

- **Parameters:** None.
- **Response:**
  - Success: `loading wallet`
  - Error: Error message if wallet loading fails.

---

### `/tl_gettransactionsforaddress`

**Description:** Retrieves transactions associated with a specific address.

- **Parameters:**
  - `address` (string) - The address to query.
- **Response:**
  - Success: Array of transactions for the address.
  - Error: Error message if retrieval fails.

---

### `/tl_gettransactionforblock`

**Description:** Retrieves transactions associated with a specific block.

- **Parameters:**
  - `blockHeight` (number) - The block height.
- **Response:**
  - Success: Array of transactions for the block.
  - Error: Error message if retrieval fails.

---

### `/tl_getMaxProcessedHeight`

**Description:** Retrieves the maximum processed block height.

- **Parameters:** None.
- **Response:**
  - Success: Maximum processed block height.
  - Error: Error message if retrieval fails.

---

### `/tl_getMaxParsedHeight`

**Description:** Retrieves the maximum parsed block height.

- **Parameters:** None.
- **Response:**
  - Success: Maximum parsed block height.
  - Error: Error message if retrieval fails.

---

### `/tl_pause`

**Description:** Pauses the main processor.

- **Parameters:** None.
- **Response:**
  - Success: Pause status.
  - Error: Error message if pausing fails.

---

### `/tl_getAllBalancesForAddress`

**Description:** Retrieves all balances for a specific address.

- **Parameters:**
  - `params` (string) - The address to query.
- **Response:**
  - Success: Balances for the address.
  - Error: Error message if retrieval fails.

---

### `/tl_getChannel`

**Description:** Retrieves channel information for a given address.

- **Parameters:**
  - `params` (string) - The address to query.
- **Response:**
  - Success: Channel information or message if no channel is found.
  - Error: Error message if retrieval fails.

**Example Response:** ```json
{"_id":"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8","data":{"participants":{"A":"","B":"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8"},"channel":"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8","commits":[{"senderAddress":"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8","propertyId":4,"tokenAmount":0.00001,"block":3348377,"columnAssigned":"B"},{"senderAddress":"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8","propertyId":4,"tokenAmount":0.00001,"block":3348528,"columnAssigned":"B"}],"A":{},"B":{"4":0},"lastCommitmentTime":3348528,"lastUsedColumn":"B"}}

```
---

### `/tl_createrawtx_opreturn`

**Description:** Adds an OP_RETURN to a transaction blob.

- **Parameters:**
  - `txHex` (string) - Transaction hex.
  - `payload` (string) - OP_RETURN payload.
- **Response:**
  - Success: Transaction with OP_RETURN added.
  - Error: Error message if creation fails.

---

### `/tl_getProperty`

**Description:** Retrieves property data based on property ID.

- **Parameters:**
  - `params` (string) - Property ID.
- **Response:**
  - Success: Property data.
  - Error: Error message if retrieval fails.


**Example Response:** ```json

[1,{\"ticker\":\"TL\",\"totalInCirculation\":500000,\"type\":1,\"whitelistId\":0}]
 ```

---

### `/tl_listProperties`

**Description:** Lists all properties.

- **Parameters:** None.
- **Response:**
  - Success: Array of properties.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{"_id":"propertyIndex","value":"[[1,{\"ticker\":\"TL\",\"totalInCirculation\":500000,\"type\":1,\"whitelistId\":0}],[2,{\"ticker\":\"TLVEST\",\"totalInCirculation\":250000,\"type\":4,\"whitelistId\":0}],[3,{\"ticker\":\"TLIVEST\",\"totalInCirculation\":1500000,\"type\":4,\"whitelistId\":0}],[4,{\"ticker\":\"TLI\",\"totalInCirculation\":1500001,\"type\":3,\"whitelistId\":0}],[5,{\"ticker\":\"TJRZT\",\"totalInCirculation\":694258,\"type\":1,\"whitelistId\":0,\"issuer\":\"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8\",\"backupAddress\":\"LNmiS6p8z3KuHHx3q6Jf6x6TfcyptE68oP\"}],[6,{\"ticker\":\"CELFE\",\"totalInCirculation\":741256,\"type\":1,\"whitelistId\":0,\"issuer\":\"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8\",\"backupAddress\":\"LNmiS6p8z3KuHHx3q6Jf6x6TfcyptE68oP\"}],[7,{\"ticker\":\"OZGJE\",\"totalInCirculation\":471902,\"type\":1,\"whitelistId\":0,\"issuer\":\"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8\",\"backupAddress\":\"LNmiS6p8z3KuHHx3q6Jf6x6TfcyptE68oP\"}]]"}
 ```

---

### `/tl_listFeeCache`

**Description:** Retrieves fee cache for all properties.

- **Parameters:** None.
- **Response:**
  - Success: Fee cache data.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{id:’feeCache’, value:[{id:1, amount:123432.2343},{id:5,amount: 343.23}]

 ```

---

### `/tl_propertyFeeCache`

**Description:** Retrieves fee cache for a specific property.

- **Parameters:**
  - `id` (string) - Property ID.
- **Response:**
  - Success: Fee cache data for the property.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{id:5,amount: 343.23}

 ```

---

### `/tl_getActivations`

**Description:** Retrieves the list of activations.

- **Parameters:** None.
- **Response:**
  - Success: Array of activations.
  - Error: Error message if retrieval fails.

---

### `/tl_getOrderbook`

**Description:** Retrieves the order book for a given property pair.

- **Parameters:**
  - `propertyId1` (number) - First property ID.
  - `propertyId2` (number) - Second property ID.
- **Response:**
  - Success: Order book data.
  - Error: Error message if retrieval fails.

---

### `/tl_getContractOrderbook`

**Description:** Retrieves the contract order book.

- **Parameters:**
  - `contractId` (number) - Contract ID.
- **Response:**
  - Success: Contract order book data.
  - Error: Error message if retrieval fails.

---

### `/tl_listContractSeries`

**Description:** Lists series for a specific contract.

- **Parameters:**
  - `contractId` (number) - Contract ID.
- **Response:**
  - Success: Array of contract series.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{"id":1,"data":{"id":1,"issuer":"tltc1qa0kd2d39nmeph3hvcx8ytv65ztcywg5sazhtw8","native":true,"underlyingOracleId":0,"onChainData":[[0,1]],"notionalPropertyId":0,"notionalValue":0.0001,"collateralPropertyId":1,"leverage":5,"expiryPeriod":4032,"series":5,"inverse":true,"fee":false,"whitelist":0,"contracts":{"expired":[],"unexpired":[{"id":"1-3086534","expirationBlock":3086534},{"id":"1-3090566","expirationBlock":3090566},{"id":"1-3094598","expirationBlock":3094598},{"id":"1-3098630","expirationBlock":3098630},{"id":"1-3102662","expirationBlock":3102662}]},"ammPool":{"position":0,"maxPosition":1,"maxQuoteSize":10,"contractType":1,"lpAddresses":{},"ammOrders":[]}},"type":"contractSeries","_id":"c3ChX43pOXVagVqn"}

```
---

### `/tl_listOracles`

**Description:** Lists all oracles.

- **Parameters:** None.
- **Response:**
  - Success: Array of oracles.
  - Error: Error message if retrieval fails.

---
### `/tl_listClearlists`

**Description:** Lists all clearLists.

- **Parameters:** None.
- **Response:**
  - Success: Array of clearlists.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{"_id":1,"data":{"name":"Market Maker Whitelist","description":"Market Makers and active traders who do not wash trade."}}
```
—

### `/tl_showClearlist`

**Description:** Lists all clearLists.

- **Parameters:** id
- **Response:**
  - Success: Array of clearlists.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{"_id":1,"data":{"name":"Market Maker Whitelist","description":"Market Makers and active traders who do not wash trade."}}
```
—

### `/tl_contractPosition`

**Description:** Retrieves the contract position for a given address and contract ID.

- **Parameters:**
  - `address` (string) - Address to query.
  - `contractId` (number) - Contract ID.
- **Response:**
  - Success: Contract position data.
  - Error: Error message if retrieval fails.

---

### `/tl_tradeHistory`

**Description:** Retrieves the trade history for a given property pair.

- **Parameters:**
  - `propertyId1` (number) - First property ID.
  - `propertyId2` (number) - Second property ID.
- **Response:**
  - Success: Trade history data.
  - Error: Error message if retrieval fails.

**Example Response:** ```json

{"_id":"token-1-0-cbd88a9b-e324-458d-ada8-26be4c57becf-3395569","key":"token-1-0","type":"token","trade":{"offeredPropertyId":1,"desiredPropertyId":0,"amountOffered":1e-8,"amountExpected":1000000},"blockHeight":3395569,"txid":"c59fd0a35bc93979133cda1ae86c235428112c153fbdabed2cbc7ea86e60543f"}
```


---

### `/tl_getInitMargin`

**Description:** Retrieves the initial margin for a contract based on price.

- **Parameters:**
  - `contractId` (number) - Contract ID.
  - `price` (number) - Price of the contract.
- **Response:**
  - Success: Returns a number for the amount of collateral id needed at the given price to margin 1 contract..
  - Error: Error message if retrieval fails.

---

### `/tl_contractTradeHistory`

**Description:** Retrieves trade history for a specific contract.

- **Parameters:**
  - `contractId` (number) - Contract ID.
- **Response:**
  - Success: Contract trade history data.
  - Error: Error message if retrieval fails.

---

### `/tl_fundingHistory`

**Description:** Retrieves funding history for a specific contract.

- **Parameters:**
  - `contractId` (number) - Contract ID.
- **Response:**
  - Success: Funding history data.
  - Error: Error message if retrieval fails.

---

### `/tl_oracleHistory`

**Description:** Retrieves oracle history for a specific contract.

- **Parameters:**
  - `contractId` (number) - Contract ID.
- **Response:**
  - Success: Oracle history data.
  - Error: Error message if retrieval fails.


_Last updated: [10*8*2024]_