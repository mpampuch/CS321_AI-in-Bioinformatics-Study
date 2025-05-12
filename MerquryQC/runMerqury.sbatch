#!/bin/bash
#SBATCH --job-name=Merqury_%A_%a
#SBATCH --output=slurm_Merqury_%A_%a.out
#SBATCH --error=slurm_Merqury_%A_%a.err
#SBATCH --array=0-$(($(wc -l < 20250408_QC-ready-files-and-ref-paths.csv)-1)) # Create an array job based on the number of lines in the CSV file
#SBATCH --time=1-23:00:00   # Adjust the wall time limit as needed
#SBATCH --mem=128G        # Adjust memory requirements as needed
#SBATCH --cpus-per-task=32 # Number of CPUs per task
#SBATCH --mail-type=ALL

# Initiate environments
module load merqury
module load seqkit

# Get the line corresponding to this job array index
line=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" samplesheet.csv)

READS=$(echo "$line" | cut -d',' -f1)  # Extract the reads file path
REFERENCE=$(echo "$line" | cut -d',' -f2)  # Extract the reference file path

# Extract basenames without extensions
READS_BASE=$(basename "$READS")  # Change .fastq to whatever your file extension is
# Remove -'s from the file name
echo "Original reads base: $READS_BASE"
READS_BASE_CLEANED_UP=$(echo "$READS_BASE" | tr '-' '_')
echo "Cleaned up reads base: $READS_BASE_CLEANED_UP"
REFERENCE_BASE=$(basename "$REFERENCE")  # Change .fasta if it's different
echo "Original reference base: $REFERENCE_BASE"
REFERENCE_BASE_CLEANED_UP=$(echo "$REFERENCE_BASE" | tr '-' '_')
echo "Cleaned up reference base: $REFERENCE_BASE_CLEANED_UP"
# Create an output directory for this job
OUTPUT_DIR="OUTPUTS_MERQURY/$READS_BASE_CLEANED_UP"
mkdir -p "$OUTPUT_DIR"  # Create directory if it doesn't exist

# Convert fastq to fasta
echo "Converting FASTQ File ($READS) to FASTA ($OUTPUT_DIR/$READS_BASE_CLEANED_UP.fasta)"
seqkit fq2fa  -o "$OUTPUT_DIR/$READS_BASE_CLEANED_UP.fasta" "$READS"  # Convert fastq to fasta

# if find . -iname "*-*fasta" finds something, echo found
echo "Renaming any potential fasta files with - in the name (-'s break merqury)"
if find . -iname "*-*fasta" | grep -q .; then
    echo "Found fasta files with - in the name. Renaming them to remove -"
    find . -iname "*-*fasta" | while read -r file; do mv "$file" "$(dirname "$file")/$(basename "$file" | tr '-' '_')"; done
    echo "Renamed fasta files with - in the name."
else
    echo "No fasta files with - in the name found."
fi

echo "Processing reads: $READS_BASE_CLEANED_UP.fasta"
echo "Using reference: $REFERENCE"
echo "Output will be saved to directory: $OUTPUT_DIR"

# Get optimal k-mer size
# if gzipped, use gunzip -c
if [[ $REFERENCE == *.gz ]]; then
    GENOME_SIZE=$(gunzip -c "$REFERENCE" | grep -v "^>" | tr -d '\n' | wc -c)
else
    GENOME_SIZE=$(grep -v "^>" "$REFERENCE" | tr -d '\n' | wc -c)
fi
KMER_SIZE=$(sh "$MERQURY/best_k.sh" "$GENOME_SIZE" | tail -n 1 | awk '{printf "%.0f\n", $1}')
echo "Best k-mer size found to be $KMER_SIZE"


# Create meryl database
echo "Building meryl database using k=$KMER_SIZE on $OUTPUT_DIR/$READS_BASE_CLEANED_UP.fasta and outputting as $OUTPUT_DIR/$READS_BASE_CLEANED_UP.meryl"
meryl k="$KMER_SIZE" count "$OUTPUT_DIR/$READS_BASE_CLEANED_UP.fasta" output "$OUTPUT_DIR/$READS_BASE_CLEANED_UP.meryl" 

# Run merqury
# merqury.sh <read-db.meryl> <asm1.fasta> <out_prefix>
echo "Running Merqury using the $OUTPUT_DIR/$READS_BASE_CLEANED_UP.meryl database and $OUTPUT_DIR/$REFERENCE file"
"$MERQURY"/merqury.sh "$OUTPUT_DIR/$READS_BASE_CLEANED_UP.meryl" "$REFERENCE" "$READS_BASE_CLEANED_UP"

echo "SCRIPT COMPLETED"

