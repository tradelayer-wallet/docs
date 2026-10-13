# Verify Downloads

TradeLayer distributes the desktop wallet installer and the browser extension as raw binaries from this repository. These binaries are currently **unsigned**, so the only way to confirm that a download has not been corrupted or tampered with is to check its SHA-256 checksum **before** installing or loading it.

## Official checksums

The values below match the binaries currently published on the `main` branch of the [tradelayer-wallet/docs](https://github.com/tradelayer-wallet/docs) repository (verified 2026-10-13):

| File | Size (bytes) | SHA-256 |
| --- | --- | --- |
| [TradeLayer-Wallet-Setup-0.1.exe](../TradeLayer-Wallet-Setup-0.1.exe) (Windows installer) | 92879604 | `61ba293cfb84d7f3ecb94902b1df0ad8a7cc79780fcf7551662edd5ff5fc2ce8` |
| [TL-Extension.zip](../TL-Extension.zip) (browser extension) | 5914723 | `efab02f55b2532e2e3912621d55584db20c385a0141887400809e7ad4d477914` |

The same values in `sha256sum -c` format (save as `SHA256SUMS` next to the downloaded files):

```
61ba293cfb84d7f3ecb94902b1df0ad8a7cc79780fcf7551662edd5ff5fc2ce8  TradeLayer-Wallet-Setup-0.1.exe
efab02f55b2532e2e3912621d55584db20c385a0141887400809e7ad4d477914  TL-Extension.zip
```

## How to verify

Run the command for your operating system in the directory containing the downloaded file. The printed hash must match the table above **exactly**. Substitute `TL-Extension.zip` for the file name when verifying the browser extension.

### Windows

Command Prompt:

```
certutil -hashfile TradeLayer-Wallet-Setup-0.1.exe SHA256
```

PowerShell:

```
Get-FileHash .\TradeLayer-Wallet-Setup-0.1.exe -Algorithm SHA256
```

### macOS

```
shasum -a 256 TradeLayer-Wallet-Setup-0.1.exe
```

### Linux

```
sha256sum TradeLayer-Wallet-Setup-0.1.exe
```

Or, with the `SHA256SUMS` file from above:

```
sha256sum -c SHA256SUMS
```

## Warnings

> **Only download TradeLayer software from official sources** — the [tradelayer.org/downloads](https://tradelayer.org/downloads) page or this repository. Never install a binary that was forwarded to you by a third party, surfaced by a search ad, or offered in a chat room.

> **Verify before installing.** If the computed hash does not match the published value, do not run the file — delete it and report the incident to desk@tradelayer.org.

Limitations you should be aware of:

- The binaries are currently **unsigned** (no Authenticode / code-signing), so your operating system cannot vouch for the publisher. Windows SmartScreen may warn about the installer; verifying the checksum is the mitigation available today.
- A checksum only proves your copy matches what this repository publishes — it cannot prove who built the binary. Always compare against the checksums in the official repository (this page, or [SECURITY.md](https://github.com/tradelayer-wallet/docs/blob/main/SECURITY.md)), not a copy received elsewhere.
- The long-term fix is code signing plus GPG-signed checksums; see [SECURITY.md](https://github.com/tradelayer-wallet/docs/blob/main/SECURITY.md) for the recommended roadmap.

_Last updated: [10*13*2026]_
