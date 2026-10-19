#!/usr/bin/env bash
# Regression tests for scripts/check-download-hashes.sh. Each case clones the
# committed HEAD, commits one edit to the generated copies, and runs the
# checker inside that clone. Honest edits must pass; bogus values that a reader
# can see must fail.
#
# Run from the repository root. Usage: scripts/test-check-download-hashes.sh

set -u

root=$(git rev-parse --show-toplevel) || exit 1
checker=$root/scripts/check-download-hashes.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

# Every case clones the repository, which holds a 90 MB installer, so each clone
# is removed when its case ends.
bogus=$(printf 'f0%.0s' $(seq 32))
bogus_entities=$(python3 -I -c 'import sys; print("".join("&#%d;" % ord(c) for c in sys.argv[1]))' "$bogus")
bogus_split="<span>${bogus:0:32}</span><span>${bogus:32}</span>"
zwsp=$(printf '\342\200\213')
bogus_zwsp="${bogus:0:20}${zwsp}${bogus:20}"
bogus_fullwidth=$(python3 -I -c 'import sys
print("".join(chr(0xFF10 + int(c)) if c.isdigit() else chr(0xFF21 + ord(c) - ord("A") if c.isupper() else 0xFF21 + ord(c) - ord("a")) for c in sys.argv[1]))' "$bogus")
bogus_arabic=$(printf '\331\240%.0s' $(seq 64))
regroup() {
  python3 -I -c 'import sys
s, n, sep = sys.argv[1], int(sys.argv[2]), sys.argv[3]
print(sep.join(s[i:i + n] for i in range(0, len(s), n)))' "$1" "$2" "$3"
}
grouped_spaces=$(regroup "$bogus" 4 ' ')
grouped_dashes=$(regroup "$bogus" 2 '-')
grouped_colons=$(regroup "$bogus" 8 ':')

failures=0

# run_case NAME EXPECT EDIT_SNIPPET
# EXPECT is "pass" or "fail". EDIT_SNIPPET is a shell command run in the clone.
run_case() {
  local name=$1 expect=$2 edit=$3 dir out code
  dir="$tmp/$name"
  if ! git clone -q "$root" "$dir"; then
    echo "ERROR $name: clone failed"
    failures=$((failures + 1))
    return
  fi
  if ! (cd "$dir" && eval "$edit" \
      && git add -A \
      && { git diff --cached --quiet || git -c user.name=test -c user.email=test@example.invalid commit -q -m fixture; }); then
    echo "ERROR $name: fixture edit failed"
    failures=$((failures + 1))
    rm -rf "$dir"
    return
  fi
  out=$(cd "$dir" && bash "$checker" 2>&1)
  code=$?
  rm -rf "$dir"
  if [ "$expect" = pass ] && [ "$code" -ne 0 ]; then
    echo "FAIL  $name: honest edit refused"
    printf '%s\n' "$out" | sed 's/^/      /'
    failures=$((failures + 1))
  elif [ "$expect" = fail ] && [ "$code" -eq 0 ]; then
    echo "FAIL  $name: bogus value passed"
    failures=$((failures + 1))
  else
    echo "PASS  $name"
  fi
}

# Inserts HTML before </body> in the Verify Downloads page.
insert_html() {
  python3 -I -c '
import sys
path, snippet = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
assert text.count("</body>") == 1
open(path, "w", encoding="utf-8").write(text.replace("</body>", snippet + "</body>"))
' _book/downloads/VERIFY.html "$1"
}

# Appends text to the body of the Verify Downloads search index record.
append_index_body() {
  python3 -I -c '
import json, sys
path, extra = sys.argv[1], sys.argv[2]
data = json.load(open(path, encoding="utf-8"))
data["downloads/VERIFY.html"]["body"] += " " + extra
json.dump(data, open(path, "w", encoding="utf-8"), ensure_ascii=False)
' _book/search_plus_index.json "$1"
}

# Edits that run insert_html or append_index_body with a snippet. The snippet is
# quoted so that the eval in run_case passes it through unchanged.
page_edit() { printf 'insert_html %q' "$1"; }
index_edit() { printf 'append_index_body %q' "$1"; }

# Rewrites every 64-hex checksum in the authored and generated copies in upper case.
uppercase_hashes() {
  python3 -I -c '
import re, sys
for path in sys.argv[1:]:
    text = open(path, encoding="utf-8").read()
    text = re.sub(r"[0-9a-f]{64}", lambda m: m.group(0).upper(), text)
    open(path, "w", encoding="utf-8").write(text)
' _book/downloads/VERIFY.md _book/downloads/VERIFY.html _book/search_plus_index.json
}

# Commits a third download, _book/$1 (a path under _book), with its row in every
# copy. The row link is relative to downloads/VERIFY.md.
add_download() {
  local rel=$1 base h size
  base=$(basename "$rel")
  mkdir -p "_book/$(dirname "$rel")"
  printf 'extra build\n' > "_book/$rel"
  h=$(sha256sum "_book/$rel" | cut -d' ' -f1)
  size=$(stat -c %s "_book/$rel")
  python3 -I -c '
import sys
rel, base, h, size = sys.argv[1:5]
md = "_book/downloads/VERIFY.md"
lines = open(md, encoding="utf-8").read().split("\n")
i = next(n for n, line in enumerate(lines) if line.startswith("| [TL-Extension.zip]"))
lines.insert(i + 1, "| [%s](../%s) (test) | %s | `%s` |" % (base, rel, size, h))
open(md, "w", encoding="utf-8").write("\n".join(lines))
' "$rel" "$base" "$h" "$size"
  insert_html "<p>$base $size <code>$h</code></p>"
  python3 -I -c '
import json, sys
path, base, h, size = sys.argv[1:5]
data = json.load(open(path, encoding="utf-8"))
data["downloads/VERIFY.html"]["body"] += " %s %s %s" % (base, size, h)
json.dump(data, open(path, "w", encoding="utf-8"), ensure_ascii=False)
' _book/search_plus_index.json "$base" "$h" "$size"
}

run_case honest-head pass 'true'

run_case honest-uppercase-hashes pass 'uppercase_hashes'

run_case honest-third-download pass 'add_download Extra.zip'

run_case honest-nested-download pass 'add_download downloads/extra.exe'

run_case honest-uppercase-extension pass 'add_download Extra.EXE'

run_case honest-table-cells pass \
  "$(page_edit '<table><tr><td>92879604</td><td>Windows installer</td></tr></table>')"

run_case download-without-row fail \
  "printf 'extra build\\n' > _book/Extra.zip"

run_case nested-download-without-row fail \
  "mkdir -p _book/downloads && printf 'extra build\\n' > _book/downloads/extra.exe"

run_case uppercase-download-without-row fail \
  "printf 'extra build\\n' > _book/Extra.EXE"

run_case bogus-numeric-entities fail \
  "$(page_edit "<p>$bogus_entities</p>")"

run_case bogus-split-across-tags fail \
  "$(page_edit "<p>$bogus_split</p>")"

run_case bogus-split-across-inline-tags fail \
  "$(page_edit "<p><code>${bogus:0:20}</code><em>${bogus:20:24}</em><span>${bogus:44}</span></p>")"

run_case bogus-split-across-table-cells fail \
  "$(page_edit "<table><tr><td>92879604</td><td><code>${bogus:0:63}</code></td></tr></table>")"

run_case bogus-in-attribute fail \
  "$(page_edit "<p data-ref=\"$bogus\">note</p>")"

run_case bogus-entities-in-attribute fail \
  "$(page_edit "<a title=\"$bogus_entities\">note</a>")"

run_case bogus-in-comment fail \
  "$(page_edit "<!-- $bogus -->")"

run_case bogus-in-cdata fail \
  "$(page_edit "<svg xmlns=\"http://www.w3.org/2000/svg\"><text><![CDATA[$bogus]]></text></svg>")"

run_case bogus-in-style fail \
  "$(page_edit "<style>.x::after{content:\"$bogus\"}</style>")"

run_case bogus-in-script fail \
  "$(page_edit "<script>var h='$bogus';</script>")"

run_case bogus-zero-width-space fail \
  "$(page_edit "<p>$bogus_zwsp</p>")"

run_case bogus-fullwidth-digits fail \
  "$(page_edit "<p>$bogus_fullwidth</p>")"

run_case bogus-arabic-indic-digits fail \
  "$(page_edit "<p>$bogus_arabic</p>")"

run_case bogus-grouped-spaces fail \
  "$(page_edit "<p>$grouped_spaces</p>")"

run_case bogus-grouped-dashes fail \
  "$(page_edit "<p>$grouped_dashes</p>")"

run_case bogus-grouped-colons fail \
  "$(page_edit "<p>$grouped_colons</p>")"

run_case bogus-grouped-in-index fail \
  "$(index_edit "$grouped_spaces")"

run_case bogus-numeric-entities-in-index fail \
  "$(index_edit "$bogus_entities")"

run_case bogus-verify-cmd-grouped-check fail \
  "$(page_edit "<pre>echo \"$grouped_spaces  TL-Extension.zip\" | sha256sum --check</pre>")"

run_case bogus-verify-cmd-short-hash-check fail \
  "$(page_edit '<pre>echo "0123abcd  TL-Extension.zip" | sha256sum --check</pre>')"

run_case extra-verify-command-without-check fail \
  "$(page_edit '<pre>sha256sum TL-Extension.zip</pre>')"

if [ "$failures" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
fi
echo "$failures TEST(S) FAILED"
exit 1
