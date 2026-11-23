#!/bin/bash
#SBATCH --job-name=hisat2_index
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=06:00:00
#SBATCH --output=logs/index_%j.log

set -e

cd ~/rna_seq_3
source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores 8 reference/hisat2/grch38.1.ht2 --sdm conda
