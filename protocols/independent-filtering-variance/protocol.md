---
name: "independent-filtering-variance"
description: "Filter high-throughput features by overall variance or mean across all samples before a separately specified downstream analysis."
version: "1.2.1"
authors:
  - name: "Otto Infield-Harm"
  - name: "Levi Waldron"
    orcid: "0000-0003-2725-0694"
date: "2026-09-03"
status: "draft"
type: "atomic"
license: "CC-BY-4.0"
publication_doi: "10.1073/pnas.0914005107"
citation: "20460310"
protocols_used: []
category: "Statistical Analysis"
tags: [filtering, variance, mean, high-throughput]
---

# Independent Filtering by Overall Variance or Mean
This protocol removes a prespecified fraction of features with the lowest overall variance or overall mean across all samples before a separately specified downstream analysis. The selected filter is calculated without using sample-class labels or any other outcome information.

## Materials
- **Input data**
  - A feature-by-sample measurement matrix with one row per feature and one column per sample.
  - Measurements must be on a scale for which comparing the selected feature summary is meaningful. Any required normalization or transformation must be completed before filtering.
- **Parameters**
  - `filter`: either `variance` or `mean`. Select exactly one; these are alternative filters and must not be applied sequentially.
  - `theta`: the fraction of features with the lowest value of the selected summary to remove. `theta` must be between 0 and 1. The default for this protocol is 0.5.

## Steps

### Step 1: Confirm the input matrix and filter choice
Verify that each feature is represented by one row and each sample by one column. Confirm that the measurements have undergone all required quality control, normalization, and transformation steps before calculating the selected summary.

Do not use sample labels, group assignments, outcomes, or preliminary test statistics to determine which features pass the filter.

Select either the variance filter or the mean filter before evaluating downstream results. Record the selected filter and `theta`.

### Step 2: Calculate the selected overall feature summary
Use all sample columns in the calculation, regardless of class or experimental group.

#### Variance filter
For every feature, calculate the sample variance across all available samples. Use the usual unbiased denominator: one fewer than the number of non-missing measurements for that feature.

#### Mean filter
For every feature, calculate the arithmetic mean across all available samples. The mean is calculated across the same sample set used for the analysis, without separating or weighting samples by class.

Record the number of measurements used for each feature. A feature with insufficient non-missing measurements to calculate the selected summary must not be treated as a low-summary feature; handle it according to the study's missing-data policy and record its exclusion.

### Step 3: Set the filter cutoff
Let `n_eligible` be the number of eligible features and set `m = floor(theta * n_eligible)`. If `m = 0`, remove no features and define no cutoff. If `m > 0`, rank eligible features from lowest to highest summary value, using a prespecified deterministic tie-breaker such as feature identifier, and remove the first `m` features. Define the cutoff as the largest summary value among the removed features. With the default `theta = 0.5`, `m = floor(0.5 * n_eligible)` eligible features are removed.

Record the tie-breaker, `n_eligible`, `m`, the cutoff when one exists, and the resulting number of retained and removed features. Do not silently change `theta` because of tied summary values.

### Step 4: Retain features passing the filter
Remove the features selected by the cutoff and retain the remaining feature rows with their sample measurements unchanged. Preserve feature identifiers and the mapping of retained features to the original input matrix.

The output of this protocol is the filtered feature-by-sample matrix and a table documenting each feature's selected summary value, missing-value count, filter decision, selected filter, `theta`, cutoff, and tie-handling outcome.

### Step 5: Pass the filtered data to a separate analysis
Use the retained feature set as input to a downstream analysis that is specified independently. This protocol does not define or perform hypothesis testing, p-value calculation, multiple-testing adjustment, differential-expression analysis, or interpretation of discoveries.

## Notes
The paper associated with this protocol describes both overall variance filtering and overall mean filtering as independent-filtering strategies for high-throughput experiments. A label-agnostic filter is necessary but does not, by itself, guarantee statistical independence from a later test statistic. The paper's validity results depend on the data-generating assumptions and the particular filter/test-statistic pair; therefore, the downstream analyst must assess those requirements separately.

In the paper's microarray example, overall variance filtering increased discoveries when followed by a standard test, whereas overall mean filtering was less effective, particularly when larger fractions of features were removed. These are dataset-specific empirical results, not a universal ranking of methods or a guarantee of improved performance. Select the filter and `theta` before evaluating downstream results, and document both choices.

This protocol covers only the filtering operation. Any downstream testing or multiple-testing adjustment must be specified and justified separately.
