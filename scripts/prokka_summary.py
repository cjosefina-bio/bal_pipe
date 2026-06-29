import pandas as pd
from pathlib import Path

rows = []

for report in snakemake.input:
    report = Path(report)
    sample = report.parent.name

    df = pd.read_csv(report, sep="\t")

    counts = df["ftype"].value_counts()

    hypothetical_proteins = (
        df["product"]
        .fillna("")
        .str.lower()
        .eq("hypothetical protein")
        .sum()
    )

    cds_count = counts.get("CDS", 0)

    hypothetical_percent = round(
        hypothetical_proteins / cds_count * 100,
        2
    ) if cds_count > 0 else 0

    row = {
        "sample": sample,
        "CDS": cds_count,
        "tRNA": counts.get("tRNA", 0),
        "rRNA": counts.get("rRNA", 0),
        "tmRNA": counts.get("tmRNA", 0),
        "misc_RNA": counts.get("misc_RNA", 0),
        "hypothetical_proteins": hypothetical_proteins,
        "hypothetical_percent": hypothetical_percent,
        "total_features": len(df)
    }

    rows.append(row)

summary = pd.DataFrame(rows)

output = Path(snakemake.output[0])
output.parent.mkdir(parents=True, exist_ok=True)

summary.to_csv(output, sep="\t", index=False)