#!/usr/bin/env python3

import argparse
from pathlib import Path


def read_fasta(fasta_file):
    """Read a FASTA file without external Python dependencies."""

    records = []
    seqid = None
    sequence = []

    with open(fasta_file) as fasta:
        for line in fasta:
            line = line.strip()

            if not line:
                continue

            if line.startswith(">"):
                if seqid is not None:
                    records.append((seqid, "".join(sequence).upper()))

                seqid = line[1:].split()[0]
                sequence = []

            else:
                sequence.append(line)

    if seqid is not None:
        records.append((seqid, "".join(sequence).upper()))

    return records


def calculate_gc(sequence):
    """Calculate GC content as a proportion between 0 and 1."""

    sequence = sequence.upper()

    a = sequence.count("A")
    c = sequence.count("C")
    g = sequence.count("G")
    t = sequence.count("T")

    total = a + c + g + t

    if total == 0:
        return 0.0

    return (g + c) / total


def select_contigs(records, min_contig_length, max_contigs):
    """Filter contigs by length and retain the largest contigs."""

    selected = []

    for seqid, sequence in records:
        if len(sequence) >= min_contig_length:
            selected.append((seqid, sequence))

    selected.sort(key=lambda record: len(record[1]), reverse=True)

    if max_contigs > 0:
        selected = selected[:max_contigs]

    return selected


def write_karyotype(records, output_file):
    """Create one Circos ideogram for each selected contig."""

    with open(output_file, "w") as output:
        for index, (seqid, sequence) in enumerate(records, start=1):

            if index % 2 == 0:
                color = "lgrey"
            else:
                color = "vvlgrey"

            output.write(
                f"chr - {seqid} {seqid} 0 {len(sequence)} {color}\n"
            )


def write_gc_content(
    records,
    output_file,
    window_size,
    step_size
):
    """Calculate GC content independently for each contig."""

    number_of_windows = 0

    with open(output_file, "w") as output:

        for seqid, sequence in records:
            contig_length = len(sequence)

            if contig_length < window_size:
                gc = calculate_gc(sequence)

                output.write(
                    f"{seqid} 0 {contig_length} {gc:.4f}\n"
                )

                number_of_windows += 1
                continue

            for start in range(
                0,
                contig_length - window_size + 1,
                step_size
            ):
                end = start + window_size
                window = sequence[start:end]
                gc = calculate_gc(window)

                output.write(
                    f"{seqid} {start} {end} {gc:.4f}\n"
                )

                number_of_windows += 1

    return number_of_windows


def write_annotation_tracks(
    gff_file,
    selected_contigs,
    cds_forward_file,
    cds_reverse_file,
    rrna_file,
    trna_file
):
    """Extract CDS, rRNA and tRNA features from the Prokka GFF file."""

    feature_counts = {
        "CDS_forward": 0,
        "CDS_reverse": 0,
        "rRNA": 0,
        "tRNA": 0
    }

    with open(gff_file) as gff, \
         open(cds_forward_file, "w") as cds_forward, \
         open(cds_reverse_file, "w") as cds_reverse, \
         open(rrna_file, "w") as rrna, \
         open(trna_file, "w") as trna:

        for line in gff:
            if line.startswith("#"):
                continue

            fields = line.rstrip("\n").split("\t")

            if len(fields) < 9:
                continue

            seqid = fields[0]

            if seqid not in selected_contigs:
                continue

            feature = fields[2]

            try:
                start = int(fields[3]) - 1
                end = int(fields[4])
            except ValueError:
                continue

            strand = fields[6]

            if start < 0:
                start = 0

            if end > selected_contigs[seqid]:
                end = selected_contigs[seqid]

            if start >= end:
                continue

            circos_line = f"{seqid} {start} {end}\n"

            if feature == "CDS":

                if strand == "+":
                    cds_forward.write(circos_line)
                    feature_counts["CDS_forward"] += 1

                elif strand == "-":
                    cds_reverse.write(circos_line)
                    feature_counts["CDS_reverse"] += 1

            elif feature == "rRNA":
                rrna.write(circos_line)
                feature_counts["rRNA"] += 1

            elif feature == "tRNA":
                trna.write(circos_line)
                feature_counts["tRNA"] += 1

    return feature_counts


def write_summary(
    all_records,
    selected_records,
    feature_counts,
    number_of_gc_windows,
    min_contig_length,
    max_contigs,
    output_file
):
    """Write a summary of the sequences represented in Circos."""

    total_assembly_size = sum(
        len(sequence) for _, sequence in all_records
    )

    represented_assembly_size = sum(
        len(sequence) for _, sequence in selected_records
    )

    excluded_contigs = len(all_records) - len(selected_records)

    with open(output_file, "w") as output:
        output.write("metric\tvalue\n")
        output.write(f"total_assembly_contigs\t{len(all_records)}\n")
        output.write(f"total_assembly_size_bp\t{total_assembly_size}\n")
        output.write(f"represented_contigs\t{len(selected_records)}\n")
        output.write(
            f"represented_assembly_size_bp\t"
            f"{represented_assembly_size}\n"
        )
        output.write(f"excluded_contigs\t{excluded_contigs}\n")
        output.write(
            f"minimum_contig_length_bp\t{min_contig_length}\n"
        )
        output.write(f"maximum_contigs\t{max_contigs}\n")
        output.write(f"gc_windows\t{number_of_gc_windows}\n")

        for feature, count in feature_counts.items():
            output.write(f"{feature}\t{count}\n")


def main():

    parser = argparse.ArgumentParser(
        description=(
            "Prepare Circos files from a bacterial assembly "
            "and a Prokka GFF annotation."
        )
    )

    parser.add_argument("--fasta", required=True)
    parser.add_argument("--gff", required=True)
    parser.add_argument("--outdir", required=True)

    parser.add_argument(
        "--min-contig-length",
        type=int,
        default=10000
    )

    parser.add_argument(
        "--max-contigs",
        type=int,
        default=50
    )

    parser.add_argument(
        "--gc-window-size",
        type=int,
        default=5000
    )

    parser.add_argument(
        "--gc-step-size",
        type=int,
        default=1000
    )

    args = parser.parse_args()

    if args.min_contig_length < 1:
        raise ValueError(
            "The minimum contig length must be greater than zero."
        )

    if args.max_contigs < 0:
        raise ValueError(
            "The maximum number of contigs cannot be negative."
        )

    if args.gc_window_size < 1:
        raise ValueError(
            "The GC window size must be greater than zero."
        )

    if args.gc_step_size < 1:
        raise ValueError(
            "The GC step size must be greater than zero."
        )

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    all_records = read_fasta(args.fasta)

    selected_records = select_contigs(
        all_records,
        args.min_contig_length,
        args.max_contigs
    )

    if not selected_records:
        raise ValueError(
            "No contigs passed the configured selection criteria."
        )

    selected_contigs = {
        seqid: len(sequence)
        for seqid, sequence in selected_records
    }

    write_karyotype(
        selected_records,
        outdir / "karyotype.txt"
    )

    number_of_gc_windows = write_gc_content(
        selected_records,
        outdir / "gc_content.txt",
        args.gc_window_size,
        args.gc_step_size
    )

    feature_counts = write_annotation_tracks(
        args.gff,
        selected_contigs,
        outdir / "cds_forward.txt",
        outdir / "cds_reverse.txt",
        outdir / "rrna.txt",
        outdir / "trna.txt"
    )

    write_summary(
        all_records,
        selected_records,
        feature_counts,
        number_of_gc_windows,
        args.min_contig_length,
        args.max_contigs,
        outdir / "contig_summary.tsv"
    )

    print(f"Assembly: {args.fasta}")
    print(f"Annotation: {args.gff}")
    print(f"Total contigs: {len(all_records)}")
    print(f"Represented contigs: {len(selected_records)}")
    print(f"Output directory: {outdir}")


if __name__ == "__main__":
    main()