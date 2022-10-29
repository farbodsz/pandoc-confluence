#!/usr/bin/env sh

EXECUTABLE="pandoc-confluence"
OUTPUT_FILE="/tmp/pandoc-confluence-test-output.html"

#------------------------------------------------------------------------------
# Colors and pretty output
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

DIVIDER_LINE="--------------------------------------------------"
DIVIDER_LINE_THICK="=================================================="

#------------------------------------------------------------------------------
# Build
#------------------------------------------------------------------------------

run_build() {
  set -e
  echo ""
  echo $DIVIDER_LINE_THICK
  echo "Building..."
  echo ""
  stack build
  FILTER_PATH=$(stack exec -- whereis $EXECUTABLE | awk -F ': ' '{ print $2 }')
}

#------------------------------------------------------------------------------
# Tests
#------------------------------------------------------------------------------

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

run_tests() {
  set +e
  echo $DIVIDER_LINE_THICK
  echo "Running tests..."
  echo ""

  passed=0
  failed=0

  for input_file in ./tests/*.md; do
    _basename="${input_file##*/}"
    test_name="${input_file%.*}"

    generate_output "$input_file" >$OUTPUT_FILE
    expected_output_file="${test_name}.html"

    info $DIVIDER_LINE
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

  echo $DIVIDER_LINE_THICK
  if [ $failed -gt 0 ]; then
    failure "RESULT: Failed ${failed} / $((passed + failed)) tests!"
  else
    success "RESULT: All ${passed} tests passed!"
  fi
  echo $DIVIDER_LINE_THICK
  exit $failed
}

#------------------------------------------------------------------------------
# Main / entry point
#------------------------------------------------------------------------------

run_build
run_tests
