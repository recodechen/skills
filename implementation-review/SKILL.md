---
name: implementation-review
description: Review a completed section of a development plan against project design, source code, and tests, and record the findings in a review document. Use to find real bugs, incomplete implementation, design deviations, unnecessary complexity or repeated work, and missing critical tests.
---

# Implementation Review

Review the completed implementation identified by the user.

The request should identify:

* the development plan file;
* the completed section to review: one or more completed steps, or a larger group of steps.

It may also identify:

* the code change range, such as a base revision or commit range;
* the review document path. Default: `<plan file stem>_review.md` in the same directory as the plan file.

Accept these in natural language; do not require a fixed argument format.

If the plan file or target section cannot be identified unambiguously from the request and available context, ask the user for clarification before reviewing; do not guess. If the identified section cannot be read, report the blocker rather than infer its content.

If no change range is given, locate the changes from version-control history that references the section's step identifiers. If the range remains ambiguous, ask the user.

Read the target section first, including steps marked completed under the plan's convention, then read only the relevant design, instruction, source, and test files needed to verify it. When the change range is large, verify it step by step or commit by commit, then consolidate the findings and fix order across the whole section.

Check for:

* real bugs, edge-case errors, or incomplete implementation;
* deviations from the target section or project design;
* violations of layering, dependency, public API/ABI, or packaging boundaries defined by the project's authoritative documents; cite the specific section instead of restating the rule;
* ownership, lifecycle, state, concurrency, or failure-semantic problems;
* interfaces that work now but are hard to extend because parameters cannot express the need, or lifecycle, ownership, or handle/reference semantics are unclear;
* capabilities placed at the wrong layer or implemented more than once, judged by existing consumers, layer responsibilities, or actual complexity benefit, not hypothetical reuse;
* bypasses of the project's established lifecycle, asynchronous, cache, registry, or thread-ownership mechanisms, and other duplicate sources of truth;
* wrappers, facades, or forwarding that add no abstraction value; boundary layers required by the project's authoritative documents are not issues;
* avoidable data movement or repeated work, including redundant copies, conversions, temporary intermediates, recomputation, lifecycle detours, or repeated traversals, lookups, or classification of the same set that duplicate dispatch or create order dependence; ownership transfers and asynchronous paths required by the authoritative design are not redundancy;
* unnecessary state, mechanisms, or abstractions;
* missing tests for important behavior or failure paths, judged against the project's test policy.

Principles:

* Project design and explicit project constraints override generic best practices. The project instruction file (for example `AGENTS.md`) governs scope, permissions, test design, and validation; where this skill's generic guidance differs, follow the project instruction file.
* If the target section conflicts with current project design or explicit constraints, establish the applicable requirement from project evidence before judging the implementation. If the conflict remains unresolved, report it as a limitation rather than an implementation defect.
* Do not invent requirements that are not supported by the project.
* Report only issues supported by concrete evidence.
* Working behavior, such as a passing sample, does not exempt an unsound design.
* Prefer the simplest correct implementation.
* Apply Occam's razor: do not add complexity for patterns, standards, theoretical purity, or hypothetical future needs.
* Repeated work is only a problem when it can be removed without making the implementation less clear, less correct, or harder to maintain. Batching with a clear locality, parallelism, or lifecycle benefit is not repeated work.
* Do not require responsibilities that belong to later development stages.
* Merge findings that share a root cause into one finding.
* Recommend the smallest change that fully fixes the issue.
* Do not report style-only preferences unless they create a real correctness or maintenance problem.
* Use plain, direct language. Explain why each issue matters in practical terms while preserving precise project terminology.

## Review Document

Write the results to the review document; create it if it does not exist. Keep one block per reviewed section and modify only that block:

```markdown
## <section>

- Scope: <plan items and change range actually reviewed>
- Conclusion: <concise overall conclusion>
- Evidence gaps: <material gaps and unverified requirements, or "none">

### <section>-R<n> [<severity>] [<status>] <title>

- Location:
- Problem:
- Impact:
- Minimal fix:
- Requirement: <relevant design or plan requirement, when it materially supports the finding>

Fix order: <finding IDs grouped by dependencies>
```

* Severity is `critical`, `important`, or `suggestion`, classified by demonstrated impact: `critical` for confirmed issues with severe or broad consequences, such as unsafe behavior, data/state corruption, or a fundamental design violation; `important` for other actionable confirmed defects or material design and maintenance risks; `suggestion` for worthwhile improvements without a confirmed defect or material risk. Apply the same thresholds to edge cases and design deviations.
* Status is `open`, `fixed`, or `accepted`. New findings are `open`; `fixed` is set by whoever fixes the finding, and `accepted` only by the user or a developer who decides not to fix it.
* List findings by severity; within the same severity, list architecture-level findings before code-organization findings.
* Finding IDs are stable. When re-reviewing a section, keep existing IDs, re-verify `fixed` findings and reopen any that are not actually fixed, number new findings after the highest existing ID, and update the scope, conclusion, evidence gaps, and fix order.
* Limit any "no issues found" conclusion to the material actually reviewed. If no worthwhile issues are found, say so directly. Do not manufacture findings to make the review appear more complete.

## Output

After writing the review document, reply with the review document path, the overall conclusion, the number of open findings by severity, and the fix order.

Unless explicitly requested, do not modify source code or any document other than the review document.
