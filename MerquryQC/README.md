# Merqury Quality Assessment Pipeline

This repository contains a pipeline for evaluating genome assembly completeness and accuracy using **Merqury** . It is designed to run multiple read/reference genome pairs in parallel on an HPC cluster using SLURM job arrays.

---

## Contents

- `samplesheet.csv`: Input CSV file listing read sets and reference genome paths.

- `runMerqury.sbatch`: SLURM job array script to process each read/reference pair and run Merqury.

---

## Purpose

This pipeline performs k-mer-based evaluation of genome assemblies using Merqury. It provides:

- **Completeness** and **consensus quality (QV)** of assemblies

- k-mer spectrum plots and other Merqury metrics

- Automated handling of FASTQ-to-FASTA conversion and k-mer size optimization

---

## Input

`samplesheet.csv`

A comma-separated list of input read and reference genome paths:

```
/path/to/reads1.fastq,/path/to/reference/genome1.fasta
/path/to/reads2.fastq,/path/to/reference/genome2.fasta
...
```

---

## How It Works

### 1. SLURM Job Setup

- A job array is created where each task processes one line from the `samplesheet.csv`.

- Input read files and references are extracted per task.

### 2. Preprocessing

- Input FASTQ reads are converted to FASTA using `seqkit`.

- Filenames are sanitized to remove hyphens (`-`) which can break Merqury.

### 3. k-mer Size Optimization

- The genome size is estimated from the reference sequence.

- Merqury’s `best_k.sh` script is used to compute the optimal k-mer size.

### 4. Meryl Database Construction

- A Meryl database is built from the read FASTA using the computed k-mer size.

### 5. Run Merqury

- Merqury is executed using the Meryl DB and reference genome.

- Output includes QV scores, completeness, and k-mer spectrum plots.

---

## Output

For each read/reference pair, results are saved to:

```
OUTPUTS_MERQURY/<CLEANED_READS_FILENAME>/
```

This directory will contain:

- `<prefix>.qv` — Consensus quality value

- `<prefix>.spectra-cn.*` — Spectrum plots

- `<prefix>.merqury.*` — Summary metrics and reports

---

## How to Run

Submit the SLURM job with:

```bash
sbatch runMerqury.sbatch
```

Make sure the following are available in your environment:

- `merqury` (and `$MERQURY` environment variable set to its path)

- `meryl`

- `seqkit`

- Python 3 (for Merqury’s plotting utilities, if used)

---

## Notes

- File and directory names must not contain hyphens (`-`) due to Merqury limitations. This is handled automatically in the script.

- Adjust SLURM resource parameters (`--mem`, `--cpus-per-task`, etc.) according to your dataset sizes.

- Reference files can be gzip-compressed (`.gz`); the script handles decompression on the fly.

---
