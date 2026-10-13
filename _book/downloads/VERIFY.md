# Verify Downloads

TradeLayer distributes the desktop wallet installer and the browser extension as raw binaries from this repository. These binaries are currently **unsigned**, so a SHA-256 checksum is the only integrity check available today. It catches corrupted or incomplete downloads, but it is not an independent proof of authenticity (see [Limitations](#limitations)). Verify the file **before** installing or loading it.

## Official checksums

The values below match the binaries committed to the `main` branch of this repository (verified 2026-10-13):

| File | Size (bytes) | SHA-256 |
| --- | --- | --- |
| [TradeLayer-Wallet-Setup-0.1.exe](../TradeLayer-Wallet-Setup-0.1.exe) (Windows installer) | 92879604 | `61ba293cfb84d7f3ecb94902b1df0ad8a7cc79780fcf7551662edd5ff5fc2ce8` |
| [TL-Extension.zip](../TL-Extension.zip) (browser extension) | 5914723 | `efab02f55b2532e2e3912621d55584db20c385a0141887400809e7ad4d477914` |

These hashes apply to the binaries as of the date stated above; if the binaries change and this page is not updated, treat the published hashes as unverifiable.

## How to verify

Run the command for your operating system in the folder that contains the downloaded file, then compare the full printed hash with the value for that file in the table above. Substitute `TL-Extension.zip` for the file name when verifying the browser extension.

- Compare the **full 64-character** value. A match on only the first few characters is a failure.
- Letter case does not matter, because some tools print uppercase hex.
- If a command errors, prints nothing, or the values differ, **do not run the file** (see [Warnings](#warnings)).
- The pass/fail commands below use the placeholder `<SHA-256 from the table>`. Replace it with the value from the table for your file. If you leave the placeholder in, the command reports a failure, so a mistake cannot show a false pass.

### Windows

Command Prompt, prints the hash to compare by eye:

```
certutil -hashfile TradeLayer-Wallet-Setup-0.1.exe SHA256
```

PowerShell, prints the hash to compare by eye:

```
Get-FileHash .\TradeLayer-Wallet-Setup-0.1.exe -Algorithm SHA256
```

PowerShell pass/fail check, prints `True` only if the hash matches (case is ignored):

```
(Get-FileHash .\TradeLayer-Wallet-Setup-0.1.exe -Algorithm SHA256).Hash -eq '<SHA-256 from the table>'
```

### macOS

```
shasum -a 256 TradeLayer-Wallet-Setup-0.1.exe
```

Pass/fail check, prints `OK` only if the hash matches and `FAILED` otherwise:

```
echo "<SHA-256 from the table>  TradeLayer-Wallet-Setup-0.1.exe" | shasum -a 256 -c -
```

The installer is a Windows program, so hashing it on macOS only confirms that your copy matches the table.

### Linux

```
sha256sum TradeLayer-Wallet-Setup-0.1.exe
```

Pass/fail check, prints `OK` only if the hash matches and `FAILED` otherwise:

```
echo "<SHA-256 from the table>  TradeLayer-Wallet-Setup-0.1.exe" | sha256sum -c -
```

If the placeholder was not replaced, the command reports that no properly formatted checksum line was found and exits with an error. Treat that as a failed check.

## Warnings

> **Only download TradeLayer software from official sources** — the [tradelayer.org/downloads](https://tradelayer.org/downloads) page or this repository. Never install a binary that was forwarded to you by a third party, surfaced by a search ad, or offered in a chat room.

> **Verify before installing.** If the computed hash does not match the published value, or you cannot run a verification command, do not run the file — delete it and report the incident to desk@tradelayer.org.

## Limitations

- The binaries are currently **unsigned** (no Authenticode / code-signing), so your operating system cannot vouch for the publisher. Windows SmartScreen may warn about the installer; verifying the checksum is the mitigation available today.
- A checksum proves only that your copy matches the file this repository publishes now. It cannot prove who built the binary. The checksums are served from the same repository as the binaries, so anyone who can change a binary there can change its checksum too, and a matching hash does not protect you against a compromised repository. Do not accept a checksum copied from a forum, chat, search result, or any other third-party page.
- The long-term fix is code signing plus GPG-signed checksums; see `SECURITY.md` in this repository for the recommended roadmap.

_Last updated: 2026-10-13_
