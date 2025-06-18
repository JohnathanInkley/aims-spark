#!/usr/bin/env zsh 
set -e

# === Source directory ===
SOURCE_DIR="/Volumes/T7/PropertyData/AddressBase/ab_prem_full_csv_2023-06-26"

# === List of source files to symlink ===
files=(
  "ID21_BLPU_Records.csv:$SOURCE_DIR/ID21_BLPU_Records.csv"
  "ID24_LPI_Records.csv:$SOURCE_DIR/ID24_LPI_Records.csv"
  "ID11_Street_Records.csv:$SOURCE_DIR/ID11_Street_Records.csv"
  "ID15_StreetDesc_Records.csv:$SOURCE_DIR/ID15_StreetDesc_Records.csv"
  "ID31_Org_Records.csv:$SOURCE_DIR/ID31_Org_Records.csv"
  "ID32_Class_Records.csv:$SOURCE_DIR/ID32_Class_Records.csv"
  "ID23_XREF_Records.csv:$SOURCE_DIR/ID23_XREF_Records.csv"
  "ID30_Successor_Records.csv:$SOURCE_DIR/ID30_Successor_Records.csv"
  "ai_aims_delivery_point_20230626.csv:$SOURCE_DIR/ID28_DPA_Records.csv"
)

echo "=== Setting up symlinks ==="
for entry in "${files[@]}"; do
  linkName="${entry%%:*}"
  realPath="${entry##*:}"
  if [ -e "$linkName" ]; then
    echo "Removing existing link or file: $linkName"
    rm -f "$linkName"
  fi
  echo "Creating symlink: $linkName -> $realPath"
  ln -s "$realPath" "$linkName"
done

# === Run the Spark job ===
echo "=== Running Spark job ==="
java \
  --add-exports java.base/sun.nio.ch=ALL-UNNAMED \
  --add-opens java.base/java.nio=ALL-UNNAMED \
  --add-opens java.base/java.lang.invoke=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.io=ALL-UNNAMED \
  --add-exports java.base/sun.util.calendar=ALL-UNNAMED \
  -Dconfig.file=application.conf \
  -jar batch/target/scala-2.13/ons-ai-batch-assembly-0.0.1.jar

# Get index name
index_name=$(curl -s -X GET "localhost:9200/_alias" | jq -r 'keys[0]')

echo "Detected index: $index_name"

# Check if index_name is non-empty
if [ -z "$index_name" ]; then
  echo "No index name found. Exiting."
  exit 1
fi

# Create alias JSON with the index name filled in
alias_payload=$(cat <<EOF
{
  "actions": [
    { "add": { "index": "$index_name", "alias": "index_full_hist_current" } },
    { "add": { "index": "$index_name", "alias": "index_full_nohist_current" } },
    { "add": { "index": "$index_name", "alias": "index_full_hist_111" } },
    { "add": { "index": "$index_name", "alias": "index_full_nohist_111" } },
    { "add": { "index": "$index_name", "alias": "index_skinny_hist_current" } },
    { "add": { "index": "$index_name", "alias": "index_skinny_nohist_current" } },
    { "add": { "index": "$index_name", "alias": "index_skinny_hist_111" } },
    { "add": { "index": "$index_name", "alias": "index_skinny_nohist_111" } }
  ]
}
EOF
)

# Post aliases to Elasticsearch
echo "Creating aliases..."
curl -s -X POST "localhost:9200/_aliases" \
  -H 'Content-Type: application/json' \
  -d "$alias_payload" | jq .

echo "Aliases created for index: $index_name"
