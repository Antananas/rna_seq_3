configfile: "config.yaml"

meginiai = config["samples"]

rule all:
    input:
        expand("results/fastqc/raw/{meginys}_{pora}_fastqc.html",
               meginys=meginiai, pora=[1, 2]),
        expand("results/fastqc/trimmed/{meginys}_{pora}_fastqc.html",
               meginys=meginiai, pora=[1, 2]),
        expand("results/fastp/{meginys}.html", meginys=meginiai)

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

rule fastp:
    input:
        r1="data/raw/{meginys}_1.fastq.gz",
        r2="data/raw/{meginys}_2.fastq.gz"
    output:
        r1="data/trimmed/{meginys}_1.fastq.gz",
        r2="data/trimmed/{meginys}_2.fastq.gz",
        html="results/fastp/{meginys}.html",
        json="results/fastp/{meginys}.json"
    threads: 4
    conda:
        "envs/qc.yaml"
    log:
        "logs/fastp/{meginys}.log"
    shell:
        """
        mkdir -p data/trimmed results/fastp logs/fastp
        fastp -i {input.r1} -I {input.r2} \
        -o {output.r1} -O {output.r2} \
        --detect_adapter_for_pe \
        --thread {threads} \
        --html {output.html} \
        --json {output.json} > {log} 2>&1
        """

rule fastqc_trimmed:
    input:
        "data/trimmed/{meginys}_{pora}.fastq.gz"
    output:
        html="results/fastqc/trimmed/{meginys}_{pora}_fastqc.html",
        zip="results/fastqc/trimmed/{meginys}_{pora}_fastqc.zip"
    threads: 2
    conda:
        "envs/qc.yaml"
    log:
        "logs/fastqc/trimmed_{meginys}_{pora}.log"
    shell:
        "mkdir -p results/fastqc/trimmed logs/fastqc; "
        "fastqc --threads {threads} --outdir results/fastqc/trimmed "
        "{input} > {log} 2>&1"
