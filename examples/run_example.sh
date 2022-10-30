#!/usr/bin/env sh

EXECUTABLE="pandoc-confluence"
INPUT_FILE="examples/input.md"
OUTPUT_FILE="examples/output.html"
OUTPUT_LOG="examples/output.json"

stack build --force-dirty
FILTER_PATH=$(stack exec -- whereis $EXECUTABLE | awk -F ': ' '{ print $2 }')

pandoc -s $INPUT_FILE -t json -o $OUTPUT_LOG

pandoc -s $INPUT_FILE \
  --filter "$FILTER_PATH" \
  -o $OUTPUT_FILE
