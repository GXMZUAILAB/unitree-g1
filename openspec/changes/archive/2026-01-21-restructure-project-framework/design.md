## Context
The project was initialized with a template that used "VibeCoding" as its core paradigm. While helpful for initial setup, the project has now matured and needs a more standard structure that aligns with Isaac Lab conventions and the OpenSpec framework.

## Goals
- Align project structure with standard humanoid robot RL projects.
- Formalize OpenSpec as the documentation and planning standard.
- Remove generic "VibeCoding" references and placeholder files.
- Enable easier integration with Isaac Lab and other tools.

## Decisions

### 1. Directory Structure Changes
- **Rename `data/` to `assets/`**: This is a standard convention in robotics and game development for storing models (`usd`, `urdf`), textures, and reference motions (`bvh`).
- **Move `prompts/` to `resources/prompts/`**: Prompts are useful as reference material but shouldn't be a top-level directory in a production-ready codebase.
- **`unitree_rl/` Standardisation**: Keep this as the root Python package. Ensure it has a valid `__init__.py`.
- **Add `tests/`**: Create a top-level tests directory for unit and integration tests.

### 2. Documentation Standards
- **README.md Transition**: Transition from a "VibeCoding" centric README to a project-centric README that explains the mission, technical stack (Isaac Lab, RL), and development process (OpenSpec).
- **OpenSpec Integration**: Explicitly mention how to use OpenSpec for proposing and implementing changes.

## Migration Plan
1.  **Preparation**: Identify all files to be moved or deleted.
2.  **Structural Changes**: Perform `mv` operations for `data` and `prompts`.
3.  **Code Updates**: Update internal references to `data/` (likely in configs or scripts) to `assets/`.
4.  **Documentation Update**: Rewrite `README.md` and update `openspec/project.md`.
5.  **Clean-up**: Remove unnecessary placeholder files.
6.  **Infrastructure**: Create `setup.py` and `requirements.txt`.

## Risks / Trade-offs
- **Breaking Path References**: Changing `data/` to `assets/` will break scripts that hardcode the path. We must ensure a thorough search and replace.
- **Dependency on Isaac Sim**: The project still depends heavily on the Isaac Sim environment.
