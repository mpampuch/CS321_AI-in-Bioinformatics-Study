# Bin Reads by Quality Scores

This repository contains a script that bins reads from a FASTQ file into different quality ranges, processes them, and saves the results into separate FASTQ files based on quality scores. The script uses **`fastq-filter`** and **`seqkit`** tools to process the reads and is designed to be run within a **Conda** environment.

## Requirements

- **fastq-filter**: For filtering reads based on quality scores.
- **seqkit**: For converting FASTQ to TSV format for easier processing.

The required dependencies are specified in the `environment.yml` file and can be installed using Conda.

### To create the environment:

```bash
conda env create -f environment.yml
```

This will create a Conda environment with the necessary dependencies.

---

## Usage

### 1. Activate the Conda environment

Before running the script, activate the Conda environment:

```bash
source /path/to/mambaforge/etc/profile.d/conda.sh
conda activate /path/to/environment
```

2. Run the `bin-reads-by-q-scores-using-fastq-filter.sh` script
   The script takes a single argument: the path to the input `.fastq.gz` file.

#### Syntax:

```bash
./bin-reads-by-q-scores-using-fastq-filter.sh <input_file.fastq.gz>
```

#### Example:

```bash
./bin-reads-by-q-scores-using-fastq-filter.sh /path/to/input_file.fastq.gz
```

The script will:

- Bin the reads into 5 quality score ranges: `21-99`, `16-20`, `11-15`, `6-10`, and `0-5`.

- Process the reads in each range, removing any already processed reads.

- Store the processed reads in a specific output directory named after the input file, under the directory `/ibex/scratch/projects/c2303/CS312_AI-in-Bioinformatics/20250323_partition-data/READ-LENGTH-BENCHMARKING/QUALITY-BINS/`.

---

## Output

For each quality range, the script will create a new FASTQ file in the output directory:

- The output files will be named in the format: `<input_file_name>.q<MIN_QUALITY>-<MAX_QUALITY>.fastq`.

- A `processed_read_ids.txt` file will track all processed read IDs to avoid duplication across quality bins.

Example output file names:

- `input_file.q21-99.fastq`

- `input_file.q16-20.fastq`

- `input_file.q11-15.fastq`

The processed reads will be stored in:

```
/ibex/scratch/projects/c2303/CS312_AI-in-Bioinformatics/20250323_partition-data/READ-LENGTH-BENCHMARKING/QUALITY-BINS/<input_file_basename>/
```

---

## Script Details

1. **Quality Ranges**

The script uses 5 predefined quality ranges:

- `21-99`

- `16-20`

- `11-15`

- `6-10`

- `0-5`

These ranges are processed in the order from highest quality to lowest.

2. **Processing Steps**

- **Step 1** : Reads are filtered by quality score using the `fastq-filter` tool.

- **Step 2** : The filtered reads are converted to a TSV format using `seqkit fx2tab`.

- **Step 3** : Reads that have already been processed in a higher quality bin are excluded from the current bin.

- **Step 4** : The TSV file is converted back to FASTQ format using `seqkit tab2fx`.

- **Step 5** : The processed read IDs are updated to ensure that reads in lower quality bins are not processed again.

3. **Temporary Files**

- Temporary files are created to hold intermediate results:

  - `tmp.q<MIN_QUALITY>-<MAX_QUALITY>.fastq`: The filtered FASTQ file for each quality range.
  - `tmp.q<MIN_QUALITY>-<MAX_QUALITY>.fastq.tsv`: The TSV file format of the filtered reads.
  - `processed_read_ids.txt`: A file tracking all processed read IDs.

These temporary files are cleaned up after processing each quality range.

---

## Notes

- Ensure that the input file is a valid gzipped FASTQ file (i.e., `.fastq.gz`).

- This script assumes that the input file is large enough to benefit from quality binning.

- If any errors occur during execution, ensure that the required dependencies (`fastq-filter`, `seqkit`, and `conda`) are correctly installed and accessible.

---
