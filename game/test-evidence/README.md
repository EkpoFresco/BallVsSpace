# Test evidence

| Location | Contents |
| --- | --- |
| [screenshots/](screenshots/) | 34 retained 0.3 desktop, emulated-phone and world-prompt captures |
| [results/](results/) | Selected final results and benchmark/reference checks |
| [archive/index.json](archive/index.json) | Searchable original paths and hashes for 1,096 earlier tracked files |
| [archive/2026-10-18-earlier-runs.zip](archive/2026-10-18-earlier-runs.zip) | Earlier receipts, successes/failures, screenshots and historical comparison |
| `runs/` | Ignored fresh command output; promote only meaningful final evidence |

For visual browsing use the [UI map](../docs/ui/map.html) and [reference comparison](../docs/ui/reference-comparison.html). Existing captures are dated 17 October; reorganizing them is not a new runtime test.

## Key retained results

- [Practice and menu flow](results/review-final-result.json), [emulated layouts](results/review-layout-final-result.json), [world prompts](results/visual-v3-world-result.json).
- [Logic suite](results/replica-review-core.json), [400 mirrored rounds](results/replica-review-mirrored-final.json), [two-client match](results/replica-review-multiplayer-tracked-result.json).
- [UI/interpolation lifecycle](results/replica-review-client.json), [equipped draft](results/replica-review-equipped-draft.json).
- [Baseline renderer](results/replica-review-baseline-render.json) and [final renderer](results/replica-review-final-render.json); fixture results, not phone FPS.
- [Source consistency](results/source-consistency.json), [clean clone](results/review-clean-clone.json), [hosted build](results/github-actions-verified.json), [artifact match](results/github-artifact-verification.json).
- [UI map checks](results/ui-handoff-validation.json), [earlier sharing-packet checks](results/ui-packet-validation.json).
- [Repository cleanup](results/repository-cleanup.json): preserved source/reference hashes, tooling/build checks and the regenerated standalone UI packet.

Run commands and interpretation are in [testing](../docs/testing.md). Human acceptance, physical touch/device performance and later networking/release gates remain pending. Archive members retain their original paths; failures have not been relabeled as passes.
