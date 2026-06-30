# ---------------------------------------------------
# 05 - Assembly quality - QUAST
# ---------------------------------------------------

rule r05_01_quast:
    input:
        contigs = config["04_assembly"]["spades"]["output_dir"] + "/{sample}/contigs.fasta"

    output:
        html = config["05_assembly_quality"]["quast"]["output_dir"] + "/{sample}/report.html",
        tsv = config["05_assembly_quality"]["quast"]["output_dir"] + "/{sample}/report.tsv",
        done = config["05_assembly_quality"]["quast"]["output_dir"] + "/.done/{sample}.quast.done"

    log:
        config["05_assembly_quality"]["quast"]["log_dir"] + "/{sample}.quast.log"

    threads:
        config["05_assembly_quality"]["quast"]["threads"]

    params:
        outdir = config["05_assembly_quality"]["quast"]["output_dir"] + "/{sample}",
        done_dir = config["05_assembly_quality"]["quast"]["output_dir"] + "/.done",
        logdir = config["05_assembly_quality"]["quast"]["log_dir"],
        docker_image = config["05_assembly_quality"]["quast"]["docker_image"],
        platform = config["05_assembly_quality"]["quast"]["platform"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.done_dir}
        mkdir -p {params.logdir}

        docker run --rm --platform {params.platform} \
          -v $PWD:/data \
          {params.docker_image} \
          quast.py \
          /data/{input.contigs} \
          -o /data/{params.outdir} \
          -t {threads}

          > {log} 2>&1

        touch {output.done}
        """