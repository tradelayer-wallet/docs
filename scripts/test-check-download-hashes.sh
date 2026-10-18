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

bogus=$(printf 'f0%.0s' $(seq 32))
bogus_entities=$(python3 -I -c 'import sys; print("".join("&#%d;" % ord(c) for c in sys.argv[1]))' "$bogus")
bogus_split="<span>${bogus:0:32}</span><span>${bogus:32}</span>"

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
      && { git diff --quiet || git -c user.name=test -c user.email=test@example.invalid commit -q -am fixture; }); then
    echo "ERROR $name: fixture edit failed"
    failures=$((failures + 1))
    return
  fi
  out=$(cd "$dir" && bash "$checker" 2>&1)
  code=$?
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

run_case honest-head pass 'true'

run_case honest-table-cells pass \
  "insert_html '<table><tr><td>92879604</td><td><code>${bogus:0:63}</code></td></tr></table>'"

run_case bogus-numeric-entities fail \
  "insert_html '<p>$bogus_entities</p>'"

run_case bogus-split-across-tags fail \
  "insert_html '<p>$bogus_split</p>'"

run_case bogus-split-across-inline-tags fail \
  "insert_html '<p><code>${bogus:0:20}</code><em>${bogus:20:24}</em><span>${bogus:44}</span></p>'"

run_case bogus-in-attribute fail \
  "insert_html '<p data-ref=\"$bogus\">note</p>'"

run_case bogus-entities-in-attribute fail \
  "insert_html '<a title=\"$bogus_entities\">note</a>'"

run_case bogus-numeric-entities-in-index fail \
  "append_index_body '$bogus_entities'"

if [ "$failures" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
fi
echo "$failures TEST(S) FAILED"
exit 1
