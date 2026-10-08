---
name: data-flow-map
description: Trace how one meaningful piece of data or render representation moves and changes between optional start and end points, then output semantic JSON for the bundled interactive Data Flow Map viewer. Use to understand transformations such as source object -> normalized contribution -> packet -> draw command.
---

# Data Flow Map

## Deliverable and Resources

Produce UTF-8 semantic JSON for the bundled [index.html](index.html) viewer. Do not generate HTML or embed project facts into HTML.

Use these resources:

- [data-flow-map.schema.json](data-flow-map.schema.json): authoritative JSON contract; read it before producing data.
- [data-flow-map.example.json](data-flow-map.example.json): serialization and Chinese explanation style only; its UE5 facts are illustrative and unverified.
- [index.html](index.html): fixed offline viewer asset. Treat it as opaque during normal map generation; do not analyze, regenerate, or edit it.

Copy the bundled viewer byte-for-byte to `doc/data-flow-map/index.html` when the output is missing or differs from the bundled asset. The output viewer is a generated copy; do not hand-edit it.

The result should answer: “这份数据从哪里来？中间经过哪些真实代码处理？每一步变成了什么表示？哪里只是引用、哪里复制、哪里解析、过滤、发布或上传？”

## Task Parameters

- `scope`: Codebase scope; default is the current project.
- `start`: Optional real data type/object representation or source symbol where flow tracing begins.
- `end`: Optional real data type/object representation or source symbol where flow tracing ends.
- `max_nodes`: Target size; default `40`. Keep the complete meaningful corridor even if it exceeds the target; remove only optional side branches and explain any overrun in `map.description`.
- `output`: Output filename or filename stem; default `data-flow-map`.
- `design_doc`: Optional single design or architecture document used as navigation context.

Output directory is always `doc/data-flow-map/`. `output` must be a filename or stem without path separators. If it does not already end with `.json`, append `.json` directly.

All user-facing semantic text must be Chinese. Preserve real source symbols exactly.

## Start and End Semantics

- Both supplied: trace the meaningful data corridor from `start` to `end`, inclusive.
- Only `start`: trace downstream to a natural stable representation near `max_nodes`; state the actual stopping representation in `map.description`.
- Only `end`: trace upstream only far enough to explain how that representation is produced.
- Neither supplied: choose one important data pipeline inside the requested scope; set its start/end node IDs and state those boundaries in `map.description`.

Set `map.startNodeId` / `map.endNodeId` to the resolved or chosen boundary nodes when known. Resolve names to real source symbols or explicit source-backed runtime representations. If ambiguous or absent, report that instead of guessing. If no source-supported directed flow connects both requested boundaries, report the gap and do not produce a map or copy the viewer for that request.

## Node Semantics

Use two node kinds:

- `data`: a real source data type or explicit runtime representation carried by the code;
- `transform`: a real function, method, class, or module that materially changes, resolves, filters, publishes, uploads, or packages the data.

Do not use vague conceptual nodes such as“渲染数据处理层”unless there is a real source object representing it.

For `data` nodes explain:

- `summary`: what this data represents;
- `representation`: what information is actually available at this point;
- optional `lifetime`: how long this representation is valid when that matters.

For `transform` nodes explain:

- `summary`: what code object this is;
- `action`: what it does to the flowing data.

## What to Trace

Trace semantic data changes, not every pointer assignment.

Include important boundaries such as:

- source extraction;
- normalization;
- resource resolution;
- filtering / visibility;
- copying versus referencing;
- immutable publication;
- CPU -> GPU upload;
- aggregation / splitting;
- final command materialization.

Do not treat a function call as data flow unless meaningful data crosses that boundary.

## Source Analysis

1. Read repository instructions.
2. Read `design_doc` first when supplied, only to identify candidate representations and stages.
3. Resolve start/end.
4. Follow actual producers, consumers, parameter/return types, stored representations, and conversion code.
5. Distinguish reference/borrow from copy and transformation.
6. Record where a representation becomes immutable, published, cached, uploaded, or otherwise changes lifetime.
7. Stop when the requested end representation is produced/consumed as requested.

Confidence:

- `confirmed`: verified from current source;
- `inferred`: supported but not fully verified;
- `unresolved`: insufficient evidence.

Every confirmed node and flow must carry non-empty current-source evidence. Each evidence entry must identify a source location by repository-relative path and line or symbol, and state what that source proves.

## JSON Contract

Use exactly [data-flow-map.schema.json](data-flow-map.schema.json) with `schemaVersion: "1.0"`.

Top-level fields:

- `map`: metadata plus optional `startNodeId` and `endNodeId`;
- `nodes`: data and transform nodes;
- `flows`: directed data-flow edges.

Use only these `flowKind` values:

- `input` → 输入
- `output` → 输出
- `transform` → 转换
- `resolve` → 解析
- `filter` → 过滤
- `copy` → 复制
- `reference` → 引用
- `publish` → 发布
- `upload` → 上传
- `aggregate` → 聚合
- `split` → 拆分
- `cache` → 缓存
- `handoff` → 交接

Direction always follows the actual data movement from earlier representation/producer toward later consumer/representation.

Do not label a reference as a copy. Do not label a cache hit as a transformation. Use `description` in Chinese when the fixed kind needs qualification.

## Validation and Delivery

Before finishing:

1. Parse and schema-validate the JSON.
2. Verify unique node IDs and all flow endpoints.
3. Verify start/end IDs exist when present.
4. When both IDs are present, verify that `endNodeId` is reachable from `startNodeId` following `from` → `to` edges.
5. Verify every data node is source-backed and every transform node names a real source symbol.
6. Verify flow direction follows actual data movement.
7. Verify copy/reference/transform semantics from code instead of guessing.
8. Verify confirmed facts have locatable evidence.
9. If the map exceeds `max_nodes`, verify that every retained node is needed and `map.description` explains why.
10. Verify that the output viewer is byte-identical to the bundled asset, copying it when needed.

Deliver:

- `doc/data-flow-map/index.html`
- `doc/data-flow-map/<output>.json`

Subsequent updates replace semantic JSON and sync the bundled viewer only when its bytes change.
