#!/bin/bash

# Initialize Conda
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
ENV_DIR="$SCRIPT_DIR/env"
source "/ibex/user/pampum/mambaforge/etc/profile.d/conda.sh"
conda activate "$ENV_DIR"

# Check input
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file.fastq.gz>"
    exit 1
fi

INPUT_FILE="$1"
BASE_NAME=$(basename "$INPUT_FILE" ".fastq.gz")

# Define QUALITY RANGES (non-overlapping, processed HIGH to LOW)
QUALITY_RANGES=(
    "21-99"
    "16-20"
    "11-15"
    "6-10"
    "0-5" 
)

# Output directory
OUTPUT_DIR="/ibex/scratch/projects/c2303/CS312_AI-in-Bioinformatics/20250323_partition-data/READ-LENGTH-BENCHMARKING/QUALITY-BINS/${BASE_NAME}"
mkdir -p "$OUTPUT_DIR"
# Remove any existing files
rm -f "${OUTPUT_DIR}/"*

# Temporary ID files (to track processed reads)
PROCESSED_IDS="${OUTPUT_DIR}/processed_read_ids.txt"
touch "$PROCESSED_IDS"

# Monitor if this is the first loop
FIRST_LOOP=true

# Process each range (highest quality first)
for RANGE in "${QUALITY_RANGES[@]}"; do
    MIN_Q="${RANGE%-*}"  # Extract min Q (e.g., 30 from "30-34")
    MAX_Q="${RANGE#*-}"  # Extract max Q (e.g., 34 from "30-34")
    
    # echo "Binning reads with Q${MIN_Q}-Q${MAX_Q}..."

    # Output file
    OUTPUT_FILE="${OUTPUT_DIR}/${BASE_NAME}.q${MIN_Q}-${MAX_Q}.fastq"
    # echo "OUTPUT_FILE: $OUTPUT_FILE"

    # Step 1: Get reads in this quality range (excluding already processed IDs)
    TMP_FILE="${OUTPUT_DIR}/tmp.q${MIN_Q}-${MAX_Q}.fastq"
    # TMP_FILE_GZIPPED="${TMP_FILE}.gz"
    # echo "fastq-filter -q $MIN_Q -o $TMP_FILE $INPUT_FILE"
    fastq-filter -q "$MIN_Q" -o "$TMP_FILE" "$INPUT_FILE" 
    # echo "wc -l of $TMP_FILE is $(wc -l $TMP_FILE)"

    # Step 2: Convert to TSV for processing
    TMP_FILE_TSV="${TMP_FILE}.tsv"
    seqkit fx2tab "$TMP_FILE" > "$TMP_FILE_TSV"
    echo "The number of lines in $(basename $TMP_FILE_TSV) (before filtering) is $(cat "$TMP_FILE_TSV" | wc -l)"

    # Step 3: Filter out reads already captured in higher-quality bins
    # if this is not the first loop, then filter out the processed IDs
    if [ "$FIRST_LOOP" = true ]; then
        echo "First loop, no filtering needed"
        cp "$TMP_FILE" "$OUTPUT_FILE"
        TMP_FILE_TSV_FILTERED="$TMP_FILE_TSV"
        FIRST_LOOP=false
    else
        echo "Filtering out reads that were already processed"
        TMP_FILE_TSV_FILTERED="${TMP_FILE}.filtered.tsv"
        grep -v -f "$PROCESSED_IDS" "$TMP_FILE_TSV" > "$TMP_FILE_TSV_FILTERED"
     fi

    # grep -v -f "$PROCESSED_IDS" "$TMP_FILE_TSV" | wc -l
    # echo "The number of lines in $(basename $TMP_FILE_TSV) is $(cat "$TMP_FILE_TSV" | wc -l)"
    echo "The number of lines in $(basename $TMP_FILE_TSV_FILTERED) (after filtering) is $(cat "$TMP_FILE_TSV_FILTERED" | wc -l)"
    seqkit tab2fx "$TMP_FILE_TSV_FILTERED" > "$OUTPUT_FILE"
    # shellcheck disable=SC2002
    # cat "$OUTPUT_FILE" | wc -l
    # grep -v -f "$PROCESSED_IDS" "$TMP_FILE" > "$OUTPUT_FILE" #| gzip > "$OUTPUT_FILE"
    # echo "wc -l of $OUTPUT_FILE is $(wc -l $OUTPUT_FILE)"

    # Step 4: Update processed IDs (append new IDs to the list)
    seqkit fx2tab "$TMP_FILE" | awk '{print $1}' >> "$PROCESSED_IDS"
    touch tmp.txt
    cat "$PROCESSED_IDS" | sort | uniq > tmp.txt
    mv tmp.txt "$PROCESSED_IDS" 
    echo "The number of processed IDs is $(cat "$PROCESSED_IDS" | wc -l)"

    # Cleanup and log
    rm "$TMP_FILE" "$TMP_FILE_TSV" "$TMP_FILE_TSV_FILTERED"

done

# Cleanup
rm "$PROCESSED_IDS"
echo "Quality binning complete. Results in: $OUTPUT_DIR"
