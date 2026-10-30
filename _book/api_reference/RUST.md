# Rust components

TradeLayer's services and wallets are being ported from JavaScript/TypeScript to
Rust in additive `rust/` directories, one bounded crate per repository. The legacy
code keeps running until each crate passes review; no Rust component is deployed
as a replacement yet. Consensus state transitions, ledger arithmetic and chain replay
are implemented in the separate protocol core,
[`patrickdugan/TradeLayer-Rust`](https://github.com/patrickdugan/TradeLayer-Rust);
the crates below call into or check against it rather than re-implementing it.

| Repository | Crate | Scope |
|---|---|---|
| `tl-rpc` | `tl-rpc-client` | Read-only node RPC: a closed set of calls, bounded HTTPS/loopback transport, strict response checks |
| `tl-collator` | `tl-collator-wire`, `tl-witness-service`, `tl-rpc-router` | Canonical signed order envelopes, verified tape replay, an independent checkpoint witness, provider-routed RPC |
| `tl-orderbook-server` | `tl-orderbook` | External order book, matching, order lifecycle and swap-step protocol |
| `tl-relayer` | `tl-relayer-core` | Watch-only registry, unsigned transaction building, routed read RPC |
| `tradelayer-wallet` | `tl-wallet-service` | Desktop wallet backend contracts and the channel-swap state machine |
| `TL-Extension` | `tl-wallet-core` | Pure wallet operations for the browser extension (WASM-ready): addresses, coin selection, transaction building, message signing, a scoped signing capability |
| `tl-explorer` | `tl-explorer-api` | Typed explorer API endpoints, routes and link rules |
| `tradelayer-core` | `tl-core-reference` | Payload encoding and activation rules of the C++ reference node, with vectors generated from the C++ source |
| `Ark-TradeLayer` | `tl-ark-dlc` | Experimental Ark/DLC attestation and handshake vectors |
| `docs` | `tl-release-verify` | Checks downloads against `RELEASES.sha256` |

## Conventions

- Pinned toolchain (Rust 1.90.0), committed `Cargo.lock`, `#![forbid(unsafe_code)]`.
- Money is integer units or explicitly scaled decimals, never floating point.
- Every network is explicit; a chain is never inferred from an address prefix.
- Signing happens only through a capability bound to origin, network, account,
  approved inputs and outputs, and a fee limit.
- Each crate's README lists the legacy files it ports, a compatibility table
  (preserved behaviour, repaired defect, versioned change, open question) and the
  exact test commands.
- Each crate carries a `lean/` directory: Lean 4 models of its key functions with
  machine-checked proofs of the safety properties that matter for it (for example
  value conservation, authorization, bounds and round-trip encoding), plus concrete
  examples shared with the Rust tests.

Status per crate is in its README; nothing here has been audited independently yet.
