#!/bin/bash
#SBATCH --job-name=hisat2_align
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=16:00:00
#SBATCH --output=logs/alignment_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 8 --sdm conda --latency-wait 60 --rerun-triggers mtime
