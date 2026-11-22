#!/bin/bash
#SBATCH --job-name=rna_download
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=logs/download_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate sra_tools

mkdir -p data/sra data/raw data/tmp

prefetch SRR1039508 -O data/sra

fasterq-dump data/sra/SRR1039508/SRR1039508.sra \
    --split-files \
    --threads 8 \
    --outdir data/raw \
    --temp data/tmp

gzip data/raw/SRR1039508_1.fastq
gzip data/raw/SRR1039508_2.fastq
