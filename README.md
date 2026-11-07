# RTV-Net implementation package

A runnable PyTorch implementation of the **proposed** reliability-guided trend–variation network for plant electrical signals. Source files contain numbered steps explaining preparation, feature encoding, reliability estimation, training and evaluation.

**Start here:** Read `START\_HERE.md` for the shortest setup path.

This archive contains working code and an engineering demo, not trained disease-detection weights or experimental validation. No manuscript accuracy, latency or parameter placeholder is hard-coded. Actual values are written by the program. 



Changes in version 0.2.1

The final update adds location-independent demo launchers, `--version`, a concise start guide and corrected example output paths. See CHANGELOG.md for input validation, portable checkpoint binding, run-overwrite protection, command-line preparation settings and corrected explanation plots.

## 1\. Install

Python 3.10 or later is required. Internet access is needed once to install dependencies; dependency binaries are not inside the ZIP.

```bash
python -m venv .venv
# Linux/macOS:
source .venv/bin/activate
# Windows PowerShell instead:
# .venv\\Scripts\\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -e .
```

For a CPU-only PyTorch installation, install torch from https://download.pytorch.org/whl/cpu first, then run the editable-install command. Choose a CUDA build separately if needed; the default commands use CPU.

## 2\. Run the complete engineering smoke demo

From the extracted `RTVNet` directory:

```bash
python scripts/quickstart.py
python -m unittest discover -s tests -v
```

Each smoke run writes to a fresh timestamped directory, so rerunning the script does not mix earlier models or results. The script generates synthetic electrical observations, prepares windows, trains all four module configurations for two epochs on one outer fold, exports a model explanation and measures inference time. This is intentionally a short execution check. The outputs say `synthetic: true` and `complete\_outer\_cv: false`; they must not be used as research results.

A complete outer-fold demo (still synthetic) uses a fresh directory; the shipped `runs/full\_demo` contains validated examples:

```bash
python -m rtvnet train --data data/demo/windows.npz --out runs/my\_full\_demo --epochs 3 --seeds 11
python -m rtvnet robustness --data data/demo/windows.npz --run runs/my\_full\_demo --out runs/my\_full\_demo/robustness --repeats 1
```

For actual experiments, use the default 200-epoch upper limit, early stopping, five seeds and 20 robustness repetitions. An epoch limit is a budget, not a claim that every run uses that many epochs.

## 3\. Audit the supplied public dataset

Keep the original `DATASET\_ElectricalSignaling-in-tomato-for-detect-P.zip` downloaded from https://data.mendeley.com/datasets/yr8zhsc6mh/1. It is not duplicated inside this code ZIP.

```bash
python -m rtvnet audit --archive /path/to/DATASET\_ElectricalSignaling-in-tomato-for-detect-P.zip --out data/source\_audit
```

The package already contains an audit of the supplied archive: 789 CSV files, six XLSX workbooks, worksheet dimensions, candidate annotation rows and SHA-256 checksums. The audit is NOT a verified biological mapping. Exact file duplicates are identified; shifted, combined or transformed worksheet duplicates require manual provenance review.

Review `data/source\_audit/mapping\_template.json`. Fill it using the inventory and biological acquisition records. In particular:

1. Establish which electrodes belong to each plant.
2. Establish whether a plant reappears across sessions/experiments.
3. Confirm substrate, source label convention, timestamp units and any clock offsets.
4. Select only one numerical representation of each recording; never add combined/averaged copies as new data.
5. Exclude reference and environmental channels.
6. Record the reviewer and set `verified` to true ONLY after these checks.

A cable is not automatically a plant. Source healthy=1/infected=0 labels must be converted to target healthy=0/inoculated=1 in the mapping. The current files do not justify inventing plant IDs or assuming A/B/C are independent biological replicates. Contact the data authors if provenance cannot be established.

### Mapping formats

All spreadsheet coordinates are **1-based**. Source ZIP members must match exact inventory paths.

* `annotated\_rows`: `sheet`, `time\_row`, `first\_value\_column`, optional `last\_value\_column`; each channel has `row`, `plant\_id`, `electrode\_id`, target `label`, and `substrate`.
* `triplet\_sheet`: `sheet`, optional `first\_row`; each channel has numeric `channel`, plant identity, electrode identity, target label, and substrate.
* `triplet\_csv`: tab/whitespace-separated channel–time–voltage triplets with the same channel mapping.

`voltage\_unit` must be `V` or `mV` (converted to volts). `time\_unit` is `seconds` or `excel\_days` (multiplied by 86400). `time\_origin\_s` is an explicit reviewed offset. For fragmented CSV files with resetting clocks, assign a reviewed offset for EACH source; do not assume filenames supply a complete clock reconstruction.

The annotated-row format may contain cleaned or shifted data. Confirm whether raw triplet sheets are preferable, and document any source processing that remains. Do not describe processed worksheet values as untouched raw measurements.

```bash
python -m rtvnet export --archive /path/to/dataset.zip --mapping data/reviewed\_mapping.json --out data/tomato\_long.csv
python -m rtvnet prepare --csv data/tomato\_long.csv --manifest data/tomato\_long.csv.manifest.json --out data/tomato\_windows.npz
```

Alternatively supply an independently reviewed CSV with columns:

```text
plant\_id,session\_id,electrode\_id,time\_s,voltage\_v,label,substrate
```

Times are seconds; voltages are volts. Identical measurements are deduplicated; conflicting duplicate voltages fail. The manifest must contain `verified: true`, `synthetic: false`, a nonempty `reviewed\_by`, and provenance notes. This is an explicit user review, not an automatic guarantee of label validity.

## 4\. Understand preparation

Implemented defaults are documented in `configs/defaults.json`; this is a documentation snapshot, not an automatically loaded configuration file.

* 240 s grid; 4 h windows; 2 h stride; 60 time positions.
* Actual observations map to nearest grid centres within half a grid interval. If multiple observations map to one bin, the closest is retained.
* Derivatives are computed on ORIGINAL adjacent observations, in volts/hour, before alignment. They never cross a window boundary or a gap longer than 480 s.
* Short-gap fills are stored for export but remain masked and do not contribute as measurements. The network suppresses unsupported inputs.
* At least 70% observation coverage per electrode, and at least two eligible electrodes per clean window.
* Quality vector: observed fraction, longest missing run / window length, dropout-run count per hour.
* Global voltage and derivative scalers and per-quality-descriptor scalers are fitted only on training windows. Overlapping training windows repeat samples in the scaler fit; document this window-weighted convention. Validation/test data never enter the fit.
* Variable electrode counts are padded with unavailable channels. Shared processing and masked fusion support this padding.

Preparation settings are available directly in the CLI, for example `--grid 240 --window 14400 --stride 7200 --max-gap 480 --coverage 0.70 --min-electrodes 2`. They can also be changed through `rtvnet.data.prepare(...)` keyword arguments. If changing settings, regenerate windows and rerun every configuration on identical splits.

## 5\. Train the proposed method

```bash
python -m rtvnet train --data data/tomato\_windows.npz --out runs/tomato/rtvnet
```

The selected protocol requires at least THREE verified plants per class. It fails if this is not feasible. Outer evaluation leaves one plant out. Inner validation reserves one plant from each class; remaining plants form training. Substrate matching is preferred, not guaranteed. The fixed split manifest is exported, allowing review before claims about generalisation.

Defaults: Adam, learning rate 0.001, batch size 16, 200 maximum epochs, LR patience 10, LR factor 0.5, LR floor 0.00001, early-stopping patience 25, seeds 11/22/33/44/55. Training resampling gives equal expected contribution to each plant. Validation loss is averaged equally across validation plants. Test plants are not used for early stopping.

Metrics: per-seed pooled out-of-fold plant predictions, fixed 0.5 threshold; window probabilities -> equal-weight session means -> equal-weight plant session means. Each seed's metrics are retained and averaged; seeds are NOT merged as if independent plants. Class-stratified bootstrap resamples plants, not windows, for conditional 95% intervals. These intervals do not include uncertainty from collecting new experimental batches or retraining the entire pipeline. Single-class partial runs leave balanced accuracy and undefined sensitivity/specificity as null.

### Architecture switches and ablation

```bash
python -m rtvnet ablate --data data/tomato\_windows.npz --out runs/tomato\_ablation
python -m rtvnet report --runs runs/tomato\_ablation --out runs/tomato\_ablation/results.csv
```

Variants:

|CLI name|TVEM|ERFM|Electrode aggregation|
|-|-|-|-|
|backbone|off|off|Mean electrode probabilities|
|tvem\_only|on|off|Mean electrode probabilities|
|erfm\_only|off|on|Feature/quality-conditioned fusion|
|rtvnet|on|on|Feature/quality-conditioned fusion|

`backbone` is our shared-electrode **LITEMV-inspired adaptation**, not a claim to reproduce original multivariate LITEMV exactly. Use the untouched official implementation in `vendor/LITE-original.zip` for a separate faithful LITEMV competitor. Other competitors such as MiniRocket, ModernTCN and InceptionTime are not reimplemented here; integrate their official code with the exported grouped splits. This package implements RTV-Net and its component ablations.

Widths can be selected with `--branch-width`, `--width` and `--hidden`. Existing nonempty output directories are refused unless `--overwrite` is supplied. Overwrite requires a recognised RTV-Net run and removes its prior seed checkpoints and standard derived outputs before training; use a new output directory to preserve earlier work. Default branch width=8, backbone width=16, reliability hidden width=8. Fixed pattern filters follow the supplied reference filter construction, including scales larger than the 60-position input (SAME padding). Validate kernel scales on training/validation plants if changing this design. The model uses symmetric temporal context and is an offline window classifier, not a causal early-warning model.

## 6\. Inspect results

Each training directory contains:

* `run\_config.json`: settings, environment and synthetic/complete-CV status.
* `splits.json`: actual training/validation/test plant IDs and window indices.
* `seed\_\*/fold\_\*/best.pt`: validation-selected state dictionary and scalers.
* `history.csv`: loss per epoch.
* `window\_predictions.csv`: held-out predictions with plant/session/fold/seed.
* `plants\_seed\_\*.csv`: aggregated plant probabilities.
* `summary.json`: measured metrics and plant bootstrap intervals for complete CV.

Never substitute the previous manuscript's numerical placeholders for these outputs. Default architecture parameter counts differ from the manuscript draft: the smoke check found **8,867** RTV-Net trainable parameters. Real latency depends on hardware/software and scope; inspect the benchmark JSON rather than claiming 1.12 ms.

## 7\. Prediction and explanation

Use a checkpoint path from your run:

```bash
python -m rtvnet infer --data data/tomato\_windows.npz --checkpoint runs/tomato/rtvnet/seed\_11/fold\_0/best.pt --out runs/predictions.csv
python -m rtvnet explain --data data/tomato\_windows.npz --checkpoint runs/tomato/rtvnet/seed\_11/fold\_0/best.pt --out runs/explanation
```

General `infer` is not an independent-test claim. It checks saved preparation dimensions and includes a `usable` flag; unavailable predictions are not assigned a disease class. Explanation and robustness commands additionally bind checkpoints to a portable fingerprint of the training/evaluation arrays and plant identities. This rejects accidental use of a different dataset with familiar plant names. Old 0.1 checkpoints need retraining for these commands; replacement demo checkpoints are included. `explain` selects a held-out window for that checkpoint, unless an explicit held-out `--window-index` is given. It plots raw potentials, RMS feature magnitude and model weights. The response scale is the 99th percentile of VALID TRAINING feature magnitudes, then clipped to \[0,1]. This is activation magnitude, not Grad-CAM or causal attribution. Synthetic data are visibly labelled. Missing response cells are grey, weights use step plots, and all three temporal axes have the same physical width. No predetermined weight reduction or class response is imposed by the explanation code.

ERFM logits are window-level. Weights change within a window ONLY if availability changes. Across windows the logits can vary. Do not present arbitrary continuously varying weights as outputs of this implementation. Quality features describe completeness, not independently measured electrode-contact health.

## 8\. Controlled robustness

```bash
python -m rtvnet robustness --data data/tomato\_windows.npz --run runs/tomato/rtvnet --out runs/tomato/robustness --repeats 20
```

This command reloads the canonical original-observation CSV and perturbs only held-out windows. If the files were moved, supply `--raw-csv /new/path/tomato\_long.csv`. It verifies that unperturbed reconstruction reproduces the prepared input before adding corruptions.

Missing fractions: 0, .05, .10, .20, .30, .40. Noise ratios: 0, .25, .5, 1, 1.5, 2. One electrode is chosen uniformly per window; Gaussian noise is proportional to that electrode's original standard deviation. All derivatives are recomputed AFTER corruption. Completeness descriptors remain unchanged under additive noise. Corruption seeds are identical across variants. Clean window membership remains fixed; individual windows with no available data are counted as failures. A repetition containing failures does not receive a survivor-only accuracy.

Output includes `robustness\_predictions.csv`, protocol metadata, summary CSV and PNG/PDF plots from actual predictions. The plot error bars show variation across seeds/repetitions, not a plant confidence interval. Run separately for each model/ablation and compare their exported summaries.

## 9\. Benchmark

```bash
python -m rtvnet benchmark --data data/tomato\_windows.npz --checkpoint runs/tomato/rtvnet/seed\_11/fold\_0/best.pt --out runs/benchmark.json
```

One CPU thread, batch size one, 100 warm-ups and 1,000 repetitions. It includes training-fitted scaling, tensor conversion, feature extraction and classification of an already prepared window. It EXCLUDES file parsing, temporal resampling and raw-time differentiation. Report that scope explicitly; this is not acquisition-to-decision latency. Actual input shape, trainable parameters, CPU/platform and package versions are recorded. Compare competitors on identical dimensions and scope. Override repetition counts only for smoke tests.

## 10\. Tests and implementation details

```bash
python -m unittest discover -s tests -v
```

Tests check electrode permutation invariance, independence from values in missing positions, all-missing handling, weight normalisation, backpropagation, frozen kernels, all ablation paths, group separation, training-only scaling, data-adapter units and original-observation reconstruction.

This implementation uses BatchNorm in temporal blocks. Normalisation statistics include zero-filled positions; it is not a masked-normalisation layer. The frozen filter bank is adapted from original LITEMV. The program does not implement the manuscript's unverified numerical claims, guarantee disease detection, or supply disease-trained weights.

## Files

* `src/rtvnet/model.py`: TVEM, adapted backbone, ERFM and classifier.
* `data.py`: alignment, derivatives, masks, quality descriptors and scaling.
* `adapters.py`: ZIP audit and reviewed mapping export.
* `splits.py`: nested plant grouping.
* `engine.py`: optimisation, aggregation, inference and timing.
* `robustness.py`: corruption of original observations and reconstruction.
* `plots.py`: figures from actual outputs.
* `demo.py`: synthetic fixture generator.
* `\_\_main\_\_.py`: step-by-step CLI.
* `scripts/quickstart.py`: runnable smoke workflow.
* `tests/`: verification suite.
* `vendor/LITE-original.zip`: unchanged source supplied by the user.
* `THIRD\_PARTY\_NOTICES.md`: attribution and research references.
* `VALIDATION.md`: execution results from this package build.
* `START\_HERE.md`: concise installation and execution steps.
* `CHANGELOG.md`: revision history.

## Licensing

GPL-3.0, following the supplied LITE source and adapted fixed-filter construction. See LICENSE and THIRD\_PARTY\_NOTICES.md. The public dataset is separately licensed; download and cite it at its original repository. Installed libraries have their own licences.

