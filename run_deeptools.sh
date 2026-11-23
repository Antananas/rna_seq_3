#!/bin/bash
#SBATCH --job-name=deeptools
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --output=logs/deeptools_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 4 --sdm conda --latency-wait 60 --rerun-triggers mtime
