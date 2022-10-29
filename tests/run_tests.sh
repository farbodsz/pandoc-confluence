#!/usr/bin/env sh
# Runs tests

#------------------------------------------------------------------------------
# Colors
#------------------------------------------------------------------------------

RED="\033[0;31m"
GREEN="\033[0;32m"
ORANGE="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m"

info() {
  printf "${CYAN}%s${NC}\n" "$1"
}

warn() {
  printf "${ORANGE}%s${NC}\n" "$1"
}

success() {
  printf "${GREEN}%s${NC}\n" "$1"
}

failure() {
  printf "${RED}%s${NC}\n" "$1"
}

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

EXECUTABLE="pandoc-confluence"
OUTPUT_FILE="/tmp/pandoc-confluence-test-output.html"

set -e
echo "Building..."
stack build
FILTER_PATH=$(stack exec -- whereis $EXECUTABLE | awk -F ': ' '{ print $2 }')

keep_body_only() {
  tail -n +26 | head -n -2
}

generate_output() {
  pandoc -s "$1" \
    --css /dev/null \
    --metadata title="Test" \
    --filter "$FILTER_PATH" \
    --to html |
    keep_body_only
}

echo ""
echo "Running tests..."
echo ""

passed=0
failed=0

for input_file in ./tests/*.md; do
  _basename="${input_file##*/}"
  test_name="${input_file%.*}"

  generate_output "$input_file" >$OUTPUT_FILE
  expected_output_file="${test_name}.html"

  info "TESTING: $test_name"

  if cmp --silent "$OUTPUT_FILE" "$expected_output_file"; then
    success "PASSED"
    passed=$((passed + 1))
  else
    failure "FAILED"
    warn "Expected:"
    cat "$expected_output_file"
    warn "Got:"
    cat "$OUTPUT_FILE"
    echo ""
    failed=$((failed + 1))
  fi
  echo ""
done

if [ $failed -gt 0 ]; then
  failure "Failed ${failed} / $((passed + failed)) tests!"
  exit 1
else
  success "All ${passed} tests passed!"
  exit 0
fi
