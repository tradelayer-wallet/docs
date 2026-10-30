# tl-release-verify (RUST-13)

Baseline: `tradelayer-wallet/docs` main `ff1e1fad3f1f44f35e1fd70a6670c50de2ff4052`.
Inspected: `_book/` (GitBook output with its Markdown sources), `.gitattributes`,
`_book/.gitattributes`, and the two committed downloads `TL-Extension.zip`
(5,914,723 bytes) and `TradeLayer-Wallet-Setup-0.1.exe` (92,879,604 bytes).

The charter task for this repository is prose plus release verification: this
repository has no executable code of its own to port. It adds:

- `rust/tl-release-verify`: a library and CLI that parse GNU `sha256sum` manifests
  and check artifacts against them.
- `_book/RELEASES.sha256`: SHA-256 of both downloads at the baseline commit.
- `_book/release_verification/VERIFY.md`: how to check downloads and what the checks
  do not prove (unsigned installer, no detached signature, same-origin hashes, no
  reproducible build). `Get-AuthenticodeSignature` on 2026-10-30 reported the
  installer `NotSigned`.
- `_book/api_reference/RUST.md`: the Rust components across the public repositories.

The rendered HTML (`*.html`, `search_plus_index.json`) was not regenerated: the
GitBook toolchain is not part of this repository. Open PR #2 (artifact
verification and unsigned-release disclosures) overlaps; this branch does not edit
its files.

## Behaviour

| Function | Rule |
|---|---|
| `parse_manifest` | `<64 lowercase hex>␠␠<path>` or `<hex>␠*<path>`; blank lines ignored; refuses uppercase/short digests, unsafe or duplicate paths, empty manifests, more than 1,000 entries |
| `safe_path` | relative `/`-separated segments of `[A-Za-z0-9._ -]`, never `.`/`..`, no leading `/` or `-`, <= 255 bytes |
| `verify` / `Report::all_ok` | each entry `Ok`/`Missing`/`Mismatch{actual}`; present-but-unlisted files reported; passes only if all are `Ok` and nothing is unlisted |
| `render_manifest` | sorted, `sha256sum -b` style, round-trips through `parse_manifest` |
| CLI | `check <manifest> <dir> [artifact…]` (exit 0/1/2), `make <dir> <artifact…>` |

## Dependency

`sha2 =0.10.9` (RustCrypto), the same pinned version used by `tl-collator`. Hashing is
not implemented here.

## Verification

    cargo test --locked --offline          # 5 tests incl. the committed downloads
    cargo clippy --locked --offline --all-targets -- -D warnings
    cargo fmt --all -- --check
    cargo run --locked --offline -- check ../../_book/RELEASES.sha256 ../../_book
    cd lean && lake build && lake env lean AxiomCheck.lean

`lean/` (Lean 4 v4.34.1, core only):

| Theorem | Statement |
|---|---|
| `accept_spec`, `parse_sound` | an accepted manifest is non-empty, has only safe paths and no repeated path |
| `allOk_sound` | passing verification means every listed file is present with exactly its listed digest and nothing unlisted was supplied |
| `tamper_detected` | a listed file with a different digest always fails verification |

SHA-256 is an abstract function in the model; its collision resistance is assumed.
`decide` examples replay `verify_reports_missing_mismatch_and_unlisted` and the
duplicate-path case.

## Not done

- Signing: there is no signature scheme or key; `VERIFY.md` lists it as planned work.
- CI workflow `.github/workflows/rust-tl-release-verify.yml` has not run (not pushed).
  The downloads are ordinary Git blobs (the LFS rules in `.gitattributes` match other
  file names), so a normal checkout contains them; the committed-download test
  tolerates absent files (e.g. blob-filtered clones) but fails on any mismatch.
