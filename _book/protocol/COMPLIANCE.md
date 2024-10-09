
# Compliance

TradeLayer has a whitelist feature built-in, taking up a few tx types, for creating new whitelists and issuing/revoking attestations from that admin address.Like oracles and token issuer addresses, there’s a back-up address parameter and an update admin transaction type to refresh multisig security protocols, update to quantum-resistant addresses when those come out, and so on.The protocol uses two lists to verify who qualifies for delux rebates in the early stages of the protocol launch and which centralized oracles and tokens qualify to be included in cumulative LTC-equivalent volume for vesting and rebates.

Centralized issuers can use whitelists to gate who can trade their security tokens, contracts or stablecoins, in order to comply with relevant regulations as needed.Their policies for issuing and revoking addresses from the lists can be tailored to regulatory requirements off-chain and administered.

The mainnet release of the wallet will have IP verification and VPN detection to lock the wallet from being used by US persons.Even spot trading, unfortunately, is disabled for US persons as the 6050i rule puts criminal liability on transacting <10k USD without collecting social security numbers.Unless things change in the US, geofencing is the situation, there are plenty of regulated products US residents can utilize.6050i doesn’t apply to transactions conducted entirely (both parties) outside the USA and neither do SEC and CFTC restrictions.Additionally to build useful information about future whitelists, the wallet will issue a self-attestation with the country code of the user’s IP address when they interact with a wallet the first time, later issuers can parse that to draw up whitelists based on who they want to include.Using VPNs even after having tagged an address while on vacation to Costa Rica, will flag an address with an additional self-attestation.

This is designed to keep things as unrestricted for most of the world’s users and as smooth as possible while giving people who need the information the ability to filter counterparties or implement issuance policies.


_Last updated: [10*8*2024]_
