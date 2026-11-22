#!/bin/bash
#SBATCH --job-name=rna_download
#SBATCH --array=0-2%3
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=08:00:00
#SBATCH --output=logs/download_%A_%a.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate sra_tools

meginiai=(SRR1039512 SRR1039509 SRR1039518)
meginys=${meginiai[$SLURM_ARRAY_TASK_ID]}

mkdir -p data/sra data/raw data/tmp/$meginys

prefetch "$meginys" -O data/sra

fasterq-dump "data/sra/$meginys/$meginys.sra" \
    --split-files \
    --threads 4 \
    --outdir data/raw \
    --temp "data/tmp/$meginys"

gzip "data/raw/${meginys}_1.fastq"
gzip "data/raw/${meginys}_2.fastq"
