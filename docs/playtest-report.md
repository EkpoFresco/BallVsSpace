# M1 playtest report — 16 October 2026

**Build:** 0.1.0-m1, rules bvs-rules-1. **Verdict:** playable desktop two-kit slice; M1 human acceptance remains pending. No public release or durable progression.

**Implemented:** Drift/Anchor draft, private aiming and first-bounce preview, server-owned automatic motion/abilities, signed territory, exact regulation/overtime/match points, Practice, results, two-second replay and rematch. Original primitive art. Session-only progress.

**Evidence:** Ten core Studio logic test groups passed, including 126 influence cases, 1,000 randomized board updates, tick-1800/no-late-paint and overtime boundaries. Two hundred mirrored pairs (400 rounds) matched every reflected cell, final counts and result, with zero solver recoveries after two collision fixes. Edit-mode simulation step work p95 was 0.286 ms; this does not measure physical-phone rendering. Every live server territory update asserts a complete recount. Formatting, lint and strict type analysis passed; Rojo produced binary/XML places.

**Actual multiplayer:** Final accounting is pending the active ten-attempt run and corrected follow-up. Two real clients use ordinary commands at normal clocks. One attempt aborted under host load through the simulation-debt guard. Both client hashes equaled the frozen server hash; the harness incorrectly compared the last territory tick to the movement tick, producing two false tick mismatches. The corrected harness excludes aborts and compares ticks for the same represented board. The failed run is retained, and only normal match-points completions will count toward the required ten.

**Visual QA:** Desktop court, percentages/neutral area, two kit silhouettes, team symbols and cooldown labels inspected in the real client. Camera Focus and invisible-label issues were fixed. iPhone 17 Pro portrait emulation at an observed 401×778 viewport displayed the full court; landscape at 750×381 failed because the fixed-height HUD obscured the court. Compact landscape must be redesigned for M3. No physical device or gamepad usability pass is claimed.

**Artifacts:** `builds/BallVsSpace.rbxl`; `test-evidence/logic-final.json`; `mirrored-fixtures-fixed.json`; `grid-fixture.svg`; `final-desktop-0.png`; `phone-portrait-0.jpg`; `phone-landscape-0.jpg`; final multiplayer JSON/logs and inspected two-client recording when complete. Initial failures remain separate files. Some Studio Core UI/asset warnings are present; they are not hidden or described as project script errors.

**Next gate:** Ten unfamiliar people, thresholds 8/10 leader recognition within two seconds, 8/10 reinforced-cell capture understanding, 6/10 voluntary replay. Use `docs/testing.md` and the blank observation sheet. No human results exist yet. M2 reliable multiplayer, M3 six-kit/content/phone work, M4 durable progression and M5 beta remain dependency-gated.
