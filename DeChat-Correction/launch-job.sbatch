#!/bin/bash --login
# Set your job walltime (D-HH:MM:SS)
#SBATCH --time=13-12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks=1
#SBATCH --mem=5G
#SBATCH --partition=batch
#SBATCH --output=.slurm_%j.out
#SBATCH --error=.slurm_%j.err
#SBATCH --mail-type=ALL
#SBATCH --job-name=DeChat-Correction

# Activate your environment for your job
source env.sh 

# Load required modules
module load nextflow/24.10.2
module load singularity/3.9.7

# Put in your file paths
INPUT_FILE="samplesheet.txt"
echo "INPUT_FILE: $INPUT_FILE"
NXF_OUTPUT_DIR="OUTPUTS/$(date -Iseconds | sed 's/-//g; s/://g; s/T/_/; s/+.*//')"
echo "NXF_OUTPUT_DIR: $NXF_OUTPUT_DIR"
NXF_LOG_FILE="$NXF_OUTPUT_DIR/nextflow.log"
echo "NXF_LOG_FILE: $NXF_LOG_FILE"

# Run your job script here
nextflow -log "$NXF_LOG_FILE" run main.nf -c nextflow.config --fastq_files "$INPUT_FILE" --outdir "$NXF_OUTPUT_DIR";
