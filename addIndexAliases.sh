#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <index_suffix>"
  exit 1
fi

SUFFIX="$1"
INDEX_NAME="hybrid-historical_102_20230626_$SUFFIX"

curl -X POST "localhost:9200/_aliases" -H 'Content-Type: application/json' -d "{
  \"actions\": [
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_full_hist_current\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_full_nohist_current\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_full_hist_102\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_full_nohist_102\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_skinny_hist_current\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_skinny_nohist_current\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_skinny_hist_102\" } },
    { \"add\": { \"index\": \"$INDEX_NAME\", \"alias\": \"index_skinny_nohist_102\" } }
  ]
}"

