#!/usr/bin/env bash
# Checks the download checksums on the Verify Downloads page.
#
# 1. Each checksum row in _book/downloads/VERIFY.md equals the SHA-256 and the
#    byte size of the committed binary (HEAD:<file>), so the page cannot drift
#    from the published file.
# 2. Each checksum is written once in VERIFY.md, the authored source, and once
#    in each generated copy (VERIFY.html and the search index), and each copy
#    gives the same size next to it. No other committed file may contain it.
#
# Run from the repository root after committing the binaries.
# Usage: scripts/check-download-hashes.sh

set -u

doc=_book/downloads/VERIFY.md
page=_book/downloads/VERIFY.html
index=_book/search_plus_index.json
allowed=" $doc $page $index "
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
  size=$(printf '%s\n' "$row" | cut -d'|' -f3 | tr -d ' ')
  hash=$(printf '%s\n' "$row" | grep -oE '`[0-9a-f]{64}`' | tr -d '`')
  if [ -z "$hash" ]; then
    fail "$name: no 64-character lowercase SHA-256 in its row"
    continue
  fi
  if ! git cat-file -e "HEAD:_book/$name" 2>/dev/null; then
    fail "$name: not committed at HEAD:_book/$name"
    continue
  fi
  committed=$(git show "HEAD:_book/$name" | sha256sum | cut -d' ' -f1)
  committed_size=$(git cat-file -s "HEAD:_book/$name")
  if [ "$hash" = "$committed" ]; then
    echo "PASS  $name matches committed blob"
  else
    fail "$name: table $hash, committed blob $committed"
  fi
  if [ "$size" = "$committed_size" ]; then
    echo "PASS  $name size matches committed blob"
  else
    fail "$name: table size $size, committed blob $committed_size bytes"
  fi
  for f in "$doc" "$page" "$index"; do
    n=$(git show "HEAD:$f" | grep -o -F "$hash" | wc -l)
    if [ "$n" -ne 1 ]; then
      fail "$name: hash appears $n times in $f (expected 1)"
    fi
  done
  for f in "$page" "$index"; do
    text=$(git show "HEAD:$f" | sed 's/<[^>]*>/ /g' | tr -s '[:space:]' ' ')
    if ! grep -q -F "$size $hash" <<< "$text"; then
      fail "$name: $f does not give size $size next to hash"
    fi
  done
  while IFS= read -r f; do
    case "$allowed" in
      *" $f "*) ;;
      *) fail "$name: hash also written in $f" ;;
    esac
  done < <(git grep -l -i -F "$hash" HEAD -- . | sed 's/^HEAD://')
done < <(printf '%s\n' "$rows")

if [ "$failures" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
  exit 0
fi
echo "$failures CHECK(S) FAILED"
exit 1
