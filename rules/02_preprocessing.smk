# ---------------------------------------------------
# 02 - Preprocessing - fastp - fastqc - multiqc
# ---------------------------------------------------

rule r02_01_fastp:
    input:
        r1 = lambda wildcards: config["samples"][wildcards.sample]["r1"],
        r2 = lambda wildcards: config["samples"][wildcards.sample]["r2"],    
    # Dependencia del control de calidad inicial
        raw_multiqc_done=config["01_quality_control"]["multiqc"]["output_dir"] + "/.done/raw_multiqc.done"
    
    output:
        r1 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}_R1.trimmed.fastq.gz",
        r2 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}_R2.trimmed.fastq.gz",
        html = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}.fastp.html",
        json = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}.fastp.json",
        done = config["02_preprocessing"]["fastp"]["output_dir"] + "/.done/{sample}.fastp.done"

    log:
        config["02_preprocessing"]["fastp"]["log_dir"] + "/{sample}.fastp.log"

    conda:
        "../envs/02_preprocessing.yml"

    threads:
        config["02_preprocessing"]["fastp"]["threads"]

    params:
        outdir = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}",
        done_dir = config["02_preprocessing"]["fastp"]["output_dir"] + "/.done",
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

rule r02_02_trimmed_fastqc:
    input:
        r1 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}_R1.trimmed.fastq.gz",
        r2 = config["02_preprocessing"]["fastp"]["output_dir"] + "/{sample}/{sample}_R2.trimmed.fastq.gz",
        fastp_done= config["02_preprocessing"]["fastp"]["output_dir"] + "/.done/{sample}.fastp.done"
    output:
        done = config["02_preprocessing"]["fastqc"]["output_dir"] + "/.done/{sample}.trimmed_fastqc.done"       
    
    log:
        config["02_preprocessing"]["fastqc"]["log_dir"] + "/{sample}.trimmed_fastqc.log"
    
    conda:
        "../envs/01_quality_control.yml"
    
    threads:
        config["02_preprocessing"]["fastqc"]["threads"]
    
    params:
        outdir = config["02_preprocessing"]["fastqc"]["output_dir"] + "/{sample}",
        done_dir = config["02_preprocessing"]["fastqc"]["output_dir"] + "/.done",
        logdir = config["02_preprocessing"]["fastqc"]["log_dir"]
    
    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.done_dir}
        mkdir -p {params.logdir}

        fastqc \
          --threads {threads} \
          --outdir {params.outdir} \
          {input.r1} {input.r2} \
          > {log} 2>&1

        touch {output.done}
        """

rule r02_03_trimmed_multiqc:
    input:
        fastqc_done=expand(
            config["02_preprocessing"]["fastqc"]["output_dir"] + "/.done/{sample}.trimmed_fastqc.done",
            sample=SAMPLES
        )
    
    output:
        html = config["02_preprocessing"]["multiqc"]["output_dir"] + "/multiqc_report.html",
        done = config["02_preprocessing"]["multiqc"]["output_dir"] + "/.done/trimmed_multiqc.done"
    
    log:
        config["02_preprocessing"]["multiqc"]["log_dir"] + "/multiqc.log"
    
    conda:
        "../envs/01_quality_control.yml"
    
    params:
        fastqc_dir = config["02_preprocessing"]["fastqc"]["output_dir"],
        outdir = config["02_preprocessing"]["multiqc"]["output_dir"],
        logdir = config["02_preprocessing"]["multiqc"]["log_dir"]
    
    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.logdir}

        multiqc \
          {params.fastqc_dir} \
          --outdir {params.outdir} \
          --force \
          > {log} 2>&1
        
        touch {output.done}
        """