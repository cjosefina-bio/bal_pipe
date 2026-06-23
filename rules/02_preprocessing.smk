# ---------------------------------------------------
# 02 - Preprocessing - fastp
# ---------------------------------------------------

rule r02_01_fastp:
    input:
        r1 = lambda wildcards: config["samples"][wildcards.sample]["r1"],
        r2 = lambda wildcards: config["samples"][wildcards.sample]["r2"]

    output:
        r1 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}_R1.trimmed.fastq.gz",
        r2 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}_R2.trimmed.fastq.gz",
        html = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}.fastp.html",
        json = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}.fastp.json",
        done = config["02_preprocessing"]["fastp"]["output_dir"] + "/.done/{sample}.fastp.done"

    log:
        config["02_preprocessing"]["fastp"]["log_dir"] + "/{sample}.fastp.log"

    conda:
        "../envs/02_preprocessing.yml"

    threads:
        config["02_preprocessing"]["fastp"]["threads"]

    params:
        outdir = config["02_preprocessing"]["fastp"]["output_dir"],
        logdir = config["02_preprocessing"]["fastp"]["log_dir"],
        detect_adapter_for_pe = config["02_preprocessing"]["trimming"]["detect_adapter_for_pe"],
        cut_tail = config["02_preprocessing"]["trimming"]["cut_tail"],
        cut_window_size = config["02_preprocessing"]["trimming"]["cut_window_size"],
        cut_mean_quality = config["02_preprocessing"]["trimming"]["cut_mean_quality"],
        length_required = config["02_preprocessing"]["trimming"]["length_required"],
        trim_poly_x = config["02_preprocessing"]["trimming"]["trim_poly_x"],
        trim_poly_g = config["02_preprocessing"]["trimming"]["trim_poly_g"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.outdir}/.done
        mkdir -p {params.logdir}

        fastp \
          -i {input.r1} \
          -I {input.r2} \
          -o {output.r1} \
          -O {output.r2} \
          --html {output.html} \
          --json {output.json} \
          --thread {threads} \
          --detect_adapter_for_pe \
          --cut_tail \
          --cut_window_size {params.cut_window_size} \
          --cut_mean_quality {params.cut_mean_quality} \
          --length_required {params.length_required} \
          --trim_poly_x \
          --trim_poly_g \
          > {log} 2>&1

        touch {output.done}
        """