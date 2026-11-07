# Start here: RTV-Net 0.2.1

## What is included?

TVEM, a LITEMV-inspired backbone, ERFM, data preparation, grouped training, four component configurations, robustness experiments, explanations, benchmarking, tests and a runnable synthetic demo.

## Step 1 — Extract

Extract the ZIP and open the `RTVNet` directory. Python 3.10 or later and initial Internet access are required. The public tomato dataset and dependency binaries are not duplicated in this archive.

## Step 2 — Install and run

**Windows:** run `RUN_DEMO.bat`. It creates a local environment, installs the package, runs the synthetic demo and executes the tests. Windows execution has not been tested on this Linux host.

**Linux/macOS:** from the project directory, run:

```bash
bash scripts/run_demo.sh
```

**Manual installation, any supported platform:**

```bash
python -m venv .venv
# Activate .venv using your platform's command, then:
python -m pip install -e .
python -m rtvnet --version
python scripts/quickstart.py
python -m unittest discover -s tests -v
```

## Step 3 — Find the outputs

Quickstart prints a unique directory under `runs/demo_...`. Look there for model checkpoints, loss histories, prediction CSVs, explanation figures, a measured timing JSON and a summary CSV.

`runs/full_demo` already contains a six-fold synthetic engineering example. It is not a tomato disease experiment. Do not use its accuracy as manuscript evidence.

## Step 4 — Use the real dataset

Follow README sections 3–5. Audit the source ZIP, review plant/electrode/session identities, export a canonical CSV, then prepare windows. Do not infer a plant from a cable number. Real-data training requires reviewed provenance and enough independent plants for the grouped protocol.

## Step 5 — Run final experiments

Use fresh output folders. Run the full five-seed grouped protocol, component ablations and 20 robustness repetitions. Export measured results; replace every provisional manuscript value. The default implementation has 8,867 trainable parameters, not the earlier manuscript placeholder count.

## If a command stops

- **Output directory not empty:** use a fresh folder. `--overwrite` is available only for a recognised training run and replaces its standard outputs.
- **Checkpoint/dataset mismatch:** use the exact prepared dataset associated with that model or retrain. Do not disable the binding check for reported evaluation.
- **Insufficient plants:** verify biological identities; never substitute windows or electrodes for independent plants.
- **Dependency installation fails:** consult README and your Python/PyTorch platform installation instructions. Installed wheels are external dependencies.

Read VALIDATION.md for tested behaviour and remaining limits. Existing version 0.2.0 demo checkpoints remain compatible with this usability update.
