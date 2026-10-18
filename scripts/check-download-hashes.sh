#!/usr/bin/env bash
# Checks the download checksums on the Verify Downloads page.
#
# 1. Each checksum row in _book/downloads/VERIFY.md equals the SHA-256 and the
#    byte size of the committed binary (HEAD:<file>), so the page cannot drift
#    from the published file.
# 2. Each checksum is written once in VERIFY.md, the authored source, and once
#    in each generated copy (VERIFY.html and the search index entry for the
#    page), and each copy gives the same size next to it. No other committed
#    file may contain it.
# 3. Every 64-hex string a reader can see in each generated copy is one of the
#    authored checksums, so a stale or bogus value anywhere on the page fails.
#    The copies are read as rendered text (see render_html), not as raw bytes.
# 4. Every pass/fail verify command in a copy carries the placeholder the page
#    tells readers to replace, and each copy has the same number of such
#    commands as VERIFY.md. A checksum typed into a command is refused by rule 2
#    (the exactly-once count) and by this rule, so a wrong value cannot ride along.
#
# The search index holds every page of the site, and other pages legitimately
# contain 64-hex values (transaction ids), so rule 3 reads only the index
# record for the Verify Downloads page.
#
# Run from the repository root after committing the binaries.
# Usage: scripts/check-download-hashes.sh

set -u

doc=_book/downloads/VERIFY.md
page=_book/downloads/VERIFY.html
index=_book/search_plus_index.json
allowed=" $doc $page $index "
placeholder='<SHA-256 from the table>'
failures=0

fail() {
  echo "FAIL  $1"
  failures=$((failures + 1))
}

# The pass/fail verify commands that name file $1, one slot per line: the text
# the reader must replace. Reads normalized page text on stdin.
verify_slots() {
  local esc=${1//./\\.}
  grep -oE "echo \"[^\"]* $esc\" \| (shasum -a 256|sha256sum) -c" \
    | sed -E "s/^echo \"(.*) $esc\" .*/\1/"
  grep -oE "Get-FileHash [^ ]* ?$esc -Algorithm SHA256\)\.Hash -eq '[^']*'" \
    | sed -E "s/.*-eq '([^']*)'\$/\1/"
}

rows=$(grep -E '^\| \[[^]]+\]\(\.\./[^)]+\)' "$doc")
row_count=$(printf '%s\n' "$rows" | grep -c .)
if [ "$row_count" -ne 2 ]; then
  fail "expected 2 checksum rows in $doc, found $row_count"
fi

authored_pairs=""
authored_hashes=""
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
  authored_pairs+="$name"$'\t'"$hash"$'\n'
  authored_hashes+="$hash"$'\n'
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

# Rendered text of an HTML document on stdin, one line per block: entities are
# decoded, tags are removed, and inline tags (span, code, ...) join the text on
# either side of them, so a value split across them is seen whole. Any other
# tag starts a new line, as a browser does for a block. Attribute values are
# listed after the text as lines of their own. Comments are not rendered.
render_html() {
  python3 -I -c '
import html.parser, sys

INLINE = {"a", "abbr", "b", "bdi", "bdo", "cite", "code", "data", "dfn", "em",
          "font", "i", "kbd", "mark", "q", "s", "samp", "small", "span", "strike",
          "strong", "sub", "sup", "time", "tt", "u", "var"}

class Render(html.parser.HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.lines = [""]
        self.attributes = []

    def handle_starttag(self, tag, attrs):
        self.attributes += [value for _, value in attrs if value]
        if tag not in INLINE:
            self.lines.append("")

    def handle_endtag(self, tag):
        if tag not in INLINE:
            self.lines.append("")

    def handle_data(self, data):
        self.lines[-1] += data

parser = Render()
parser.feed(sys.stdin.buffer.read().decode("utf-8", "replace"))
parser.close()
text = "\n".join(" ".join(line.split()) for line in parser.lines + parser.attributes) + "\n"
sys.stdout.buffer.write(text.encode("utf-8"))
'
}

# Text of each generated copy. The page is HTML, so it is read rendered. The
# index body is plain text, so it is also read raw, where a placeholder such as
# <SHA-256 from the table> is still visible.
doc_text=$(git show "HEAD:$doc" | tr -s '[:space:]' ' ')
page_text=$(git show "HEAD:$page" | render_html)
index_body=$(git show "HEAD:$index" \
  | python3 -I -c 'import json, sys; print(json.load(sys.stdin)["downloads/VERIFY.html"]["body"])')
index_text=$(printf '%s\n' "$index_body" | tr -s '[:space:]' ' ')
index_hex_text=$(printf '%s\n%s\n' "$(printf '%s\n' "$index_body" | render_html)" "$index_text")

check_copy() {
  local label=$1 hex_text=$2 text=$3 h name want slots count slot
  while IFS= read -r h; do
    [ -n "$h" ] || continue
    if ! grep -qxF "$h" <<< "$authored_hashes"; then
      fail "$label: 64-hex $h is not an authored checksum"
    fi
  done < <(printf '%s\n' "$hex_text" | grep -oE '[0-9A-Fa-f]{64,}' | tr 'A-F' 'a-f')

  while IFS=$'\t' read -r name _; do
    [ -n "$name" ] || continue
    want=$(printf '%s\n' "$doc_text" | verify_slots "$name" | grep -c .)
    slots=$(printf '%s\n' "$text" | verify_slots "$name")
    count=$(printf '%s\n' "$slots" | grep -c .)
    if [ "$count" -ne "$want" ]; then
      fail "$label: $count verify commands for $name, VERIFY.md has $want"
    fi
    while IFS= read -r slot; do
      [ -n "$slot" ] || continue
      if [ "$slot" != "$placeholder" ]; then
        fail "$label: a verify command for $name carries $slot, not the placeholder"
      fi
    done <<< "$slots"
  done <<< "$authored_pairs"
}

check_copy "$page" "$page_text" "$page_text"
check_copy "$index (downloads record)" "$index_hex_text" "$index_text"

if [ "$failures" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
  exit 0
fi
echo "$failures CHECK(S) FAILED"
exit 1
