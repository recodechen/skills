---
name: system-map
description: Analyze a codebase's stable structure and core code-object relationships, then output semantic JSON for the bundled interactive System Map viewer. Use for architecture, ownership, containment, references, and other static relationships.
---

# System Map

## Deliverable and Resources

Produce UTF-8 semantic JSON for the bundled [index.html](index.html) viewer. Do not generate HTML or embed project facts into HTML.

Use these resources:

- [system-map.schema.json](system-map.schema.json): authoritative JSON contract; read it before producing data.
- [system-map.example.json](system-map.example.json): serialization and Chinese explanation style only; its UE5 facts are illustrative and unverified.
- [index.html](index.html): fixed offline viewer asset. Do not inspect its implementation, regenerate, or edit it during normal map generation; byte comparison for delivery is allowed.

If `doc/system-map/index.html` is absent, copy the bundled viewer there byte-for-byte. If it exists, compare it byte-for-byte with the bundled viewer and leave it unchanged only when identical. If different, preserve it, report the conflict, and do not claim viewer delivery until resolved; replace it only when the user has authorized replacing that file.

The result should let a developer unfamiliar with the project identify core code objects, their primary positions, responsibilities, verified owners, important static relationships, and omitted deeper structure without substantial source reading.

## Task Parameters

- `scope`: Codebase to analyze; default is the current project.
- `focus`: Optional real source symbol used as the exported local root.
- `depth`: Maximum conceptual depth; default `3`, clamp to `1..5`.
- `max_nodes_per_level`: Soft limit on code nodes at one conceptual level; default `15`.
- `output`: Output filename or filename stem; default `system-map`.
- `design_doc`: Optional single design or architecture document used to identify candidate structure.

Output directory is always `doc/system-map/`.

Normalize `output` to its final filename component. If it does not already end with `.json`, append `.json` directly. Do not remove or replace an existing extension.

Examples:

- omitted → `doc/system-map/system-map.json`
- `engine` → `doc/system-map/engine.json`
- `engine.json` → `doc/system-map/engine.json`
- `engine.html` → `doc/system-map/engine.html.json`
- `other/path/engine.txt` → `doc/system-map/engine.txt.json`

All user-facing semantic text in generated JSON must be Chinese. Preserve real source symbols exactly. Machine keys and enum values remain English.

## Scope and Explanations

Analyze stable static structure:

- core code objects
- primary placement
- ownership and containment
- references
- registration, lookup, and resolution
- production and consumption relationships
- major system boundaries
- inheritance when structurally important

Do not analyze runtime state changes, state machines, scheduling, execution order, concurrency, transient execution context, dynamic consistency, or failure recovery unless requested separately.

Do not copy a directory tree as architecture or enumerate every type and function. Prefer lifecycle owners, important resources, stable boundaries, registries, factories, and important producers or consumers. Include a function only when it has a stable system-level responsibility. Normally omit helpers, temporary builders, generated files, third-party internals, tests, samples, and benchmarks unless they are the requested scope.

Each `kind: "code"` node must represent exactly one real source symbol. Never invent conceptual code symbols, rename symbols, or merge several source objects into one fictional node. Use `kind: "group"` only for Chinese visual grouping. The project root uses the real project name.

Write `summary` and `role` in plain Chinese:

- explain what the object does before details;
- use concrete actions and results;
- assume the reader is unfamiliar with the project;
- do not explain one unexplained technical term with another;
- keep source symbols unchanged.

## Source Analysis

1. Read applicable repository instructions.
2. If supplied, read `design_doc` before broad exploration to learn terminology and candidate boundaries. It is navigation context, not proof.
3. Start with build entry points, public interfaces, lifecycle owners, and relevant production call sites.
4. Identify core objects and choose one primary position per object. Cross-system relationships must reuse the same node ID rather than duplicate a code node.
5. Verify selected relationships against current code: type/member definitions, creation/storage/destruction, registration/lookup/resolution, and real call sites.
6. Retain concise source evidence on important code nodes and relations. Prefer repository-relative paths with symbols or line numbers.
7. If implementation differs from the design document, describe the implementation and note the discrepancy; do not modify either source or design documentation.

Confidence:

- `confirmed`: directly verified from current source.
- `inferred`: supported interpretation, but not fully verified.
- `unresolved`: insufficient evidence.

Every `confirmed` code node and every `confirmed` relation must contain a non-empty `evidence` array. Do not fabricate evidence, owners, or precise relationships.

For code nodes, `definition` is optional. Omit it by default; when useful, include at most one primary definition location. Keep detailed source locations in hidden `evidence`. Root and group nodes must not contain `confidence`, `evidence`, or `definition`.

Inspect only as deeply as needed to establish the requested structure. Prefer breadth for a first whole-project map and deeper analysis through `focus`.

## Depth, Focus, and Coverage

Count the analyzed root at conceptual depth `0`. A code-object child advances depth by one. Visual group nodes organize a conceptual level and do not consume depth.

At the depth limit:

- stop adding children;
- set `hasMore: true` only when omitted deeper structure is actually known to exist;
- do not invent omitted counts for unexplored areas.

If a level exceeds `max_nodes_per_level`, keep the objects most useful for system understanding and describe known coverage limits in `map.description`.

When `focus` is supplied:

- resolve it to one real source symbol;
- if missing or ambiguous, report the problem and closest candidates instead of guessing;
- export that `kind: "code"` node as `map.rootId`;
- give it no parent in `tree`;
- restart conceptual depth at zero;
- put global ancestor labels before it in `map.contextPath`;
- do not emit relation endpoints outside the exported node set.

The viewer's interactive focus only filters existing JSON; deeper source discovery requires another skill run.

## JSON Contract

Use exactly [system-map.schema.json](system-map.schema.json), headed by:

```json
"schemaVersion": "1.0"
```

Top-level fields:

- `map`: stable map ID, Chinese title, root ID, optional Chinese description and context path.
- `nodes`: flat root/group/code nodes with unique stable IDs.
- `tree`: primary reading-position edges `{parent, child, order?}`.
- `relations`: optional semantic edges `{from, to, relationKind, description?, confidence, evidence?}`; omit only when there are no semantic relationships, or emit an empty array.

Root and group nodes use `name`. Code nodes use `symbol`, `symbolKind`, `summary`, `role`, and `confidence`.

`relationKind` is a fixed machine semantic. Use only:

- `ownership`
- `containment`
- `inheritance`
- `creation`
- `destruction`
- `handle_reference`
- `reference`
- `registration`
- `lookup`
- `resolution`
- `publication`
- `consumption`
- `production`
- `dependency`

The viewer renders these as Chinese labels. Use Chinese `description` only to qualify the fixed relation; never invent a new relationship type through free text.

Use stable IDs that distinguish same-named symbols in different scopes. Keep IDs stable across updates to the same map. Give different scope/focus maps different `map.id` values because viewer layout and collapse state are stored by `map.id`.

Do not output coordinates, colors, HTML, JavaScript, Markdown fences, comments, or fields outside the schema.

### Primary Tree Invariants

Verify separately from JSON Schema:

- all node IDs are unique;
- every tree and relation endpoint exists;
- `map.rootId` is the sole `kind: "root"` node for a whole-project map, or the code root for a focused map;
- a visual group is never the exported root;
- the root has no parent;
- every other node has exactly one parent;
- every node is reachable from the root;
- reject self-loops, cycles, duplicate tree edges, disconnected nodes, and multiple parents.

`tree` describes reading position only. It does not assert ownership, inheritance, containment, dependency, or runtime order. Put semantic relationships in `relations` even when both nodes are also parent/child in `tree`.

### Relationship Semantics

Edges read as:

`from` → `relationKind` → `to`

The viewer derives Chinese relationship labels from `relationKind`.

Pointers, handles, references, smart pointers, and tree parents do not prove ownership. Use `ownership` only after verifying creation, storage, and destruction behavior.

Do not convert uncertain relationships into stronger kinds. Prefer `dependency` or `unresolved` confidence over inventing a more precise meaning.

Only `relationKind: "ownership"` with `confidence: "confirmed"` populates the viewer's “谁拥有它” field.

## Validation and Delivery

Before finishing:

1. Parse the exact output JSON.
2. Validate it against [system-map.schema.json](system-map.schema.json) with an available JSON Schema validator.
3. Check all graph invariants above.
4. Check that all visible semantic text is Chinese except real source symbols.
5. Check that every `confirmed` code node and relation has non-empty current-source evidence.
6. Check that root/group nodes contain no `confidence`, `evidence`, or `definition`, and that code-node `definition`, when present, contains at most one primary definition location.
7. Check depth, `hasMore`, coverage notes, and unresolved conclusions against the analyzed scope.
8. Check that `doc/system-map/index.html` is byte-identical to the bundled viewer, applying the copy and conflict rule above.
9. Do not launch a browser, preview server, engine build, or unrelated test unless the user or repository rules require it.

When the viewer check succeeds, deliver links to:

- `doc/system-map/index.html`
- the generated `doc/system-map/<name>.json`

Explain briefly that the viewer can load the JSON by file selection/drag-and-drop. When served over HTTP, `index.html?data=<relative-json-path>` may load it directly.

Subsequent updates should replace semantic JSON, not regenerate the viewer.
