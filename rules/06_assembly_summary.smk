# ---------------------------------------------------
# 06 - Assembly summary - QUAST
# ---------------------------------------------------

rule r06_01_quast_summary:
    input:
        expand(
            config["04_assembly_quality"]["quast"]["output_dir"] + "/{sample}/report.tsv",
            sample=SAMPLES
        )
    output:
        config["06_assembly_summary"]["output_dir"] + "/quast_summary.tsv"
    log:
        config["06_assembly_summary"]["log_dir"] + "/quast_summary.log"
    conda:
        "../envs/06_assembly_summary.yml"
    script:
        "../scripts/quast_summary.py"