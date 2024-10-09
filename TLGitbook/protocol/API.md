

###API

## API Reference

This API wrapper provides WebSocket and HTTP functionality to interact with an order book server. It includes methods to place and manage orders, retrieve market data, and access real-time order book information.

## Initialization

To initialize the API wrapper, create an instance of `ApiWrapper` by specifying the `baseURL` and `port`:

```javascript
const api = new ApiWrapper('http://example.com', 9191);

# WebSocket Events

### connect
- **Description**: Triggered upon successful connection to the WebSocket server.
- **Example Output**:
	```plaintext
	Connected to Orderbook Server with ID: socket_id
	```

### disconnect
- **Description**: Triggered when the connection to the server is lost.
- **Parameters**:
  - `reason` (string): Reason for disconnection.
- **Example Output**:
	```plaintext
	Disconnected: transport close
	```

### order:saved
- **Description**: Triggered when a new order is successfully saved.
- **Example Output**:
	```plaintext
	Order saved with UUID: order_uuid
	```

### order:error
- **Description**: Triggered when there is an error processing an order.
- **Example Output**:
	```plaintext
	Order error: error_message
	```

### orderbook-data
- **Description**: Provides updates to the order book data.
- **Example Output**:
	```json
	{
  	"pair": "BTC-LTC",
  	"bids": [{"price": "0.1", "amount": "50"}],
  	"asks": [{"price": "0.15", "amount": "100"}]
	}
	```

# Methods

### sendOrder(orderDetails)
- **Description**: Emits a new order to the server.
- **Parameters**:
  - `orderDetails`: Object containing order details (`isLimitOrder`, `props`, `action`).
- **Returns**: `Promise` resolving to the `orderUuid`.
- **Example Call**:
	```javascript
	const newOrder = {
  	isLimitOrder: true,
  	props: {
      	id_desired: 1,
      	id_for_sale: 2,
      	amount: 100,
      	price: 0.05
  	},
  	action: 'BUY'
	};

	api.sendOrder(newOrder)
  	.then(orderUuid => {
      	console.log(`Order saved with UUID: ${orderUuid}`);
  	})
  	.catch(error => {
      	console.error(`Order failed: ${error}`);
  	});
	```
- **Example Response**:
	```plaintext
	Order saved with UUID: order_uuid
	```
### getOrderbookData(filter)

- **Description**: Fetches the current order book data based on filters.
- **Parameters**:
  - `filter` (object): Filtering options, e.g., `{ first_token: 1, second_token: 2, type: 'SPOT' }`.
- **Returns**: `Promise` resolving with order book data (object).
- **Example Call**:
  ```javascript
  api.getOrderbookData({ first_token: 1, second_token: 2, type: 'SPOT' })
  	.then(data => console.log('Orderbook Data:', data))
  	.catch(error => console.error('Failed to fetch orderbook data:', error));

#### Example Response:

```json
{
  "orders": [
	{
  	"type": "SPOT",
  	"action": "BUY",
  	"props": { /* object properties */ },
  	"keypair": { /* key pair properties */ },
  	"isLimitOrder": true,
  	"timestamp": 1728408839716,
  	"uuid": "8b14cf31-c2ef-4bdd-8e73-f19875808be4",
  	"socket_id": "TashlviPo3EIZ1YYAABJ",
  	"lock": false
	}
  ],
  "history": []
}



### cancelOrder(orderUUID)

- **Description**: Cancels an existing order.
- **Parameters**:
  - `orderUUID` (string): Unique identifier of the order to cancel.
- **Returns**: `Promise` resolving with confirmation (object).
- **Example Call**:
  ```javascript
  api.cancelOrder('123e4567-e89b-12d3-a456-426614174000')
  	.then(confirmation => console.log('Order canceled:', confirmation))
  	.catch(error => console.error('Failed to cancel order:', error));


### getFuturesMarkets

- **Description**: Retrieves futures markets information.
- **Returns**: `Promise` resolving with an array of futures markets (object).
- **Example Call**:
  ```javascript
  api.getFuturesMarkets()
  	.then(markets => console.log('Futures Markets:', markets))
  	.catch(error => console.error('Error fetching futures markets:', error));

### getSpotMarkets

- **Description**: Retrieves spot markets information.
- **Returns**: `Promise` resolving with an array of spot markets (object).
- **Example Call**:
  ```javascript
  api.getSpotMarkets()
  	.then(markets => console.log(‘Spot Markets:', markets))
  	.catch(error => console.error('Error fetching spot markets:', error));


#### Example Response: ```json

Spot Markets Response Data: {
  data: [
	{
  	name: 'LTC',
  	markets: [
    	{
      	first_token: { shortName: 'LTC', fullName: 'LTC', propertyId: 0 },
      	second_token: { shortName: 'TBILL', fullName: 'TBILL', propertyId: 5 },
      	disabled: false,
      	pairString: 'LTC/TBILL'
    	},
    	{
      	first_token: { shortName: 'TL', fullName: 'TL', propertyId: 1 },
      	second_token: { shortName: 'LTC', fullName: 'LTC', propertyId: 0 },
      	disabled: false,
      	pairString: 'TL/LTC'
    	},
    	{
      	first_token: { shortName: 'sLTC', fullName: 'sLTC', propertyId: 's-1-5' },
      	second_token: { shortName: 'LTC', fullName: 'LTC', propertyId: 0 },
      	disabled: false,
      	pairString: 'sLTC/LTC'
    	},
    	{
      	first_token: { shortName: 'TL', fullName: 'TL', propertyId: 1 },
      	second_token: { shortName: 'TBILL', fullName: 'TBILL', propertyId: 5 },
      	disabled: false,
      	pairString: 'TL/TBILL'
    	},
    	{
      	first_token: { shortName: 'sLTC', fullName: 'sLTC', propertyId: 's-1-5' },
      	second_token: { shortName: 'TBILL', fullName: 'TBILL', propertyId: 5 },
      	disabled: false,
      	pairString: 'sLTC/TBILL'
    	}
  	],
  	icon: 'https://bitcoin-capital.bg/wp-content/uploads/2019/07/1920px-LTC-400-min-300x300.png',
  	disabled: false
	}
  ]
}


_Last updated: [10*8*2024]_
