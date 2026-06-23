# ---------------------------------------------------
# 03 - De novo assembly - SPAdes
# ---------------------------------------------------

rule r03_01_spades:
    input:
        r1 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}_R1.trimmed.fastq.gz",
        r2 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}_R2.trimmed.fastq.gz"

    output:
        contigs = config["03_assembly"]["spades"]["output_dir"] + "/{sample}/contigs.fasta",
        scaffolds = config["03_assembly"]["spades"]["output_dir"] + "/{sample}/scaffolds.fasta",
        done = config["03_assembly"]["spades"]["output_dir"] + "/.done/{sample}.spades.done"

    log:
        config["03_assembly"]["spades"]["log_dir"] + "/{sample}.spades.log"

    conda:
        "../envs/03_assembly.yml"

    threads:
        config["03_assembly"]["spades"]["threads"]

    params:
        outdir = config["03_assembly"]["spades"]["output_dir"] + "/{sample}",
        done_dir = config["03_assembly"]["spades"]["output_dir"] + "/.done",
        logdir = config["03_assembly"]["spades"]["log_dir"],
        cov_cutoff = config["03_assembly"]["spades"]["cov_cutoff"],
        memory = config["03_assembly"]["spades"]["memory_gb"]

    shell:
        """
    mkdir -p {params.outdir}
    mkdir -p {params.done_dir}
    mkdir -p {params.logdir}

    spades.py \
      -1 {input.r1} \
      -2 {input.r2} \
      -o {params.outdir} \
      --careful \
      --cov-cutoff {params.cov_cutoff} \
      -t {threads} \
      -m {params.memory} 
      
      > {log} 2>&1

    touch {output.done}
    """