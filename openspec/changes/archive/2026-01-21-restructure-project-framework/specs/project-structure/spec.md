## ADDED Requirements

### Requirement: Standard Directory Layout
The project SHALL follow a standard layout to separate concerns:
- `assets/`: 3D models and motion data.
- `configs/`: Hydra configurations.
- `docs/`: Technical documentation.
- `unitree_rl/`: Main source code package.
- `scripts/`: Entry points for training and playback.
- `tests/`: Automated test suite.

#### Scenario: Navigating the project
- **WHEN** a developer looks for the robot model
- **THEN** they find it under `assets/`.
- **WHEN** a developer looks for the environment logic
- **THEN** they find it under `unitree_rl/envs/`.

### Requirement: Package Installability
The `unitree_rl` directory SHALL be a valid Python package.

#### Scenario: Installing the package
- **WHEN** running `pip install -e .`
- **THEN** the `unitree_rl` package is installed in editable mode.

### Requirement: OpenSpec Framework Usage
All significant changes to architecture, features, or project structure SHALL be proposed via the OpenSpec framework.

#### Scenario: Proposing a new feature
- **WHEN** a developer wants to add a new RL algorithm
- **THEN** they create a new change proposal in `openspec/changes/`.
