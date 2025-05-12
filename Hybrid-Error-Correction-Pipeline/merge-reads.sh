#!/bin/bash

# Path to CSV file
CSV_FILE="samplesheet_merge-reads.csv"

# Read the line for this task
line=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$CSV_FILE")

# Parse the CSV line
HERRO_READ=$(echo "$line" | cut -d',' -f1)
DECHAT_READ=$(echo "$line" | cut -d',' -f2)

# Validate file existence
if [[ ! -f "$HERRO_READ" ]]; then
    echo "ERROR: Raw read file not found: $HERRO_READ"
    exit 1
fi

if [[ ! -f "$DECHAT_READ" ]]; then
    echo "ERROR: Corrected read file not found: $DECHAT_READ"
    exit 1
fi

# Output file base name (e.g., from raw read filename)
BASENAME=$(basename "$HERRO_READ")
BASENAME=${BASENAME%%.fastq*}  # Remove .fastq or .fastq.gz suffix

OUTDIR="HYBRID-CORRECTED-READS"
OUTFILE="${BASENAME}.hybrid.corrected.fasta"

# Run seqkit grep to split raw reads
cat "$HERRO_READ" "$DECHAT_READ" > "$OUTDIR"/"$OUTFILE"
