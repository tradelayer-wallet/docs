#!/usr/bin/env bash
# Checks the download checksums on the Verify Downloads page.
#
# 1. Each binary in _book (.exe and .zip, in any folder and in any letter case)
#    has exactly one checksum row in _book/downloads/VERIFY.md, and each row
#    equals the SHA-256 and the byte size of the committed binary (HEAD:<file>),
#    so the page cannot drift from the published file. Hex case does not matter.
#    Binaries are listed from the commit and from the working tree, so a binary
#    that is not committed fails here too.
# 2. Each checksum is written once in VERIFY.md, the authored source, and once
#    in each generated copy (VERIFY.html and the search index entry for the
#    page), and each copy gives the same size next to it. No other committed
#    file may contain it.
# 3. No copy shows a run of 64 or more hex digits that is not an authored
#    checksum. Each copy is read two ways: as raw text, and as parsed HTML, where
#    every text node, CDATA section, comment, script and style body, and
#    attribute value counts. Each text is normalized (NFKC, digits to ASCII, and
#    format, control and combining characters dropped), the pieces are joined
#    with no separators, each authored checksum is masked, and white space,
#    dashes and colons are dropped. A value split across tags, grouped, or
#    written with invisible characters is then seen whole.
# 4. Every command in a copy that runs sha256sum, shasum, certutil or
#    Get-FileHash appears as often as in VERIFY.md, and every pass/fail command
#    carries the placeholder the page tells readers to replace. A checksum typed
#    into a command is refused by rule 2 and by rule 3.
#
# The search index holds every page of the site, and other pages legitimately
# contain 64-hex values (transaction ids), so rules 3 and 4 read only the index
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

# The pass/fail verify commands that name file $1, one per line: the text the
# reader must replace. Reads normalized text on stdin.
verify_slots() {
  python3 -I -c '
import re, sys
name = re.escape(sys.argv[1])
text = sys.stdin.read()
for slot in re.findall(r"echo \"([^\"]*) " + name + r"\" \| (?:shasum -a 256|sha256sum) -c", text):
    print(slot)
for slot in re.findall(r"Get-FileHash [^ ]* ?" + name + r" -Algorithm SHA256\)\.Hash -eq \x27([^\x27]*)\x27", text):
    print(slot)
' "$1"
}

# The number of commands that run a checksum tool, on stdin.
command_count() {
  grep -o -i -E 'sha256sum|shasum|certutil|Get-FileHash' | grep -c .
}

# Runs of 64 or more hex digits that a reader can see in a copy, one line per run
# with its length. Reads the copy's raw text on stdin. Argument 1 is raw or html;
# the authored checksums are masked, so they are never reported.
hex_runs() {
  python3 -I -c '
import html.parser, re, sys, unicodedata

class Pieces(html.parser.HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.pieces = []

    def handle_starttag(self, tag, attrs):
        self.pieces += [value for _, value in attrs if value]

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)

    def handle_data(self, data):
        self.pieces.append(data)

    handle_comment = handle_decl = handle_pi = handle_unknown_decl = handle_data

def visible(text):
    kept = []
    for c in unicodedata.normalize("NFKC", text):
        category = unicodedata.category(c)
        if category == "Nd":
            kept.append(str(unicodedata.decimal(c)))
        elif category in ("Cc", "Cf", "Mn", "Me") and not c.isspace():
            continue
        else:
            kept.append(c)
    return "".join(kept)

mode, authored = sys.argv[1], sys.argv[2].split()
raw = sys.stdin.buffer.read().decode("utf-8", "replace")
if mode == "html":
    parser = Pieces()
    parser.feed(raw)
    parser.close()
    pieces = parser.pieces
else:
    pieces = [raw]
text = "".join(visible(piece) for piece in pieces).lower()
for value in authored:
    text = text.replace(value, "@")
text = "".join(c for c in text if not (c.isspace() or c == ":" or unicodedata.category(c) == "Pd"))
for run in re.findall(r"[0-9a-f]{64,}", text):
    print(len(run))
' "$1" "$authored_hashes"
}

binaries=$({ git ls-tree -r --name-only HEAD _book/; find _book -type f; } | grep -i -E '\.(exe|zip)$' | sort -u)
rows=$(grep -E '^\| \[[^]]+\]\(\.\./[^)]+\)' "$doc")
row_count=$(printf '%s\n' "$rows" | grep -c .)
binary_count=$(printf '%s\n' "$binaries" | grep -c .)
if [ "$row_count" -ne "$binary_count" ]; then
  fail "$doc has $row_count checksum rows for $binary_count binaries"
fi
while IFS= read -r bin; do
  [ -n "$bin" ] || continue
  name=${bin#_book/}
  n=$(printf '%s\n' "$rows" | grep -c -F "(../$name)")
  if [ "$n" -ne 1 ]; then
    fail "$name: $n checksum rows in $doc, expected 1"
  fi
done <<< "$binaries"

authored_pairs=""
authored_hashes=""
while IFS= read -r row; do
  [ -n "$row" ] || continue
  name=$(printf '%s\n' "$row" | sed -E 's/^\| \[[^]]+\]\(\.\.\/([^)]+)\).*/\1/')
  size=$(printf '%s\n' "$row" | cut -d'|' -f3 | tr -d ' ')
  hash=$(printf '%s\n' "$row" | grep -oE '`[0-9A-Fa-f]{64}`' | tr -d '`' | tr 'A-F' 'a-f')
  if [ -z "$hash" ]; then
    fail "$name: no 64-character SHA-256 in its row"
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
    n=$(git show "HEAD:$f" | grep -o -i -F "$hash" | wc -l)
    if [ "$n" -ne 1 ]; then
      fail "$name: hash appears $n times in $f (expected 1)"
    fi
  done
  for f in "$page" "$index"; do
    text=$(git show "HEAD:$f" | sed 's/<[^>]*>/ /g' | tr -s '[:space:]' ' ')
    if ! grep -q -i -F "$size $hash" <<< "$text"; then
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

# Raw and rendered text of each generated copy. The page is HTML. The index body
# is plain text, so its slots are read raw, where a placeholder such as
# <SHA-256 from the table> is still visible.
doc_text=$(git show "HEAD:$doc" | tr -s '[:space:]' ' ')
doc_commands=$(git show "HEAD:$doc" | command_count)
page_raw=$(git show "HEAD:$page")
page_text=$(printf '%s\n' "$page_raw" | render_html)
index_body=$(git show "HEAD:$index" \
  | python3 -I -c 'import json, sys; print(json.load(sys.stdin)["downloads/VERIFY.html"]["body"])')
index_text=$(printf '%s\n' "$index_body" | tr -s '[:space:]' ' ')
index_rendered=$(printf '%s\n' "$index_body" | render_html)

# check_copy LABEL RAW TEXT RENDERED: RAW is the copy as written, TEXT is the
# normalized text that the verify commands are read from, RENDERED is the
# copy as a reader sees it.
check_copy() {
  local label=$1 raw=$2 text=$3 rendered=$4 mode name want slots count run
  for mode in raw html; do
    while IFS= read -r run; do
      [ -n "$run" ] || continue
      fail "$label: a run of $run hex digits ($mode text) is not an authored checksum"
    done < <(printf '%s\n' "$raw" | hex_runs "$mode")
  done

  for count in $(printf '%s\n' "$raw" | command_count) $(printf '%s\n' "$rendered" | command_count); do
    if [ "$count" -ne "$doc_commands" ]; then
      fail "$label: $count checksum commands, VERIFY.md has $doc_commands"
    fi
  done

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

check_copy "$page" "$page_raw" "$page_text" "$page_text"
check_copy "$index (downloads record)" "$index_body" "$index_text" "$index_rendered"

if [ "$failures" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
  exit 0
fi
echo "$failures CHECK(S) FAILED"
exit 1
