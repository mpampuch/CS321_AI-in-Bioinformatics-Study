#!/bin/bash

# Initialize Conda for use in this script
SCRIPT_DIR="$(dirname "$(realpath "$0")")" # Get the directory where the script is located
ENV_DIR="$SCRIPT_DIR/env" # Use the script directory to construct the full path to the environment directory
# shellcheck disable=SC1091
source "/ibex/user/pampum/mambaforge/etc/profile.d/conda.sh"
conda activate $"$ENV_DIR"

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file> (Make sure the input file is in fastq.gz format)"
    exit 1
fi

# Assign input and output files from parameters
INPUT_FILE="$1"
BASE_NAME=$(basename "$INPUT_FILE" .fastq.gz)

# Define read length bins
LOWEST_READ_LENGTH=0
INTERMEDIATE_READ_LENGTH_1=5000
INTERMEDIATE_READ_LENGTH_2=10000
HIGHEST_READ_LENGTH=50000

# Precompute bin range values
LOWER_BOUND_1=$((INTERMEDIATE_READ_LENGTH_1 + 1))
LOWER_BOUND_2=$((INTERMEDIATE_READ_LENGTH_2 + 1))
LOWER_BOUND_3=$((HIGHEST_READ_LENGTH + 1))

# Define output file names
OUTPUT_FILE_0_5000="${BASE_NAME}.${LOWEST_READ_LENGTH}-${INTERMEDIATE_READ_LENGTH_1}.fastq.gz"
OUTPUT_FILE_5001_10000="${BASE_NAME}.${LOWER_BOUND_1}-${INTERMEDIATE_READ_LENGTH_2}.fastq.gz"
OUTPUT_FILE_10001_50000="${BASE_NAME}.${LOWER_BOUND_2}-${HIGHEST_READ_LENGTH}.fastq.gz"
OUTPUT_FILE_GT50001="${BASE_NAME}.gt${LOWER_BOUND_3}.fastq.gz"

# Define output directory
OUTPUT_DIR="/ibex/scratch/projects/c2303/CS312_AI-in-Bioinformatics/20250323_partition-data/READ-LENGTH-BENCHMARKING/BINNED-READS/${BASE_NAME}"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Binning reads by sequence length
echo "Processing $INPUT_FILE"
echo "Binning reads based on sequence length"

echo "Binning reads with length $LOWEST_READ_LENGTH-$INTERMEDIATE_READ_LENGTH_1"
seqkit seq --min-len "$LOWEST_READ_LENGTH" --max-len "$INTERMEDIATE_READ_LENGTH_1" "$INPUT_FILE" | gzip > "$OUTPUT_FILE_0_5000"

echo "Binning reads with length $LOWER_BOUND_1-$INTERMEDIATE_READ_LENGTH_2"
seqkit seq --min-len "$LOWER_BOUND_1" --max-len "$INTERMEDIATE_READ_LENGTH_2" "$INPUT_FILE" | gzip > "$OUTPUT_FILE_5001_10000"

echo "Binning reads with length $LOWER_BOUND_2-$HIGHEST_READ_LENGTH"
seqkit seq --min-len "$LOWER_BOUND_2" --max-len "$HIGHEST_READ_LENGTH" "$INPUT_FILE" | gzip > "$OUTPUT_FILE_10001_50000"

echo "Binning reads with length greater than $LOWER_BOUND_3"
seqkit seq --min-len "$LOWER_BOUND_3" "$INPUT_FILE" | gzip > "$OUTPUT_FILE_GT50001"

# Move the binned reads to the output directory
mv "$OUTPUT_FILE_0_5000" "$OUTPUT_DIR"
mv "$OUTPUT_FILE_5001_10000" "$OUTPUT_DIR"
mv "$OUTPUT_FILE_10001_50000" "$OUTPUT_DIR"
mv "$OUTPUT_FILE_GT50001" "$OUTPUT_DIR"

echo "Binned reads saved to $OUTPUT_DIR"