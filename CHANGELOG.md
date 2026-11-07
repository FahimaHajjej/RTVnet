# Version 0.2.1 — final polish

- Add START_HERE.md with concise setup and run instructions.
- Resolve project paths in Python, Windows and shell demo launchers.
- Print the exact demo output directory on completion.
- Add `python -m rtvnet --version` and record the installed code version in new runs.
- Correct README commands to use fresh output directories instead of overwriting shipped examples.
- Preserve the validated model architecture, checkpoint compatibility and parameter count.

# Version 0.2.0

## Data integrity
- Validate array shapes, finite values, binary masks, label/metadata agreement, unique windows, padded channels, class identity consistency, grid length and quality/mask agreement before evaluation.
- Reject empty source CSVs, blank identity fields and invalid preprocessing budgets.
- Expose grid, window, stride, maximum gap, coverage and electrode minimum in the CLI.

## Reproducibility
- Save a portable dataset fingerprint in every new checkpoint. Explanations and robustness evaluations reject mismatched arrays or identities, while relocated identical data remain valid.
- Check inference preprocessing against checkpoint settings.
- Refuse accidental reuse of nonempty training directories. Explicit overwrite clears previous seed checkpoints and standard derived outputs.
- Write each quickstart invocation into a fresh timestamped directory.
- Reject zero/negative training or benchmark budgets, duplicate seeds, and non-finite metric probabilities.

## Outputs
- Export usability status with inference results.
- Align all explanation plots in time using a dedicated colour-bar column.
- Display unavailable responses in grey instead of showing them as low feature activity.
- Display availability-driven electrode-weight changes as steps.
- Preserve plant/session IDs as strings in robustness reports.
- Create export/benchmark parent directories automatically.

## Validation
- Extend the suite from 10 to 20 tests.
- Regenerate complete six-fold synthetic demo checkpoints and derived outputs using 0.2.0.
- Retain the original model design and its 8,867 trainable parameters.

No real-data plant identity mapping or experimental disease performance is inferred by these changes.
