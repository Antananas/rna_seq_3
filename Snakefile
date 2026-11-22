configfile: "config.yaml"

meginiai = config["samples"]

rule all:
    input:
        expand("results/fastqc/raw/{meginys}_{pora}_fastqc.html",
               meginys=meginiai, pora=[1, 2])

rule fastqc:
    input:
        "data/raw/{meginys}_{pora}.fastq.gz"
    output:
        html="results/fastqc/raw/{meginys}_{pora}_fastqc.html",
        zip="results/fastqc/raw/{meginys}_{pora}_fastqc.zip"
    threads: 2
    conda:
        "envs/qc.yaml"
    log:
        "logs/fastqc/{meginys}_{pora}.log"
    shell:
        "mkdir -p results/fastqc/raw logs/fastqc; "
        "fastqc --threads {threads} --outdir results/fastqc/raw "
        "{input} > {log} 2>&1"
