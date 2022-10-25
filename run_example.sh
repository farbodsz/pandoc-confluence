#!/usr/bin/env sh

EXECUTABLE="pandoc-confluence"
INPUT_FILE="examples/input.md"
OUTPUT_FILE="examples/output.html"

stack build --force-dirty
FILTER_PATH=$(stack exec -- whereis $EXECUTABLE | awk -F ': ' '{ print $2 }')

pandoc -s $INPUT_FILE \
  --filter "$FILTER_PATH" \
  -o $OUTPUT_FILE
