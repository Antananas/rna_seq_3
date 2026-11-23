#!/bin/bash
#SBATCH --job-name=featurecounts
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=logs/featurecounts_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 8 --sdm conda --latency-wait 60 --rerun-triggers mtime
