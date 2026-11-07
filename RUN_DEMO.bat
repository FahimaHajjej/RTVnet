@echo off
REM Resolve the project directory even when launched from another folder.
cd /d "%~dp0"
REM Step 1: create a project-local Python environment.
python -m venv .venv
if errorlevel 1 exit /b 1
REM Step 2: install the code and dependencies (Internet required once).
.venv\Scripts\python -m pip install -e .
if errorlevel 1 exit /b 1
REM Step 3: run the synthetic engineering workflow.
.venv\Scripts\python scripts\quickstart.py
if errorlevel 1 exit /b 1
REM Step 4: verify model/data invariants.
.venv\Scripts\python -m unittest discover -s tests -v
pause
