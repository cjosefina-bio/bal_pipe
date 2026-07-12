# ---------------------------------------------------
# 09 - Genomic visualization - Circos
# ---------------------------------------------------

rule circos:
    input:
        expand(
            config["09_genomic_visualization"]["circos"]["output_dir"]
            + "/{sample}/circos.png",
            sample=SAMPLES
        ),
        expand(
            config["09_genomic_visualization"]["circos"]["output_dir"]
            + "/{sample}/circos.svg",
            sample=SAMPLES
        )


rule r09_01_prepare_circos:
    input:
        contigs = config["04_assembly"]["spades"]["output_dir"]
        + "/{sample}/contigs.fasta",
        gff = config["06_annotation"]["prokka"]["output_dir"]
        + "/{sample}/{sample}.gff"

    output:
        karyotype = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/karyotype.txt",
        cds_forward = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/cds_forward.txt",
        cds_reverse = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/cds_reverse.txt",
        rrna = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/rrna.txt",
        trna = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/trna.txt",
        gc_content = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/gc_content.txt",
        contig_summary = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/contig_summary.tsv",
        done = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/.done/{sample}.prepare_circos.done"

    log:
        config["09_genomic_visualization"]["circos"]["log_dir"]
        + "/{sample}.prepare_circos.log"

    threads:
        config["09_genomic_visualization"]["circos"]["threads"]

    params:
        outdir = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data",
        done_dir = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/.done",
        logdir = config["09_genomic_visualization"]["circos"]["log_dir"],
        min_contig_length = config["09_genomic_visualization"]["circos"]
        ["min_contig_length"],
        max_contigs = config["09_genomic_visualization"]["circos"]
        ["max_contigs"],
        gc_window_size = config["09_genomic_visualization"]["circos"]
        ["gc_window_size"],
        gc_step_size = config["09_genomic_visualization"]["circos"]
        ["gc_step_size"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.done_dir}
        mkdir -p {params.logdir}

        python scripts/prepare_circos.py \
          --fasta {input.contigs} \
          --gff {input.gff} \
          --outdir {params.outdir} \
          --min-contig-length {params.min_contig_length} \
          --max-contigs {params.max_contigs} \
          --gc-window-size {params.gc_window_size} \
          --gc-step-size {params.gc_step_size} \
          > {log} 2>&1

        touch {output.done}
        """


rule r09_02_circos:
    input:
        karyotype = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/karyotype.txt",
        cds_forward = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/cds_forward.txt",
        cds_reverse = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/cds_reverse.txt",
        rrna = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/rrna.txt",
        trna = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/trna.txt",
        gc_content = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/data/gc_content.txt",
        conf = config["09_genomic_visualization"]["circos"]["conf"]

    output:
        png = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/circos.png",
        svg = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}/circos.svg",
        done = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/.done/{sample}.circos.done"

    log:
        config["09_genomic_visualization"]["circos"]["log_dir"]
        + "/{sample}.circos.log"

    threads:
        config["09_genomic_visualization"]["circos"]["threads"]

    params:
        outdir = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/{sample}",
        done_dir = config["09_genomic_visualization"]["circos"]["output_dir"]
        + "/.done",
        logdir = config["09_genomic_visualization"]["circos"]["log_dir"],
        docker_image = config["09_genomic_visualization"]["circos"]
        ["docker_image"],
        platform = config["09_genomic_visualization"]["circos"]["platform"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.done_dir}
        mkdir -p {params.logdir}

        cp {input.conf} {params.outdir}/circos.conf

        docker run --rm --platform {params.platform} \
          -v $PWD:/data \
          -w /data/{params.outdir} \
          {params.docker_image} \
          circos \
          -conf /data/{params.outdir}/circos.conf \
          > {log} 2>&1

        test -s {output.png}
        test -s {output.svg}

        touch {output.done}
        """