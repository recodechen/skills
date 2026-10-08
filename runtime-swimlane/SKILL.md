---
name: runtime-swimlane
description: Trace one concrete runtime scenario between optional start and end code points, then output semantic JSON for the bundled interactive swimlane sequence viewer. Use to understand execution order, cross-object handoffs, branches, asynchronous boundaries, and why similar schedulers/orchestrators participate at different times.
---

# Runtime Swimlane

## Deliverable and Resources

Produce UTF-8 semantic JSON for the bundled [index.html](index.html) viewer. Do not generate HTML or embed project facts into HTML.

Use these resources:

- [runtime-swimlane.schema.json](runtime-swimlane.schema.json): authoritative JSON contract; read it before producing data.
- [runtime-swimlane.example.json](runtime-swimlane.example.json): serialization and Chinese explanation style only; its UE5 facts are illustrative and unverified.
- [index.html](index.html): fixed offline viewer asset. Do not read, analyze, regenerate, or edit it during normal trace generation.

If `doc/runtime-swimlane/index.html` is absent, copy the bundled viewer there byte-for-byte. If it already exists, leave it unchanged.

The result should answer: “一次具体运行过程中，谁先做什么、接着交给谁、在哪个对象/线程/模块上发生、在哪里分支或跨异步边界？”

## Task Parameters

- `scope`: Codebase scope; default is the current project.
- `start`: Optional real source symbol or source-anchored runtime event where tracing begins.
- `end`: Optional real source symbol or source-anchored runtime event where tracing ends.
- `scenario`: Optional Chinese scenario description used to disambiguate branches, such as“正常渲染一帧”或“资源未就绪后下一帧重试”.
- `max_steps`: Preferred trace limit; default `40`. Preserve necessary steps and an explicitly requested end even when they exceed it.
- `output`: Output filename or filename stem; default `runtime-swimlane`.
- `design_doc`: Optional single design or architecture document used as navigation context.

Output directory is always `doc/runtime-swimlane/`. If `output` does not already end with `.json`, append `.json` directly.

All user-facing semantic text must be Chinese. Preserve source symbols exactly.

## Start and End Semantics

When supplied, resolve `start` and `end` before broad tracing.

- Both supplied: trace only the runtime corridor from the start point to the end point, inclusive.
- Only `start`: trace forward to a natural completion boundary; if the trace must stop near `max_steps` first, state that it is partial and omit `endStepId`.
- Only `end`: trace backward only far enough to explain how execution reaches that point.
- Neither supplied: use the scenario's natural entry and completion boundary.

If a symbol/event is ambiguous, ask or report candidates rather than guessing. If no supported path exists, report that instead of inventing steps.

## What to Trace

Trace one concrete scenario, not every possible call path.

Include only runtime steps that materially explain:

- call and return boundaries;
- orchestration handoffs;
- scheduling decisions;
- owner-thread / worker-thread handoffs when relevant;
- async submit / completion boundaries;
- publish / freeze / commit boundaries;
- important branches and early exits.

Do not produce a full call graph. Omit trivial getters, logging, helper wrappers, allocation details, and repeated inner-loop calls unless they explain the scenario.

Every step must be anchored to a real source symbol. The same source symbol may appear in more than one step if it participates at different times.

Use lanes for stable runtime participants such as an object, subsystem, module, or thread role. A lane is a reading aid; it does not itself prove ownership.

## Source Analysis

1. Read repository instructions.
2. Read `design_doc` first when supplied, only to locate candidate phases and symbols.
3. Resolve start/end and scenario.
4. Follow production call sites and actual control transfer.
5. For each step record the real source symbol, what happens there, and which lane performs it.
6. Verify branches and async boundaries from current code; do not infer runtime order from class ownership or file order.
7. Stop at `end` once its relevant work completes; do not continue simply because more calls exist.

Confidence:

- `confirmed`: verified from current source;
- `inferred`: supported but not fully verified;
- `unresolved`: insufficient evidence.

Every confirmed step and flow must carry non-empty current-source evidence.

## JSON Contract

Use exactly [runtime-swimlane.schema.json](runtime-swimlane.schema.json) with `schemaVersion: "1.0"`.

Top-level fields:

- `map`: metadata, optional scenario, `startStepId`, `endStepId`;
- `lanes`: stable runtime participants;
- `steps`: ordered source-anchored runtime actions;
- `flows`: directed transitions between steps.

Each step has a global integer `order`. Lower order occurs earlier in the chosen scenario. Two steps may share the same order only when they are intentionally concurrent/parallel and the source supports that interpretation.

Use only these `flowKind` values:

- `call` → 调用
- `return` → 返回
- `continue` → 继续
- `branch` → 分支
- `async_submit` → 异步提交
- `async_complete` → 异步完成
- `handoff` → 交接
- `publish` → 发布
- `skip` → 跳过

Direction is always from earlier source-anchored step to the next step represented by that flow.

Use `condition` for a branch/skip condition in plain Chinese. Do not turn conditions into invented source facts.

## Validation and Delivery

Before finishing:

1. Parse and schema-validate the exact JSON.
2. Verify unique lane and step IDs.
3. Verify every step references an existing lane.
4. Verify every flow endpoint exists.
5. Verify `startStepId` / `endStepId` exist when present.
6. Verify global step order matches the chosen runtime scenario.
7. Verify the trace reaches `end` when both boundaries were requested.
8. Verify confirmed facts have evidence and every step has a real source symbol.
9. Omit nonessential steps to stay near `max_steps`. If necessary steps exceed it, keep them and report the actual count and reason. Never imply that a trace stopped by the limit reached natural completion.
10. Copy the fixed viewer only when missing.

Deliver:

- `doc/runtime-swimlane/index.html`
- `doc/runtime-swimlane/<output>.json`

The local viewer loads JSON through its file picker or drag and drop. When `output` is not the default, tell the user which JSON to select; when served over HTTP, `?data=<output>.json` selects it directly.

Subsequent updates replace semantic JSON, not the viewer.
