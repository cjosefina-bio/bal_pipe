# ---------------------------------------------------
# 07 - Annotation summary - Prokka
# ---------------------------------------------------

rule r07_01_prokka_summary:
    input:
        expand(
            config["05_annotation"]["prokka"]["output_dir"] + "/{sample}/{sample}.tsv",
            sample=SAMPLES
        )
    output:
        config["07_annotation_summary"]["output_dir"] + "/prokka_summary.tsv"
    log:
        config["07_annotation_summary"]["log_dir"] + "/prokka_summary.log"
    conda:
        "../envs/07_annotation_summary.yml"
    script:
        "../scripts/prokka_summary.py"