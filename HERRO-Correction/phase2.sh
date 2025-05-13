#!/bin/bash
#SBATCH --job-name=preprocess
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:a100:1
#SBATCH --mem=200G
#SBATCH --time=30:00                   
#SBATCH --output=logs/err_correction.%a_%j_%N.out
#SBATCH --error=logs/err_correction.%a_%j_%N.out
#SBATCH --array=1-1


module load singularity

export HERRO=/ibex/sw/rl9g/herro/0.1d/rl9.1_cargo/herro.sif
export SPLIT=4
export SAMPLE=`ls -lrta fastq/*.fastq.gz | awk '{print $9}' | head -n $SLURM_ARRAY_TASK_ID | tail -n 1` ;
#export SAMPLE=`ls -lrta fastq/*.fastq | awk '{print $9}' | head -n $SLURM_ARRAY_TASK_ID | tail -n 1` ;
export FASTQ=$(basename "$SAMPLE")
export PREFIX=$(basename $FASTQ .fastq.gz) ;
#export PREFIX=$(basename $FASTQ .fastq) ;
mkdir -p err_correction;


## herro inference --read-alns <directory_alignment_batches> -t <feat_gen_threads_per_device> -d <gpus> -m <model_path> -b <batch_size> <preprocessed_reads> <fasta_output> 

#echo "singularity exec --nv --bind /ibex,/sw,/home/$USER $HERRO herro inference --read-alns batches_of_alignments/$PREFIX -t 8 -d 0 -m ./model_R10_v0.1.pt -b 4 preprocessed/$PREFIX/$PREFIX.preprocessed.fastq.gz err_correction/$PREFIX.corrected.fastq" ;

#singularity exec --nv --bind /ibex,/sw,/home/$USER $HERRO herro inference --read-alns batches_of_alignments/$PREFIX -t 8 -d 0 -m ./model_R10_v0.1.pt -b 4 preprocessed/$PREFIX/$PREFIX.preprocessed.fastq.gz err_correction/$PREFIX.corrected.fastq

#echo "singularity exec --nv --bind /ibex,/sw,/home/kathirn $HERRO herro inference --read-alns batches_of_alignments/$PREFIX -t 8 -d 0 -m /ibex/scratch/projects/c2303/naga/R1041_HG02818/model_R10_v0.1.pt -b 4 preprocessed/$PREFIX/$PREFIX.preprocessed.fastq.gz err_correction/$PREFIX.corrected.fastq"

#singularity exec --nv --bind /ibex,/sw,/home/kathirn $HERRO herro inference --read-alns batches_of_alignments/$PREFIX -t 8 -d 0 -m /ibex/scratch/projects/c2303/naga/R1041_HG02818/model_R10_v0.1.pt -b 4 preprocessed/$PREFIX/$PREFIX.preprocessed.fastq.gz err_correction/$PREFIX.corrected.fastq

#singularity exec --nv --bind /ibex,/sw /ibex/sw/rl9g/herro/0.1d/rl9.1_cargo/herro.sif herro inference --read-alns batches_of_alignments/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass -t 8 -d 0 -m /ibex/scratch/projects/c2303/naga/R1041_HG02818/model_R10_v0.1.pt -b 4 preprocessed/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass.preprocessed.fastq.gz err_correction/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass.corrected.fastq 

singularity exec --nv --bind /ibex,/sw /ibex/sw/rl9g/herro/0.1d/rl9.1_cargo/herro.sif herro inference --read-alns batches_of_alignments/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass -t 8 -d 0 -m /ibex/scratch/projects/c2303/naga/R1041_HG02818/model_R10_v0.1.pt -b 4 /ibex/scratch/projects/c2303/naga/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass.fastq.gz err_correction/02_22_23_R1041_HG02818_1_Guppy_6.4.6_prom_sup_pass.corrected.fastq 
