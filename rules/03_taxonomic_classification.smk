# ---------------------------------------------------
# 03 - Taxonomic classification - Kraken2
# ---------------------------------------------------

def get_kraken2_db_input(wildcards):
    if config["03_taxonomic_classification"]["kraken2"]["download_db"]:
        return config["03_taxonomic_classification"]["kraken2"]["database"] + "/.done"
    else:
        return []

rule r03_00_download_kraken2_db:
    output:
        done = config["03_taxonomic_classification"]["kraken2"]["database"] + "/.done"
    log:
        config["03_taxonomic_classification"]["kraken2"]["log_dir"] + "/download_kraken2_db.log"
    params:
        database = config["03_taxonomic_classification"]["kraken2"]["database"],
        db_url = config["03_taxonomic_classification"]["kraken2"]["db_url"],
        db_archive = config["03_taxonomic_classification"]["kraken2"]["db_archive"],
        logdir = config["03_taxonomic_classification"]["kraken2"]["log_dir"]
    shell:
        """
        mkdir -p {params.logdir}
        mkdir -p databases

        echo "Downloading Kraken2 database..." > {log}

        if [ ! -f "{params.database}/hash.k2d" ]; then
            wget -O {params.db_archive} {params.db_url} >> {log} 2>&1

            mkdir -p {params.database}

            tar -xzf {params.db_archive} -C databases >> {log} 2>&1

            extracted_dir=$(tar -tzf {params.db_archive} | head -1 | cut -f1 -d"/")

            if [ -d "databases/$extracted_dir" ]; then
                rm -rf {params.database}
                mv databases/$extracted_dir {params.database}
            fi
        fi

        touch {output.done}
        """

rule r03_01_kraken2:
    input:
        r1 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}_R1.trimmed.fastq.gz",
        r2 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}_R2.trimmed.fastq.gz",
        db_done = get_kraken2_db_input

    output:
        report = config["03_taxonomic_classification"]["kraken2"]["output_dir"] + "/{sample}/{sample}.kraken2.report",
        output = config["03_taxonomic_classification"]["kraken2"]["output_dir"] + "/{sample}/{sample}.kraken2.output",
        done = config["03_taxonomic_classification"]["kraken2"]["output_dir"] + "/.done/{sample}.kraken2.done"

    log:
        config["03_taxonomic_classification"]["kraken2"]["log_dir"] + "/{sample}.kraken2.log"

    conda:
        "../envs/03_taxonomic_classification.yml"

    threads:
        config["03_taxonomic_classification"]["kraken2"]["threads"]

    params:
        outdir = config["03_taxonomic_classification"]["kraken2"]["output_dir"] + "/{sample}",
        done_dir = config["03_taxonomic_classification"]["kraken2"]["output_dir"] + "/.done",
        logdir = config["03_taxonomic_classification"]["kraken2"]["log_dir"],
        database = config["03_taxonomic_classification"]["kraken2"]["database"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.done_dir}
        mkdir -p {params.logdir}

        kraken2 \
          --db {params.database} \
          --paired \
          --threads {threads} \
          --report {output.report} \
          --output {output.output} \
          {input.r1} {input.r2} \
          > {log} 2>&1

        touch {output.done}
        """