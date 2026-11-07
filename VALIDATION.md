# Validation of this implementation

These are software checks using synthetic engineering inputs, not tomato disease experiments.

- 20 unit tests passed: model masking and normalisation, all-missing failure handling, frozen filters/backpropagation, electrode permutation symmetry, all four ablation paths, independent plant partitions, training-only scaling, original-time derivative reconstruction, quality descriptors, reviewed mapping gate, time/voltage units and undefined single-class metrics.
- Editable package installation and CLI help completed successfully.
- All four ablations completed a one-fold/two-epoch smoke workflow.
- RTV-Net completed all six outer folds, one seed, three epochs per fold on synthetic data.
- Robustness processing completed all six held-out folds at six missing fractions and six noise amplitudes, one repetition per level. No-corruption reconstruction was checked against prepared windows.
- Feature-response and reliability-weight PNG/PDF figures were exported from the trained demo checkpoints.
- CPU benchmark completed with 10 warm-ups and 100 repeats for a three-electrode, 60-position window. This validation run uses fewer repeats than the full default benchmark.

Measured default RTV-Net trainable parameters: **8867**.
Measured validation-run median latency: **2.028 ms/window** on this host, for prepared-window scaling and inference. This does not include raw parsing, resampling or timestamp differentiation.

See TESTED_VERSIONS.json and runs/full_demo/benchmark.json for the actual environment.

## Version 0.2 regression validation

Input/provenance validation, checkpoint dataset bindings, safe output reuse, CLI preprocessing flags, preserved string identities and aligned/masked explanation plots are covered by the revised checks. All six synthetic outer folds and robustness levels were regenerated with version 0.2 checkpoints.

## Not validated

- Real tomato disease performance, class labels or plant/electrode mapping.
- The manuscript's placeholder results, parameter counts or timing claims.
- CUDA execution, Windows batch launcher, or dependency installation on every operating system.
- Exact equivalence to original multivariate LITEMV; the included implementation is an electrode-wise adaptation.

Full experimental settings still require five seeds, complete outer evaluation, 20 perturbation repetitions and verified biological identities.

## Final usability update (0.2.1)

The model and preprocessing are unchanged. Version reporting, location-independent demo startup, fresh output paths and the concise start guide were checked with the same 20-test suite. Windows launcher execution remains untested on this Linux host.
