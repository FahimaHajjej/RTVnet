# Attribution and references

## LITE / LITEMV

Ali Ismail-Fawaz, Maxime Devanne, Stefano Berretti, Jonathan Weber and Germain Forestier.
*Look Into the LITE in Deep Learning for Time Series Classification*, 2025.
https://arxiv.org/abs/2409.02869
https://github.com/MSD-IRIMAS/LITE

The package includes the user's unchanged LITE-main.zip as vendor/LITE-original.zip.
Reference archive comment/commit: e62f64393104be8eda415b4d974987028ca68754.
Its GPL-3.0 licence is retained at project root. The fixed temporal pattern construction in
src/rtvnet/model.py is adapted from src/classifiers/litemv.py. The proposed TVEM/ERFM and
shared-electrode PyTorch pipeline are modifications; they are not an official LITE release.
Original authors are not asserted to endorse this implementation.

The original implementation uses Keras. This package uses PyTorch and explicitly changes
input treatment, preprocessing, electrode independence and final fusion. Do not label its
backbone ablation as an exact reproduction of original multivariate LITEMV.

## Dataset

S. Matic and colleagues, *Data of electrical signalling in tomato for the detection of
powdery mildew*, Data in Brief 63 (2025), 112165.
https://doi.org/10.1016/j.dib.2025.112165
Dataset DOI: https://doi.org/10.17632/yr8zhsc6mh.1
Repository: https://data.mendeley.com/datasets/yr8zhsc6mh/1
The repository lists CC BY 4.0. The data article has its own licence. Neither raw dataset
nor article is redistributed here; included audit files are inventory/annotation summaries.

## Runtime libraries

PyTorch, NumPy, SciPy, pandas, scikit-learn, Matplotlib and openpyxl must be installed
separately and retain their respective licences. The binary dependency packages are not
included. Check LICENSE before redistributing a modified version of this package.
