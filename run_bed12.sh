#!/bin/bash
#SBATCH --job-name=bed12
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=logs/bed12_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 2 reference/gencode.v50.bed12 --sdm conda --rerun-triggers mtime --latency-wait 60
