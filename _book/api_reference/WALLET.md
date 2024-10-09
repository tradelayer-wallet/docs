
### Wallet Integration

TradeLayer’s Electron-based desktop wallet is an example of how to integrate a wallet with TradeLayer. In the first release the wallet requires both the TradeLayer application inline in the /dist folder and that the litecoind instance packaged with the installer be allowed to reach a full sync on mainnet. In subsequent releases an API-mode will enable users to point at a server hosting a litecoind node with TradeLayer and responding to external requests.

Likewise it’s possible to integrate TradeLayer into other web and browser-extension based wallets with an API mode that queries multiple end-points for security. This can be useful for trading, where most of the operations can be executed with javascript or Rust implementations of Bitcoin and Litecoin, such as litecore-lib, Bitcoin-js and others. It’s also possible to package a web wallet with a partial node that relies on the 1000 block persistence checkpoints and only verifies blocks, the correct chain, and transaction validity, parsing for TL transactions and updating state accordingly, this is more robust than an API-dependent wallet mode but much lighter than downloading the entire blockchain and using a C++ RPC client locally.

For more about wallet integration partnerships please reach out to desk@tradelayer.org and we’ll be happy to talk through possibilities.


_Last updated: [10*8*2024]_