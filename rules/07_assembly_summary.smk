# ---------------------------------------------------
# 07 - Assembly summary - QUAST
# ---------------------------------------------------

rule r07_00_quast_reports_txt:
    input:
        expand(
            config["05_assembly_quality"]["quast"]["output_dir"] + "/{sample}/report.tsv",
            sample=SAMPLES
        )
    output:
        reports_txt=config["07_assembly_summary"]["reports_file"]
    log:
        config["07_assembly_summary"]["log_dir"] + "/quast_reports_txt.log"
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

rule r07_01_quast_summary:
    input:
        reports_txt = config["07_assembly_summary"]["reports_file"]
    output:
        config["07_assembly_summary"]["output_dir"] + "/quast_summary.tsv"
    log:
        config["07_assembly_summary"]["log_dir"] + "/quast_summary.log"
    conda:
        "../envs/07_assembly_summary.yml"
    shell:
        """
        python scripts/quast_summary.py \
            -i {input.reports_txt} \
            -o {output} \
            > {log} 2>&1
        """