#!/bin/bash
#SBATCH --job-name=bam_concordance_%A_%a
#SBATCH --output=.slurm_bam_concordance_%A_%a.out
#SBATCH --error=.slurm_bam_concordance_%A_%a.err
#SBATCH --array=0-$(($(wc -l < 20250408_QC-ready-files-and-ref-paths.csv)-1)) # Create an array job based on the number of lines in the CSV file
#SBATCH --time=1-23:00:00   # Adjust the wall time limit as needed
#SBATCH --mem=128G         # Adjust memory requirements as needed
#SBATCH --cpus-per-task=32 # Number of CPUs per task
#SBATCH --mail-type=ALL

# Initiate environments
module load python
module load minimap2
module load samtools 

# Get the line corresponding to this job array index
line=$(sed -n "$((SLURM_ARRAY_TASK_ID+1))p" samplesheet.csv)

READS=$(echo $line | cut -d',' -f1)  # Extract the reads file path
REFERENCE=$(echo $line | cut -d',' -f2)  # Extract the reference file path

# Extract basenames without extensions
READS_BASE=$(basename "$READS")  # Change .fastq to whatever your file extension is

# Create an output directory for this job
OUTPUT_DIR="OUTPUTS/$READS_BASE"
mkdir -p "$OUTPUT_DIR"  # Create directory if it doesn't exist

echo "Processing reads: $READS"
echo "Using reference: $REFERENCE"
echo "Output will be saved to directory: $OUTPUT_DIR"

# Run the commands for this job
echo "Running minimap2 using $REFERENCE as reference and $READS as reads"
echo "Output will be saved to $OUTPUT_DIR/$READS_BASE.sam"
minimap2 -t 32 -ax map-ont --eqx $REFERENCE $READS -o "$OUTPUT_DIR/$READS_BASE.sam"  # Alignment

echo "Running samtools to sort and index the BAM file"
echo "Output will be saved to $OUTPUT_DIR/$READS_BASE.bam"
samtools sort -@ 32 -o "$OUTPUT_DIR/$READS_BASE.bam" "$OUTPUT_DIR/$READS_BASE.sam"  # Sort the SAM file to create BAM

echo "Running bamConcordance to compute concordance"
echo "Output will be saved to $OUTPUT_DIR/$READS_BASE.bamConcordance.csv"
python3 bamConcordance.py "$REFERENCE" "$OUTPUT_DIR/$READS_BASE.bam" "$OUTPUT_DIR/$READS_BASE.bamConcordance.csv"  # Compute bamConcordance

echo "SCRIPT COMPLETED"
echo "Output files:"
echo "$OUTPUT_DIR/$READS_BASE.bamConcordance.csv"

echo "Cleaning up intermediate files"
rm "$OUTPUT_DIR/$READS_BASE.sam" && echo "$OUTPUT_DIR/$READS_BASE.sam removed"  # Remove the SAM file if not needed 
rm "$OUTPUT_DIR/$READS_BASE.bam" && echo "$OUTPUT_DIR/$READS_BASE.bam removed" # Remove the BAM file if not needed
