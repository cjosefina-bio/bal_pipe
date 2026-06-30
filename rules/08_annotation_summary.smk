# ---------------------------------------------------
# 08 - Annotation summary - Prokka
# ---------------------------------------------------

rule r08_00_prokka_reports_txt:
    input:
        expand(
            config["06_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.tsv",
            sample=SAMPLES
        )
    output:
        reports_txt=config["08_annotation_summary"]["reports_file"]
    log:
        config["08_annotation_summary"]["log_dir"] + "/prokka_reports_txt.log"
    shell:
        """
        mkdir -p $(dirname {output.reports_txt}) $(dirname {log})

        echo -e "sample\treport" > {output.reports_txt}

        for report in {input}; do
            sample=$(basename $(dirname "$report"))
            echo -e "${{sample}}\t${{report}}" >> {output.reports_txt}
        done

        echo "Generated {output.reports_txt}" > {log}
        """
        
rule r08_01_prokka_summary:
    input:
        reports_txt=config["08_annotation_summary"]["reports_file"]
    output:
        summary=config["08_annotation_summary"]["output_dir"] + "/prokka_summary.tsv"
    log:
        config["08_annotation_summary"]["log_dir"] + "/prokka_summary.log"
    conda:
        "../envs/08_annotation_summary.yml"
    shell:
        """
        python scripts/prokka_summary.py \
            -i {input.reports_txt} \
            -o {output.summary} \
            > {log} 2>&1
        """