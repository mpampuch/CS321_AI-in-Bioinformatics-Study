#!/bin/bash
#SBATCH --job-name=seqkit_extract_%A_%a
#SBATCH --output=.slurm_seqkit_extract_%A_%a.out
#SBATCH --error=.slurm_seqkit_extract_%A_%a.err
#SBATCH --array=0-$(($(wc -l < 20250408_QC-ready-files-and-ref-paths.csv)-1))
#SBATCH --time=5:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=END,FAIL

# Load environment
module load seqkit

# Path to CSV file
CSV_FILE="samplesheet_extract-reads.csv"
OUTDIR="READS-FILTERED-BY-HERRO"

# Read the line for this task
line=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$CSV_FILE")

# Parse the CSV line
RAW_READ=$(echo "$line" | cut -d',' -f1)
CORRECTED_READ=$(echo "$line" | cut -d',' -f2)

# Validate file existence
if [[ ! -f "$RAW_READ" ]]; then
    echo "ERROR: Raw read file not found: $RAW_READ"
    exit 1
fi

if [[ ! -f "$CORRECTED_READ" ]]; then
    echo "ERROR: Corrected read file not found: $CORRECTED_READ"
    exit 1
fi

# Output file base name (e.g., from raw read filename)
BASENAME=$(basename "$RAW_READ")
BASENAME=${BASENAME%%.fastq*}  # Remove .fastq or .fastq.gz suffix

OUT_WITH="${BASENAME}.raw_reads_with_corrected_reads.fastq"
OUT_WITHOUT="${BASENAME}.raw_reads_without_corrected_reads.fastq"

# Run seqkit grep to split raw reads
echo "Extracting with IDs from: $CORRECTED_READ"
seqkit grep -f <(seqkit fx2tab -n "$CORRECTED_READ" | awk '{print $1}') "$RAW_READ" > "$OUTDIR"/"$OUT_WITH"

echo "Extracting reads not in corrected set..."
seqkit grep -v -f <(seqkit fx2tab -n "$CORRECTED_READ" | awk '{print $1}') "$RAW_READ" > "$OUTDIR"/"$OUT_WITHOUT"

echo "Done with $BASENAME"
