# Menu and static-world correction review — 20 October 2026

This pass responds to the user's screenshots and actual interaction report. It is a local source review with engine tests, not an independent review. The previous geometry-only checks missed click-through and rendered border/close-control defects.

| Finding | Correction |
| --- | --- |
| Blank modal areas clicked the outside backdrop | Full-size transparent button under modal contents consumes those clicks. Actual blank grid/header/card-padding clicks pass at three sizes. |
| Centered selection strokes clipped at the scroll origin; inset strokes could sit behind child fills | Inset outline layer above artwork/footer; 3px grid inset, reserved scrollbar gutter and complete last-row canvas height. |
| X artwork differed from Figma; direct menu switching sometimes omitted it | Native Montserrat × with matching fill/border. Show the close control one rendered frame after its parent; inspect medium, short and wide transition captures, plus lifecycle cancellation. |
| Store offers read as floating artwork and buttons | One bounded frame per offer, shared surface/padding, aligned CTA and 14px gutters; reachable scrolling at short heights. |
| Store category stayed selected after routing elsewhere | Only Events/Balls mutate Store selection; other tabs open the matching Inventory category. |
| Lobby existed only at runtime | Script-free authored model in the Rojo tree. Removed two builders; verify the same scene before/after Play, fresh-file load, and real proximity-prompt actions. |
| Repeated same-name saves and unrelated folder | One tracked primary binary built directly by verification/CI. Preserve former copies under descriptive ignored backup names. |

The [current evidence](../../test-evidence/README.md) separates 297 geometry checks, actual clicks, visual inspection, final lifecycle checks and the static-world round trip. Physical devices remain untested. Approved art and design inputs are unchanged.

## Earlier UI and logic review — 20 October 2026

Reviewed the client update loop, territory decoder, command validation, match/rematch transitions, replication, modal lifecycle and native layouts. The approved action-v1 inputs and territory rules are unchanged. This is a local source review with engine checks, not an independent agent review.

| Finding | Correction |
| --- | --- |
| Every territory delta recounted all 1,024 cells | Update counts only for changed cells; full snapshots validate/count in one pass. Copies keep rejection atomic. A 300-step full/delta chain is checked against full recounts, including malformed packets. |
| Packet updates repeated unchanged HUD work | Batch presentation updates; skip full HUD rendering for unchanged Battle/Overtime controls. Clock strings update on second/phase changes; replay history reuses the frame's position sample. |
| Rematch acceptance could be overwritten by a later state | Replicate private confirmation with a state-version change; show Requesting / Queued feedback, guard duplicate clicks and reject expired requests. |
| An uncommitted wildcard timed out to a kit with the wrong appearance | Restore the fallback kit and its matching default appearance together. |
| Decorative hearts implied lives; match results showed last-round area as the main result | Display actual match points beside players. Round cards show territory; match cards show match points. Stopped/cancelled matches explicitly record no result. |
| Replay existed but its control was unreachable | Expose Replay on results, hide the result card during playback and restore it afterward. Ball percentages follow the replay board. |
| Medium-height desktops clipped Inventory details and misaligned Store rows | Keep Equip/details fixed, scroll only the collection grid and align both Store columns to the available height. Increase desktop card labels. |
| Results and connection/replay banners became too small in landscape | Use physical font sizes and a compact centered result card; omit the large avatar before shrinking essential copy. |
| An opening tween could move a resized or closed modal | Cancel it on close or viewport relayout; cover the resize/close sequence in the lifecycle fixture. |
| A late replay could leave its status banner in the lobby | Hide status on Lobby/Queued transitions; verify an injected stale banner clears after a server Lobby state. |

The [20 October evidence](../../test-evidence/README.md) records 297 isolated scale-state checks across ten sizes plus a return pass, all catalog strings, native captures, live input and logic checks. Decoder timings compare six alternating batches of 500 calls per case in the same Studio client. The 12-cell case fell from 0.173 to 0.014 ms median; this is an isolated decoder result, not a phone-FPS claim.

Removed the unused heart helper and unreachable action branches. No new runtime modules, gameplay kits or economy systems were added. Physical-device performance, gamepad and human acceptance remain separate pending gates.

## Earlier scale review — 19 October

Reviewed the changed native UI, layout lifecycle, navigation, font/asset handling and source-to-Studio workflow. This was a local source review plus measured runtime checks, not an independent agent review.

| Finding | Correction / evidence |
| --- | --- |
| Global shrinking produced 5–9 px labels and lost Draft descriptions | Physical text/control sizes; artwork and column count adapt first. All catalog text fits across the scale matrix. |
| Short Inventory pushed Equip below the fold | Compact detail header and fixed action; only the ball grid scrolls. |
| Phone layout could leave oversized geometry after resizing | Removed separate portrait/lobby overrides; stable physical layout and small → ultrawide → small verification. |
| Modal center used the old fixed canvas width | Center follows the full safe-area container; actual clicks and bounds checked. |
| Enlarged primary action retained its old left offset; bot portrait was blank | Center action after sizing; use the generic emote portrait for bots without revealing draft choices. Reset crop when a real player thumbnail arrives. |
| Long usernames and notification copy overflowed | Fixed readable player names with explicit ellipsis; multiline notification banner. |
| UI code retained redundant visual work | Removed duplicate mini-hearts, obsolete polygon helper and discarded crown/coin primitives, unused state arrays and duplicate theme constants. |
| Keyboard listener outlived a removed panel tree | Disconnect on destruction; repeated open/appearance fixture retained. |
| Figma short-title line spacing differed from Roblox | Editable landscape Draft variants inspected and corrected; approved Inventory/Store retained. |

Validation combines static checks/builds, 198 isolated scale-state checks, 31 inspected captures and separate live flows/lifecycle/multiplayer receipts in the [evidence index](../../test-evidence/README.md). Scope is the current 12-appearance, two-kit local game. It does not certify physical phones, gamepad, human usability or whole-game FPS. No remaining issue was identified by the completed checks; the untested gates remain explicit.
