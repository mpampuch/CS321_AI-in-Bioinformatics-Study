#!/bin/bash
#SBATCH --job-name=preprocess
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=200G
#SBATCH --time=2-00:00:00                   
#SBATCH -A c2227
#SBATCH --output=logs/preprocess.%a_%j_%N.out
#SBATCH --error=logs/preprocess.%a_%j_%N.out
#SBATCH --array=1-1

module load seqkit/2.4.0 herro/0.1d

export SPLIT=4
export SAMPLE=`ls -lrta fastq/*.fastq.gz | awk '{print $9}' | head -n $SLURM_ARRAY_TASK_ID | tail -n 1` ;
export FASTQ=$(basename "$SAMPLE")
export PREFIX=$(basename $FASTQ .fastq.gz) ;

## Preprocess
mkdir -p preprocessed/$PREFIX;
preprocess.sh $SAMPLE preprocessed/$PREFIX/$PREFIX.preprocessed $SLURM_CPUS_PER_TASK $SPLIT ;


mkdir -p read_ids;
seqkit seq -ni $SAMPLE > read_ids/$PREFIX.READ_IDs ;


mkdir -p batches_of_alignments/$PREFIX/
create_batched_alignments.sh preprocessed/$PREFIX/$PREFIX.preprocessed.fastq.gz read_ids/$PREFIX.READ_IDs $SLURM_CPUS_PER_TASK batches_of_alignments/$PREFIX/ ;
