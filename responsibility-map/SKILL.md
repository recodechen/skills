---
name: responsibility-map
description: Show what important classes, functions, modules, or targets do and how they relate, using source evidence. Use when similar names make their jobs hard to tell apart.
---

# Responsibility Map

Create source-backed semantic JSON for the bundled [viewer](index.html). The map should make it clear who decides, owns, checks, produces, consumes, or hands work to whom.

Read the [schema](responsibility-map.schema.json) before writing JSON. The [example](responsibility-map.example.json) maps functions in the bundled viewer and shows the format and writing style with source locations. Copy the viewer as an asset; do not inspect or edit it during ordinary map generation.

## Inputs and output

- `scope`: codebase to analyze; default is the current project.
- `start`, `end`: optional real codebase entities to anchor the map.
- `depth`: only for exactly one anchor; maximum hops for exploring its surrounding objects, default `3` and clamp to `1..5`.
- `design_doc`: optional architecture document for terminology and candidate boundaries, never proof of current behavior.
- `output_dir`: destination directory; default `doc/responsibility-map/` under the project root.
- `output`: JSON filename or stem; default `responsibility-map`.

Use the final filename component of `output` and append `.json` unless it already ends in `.json`.
Choose a stable `map.id` for this map's scope and anchors, distinct from other maps viewed on the same origin. The viewer uses it to save layout; keep it when only `output` changes. `output` names the JSON file, not the map ID.
For each supplied anchor, set `map.startId` or `map.endId` to the resolved node ID. Omit the field for an anchor that was not supplied.

Use Chinese for user-facing JSON text by default, or the language the user requests. Keep real names and symbols unchanged; schema keys and enum values stay English.

## Scope and required nodes

Resolve each supplied anchor to one real entity before tracing relationships. A node may be a declared symbol, a defined module, or a build target as allowed by the schema. Never invent a conceptual code object or rename an entity.
Optional node `aliases` are other source-verified identifiers for that same entity, not related entities or descriptive keywords. Cite their declarations in node `evidence`; omit `aliases` when none exist. The viewer displays and searches them.

- Both anchors: find source-supported responsibility connections between them, ignoring arrow direction only while finding the corridor. Include both anchors, every indispensable intermediate, and nearby owners whose presence changes the explanation. Do not choose a shorter path that skips such an owner. `depth` has no effect.
- One anchor: examine neighbors within `depth` hops, regardless of arrow direction. Keep every indispensable entity found in that scope. If a known handoff continues beyond the limit, state that the map stops there.
- No anchors: cover the main responsibility owners in `scope`. `depth` has no effect.

If `depth` was supplied in a mode where it has no effect, say so in the delivery. If an anchor is missing or ambiguous, or no source-supported corridor connects two anchors, report that problem and stop: do not create a misleading JSON or viewer.

Before pruning, inventory candidate coordinators, schedulers, owners, validators, producers, consumers, and handoff points from the relevant source. Keep an entity when removing it would change the answer to who performs one of those jobs or where work passes between owners. Exclude incidental helpers, logging, trivial getters, and repeated call edges. Never claim complete coverage when source access or scope leaves a material boundary unresolved; report it.

Relationship arrows state the direction of a responsibility, not execution order. Keep their semantic direction even when the corridor is traced in reverse. Use `relationKind` values from the schema: for example, owner → `ownership` → owned entity, caller → `call` → callee, and consumer → `consumption` → consumed entity. A pointer, reference, or handle alone does not prove ownership.
Use `orchestration` when the source chooses or orders work across several owners, `coordination` when it manages a handoff or synchronization without choosing the larger workflow, and `scheduling` when it decides when, at what priority, or on which executor ready work runs. A direct invocation alone supports `call`; use a broader kind only when source shows that responsibility.

## Evidence and wording

Read repository instructions first. Use design documents to find candidates, then verify current behavior in declarations and production call sites: state held, decisions made, calls across boundaries, creation and cleanup, validation, and data produced or consumed. Describe the current source when it differs from a design document.

Use `confirmed` only for claims directly verified in current source, `inferred` for supported but incomplete interpretations, and `unresolved` when evidence is insufficient. Every confirmed or inferred node and relation needs non-empty current-source `evidence`. Each evidence item must name a source path and line or symbol, and explain the observed fact; for `inferred`, also state what remains unverified. Give `definition` at most one primary location. Make a negative `notResponsibleFor` claim only when the neighboring owner or handoff is supported.

Write `map.description`, node `summary` and `responsibility`, and relation `description` in short everyday language. Explain who does what and where work goes; introduce technical terms only when they are needed to stay accurate. Preserve exact source symbols and avoid claims stronger than the evidence.

## Validation and delivery

Validate the exact JSON against the schema, then check unique IDs, existing relation endpoints, real entities, source evidence, the requested language, and that anchor fields match supplied anchors. With two anchors, check that supported relations connect them when arrow direction is ignored. Check the candidate inventory once more: include every supported indispensable node within scope; report only candidates outside scope or still unresolved and explain their effect. Keep the result a responsibility map rather than a call graph.

Deliver `output_dir/index.html` and `output_dir/<output>.json`. Copy the bundled viewer byte-for-byte only if it is missing; later map updates replace the JSON and leave the viewer unchanged. When served over HTTP(S), the viewer auto-loads `responsibility-map.json` or the JSON filename in `?data=<URL-encoded filename>`; when opened as a local file, the user must select or drop the JSON. For a nondefault `output`, include the matching `?data=` link or explain how to load the file manually.
