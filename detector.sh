#!/bin/bash

UPSTREAM_PATH="${1}"
CACHED_PATH="${2}"

echo "Comparing Files:"
# Ignore whitespace changes to reduce the number of false positives
diff -EZbB $UPSTREAM_PATH $CACHED_PATH > diff_text
if [ $? -eq 0 ]; then
    echo "    upstream: $UPSTREAM_PATH"
    echo "    cached:   $CACHED_PATH"
    echo "Files match, no updates needed"
else
    echo "    upstream (<): $UPSTREAM_PATH"
    echo "    cached   (>): $CACHED_PATH"
    echo "Files do NOT match, please update before building"
    cat diff_text
    exit 10
fi
