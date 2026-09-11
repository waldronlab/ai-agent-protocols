---
name: humann4-utility-mapping
description: Generate HUMAnN 4 utility mapping databases for functional annotation.
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
  - "https://github.com/eggnogdb/eggnog-mapper"

database_urls:
  - "http://huttenhower.sph.harvard.edu/humann_data/mapping/"
  - "http://huttenhower.sph.harvard.edu/humann_data/legacy_dbs/"

protocols_used: []
key_packages: []
category: metagenomics
tags: [humann, database, functional-annotation, eggnog-mapper, uniprot]
---

# HUMAnN 4 Utility Mapping Generation

This protocol outlines the generation of the TSV mapping files used by HUMAnN 4 to translate protein cluster abundances into functional ontology abundances (e.g. KEGG Orthology, GO terms, EC numbers).

## Materials

- **Software & Repositories:**
  - `eggNOG-mapper` ([eggnogdb/eggnog-mapper](https://github.com/eggnogdb/eggnog-mapper)) — Fast functional annotation and orthology assignment.
  - `humann` ([biobakery/humann](https://github.com/biobakery/humann)) — Downstream regrouping/renaming utilities (`humann_regroup_table`, `humann_rename_table`).
- **Databases & Reference Data:**
  - Previous Utility Mapping Databases ([HUMAnN Data Server](http://huttenhower.sph.harvard.edu/humann_data/mapping/)) — Baseline mapping TSVs used in HUMAnN 3 (mapping UniRef50/UniRef90 to KO, EC, GO, Pfam, MetaCyc).
  - UniProtKB Complete Knowledgebase XML ([UniProt FTP](ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/)) — Source annotations for standard UniRef clusters.

## Steps

### Step 1: Standard Cluster Annotation via Lookup

Parse the UniProtKB XML to extract functional annotations (GO, KEGG KO, Pfam, EC, and EggNOG) for all standard UniRef90 clusters.
Direct execution of InterProScan is avoided here due to computational complexity; mappings are derived directly from the pre-computed cross-references in UniProt.

### Step 2: Primary Orthology Generation for Novel Clusters

Deploy `eggNOG-mapper` on the representative sequences of the novel `SGB_Ref90` clusters.
This provides automated mapping to KEGG Orthology (KO), KEGG BRITE, COGs, and GO categories based on orthologous group placement.

### Step 3: Targeted Biochemical Annotation (Optional)

If highly specific biochemical annotation is required, deploy targeted pipelines (such as `dbCAN2` for carbohydrate-active enzymes, or `antiSMASH` for biosynthetic gene clusters) on the novel SGB sequence catalogs.

### Step 4: Compile HUMAnN Mapping TSVs

Combine the parsed UniProt annotations (Step 1) with the eggNOG-mapper predictions (Step 2/3) into the unified TSV format required by HUMAnN.
Generate separate mapping files for each ontology (e.g. `map_uniref90_to_ko.txt`, `map_uniref90_to_ec.txt`), seamlessly integrating both standard and novel clusters.

## Notes

- **Integration with bioBakery:** This is the final step in the HUMAnN 4 database generation workflow. The resulting TSV tables are placed in the HUMAnN utility mapping directory (`humann_config --update database_folders utility_mapping <path>`) and are utilized by downstream utilities like `humann_regroup_table`.

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
