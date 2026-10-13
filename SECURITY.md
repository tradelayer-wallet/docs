# Security Policy

## Reporting a vulnerability

Please report security vulnerabilities **privately** — do not open a public GitHub issue.

- **Email:** desk@tradelayer.org (the contact referenced throughout the TradeLayer documentation)
- Please include: a description of the issue, steps to reproduce, affected versions/artifacts, and a proof of concept where possible.
- Please allow reasonable time for a fix before any public disclosure.

**Maintainers:** enable [GitHub private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/working-with-global-security-advisories-in-the-github-advisory-database/about-github-security-advisories) for this repository (Settings → Security → Private vulnerability reporting) so researchers can report privately through GitHub. As of this writing, private reporting is **not** enabled, which is why the external review in issue #1 was published publicly.

## Known limitation: distributed binaries are UNSIGNED

This repository doubles as the distribution channel for the wallet binaries (`_book/TradeLayer-Wallet-Setup-0.1.exe`, `_book/TL-Extension.zip`). These artifacts are currently **not code-signed**:

- The Windows installer carries no Authenticode signature (empty PE certificate table), so Windows cannot verify the publisher and SmartScreen will warn users.
- The browser extension ships as a raw, unsigned archive.
- No detached signatures (GPG or otherwise) are published for any artifact.

Until signing is in place, the checksums below — also published in the docs under **Downloads → Verify Downloads** ([`_book/downloads/VERIFY.md`](_book/downloads/VERIFY.md)) — are the only integrity check available to users. Be aware of what a checksum can and cannot prove: it shows a download matches what this repository publishes, but it cannot prove who built the binary, and anyone with write access to this repository could replace a binary and its published checksum in the same commit.

**Recommended remediation, in order of impact:**

1. **Code-sign all distributed binaries** — Authenticode for the Windows installer; distribute the browser extension through the browser stores' signed pipelines.
2. **Sign the published checksums** — e.g. a `SHA256SUMS.sig` made with a GPG key whose fingerprint is published out-of-band (tradelayer.org, maintainer profiles), so the checksums do not share a single point of failure with the binaries.
3. **Move binary distribution out of the docs repository** to signed GitHub Releases with [artifact attestations (build provenance)](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds).
4. **Tag releases** so users can pin a version together with its checksums.

## Artifact checksums (current `main`)

| Artifact | Size (bytes) | SHA-256 |
| --- | ---: | --- |
| `_book/TradeLayer-Wallet-Setup-0.1.exe` | 92879604 | `61ba293cfb84d7f3ecb94902b1df0ad8a7cc79780fcf7551662edd5ff5fc2ce8` |
| `_book/TL-Extension.zip` | 5914723 | `efab02f55b2532e2e3912621d55584db20c385a0141887400809e7ad4d477914` |

Values were computed directly from the blobs committed to `main` and cross-checked against the independent review in issue #1 (2026-10-13). **Update this table and `_book/downloads/VERIFY.md` whenever a binary is replaced.**

> Note: the current binaries are committed as plain git blobs, not Git LFS objects. The only LFS-tracked artifacts in this repository's history are the removed Linux builds `TradeLayer-Wallet-0.0.15.AppImage` (sha256 `d24a1d8fdb0d6faacd0c05a6bb2a50c4155786d26b697f6e65b3fa6799f9d229`) and `TradeLayer-Wallet-0.0.16.AppImage` (sha256 `c0be84e355d2861bdfc372e723af917c742deaf2e5dfcad7b1b9bdf3489c75fe`), recorded here from their LFS pointer files for completeness. They are no longer distributed from `main`.

## Scope

In scope for reports: the wallet installer, the browser extension, the relayer/orderbook API surface documented in this book, and this repository's git history. Out of scope: theoretical issues in third-party dependencies without a demonstrated impact on a TradeLayer artifact.
