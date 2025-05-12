# BAM Concordance Analysis Pipeline

This repository contains a pipeline to assess the concordance of long-read alignments against reference genomes using `minimap2`, `samtools`, and a custom Python script (`bamConcordance.py`). It is designed to process multiple sample/reference pairs in parallel on a SLURM-based HPC cluster.

---

## Contents

- `samplesheet.csv`: Input CSV file listing reads and reference genome paths.

- `bamConcordance.py`: Python script to compute per-read alignment concordance metrics.

- `runBamConcordance.sbatch`: SLURM job array script to process each sample-reference pair.

---

## Purpose

This pipeline evaluates how accurately long-read sequencing reads align to a reference genome by computing:

- Concordance (match vs. mismatch + indels)

- Concordance QV (Phred-scaled)

- High-confidence coverage

- Insertion/deletion context (homopolymer vs. non-homopolymer)

---

## Input

`samplesheet.csv`

A comma-separated list of file paths:

```
/path/to/reads1.fastq,/path/to/reference1.fasta
/path/to/reads2.fastq,/path/to/reference2.fasta
...
```

---

## How It Works

### 1. Alignment

Each job in the array:

- Uses `minimap2` to align reads to a reference genome (`--eqx` required).

- Sorts the resulting SAM to BAM using `samtools`.

### 2. Concordance Analysis

The Python script:

- Reads BAM and reference FASTA.

- Optionally uses high-confidence regions and variant calls (BED/VCF).

- Outputs a CSV per read with concordance metrics.

### 3. Cleanup

Intermediate files (SAM/BAM) are deleted after concordance analysis.

---

## Output

For each read/reference pair, the pipeline generates:

- `OUTPUTS/<READS_FILENAME>/...bamConcordance.csv`

Contains per-read statistics:

```
#read,readLengthBp,effectiveCoverage,subreadPasses,predictedConcordance,...
read1234,14023,,3,0.987654,...
```

---

## How to Run

Submit the SLURM job with:

```bash
sbatch runBamConcordance.sbatch
```

Make sure you have the following modules or tools loaded:

- Python 3

- `minimap2`

- `samtools`

---

## Notes

- `minimap2` must use `--eqx` to provide the detailed CIGAR strings required by `bamConcordance.py`.

- Adjust `SBATCH` parameters (memory, CPU, wall time) based on your dataset.

---
