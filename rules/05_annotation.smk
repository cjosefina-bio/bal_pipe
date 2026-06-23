# ---------------------------------------------------
# 05 - Annotation - Prokka
# ---------------------------------------------------

rule r05_01_prokka:
    input:
        contigs = config["03_assembly"]["spades"]["output_dir"] + "/{sample}/contigs.fasta"

    output:
        gff = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.gff",
        gbk = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.gbk",
        faa = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.faa",
        ffn = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.ffn",
        tsv = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.tsv",
        txt = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.txt",
        done = config["05_annotation"]["prokka"]["output_dir"] + "/.done/{sample}.prokka.done"

    log:
        config["05_annotation"]["prokka"]["log_dir"] + "/{sample}.prokka.log"

    threads:
        config["05_annotation"]["prokka"]["threads"]

    params:
        outdir = config["05_annotation"]["prokka"]["output_dir"] + "/{sample}",
        done_dir = config["05_annotation"]["prokka"]["output_dir"] + "/.done",
        logdir = config["05_annotation"]["prokka"]["log_dir"],
        docker_image = config["05_annotation"]["prokka"]["docker_image"],
        platform = config["05_annotation"]["prokka"]["platform"],
        kingdom = config["05_annotation"]["prokka"]["kingdom"],
        genus = config["05_annotation"]["prokka"]["genus"]

    shell:
        """
        mkdir -p {params.outdir}
        mkdir -p {params.done_dir}
        mkdir -p {params.logdir}

        docker run --rm --platform {params.platform} \
          -v $PWD:/data \
          {params.docker_image} \
          prokka \
          --outdir /data/{params.outdir} \
          --force \
          --prefix {wildcards.sample} \
          --kingdom {params.kingdom} \
          --genus {params.genus} \
          --usegenus \
          --cpus {threads} \
          /data/{input.contigs}
          
          > {log} 2>&1

        touch {output.done}
        """