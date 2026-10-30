# Verifying downloads

This site hosts two downloads in `_book/`:

| File | SHA-256 |
|---|---|
| `TL-Extension.zip` | `efab02f55b2532e2e3912621d55584db20c385a0141887400809e7ad4d477914` |
| `TradeLayer-Wallet-Setup-0.1.exe` | `61ba293cfb84d7f3ecb94902b1df0ad8a7cc79780fcf7551662edd5ff5fc2ce8` |

The same list is in [`RELEASES.sha256`](../RELEASES.sha256) (GNU `sha256sum` format).

## What these releases do and do not have

- **No code signature.** The Windows installer is not Authenticode-signed; Windows
  will show an unknown-publisher warning. The browser-extension archive is not
  signed by a store.
- **No detached signature.** There is no PGP, minisign or Sigstore signature for
  either file or for the hash list.
- **Same-origin hashes.** The hash list lives in the same repository as the files.
  Matching it detects a corrupted or truncated download. It does **not** prove that
  the files came from the TradeLayer developers: anyone able to change the files here
  could change the list too.
- **Not reproducible yet.** There is no documented build that reproduces these bytes
  from source, so you cannot check them against the published code.

Install only if you accept these limits. Prefer building from source.

## Checking a download

Linux/macOS:

    sha256sum -c RELEASES.sha256

Windows PowerShell:

    Get-FileHash .\TradeLayer-Wallet-Setup-0.1.exe -Algorithm SHA256

With the Rust checker in this repository (`rust/tl-release-verify`):

    cargo run --locked -- check _book/RELEASES.sha256 _book

It reports `OK`, `MISSING`, `MISMATCH` or `UNLISTED` for each file and exits
non-zero unless every listed file matches and nothing unlisted was named.

## Planned improvements

1. Publish releases from tagged commits with a signed hash list (key fingerprint
   published through a second channel).
2. Sign the Windows installer.
3. Document a reproducible build so independent builders can confirm the hashes.
