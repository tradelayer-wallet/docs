#!/usr/bin/env bash
# Checks the download checksums on the Verify Downloads page.
#
# 1. Each checksum row in _book/downloads/VERIFY.md equals the SHA-256 of the
#    committed binary (git show HEAD:<file>), so the page cannot drift from it.
# 2. Each checksum is written once in VERIFY.md, the authored source, and does
#    not appear in any other tracked file except the generated VERIFY.html and
#    search index, which are rendered from that page.
#
# Run from the repository root after committing the binaries.
# Usage: scripts/check-download-hashes.sh

set -u

doc=_book/downloads/VERIFY.md
generated_ok='_book/downloads/VERIFY.html _book/search_plus_index.json'
failures=0

fail() {
  echo "FAIL  $1"
  failures=$((failures + 1))
}

rows=$(grep -E '^\| \[[^]]+\]\(\.\./[^)]+\)' "$doc")
row_count=$(printf '%s\n' "$rows" | grep -c .)
if [ "$row_count" -ne 2 ]; then
  fail "expected 2 checksum rows in $doc, found $row_count"
fi

while IFS= read -r row; do
  [ -n "$row" ] || continue
  name=$(printf '%s\n' "$row" | sed -E 's/^\| \[[^]]+\]\(\.\.\/([^)]+)\).*/\1/')
  hash=$(printf '%s\n' "$row" | grep -oE '`[0-9a-f]{64}`' | tr -d '`')
  if [ -z "$hash" ]; then
    fail "$name: no 64-character lowercase SHA-256 in its row"
    continue
  fi
  committed=$(git show "HEAD:_book/$name" 2>/dev/null | sha256sum | cut -d' ' -f1)
  if [ "$hash" = "$committed" ]; then
    echo "PASS  $name matches committed blob"
  else
    fail "$name: table $hash, committed blob $committed"
  fi
  in_doc=$(grep -o -F "$hash" "$doc" | wc -l)
  if [ "$in_doc" -ne 1 ]; then
    fail "$name: hash appears $in_doc times in $doc (expected 1)"
  fi
  for f in $(git grep -l -i -F "$hash" -- . 2>/dev/null); do
    case " $doc $generated_ok " in
      *" $f "*) ;;
      *) fail "$name: hash also written in $f" ;;
    esac
  done
done < <(printf '%s\n' "$rows")

if [ "$failures" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
  exit 0
fi
echo "$failures CHECK(S) FAILED"
exit 1
