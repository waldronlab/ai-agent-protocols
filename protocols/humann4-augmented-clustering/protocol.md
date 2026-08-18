---
name: humann4-augmented-clustering
description: Predict ORFs and perform augmented UniRef-compatible protein clustering.
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
date: 2026-08-08
status: draft
license: CC-BY-4.0
type: atomic

protocol_doi: ~
repository_doi: ~
publication_doi: ~

citation: "10.1016/j.cell.2019.01.001"

upstream_repositories:
  - "https://github.com/biobakery/humann"
  - "https://github.com/biobakery/metaphlan"

database_urls:
  - "http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/"
  - "ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/"

protocols_used: []
key_packages: []
category: metagenomics
tags: [humann, chocophlan, database, uniref, clustering, mmseqs2, diamond]
---

# HUMAnN 4 Augmented Protein Clustering

This protocol outlines how to process the representative genomes for MetaPhlAn 4.2 SGBs to predict proteins and cluster them in compatibility with the UniRef90/UniRef50 ontologies.

## Materials

- **Software & Repositories:**
  - `Prodigal` ([hyattpd/Prodigal](https://github.com/hyattpd/Prodigal)) — Fast prokaryotic gene recognition and ORF prediction.
  - `DIAMOND` ([bbuchfink/diamond](https://github.com/bbuchfink/diamond)) — Accelerated protein alignment against UniRef.
  - `MMseqs2` ([soedinglab/MMseqs2](https://github.com/soedinglab/MMseqs2)) — Ultra-fast de novo protein clustering.
  - `humann` ([biobakery/humann](https://github.com/biobakery/humann)) — Upstream database utilities and configurations.
- **Databases & Reference Data:**
  - Previous UniRef Database Builds ([HUMAnN Data Server](http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/)) — Baseline UniRef50/UniRef90 releases used in HUMAnN 3.
  - UniProt UniRef Releases ([UniProt FTP](ftp://ftp.uniprot.org/pub/databases/uniprot/uniref/)) — Official UniRef90 and UniRef50 FASTA releases.

## Steps

### Step 1: Open Reading Frame (ORF) Prediction

Run `Prodigal` on all representative SGB genomes (as output by `humann4-sgb-aggregation`) to predict ORFs. Extract both the nucleotide and translated amino acid sequences.

### Step 2: Intermediate UniRef Alignment

Use `DIAMOND` to align all predicted protein sequences against the standard `UniRef90` and `UniRef50` databases.

For any ORF that matches an existing UniRef90 cluster (meeting the minimum thresholds of ≥90% identity and ≥80% coverage), assign it to that established cluster.

### Step 3: De Novo Clustering of Unmapped ORFs

For ORFs that fail to map to standard UniRef clusters, perform *de novo* clustering using `MMseqs2`. Cluster these sequences at a 90% identity threshold to create novel protein families.

Name these newly generated clusters using the convention: `SGB_Ref90_XXXX` (where XXXX is a unique identifier).

### Step 4: Generate ORF Mapping File

Compile a comprehensive TSV mapping file linking every original ORF ID (from all SGBs) to its assigned `UniRef90` ID or its novel `SGB_Ref90` ID.

## Notes

- **HPC Cluster Scalability:** Predicting ORFs and performing all-against-UniRef alignment across millions of SGB genes requires high-memory cluster nodes and multi-threaded MMseqs2/DIAMOND jobs.
- This protocol bridges the gap between characterized UniProt proteins and novel ORFs discovered via large-scale MAG assembly in MetaPhlAn 4.2.


