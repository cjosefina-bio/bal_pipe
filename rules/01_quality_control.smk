# ---------------------------------------------------
# 01 - Quality control - Raw Data
# ---------------------------------------------------

rule r01_01_raw_fastqc:
    input:
        r1 = lambda wildcards: config["samples"][wildcards.sample]["r1"],
        r2 = lambda wildcards: config["samples"][wildcards.sample]["r2"]
    output:
        done = config["01_quality_control"]["fastqc"]["output_dir"] + "/.done/{sample}.fastqc.done"
    log:
        config["01_quality_control"]["fastqc"]["log_dir"] + "/{sample}.fastqc.log"
    conda:
        "../envs/01_quality_control.yml"
    params:
        outdir = config["01_quality_control"]["fastqc"]["output_dir"],
        logdir = config["01_quality_control"]["fastqc"]["log_dir"],
        threads = config["01_quality_control"]["fastqc"]["threads"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.outdir}/.done
        mkdir -p {params.logdir}

        fastqc \
          --threads {params.threads} \
          --outdir {params.outdir} \
          {input.r1} {input.r2} \
          > {log} 2>&1

        touch {output.done}
        """


rule r01_02_raw_multiqc:
    input:
        done = expand(
            config["01_quality_control"]["fastqc"]["output_dir"] + "/.done/{sample}.fastqc.done",
            sample=SAMPLES
        )
    output:
        html = config["01_quality_control"]["multiqc"]["output_dir"] + "/multiqc_report.html"
    log:
        config["01_quality_control"]["multiqc"]["log_dir"] + "/multiqc.log"
    conda:
        "../envs/01_quality_control.yml"
    params:
        fastqc_dir = config["01_quality_control"]["fastqc"]["output_dir"],
        outdir = config["01_quality_control"]["multiqc"]["output_dir"],
        logdir = config["01_quality_control"]["multiqc"]["log_dir"]
    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.logdir}

        multiqc \
          {params.fastqc_dir} \
          --outdir {params.outdir} \
          --force \
          > {log} 2>&1
        """