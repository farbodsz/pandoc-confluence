#!/usr/bin/env sh

EXECUTABLE="pandoc-confluence"

OUTPUT_FILE_ACTUAL="/tmp/pandoc-confluence-test-output-actual.html"
OUTPUT_FILE_EXPECTED="/tmp/pandoc-confluence-test-output-exp.html"

HTML_MINIFIER="html-minifier --collapse-whitespace"

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

make_actual_output() {
  pandoc -s "$1" \
    --css /dev/null \
    --metadata title="Test" \
    --filter "$FILTER_PATH" \
    --to html |
    keep_body_only |
    $HTML_MINIFIER
}

make_expected_output() {
  $HTML_MINIFIER "$1"
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

    input_html="${test_name}.html"

    make_actual_output "$input_file" >$OUTPUT_FILE_ACTUAL
    make_expected_output "$input_html" >$OUTPUT_FILE_EXPECTED

    info $DIVIDER_LINE
    info "TESTING: $test_name"

    if cmp --silent "$OUTPUT_FILE_ACTUAL" "$OUTPUT_FILE_EXPECTED"; then
      success "PASSED"
      passed=$((passed + 1))
    else
      failure "FAILED"
      warn "Expected:"
      cat "$OUTPUT_FILE_EXPECTED"
      echo ""
      warn "Got:"
      cat "$OUTPUT_FILE_ACTUAL"
      echo ""
      failed=$((failed + 1))
    fi
    echo ""
  done

  echo $DIVIDER_LINE_THICK
  if [ $failed -gt 0 ]; then
    failure "RESULT: Passed ${passed} / $((passed + failed)) tests!"
  else
    success "RESULT: All ${passed} tests passed!"
  fi
  echo $DIVIDER_LINE_THICK
  exit $failed
}

#------------------------------------------------------------------------------
# Main / entry point
#------------------------------------------------------------------------------

# Need html-minifier from node to run tests
PATH="$(npm config get prefix)/bin:$PATH"

run_build
run_tests
