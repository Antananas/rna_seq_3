#!/bin/bash
#SBATCH --job-name=rseqc_extra
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/rseqc_extra_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 2 --sdm conda --latency-wait 60 --rerun-triggers mtime
