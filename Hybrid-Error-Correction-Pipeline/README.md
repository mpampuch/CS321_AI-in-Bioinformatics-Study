# Hybrid Error Correction Pipeline

This pipeline performs hybrid error correction of long-read sequencing data using a two-step correction strategy involving **HERRO** and **DeChat** , followed by read filtering and merging.

---

## Pipeline Overview

1. **Run HERRO correction**

2. **Filter raw reads based on HERRO correction results**

3. **Run DeChat correction on uncorrected reads from HERRO**

4. **Merge HERRO- and DeChat-corrected reads**

---

## Step-by-Step Instructions

### 1. Run HERRO

Follow the instructions provided in `HERRO-Correction/README.md` to run HERRO on your raw reads.

HERRO will output corrected reads for each sample.

---

### 2. Extract Reads Based on HERRO Output

Run the filtering script to separate raw reads into:

- Reads **corrected by HERRO**

- Reads **not corrected by HERRO**

#### Submit the Slurm job:

```bash
sbatch extract-reads-filtered-from-herro.sbatch
```

This script uses `samplesheet_extract-reads.csv`, which contains pairs of:

```php-template
<raw_reads_path>,<herro_corrected_reads_path>
```

Filtered reads will be saved in the `READS-FILTERED-BY-HERRO` directory as:

- `*.raw_reads_with_corrected_reads.fastq`

- `*.raw_reads_without_corrected_reads.fastq`

---

### 3. Run DeChat

Use the uncorrected reads from HERRO (i.e., `raw_reads_without_corrected_reads.fastq`) as input for DeChat.
Follow the instructions in `DeChat-Correction/README.md` to run DeChat on these reads.

DeChat will output another set of corrected reads.

---

### 4. Merge Corrected Reads

Merge the HERRO-corrected reads with the DeChat-corrected reads to form a single set of hybrid-corrected reads.

Ensure `samplesheet_merge-reads.csv` is populated with:

```
<herro_corrected_reads_path>,<dechat_corrected_reads_path>
```

#### Run the merge script:

```bash
./merge-reads.sh
```

This will concatenate the two corrected FASTA files and save the result to the `HYBRID-CORRECTED-READS` directory as:

```
<basename>.hybrid.corrected.fasta
```

Repeat with the appropriate SLURM array ID for each sample.

---

## Requirements

- `seqkit`
