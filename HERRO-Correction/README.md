# HERRO Error-correction

This repository documents the usage instructions for running the **HERRO** tool (v0.1d) for long-read error correction. The pipeline consists of three main stages: **preprocessing**, **alignment**, and **inference**. The preprocessing and alignment are done on CPU nodes, while the inference step utilizes GPU resources and is containerized with **Singularity**.

---

## Module Loading

HERRO is available as a module on the `ilogin` CPU node:

```bash
module load herro/0.1d
```

---

## 1. Preprocessing (CPU Node)

Split and process the input reads for batching:

```bash
srun --time=1:00:00 --mem=4GB --pty bash -l
module load herro/0.1d

preprocess.sh <input.fastq.gz> <output_dir> <num_splits> <num_threads>
```

### Example:

```bash
preprocess.sh HG002.chr19_10M_12M.fastq.gz output_dir/preprocessed 4 2
```

This will:

- Split the FASTQ file into `num_splits` parts

- Detect known adapter sequences

- Generate preprocessed reads in the specified `output_dir`

**Output folders:**

- `output_dir/split_temp/` — contains split FASTQ files

- `output_dir/preprocessed.fastq.gz` — the concatenated cleaned file

---

## 2. Create Batched Alignments (CPU Node)

After preprocessing, generate alignments using `minimap2`:

```bash
create_batched_alignments.sh <preprocessed.fastq.gz> <sample_id> <num_threads> <alignment_output_dir>
```

### Example:

```bash
create_batched_alignments.sh output_dir/preprocessed.fastq.gz HG002 4 output_dir/alignments
```

This will:

- Run `minimap2` on the cleaned reads

- Generate alignment files (`*.oec.zst`) used for inference

---

## 3. Inference (GPU Node)

Run the HERRO model on a GPU node via **Singularity** :

```bash
srun --time=1:00:00 --gres=gpu:1 --mem=16GB --pty bash -l
module load singularity
singularity exec /ibex/sw/rl9c/herro/0.1d/rl9.1_conda3/herro.sif herro inference -h
```

### Basic Command:

```bash
singularity exec /path/to/herro.sif herro inference \
  -m <model_path> \
  -b <batch_size> \
  --read-alns <alignment_dir> \
  <input_reads.fastq.gz> \
  <corrected_reads_output>
```

### Example:

```bash
singularity exec /ibex/sw/rl9c/herro/0.1d/rl9.1_conda3/herro.sif herro inference \
  -m model.pt \
  -b 64 \
  --read-alns output_dir/alignments \
  output_dir/preprocessed.fastq.gz \
  output_dir/corrected_reads.fastq.gz
```

---

## Notes

- Preprocessing and alignment should be run on **CPU nodes** .

- Inference must be executed on **GPU nodes** using **Singularity** .

- Model file `model.pt` must be available before inference.
