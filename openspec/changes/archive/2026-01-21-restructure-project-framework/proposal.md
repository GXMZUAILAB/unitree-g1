# Change: Refactor Project Structure and Framework

## Why
The current project structure is based on a "VibeCoding" template which is too generic and includes many placeholder files. We need to align with standard humanoid robot RL project norms (like Isaac Lab projects) and formalize the use of the OpenSpec framework for better collaboration and documentation.

## What Changes
- **Directory Structure Standardisation**:
    - Rename `data/` to `assets/` to better reflect its contents (models, motions).
    - Move `prompts/` to `resources/prompts/` and clarify its role as a legacy/reference resource rather than a core development paradigm.
    - Ensure `unitree_rl/` is structured as a clean Python package.
    - Create a `tests/` directory for automated verification.
- **Documentation Overhaul**:
    - Update `README.md`: Remove the "VibeCoding" introduction. Introduce the project as a Unitree G1 RL project using Isaac Lab and OpenSpec.
    - Update `openspec/project.md`: Reflect the new directory structure and replace VibeCoding conventions with OpenSpec-driven development standards.
- **File Clean-up**:
    - Review and prune placeholder files in `unitree_rl/`, `configs/`, and `docs/`.
- **Infrastructure**:
    - Add a `setup.py` or `pyproject.toml` to make `unitree_rl` installable.

## Impact
- 受影响的 Specs: `documentation-standards` (if exists) and a new `project-structure` spec.
- 受影响的代码: All directories, specifically `unitree_rl`, `configs`, `docs`, `prompts`, `data`.
- **BREAKING**: Path changes for assets and configs might require updates to scripts and Hydra configs.
