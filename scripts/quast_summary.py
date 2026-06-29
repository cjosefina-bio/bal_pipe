import pandas as pd
from pathlib import Path

metrics = {
    "# contigs": "contigs",
    "Largest contig": "largest_contig",
    "Total length": "total_length",
    "GC (%)": "gc_percent",
    "N50": "n50",
    "N90": "n90",
    "auN": "aun",
    "L50": "l50",
    "L90": "l90",
    "N's per 100 kbp": "n_per_100kbp"
}

rows = []

for report in snakemake.input:
    report = Path(report)
    sample = report.parent.name

    df = pd.read_csv(report, sep="\t", header=None, names=["metric", "value"])

    row = {"sample": sample}

    for quast_name, column_name in metrics.items():
        value = df.loc[df["metric"] == quast_name, "value"]

        if len(value) > 0:
            row[column_name] = value.iloc[0]
        else:
            row[column_name] = None

    rows.append(row)

summary = pd.DataFrame(rows)

for column in summary.columns:
    if column != "sample":
        summary[column] = pd.to_numeric(summary[column], errors="coerce")

output = Path(snakemake.output[0])
output.parent.mkdir(parents=True, exist_ok=True)

summary.to_csv(output, sep="\t", index=False)