# Security Policy

## Reporting a vulnerability

Please report security vulnerabilities **privately** — do not open a public GitHub issue.

- **Email:** desk@tradelayer.org (the contact referenced throughout the TradeLayer documentation)
- Please include: a description of the issue, steps to reproduce, affected versions/artifacts, and a proof of concept where possible.
- Please allow reasonable time for a fix before any public disclosure.

**Maintainers:** enable [GitHub private vulnerability reporting](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately) for this repository (Settings → Security → Private vulnerability reporting) so researchers can report privately through GitHub. As of this writing, private reporting is **not** enabled, which is why the external review in issue #1 was published publicly.

## Known limitation: distributed binaries are UNSIGNED

This repository doubles as the distribution channel for the wallet binaries (`_book/TradeLayer-Wallet-Setup-0.1.exe`, `_book/TL-Extension.zip`). These artifacts are currently **not code-signed**:

- The Windows installer carries no Authenticode signature (empty PE certificate table), so Windows cannot verify the publisher and SmartScreen will warn users.
- The browser extension ships as a raw, unsigned archive.
- No detached signatures (GPG or otherwise) are published for any artifact.

Until signing is in place, the checksums published on the **Downloads → Verify Downloads** page ([`_book/downloads/VERIFY.md`](_book/downloads/VERIFY.md)) are the only integrity check available to users. Be aware of what a checksum can and cannot prove: it shows a download matches what this repository publishes, but it cannot prove who built the binary, and anyone with write access to this repository could replace a binary and its published checksum in the same commit.

**Recommended remediation, in order of impact:**

1. **Code-sign all distributed binaries** — Authenticode for the Windows installer; distribute the browser extension through the browser stores' signed pipelines.
2. **Sign the published checksums** — e.g. a `SHA256SUMS.sig` made with a GPG key whose fingerprint is published out-of-band (tradelayer.org, maintainer profiles), so the checksums do not share a single point of failure with the binaries.
3. **Move binary distribution out of the docs repository** to signed GitHub Releases with [artifact attestations (build provenance)](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds).
4. **Tag releases** so users can pin a version together with its checksums.

## Changing a binary or its checksum

Changes to the binaries, their checksum page, the checker, its workflow and this policy need a review from a code owner (see [`.github/CODEOWNERS`](.github/CODEOWNERS)). That review is the only control on a binary change: the checker cannot stop one. The owner rule is enforced only when the default branch requires code-owner review.

A pull request that replaces a binary together with its table row:

- **Passes the download hash check.** The new row matches the new committed blob and the copies match the row. The checker has no trusted copy of the release hash to compare against, so it cannot tell a legitimate release from a swapped binary.
- **Is visible.** The workflow logs a warning for each binary the pull request changes, and the diff shows the binary and the row together.
- **Cannot pass** with a row that does not match the committed binary, a checksum that a reader can see on the page but is not in the table, or a changed checker: the workflow runs the checker from the base branch against the pull request's files.
- **Cannot be checked against the release.** Whether a binary is the released build is not established by this repository; see the roadmap above.

A pull request that edits `.github/workflows/` is run with its own workflow definition, so the base-branch checker does not guard it. Code-owner review of `.github/` is the control for that case.

## Checksums and historical binaries

The current checksums are published in exactly one place, [`_book/downloads/VERIFY.md`](_book/downloads/VERIFY.md), together with the verification procedure. Do not copy them elsewhere: when a binary is replaced, update that page.

> **Note on historical binaries.** The current binaries are committed as plain git blobs, not Git LFS objects. The removed Linux builds are the only artifacts in this repository's history that were converted to Git LFS pointers: `TradeLayer-Wallet-0.0.15.AppImage` (pointer oid sha256 `d24a1d8fdb0d6faacd0c05a6bb2a50c4155786d26b697f6e65b3fa6799f9d229`) and `TradeLayer-Wallet-0.0.16.AppImage` (pointer oid sha256 `c0be84e355d2861bdfc372e723af917c742deaf2e5dfcad7b1b9bdf3489c75fe`). Older `.exe` builds (0.0.12/0.0.15/0.0.16) remain in history as raw blobs with **no published checksums**.
>
> **Both AppImage hashes above are taken from LFS pointer files only.** No LFS objects for them are present in this clone, so treat them as unverified assertions, not as checksums computed from actual binaries. Git history contains both forms of `TradeLayer-Wallet-0.0.15.AppImage`: the LFS pointer recording `d24a1d8f…` and a raw 100,956,365-byte blob (commit `7d8cfda`) whose actual SHA-256 is `2e543330f6bab986a99bbd3841907891cb00db1153fde7bb1135b3eb23d485fa` — which does **not** match the pointer-derived value. History also contains two different LFS pointers for `TradeLayer-Wallet-0.0.16.AppImage` (an earlier one recording `b867cc1fe356b1f2b98b4f963404f3eeaf6330faf1ca9b997d669a6cf7c08760`; the value recorded here is the later `c0be84e3…`). None of the historical AppImage hashes have been verified against real binaries. The AppImages are no longer distributed from `main`.

## Scope

In scope for reports: the wallet installer, the browser extension, the relayer/orderbook API surface documented in this book, and this repository's git history. Out of scope: theoretical issues in third-party dependencies without a demonstrated impact on a TradeLayer artifact.
