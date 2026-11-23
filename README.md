Samples
Four paired-end RNA-seq samples were analyzed:
- SRR1039508
- SRR1039509
- SRR1039512
- SRR1039518

Project Structure
- Snakefile - Snakemake workflow rules
- config.yaml - Sample configuration
- envs/ - Conda environment definitions
- download.sh, download_rest.sh - RNA-seq dataset download scripts
- download_reference.sh - Reference genome download script
- run_*.sh - SLURM execution scripts
- data/raw/ - Original FASTQ files
- data/trimmed/ - Processed FASTQ files
- reference/ - Genome, transcriptome, annotations and indices
- results/ - Analysis results
- logs/ - Execution logs

Workflow Steps
Download sequencing data and reference files.
Check read quality with FastQC.
Trim reads using fastp.
Align reads using HISAT2 and samtools.
Quantify genes using featureCounts.
Quantify transcripts using kallisto.
Assess alignment quality using RSeQC.
Perform correlation analysis and PCA using deepTools.
Generate MultiQC reports.
Visualize alignments using IGV.

How to Run the Workflow

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

Download the sequencing datasets and reference files.

Once the FASTQ files and references are available, check the workflow:

snakemake -n --rerun-triggers mtime

Run the workflow using the provided scripts:

sbatch run_alignment.sh
sbatch run_featurecounts.sh
sbatch run_kallisto.sh
sbatch run_rseqc.sh
sbatch run_rseqc_extra.sh
sbatch run_deeptools.sh
sbatch run_multiqc.sh

The general Snakemake execution command is:

snakemake --cores 8 --sdm conda --latency-wait 60 --rerun-triggers mtime

The exact samples used in this project are defined in config.yaml. Reference paths are currently specified in the Snakefile.

Main Results
- results/fastqc/ - FastQC reports
- results/fastp/ - Trimming reports
- results/bam/ - Sorted and indexed BAM files
- results/featurecounts/gene_counts.txt - Gene expression counts
- results/kallisto/ - Transcript abundance estimates
- results/rseqc/ - Alignment quality assessment
- results/deeptools/correlation.pdf - Sample correlation heatmap
- results/deeptools/pca.pdf - Principal component analysis
- results/multiqc/multiqc_report.html - Combined quality report
