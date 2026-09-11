---
name: humann4-database-build
description: End-to-end composite pipeline for constructing HUMAnN 4 reference databases from MetaPhlAn 4.2 SGBs.
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
date: 2026-08-18
status: draft
license: CC-BY-4.0
type: composite

protocol_doi: ~
repository_doi: ~
publication_doi: ~

citation: "10.7554/eLife.65088"

upstream_repositories:
  - "https://github.com/biobakery/humann"
  - "https://github.com/biobakery/metaphlan"
  - "https://github.com/biobakery/biobakery-nextflow"

database_urls:
  - "http://huttenhower.sph.harvard.edu/humann_data/chocophlan/"
  - "http://huttenhower.sph.harvard.edu/humann_data/uniprot/uniref_annotated/"
  - "http://huttenhower.sph.harvard.edu/humann_data/mapping/"

protocols_used:
  - name: humann4-sgb-aggregation
    repository: waldronlab/agent-protocol-standard
    version: 1.0.0
  - name: humann4-augmented-clustering
    repository: waldronlab/agent-protocol-standard
    version: 1.0.0
  - name: humann4-chocophlan-build
    repository: waldronlab/agent-protocol-standard
    version: 1.0.0
  - name: humann4-translated-search-build
    repository: waldronlab/agent-protocol-standard
    version: 1.0.0
  - name: humann4-utility-mapping
    repository: waldronlab/agent-protocol-standard
    version: 1.0.0

key_packages: []
category: metagenomics
tags: [humann, chocophlan, database, pipeline, composite]
---

# HUMAnN 4 Reference Database Construction Pipeline

This composite protocol coordinates the complete end-to-end generation of reference databases required by HUMAnN 4, incorporating Species-level Genome Bins (SGBs) from MetaPhlAn 4.2.

## Materials

- **Software & Repositories:**
  - `humann` ([biobakery/humann](https://github.com/biobakery/humann)) — Downstream functional profiler and database management commands.
  - `metaphlan` ([biobakery/metaphlan](https://github.com/biobakery/metaphlan)) — Species-level genome bin taxonomy definitions.
- **Databases & Baseline Reference Data:**
  - HUMAnN 3 Reference Data Archive ([HUMAnN Server](http://huttenhower.sph.harvard.edu/humann_data/)) — Previous versions of ChocoPhlAn, UniRef DIAMOND indexes, and utility mappings.

## Steps

This composite workflow executes five constituent atomic protocols in sequence:

### Step 1: SGB Genome Aggregation & Subsampling
Execute `humann4-sgb-aggregation` to retrieve representative isolate genomes and MAGs for all MetaPhlAn 4.2 SGBs, subsampling overrepresented SGBs (max 100 genomes) via Mash distance.

### Step 2: Augmented UniRef Protein Clustering
Execute `humann4-augmented-clustering` to predict ORFs with Prodigal, map known sequences to UniRef90/UniRef50 via DIAMOND, and cluster novel unmapped ORFs into `SGB_Ref90_XXXX` families using MMseqs2.

### Step 3: ChocoPhlAn Nucleotide Pangenome Database Build
Execute `humann4-chocophlan-build` to extract representative nucleotide sequences for each SGB pan-proteome and compile SGB-specific Bowtie2 indexes.

### Step 4: Translated Search Database Build
Execute `humann4-translated-search-build` to combine official UniRef90 with novel SGB clusters and generate the comprehensive DIAMOND index (`augmented_uniref90.dmnd`).

### Step 5: Functional Utility Mapping Compilation
Execute `humann4-utility-mapping` to extract UniProtKB annotations for standard clusters, generate eggNOG-mapper orthology/pathway predictions for novel SGB clusters, and compile unified TSV cross-reference mapping tables (KO, EC, GO, Pfam, MetaCyc).

## Notes

- **HPC Execution:** This end-to-end workflow is designed for high-performance computing clusters with SLURM/PBS orchestration or workflow engines (e.g., Snakemake/Nextflow).
- **Provenance & Citations:** Executing this composite pipeline incorporates primary literature methodology citations from Pasolli et al. (2019) (*Cell*) and Beghini et al. (2021) (*eLife*).

## History & Reviews
<!-- Newest versions at the top -->

### Version 1.0.0 (2026-08-18)

#### Changes
- Initial protocol creation.

#### Reviews

**Review by Curtis Huttenhower**
- **Date:** 2026-08-18
- **Status:** `approved`
- **Notes:** Reviewed briefly. It seemed correct but light on detail. Suggested adding detail to the section "### Step 1: SGB Genome Aggregation & Subsampling".

**Review by Eric Franzosa**
- **Date:** 2026-08-18
- **Status:** `approved`
- **Notes:** Reviewed briefly. It seemed correct but light on detail. Suggested adding detail to the section "### Step 1: SGB Genome Aggregation & Subsampling".
