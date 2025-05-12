# DeChat Error Correction Pipeline

This repository contains a **Nextflow**-based pipeline to perform error correction on long-read sequencing data using [**DeChat**](https://github.com/atolab/DeChat). The pipeline is containerized using **Singularity** and designed for execution on **SLURM-managed** HPC environments.

## Contents

- `main.nf`: Main Nextflow pipeline script
- `nextflow.config`: Configuration file (SLURM + Singularity + retry logic)
- `samplesheet.txt`: Input file containing a list of FASTQ file paths (one per line)
- `launch-job.sbatch`: SLURM job submission script
- `env.sh`: User-provided environment activation script (not included)

---

## Usage

### 1. Prepare your environment

Make sure you have the following modules installed on your cluster:

- `nextflow >= 24.10.2`
- `singularity >= 3.9.7`

Activate your project environment (customize in `env.sh`).

### 2. Edit the Input Sample Sheet

List the full paths to your `.fastq` or `.fastq.gz` files in `samplesheet.txt`, one per line:

```
path/to/sample1.fastq.gz
path/to/sample2.fastq.gz
```

### 3. Submit the Job

Submit the SLURM job script:

```bash
sbatch launch-job.sbatch
```

### 4. Output

- All corrected files will be saved in a timestamped subdirectory under `OUTPUTS/`, e.g.:

```
OUTPUTS/20250512_093012/
```

- Log files:

  - `.slurm_<jobid>.out`
  - `.slurm_<jobid>.err`
  - `nextflow.log`

- Corrected FASTQ files are named:

```
<input_filename>.dechat.corrected.ec.fa
```

---

## Configuration

### Resources

Edit `nextflow.config` to adjust:

- CPU cores (`cpus`)

- Runtime (`time`)

- Memory (dynamically scales with retry attempts)

- Retry strategy for memory-related failures

### Containers

The pipeline uses a **DeChat** container hosted on [Seqera Wave]() :

```lua
oras://community.wave.seqera.io/library/dechat:1.0.1--0cdf9c7516a8a247
```

---

## Example

An example command launched by SLURM:

```bash
nextflow -log OUTPUTS/20250512_093012/nextflow.log run main.nf -c nextflow.config \
  --fastq_files samplesheet.txt --outdir OUTPUTS/20250512_093012/
```
