## 1. Directory Structure Migration
- [ ] 1.1 Rename `data/` to `assets/`
- [ ] 1.2 Move `prompts/` to `resources/prompts/` (create `resources/` if needed)
- [ ] 1.3 Create `tests/` directory
- [ ] 1.4 Update all internal references to `data/` to `assets/` (configs, scripts)

## 2. Documentation Overhaul
- [ ] 2.1 Update `README.md` to remove VibeCoding and introduce OpenSpec
- [ ] 2.2 Update `openspec/project.md` with new structure and conventions
- [ ] 2.3 Localize any remaining English placeholder docs if they are kept

## 3. Package and Dependencies
- [ ] 3.1 Review and prune placeholder files in `unitree_rl/`
- [ ] 3.2 Create `setup.py` for `unitree_rl`
- [ ] 3.3 Ensure `requirements.txt` is complete

## 4. Verification
- [ ] 4.1 Run `openspec validate restructure-project-framework --strict`
- [ ] 4.2 Verify project can still be initialized and scripts run (dry run)
