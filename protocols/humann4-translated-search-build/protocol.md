---
name: humann4-translated-search-build
description: Compile the HUMAnN 4 translated search database.
version: 1.0.0
authors:
  - name: Levi Waldron
    orcid: 0000-0003-2725-0694
reviews:
  - name: Curtis Huttenhower
    date: 2026-08-18
    protocol_version: 1.0.0
    status: approved
  - name: Eric Franzosa
    date: 2026-08-18
    protocol_version: 1.0.0
    status: approved
date: 2026-08-08
status: draft
license: CC-BY-4.0
type: atomic

protocol_doi: ~
repository_doi: ~
publication_doi: ~

citation: "10.7554/eLife.65088"

upstream_repositories:
  - "https://github.com/biobakery/humann"

database_urls:
  - "http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/"

protocols_used: []
key_packages: []
category: metagenomics
tags: [humann, database, translated-search, diamond, uniref]
---

# HUMAnN 4 Translated Search Build

This protocol compiles the comprehensive translated search database utilized by HUMAnN 4 for alignment of reads that fail to map during the nucleotide pangenome search.

## Materials

- **Software & Repositories:**
  - `DIAMOND` ([bbuchfink/diamond](https://github.com/bbuchfink/diamond)) — High-throughput translated DNA/protein aligner.
  - `humann` ([biobakery/humann](https://github.com/biobakery/humann)) — Primary consumer and configuration scripts.
- **Databases & Reference Data:**
  - Previous UniRef DIAMOND Databases ([HUMAnN Data Server](http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/)) — Pre-indexed DIAMOND reference databases for HUMAnN 3 (`uniref90_diamond`, `uniref50_diamond`).

## Steps

### Step 1: Database Concatenation

Merge the official UniRef90 FASTA database with the newly generated FASTA containing representative sequences of all novel `SGB_Ref90` clusters. 

This results in a single, comprehensive protein database encompassing both characterized UniProt sequences and novel MetaPhlAn 4.2 SGB ORFs.

### Step 2: DIAMOND Indexing

Build a `DIAMOND` index (e.g., `augmented_uniref90.dmnd`) from the merged FASTA file. 

## Notes

- **Fallback Translated Search:** This database serves as the fallback translated search target in the HUMAnN pipeline, allowing functional profiling of reads that do not map to the specific ChocoPhlAn pangenomes of identified species.
- Configured in HUMAnN via `humann_config --update database_folders protein <path>`.

## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-08-08)

#### Changes
- Initial protocol creation.

#### Reviews

**Review by Curtis Huttenhower**
- **Date:** 2026-08-18
- **Status:** `approved`
- **Notes:** Reviewed briefly. It seemed correct but light on detail.

**Review by Eric Franzosa**
- **Date:** 2026-08-18
- **Status:** `approved`
- **Notes:** Reviewed briefly. It seemed correct but light on detail.
