#!/bin/bash
#SBATCH --job-name=rseqc_extra
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=logs/rseqc_extra_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 4 --sdm conda --latency-wait 60 --rerun-triggers mtime --rerun-incomplete
