configfile: "config.yaml"

meginiai = config["samples"]

rule all:
    input:
        expand("results/fastqc/raw/{meginys}_{pora}_fastqc.html",
               meginys=meginiai, pora=[1, 2]),
        expand("results/fastqc/trimmed/{meginys}_{pora}_fastqc.html",
               meginys=meginiai, pora=[1, 2]),
        expand("results/fastp/{meginys}.html", meginys=meginiai),
        expand("results/bam/{meginys}.bam.bai", meginys=meginiai),
        "results/featurecounts/gene_counts.txt",
        "results/featurecounts/gene_counts.txt.summary",
        expand("results/kallisto/{meginys}/abundance.tsv", meginys=meginiai),
        expand("results/rseqc/{meginys}_strandedness.txt", meginys=meginiai),
        expand("results/rseqc/{meginys}_distribution.txt", meginys=meginiai),
        expand("results/rseqc/{meginys}_geneBody.geneBodyCoverage.txt", meginys=meginiai),
        expand("results/rseqc/{meginys}_inner.inner_distance_freq.txt", meginys=meginiai)
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
rule paruosti_genoma:
    input:
        "reference/GRCh38.primary_assembly.genome.fa.gz"
    output:
        "reference/GRCh38.primary_assembly.genome.fa"
    shell:
        "gzip -dc {input} > {output}"


rule hisat2_indeksas:
    input:
        "reference/GRCh38.primary_assembly.genome.fa"
    output:
        expand("reference/hisat2/grch38.{nr}.ht2", nr=range(1, 9))
    threads: 8
    conda:
        "envs/hisat2.yaml"
    log:
        "logs/hisat2_index.log"
    shell:
        """
        mkdir -p reference/hisat2 logs
        hisat2-build -p {threads} {input} reference/hisat2/grch38 > {log} 2>&1
        """
rule hisat2_alignment:
    input:
        r1="data/trimmed/{meginys}_1.fastq.gz",
        r2="data/trimmed/{meginys}_2.fastq.gz",
        indeksas=expand("reference/hisat2/grch38.{nr}.ht2", nr=range(1, 9))
    output:
        bam="results/bam/{meginys}.bam",
        bai="results/bam/{meginys}.bam.bai"
    threads: 8
    conda:
        "envs/alignment.yaml"
    log:
        "logs/hisat2/{meginys}.log"
    shell:
        """
        mkdir -p results/bam logs/hisat2
        set -euo pipefail
        hisat2 -p 6 -x reference/hisat2/grch38 \
        -1 {input.r1} -2 {input.r2} 2> {log} |
        samtools sort -@ 2 -m 1G -o {output.bam} -
        samtools index -@ 2 {output.bam}
        """
rule featurecounts:
    input:
        bam=expand("results/bam/{meginys}.bam", meginys=meginiai),
        gtf="reference/gencode.v50.primary_assembly.annotation.gtf.gz"
    output:
        counts="results/featurecounts/gene_counts.txt",
        summary="results/featurecounts/gene_counts.txt.summary"
    threads: 8
    conda:
        "envs/featurecounts.yaml"
    log:
        "logs/featurecounts.log"
    shell:
        """
        mkdir -p results/featurecounts
        featureCounts -T {threads} -p --countReadPairs -s 0 \
        -t exon -g gene_id \
        -a {input.gtf} \
        -o {output.counts} {input.bam} > {log} 2>&1
        """
rule kallisto_indeksas:
    input:
        "reference/gencode.v50.transcripts.fa.gz"
    output:
        "reference/kallisto/transcripts.idx"
    threads: 4
    conda:
        "envs/kallisto.yaml"
    log:
        "logs/kallisto/index.log"
    shell:
        """
        mkdir -p reference/kallisto logs/kallisto
        kallisto index -i {output} -t {threads} {input} > {log} 2>&1
        """


rule kallisto_quant:
    input:
        indeksas="reference/kallisto/transcripts.idx",
        r1="data/trimmed/{meginys}_1.fastq.gz",
        r2="data/trimmed/{meginys}_2.fastq.gz"
    output:
        tsv="results/kallisto/{meginys}/abundance.tsv",
        info="results/kallisto/{meginys}/run_info.json"
    threads: 4
    conda:
        "envs/kallisto.yaml"
    log:
        "logs/kallisto/{meginys}.log"
    shell:
        """
        mkdir -p logs/kallisto
        kallisto quant -i {input.indeksas} \
        -o results/kallisto/{wildcards.meginys} \
        -t {threads} {input.r1} {input.r2} > {log} 2>&1
        """
rule paruosti_bed12:
    input:
        "reference/gencode.v50.primary_assembly.annotation.gtf.gz"
    output:
        "reference/gencode.v50.bed12"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/rseqc/bed12.log"
    shell:
        """
        set -euo pipefail
        mkdir -p logs/rseqc
        gzip -dc {input} > reference/gencode.v50.gtf
        gtfToGenePred -genePredExt reference/gencode.v50.gtf reference/gencode.v50.genePred > {log} 2>&1
        genePredToBed reference/gencode.v50.genePred {output} >> {log} 2>&1
        """
rule rseqc_kryptingumas:
    input:
        bam="results/bam/{meginys}.bam",
        bed="reference/gencode.v50.bed12"
    output:
        "results/rseqc/{meginys}_strandedness.txt"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/rseqc/{meginys}_strandedness.log"
    shell:
        """
        mkdir -p results/rseqc logs/rseqc
        infer_experiment.py -i {input.bam} -r {input.bed} > {output} 2> {log}
        """


rule rseqc_pasiskirstymas:
    input:
        bam="results/bam/{meginys}.bam",
        bed="reference/gencode.v50.bed12"
    output:
        "results/rseqc/{meginys}_distribution.txt"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/rseqc/{meginys}_distribution.log"
    shell:
        """
        mkdir -p results/rseqc logs/rseqc
        read_distribution.py -i {input.bam} -r {input.bed} > {output} 2> {log}
        """
rule rseqc_gene_coverage:
    input:
        bam="results/bam/{meginys}.bam",
        bed="reference/gencode.v50.bed12"
    output:
        "results/rseqc/{meginys}_geneBody.geneBodyCoverage.txt"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/rseqc/{meginys}_geneBody.log"
    shell:
        """
        mkdir -p results/rseqc logs/rseqc
        geneBody_coverage.py -i {input.bam} -r {input.bed} \
        -o results/rseqc/{wildcards.meginys}_geneBody > {log} 2>&1
        """


rule rseqc_fragmentai:
    input:
        bam="results/bam/{meginys}.bam",
        bed="reference/gencode.v50.bed12"
    output:
        "results/rseqc/{meginys}_inner.inner_distance_freq.txt"
    conda:
        "envs/rseqc.yaml"
    log:
        "logs/rseqc/{meginys}_inner.log"
    shell:
        """
        mkdir -p results/rseqc logs/rseqc
        inner_distance.py -i {input.bam} -r {input.bed} \
        -o results/rseqc/{wildcards.meginys}_inner > {log} 2>&1
        """
