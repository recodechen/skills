---
name: implementation-review
description: Review a completed section of a development plan against project design, source code, and tests, and record the findings in a review document. Use to find real bugs, incomplete implementation, design deviations, unnecessary complexity or repeated work, and missing critical tests.
---

# Implementation Review

Review the completed implementation identified by the user.

The request should identify:

* `plan_doc`: the development plan file;
* `plan_section`: the completed section to review: one or more completed steps, or a larger group of steps.

It may also identify:

* the code change range, such as a base revision or commit range;
* `review_doc`: the review document path. Default: `<plan_doc stem>_review.md` in the same directory as `plan_doc`.

Accept these in natural language; do not require a fixed argument format.

If `plan_doc` or `plan_section` cannot be identified unambiguously from the request and available context, ask the user for clarification before reviewing; do not guess. If `plan_section` cannot be read, report the blocker rather than infer its content.

If no change range is given, locate the changes from version-control history that reference the step identifiers in `plan_section`. If no matching change is found or the range remains ambiguous, ask the user.

Read `plan_section` first. Review only the steps marked completed under the plan's convention, and list any excluded uncompleted steps in Scope; if none are marked completed, report this and stop. Then read only the relevant design, instruction, source, and test files needed to verify it. When the change range is large, verify it step by step or commit by commit, then consolidate the findings and fix order across the whole `plan_section`.

Check for:

* real bugs, edge-case errors, or incomplete implementation;
* deviations from `plan_section` or project design;
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
* If `plan_section` conflicts with current project design or explicit constraints, establish the applicable requirement from project evidence before judging the implementation. If the conflict remains unresolved, record it under Evidence gaps rather than as an implementation defect.
* Do not invent requirements that are not supported by the project.
* Report only issues supported by concrete evidence. Report an implementation precondition as a finding only when evidence shows it can be violated in a supported scenario, or that a project requirement to state or enforce it is unmet; a precondition alone does not establish a defect. Record unverified risks under Evidence gaps, not as findings. State the material conditions a finding depends on in that finding.
* Working behavior, such as a passing sample, does not exempt an unsound design.
* Prefer the simplest correct implementation.
* Apply Occam's razor: do not add complexity for patterns, standards, theoretical purity, or hypothetical future needs.
* Repeated work is only a problem when it can be removed without making the implementation less clear, less correct, or harder to maintain. Batching with a clear locality, parallelism, or lifecycle benefit is not repeated work.
* Do not require responsibilities that belong to later development stages.
* Merge findings that share a root cause into one finding.
* Do not report style-only preferences unless they create a real correctness or maintenance problem.

## Review Writing

Apply these rules to all of `review_doc`, including Scope, Conclusion, and Evidence gaps, and to the reply. Use the user's language, but keep the template's field labels, severity values, and status values literal; write for a developer with general development experience who did not take part in the implementation or review and has not read the code involved.

* State findings directly, without conversational lead-ins, explanatory prefixes, or labels about the writing style.
* Write short, plain sentences with one point each. Do not chain several conditions, calls, or state changes into one sentence with semicolons or nested clauses.
* Titles must describe the specific behavior, limitation, or missing verification. Avoid abstract titles that do not tell the reader what is wrong.
* `Problem` must explain the triggering condition or uncovered scenario, the current implementation or coverage, and why it is a problem under applicable requirements or demonstrated constraints. Its first sentence states what goes wrong and in which situation, in ordinary words without code identifiers; the mechanism follows. Write a sequence of three or more actions, especially interleaved concurrent actions, as a numbered list with one action per step and the actor named. Say what the code should do before saying what it fails to do. Use a small concrete input or call sequence when it helps the reader follow the issue.
* `Impact` must describe the practical consequence: what becomes incorrect, slower, blocked, harder to change, or otherwise affected. For a design or maintenance finding, explain the specific constraint or repeated work it creates; an immediate runtime failure is not required. Do not substitute vague risk labels for this explanation or present a possible consequence as an observed failure.
* Distinguish implementation defects from test gaps. For a test-only finding, name the uncovered scenario or missing assertion. If no independent source evidence establishes an implementation defect, say that the implementation has not been shown to be wrong; missing coverage alone does not prove broken behavior.
* Put file paths, line numbers, and detailed symbol locations primarily in `Location`. Elsewhere, name a code identifier, field, or API only when the reader needs it to follow or locate the issue, and state its role in words on first use. Use established project terminology, explain project terms that are not common programming vocabulary on first use, and do not coin shorthand, labels, or metaphors.
* Conclusion first states whether open findings remain and, if so, the most important one in plain words. Revision hashes and file lists belong in Scope.
* `Minimal fix` must first state the behavior to correct or the verification to add, then recommend the change that fully addresses the finding with the least added complexity at the correct layer. Least means the fewest new states, mechanisms, and special cases, not the smallest diff; for an implementation defect, remove its root cause instead of adding compensating logic around it. Before prescribing new interfaces, state, mechanisms, or refactoring, establish why existing capabilities cannot meet the requirement. If a materially better fix requires a design decision or work outside `plan_section`, state it briefly and note that it needs a plan revision first.

Example of the expected `Problem` style. Hard to follow:

> After `ttl` expires and `Fetch` returns 404, `Refresh` calls `Load`, which writes `entry` only after the reload returns; no `version` check precedes `Store`.

Readable:

> When two requests refresh the same expired cache entry at the same time, the older result can overwrite the newer one.
> 1. Request A reads version 1 and starts reloading.
> 2. Request B reloads and stores version 2.
> 3. Request A finishes and stores version 1 over version 2.
>
> `Store`, which writes the reloaded entry, should reject a result older than the stored version, but it writes without checking.

## Review Document

Write the results to `review_doc`; create it if it does not exist. Keep one block per reviewed `plan_section` and modify only that block:

```markdown
## <section heading>

- Scope: <plan items and change range actually reviewed>
- Conclusion: <concise overall conclusion>
- Evidence gaps: <material gaps, unverified requirements and risks, or "none">

### <section id>-R<n> [<severity>] [<status>] <title>

- Location:
- Problem:
- Impact:
- Minimal fix:
- Requirement: <relevant design or plan requirement, when it materially supports the finding>
- Status note: <latest status change and supporting evidence; omit until the status changes>

Fix order: <open finding IDs grouped by dependencies, or "none">
```

* `<section heading>` is the reviewed section's title as written in the plan; `<section id>` is its shortest unambiguous identifier in the plan, such as a step or stage number.

* Severity is `critical`, `important`, or `suggestion`, classified by demonstrated impact: `critical` for confirmed issues with severe or broad consequences, such as unsafe behavior, data/state corruption, or a fundamental design violation; `important` for other actionable confirmed defects or material design and maintenance risks; `suggestion` for worthwhile improvements without a confirmed defect or material risk. Apply the same thresholds to edge cases and design deviations.
* Status is `open`, `fixed`, `accepted`, or `dismissed`. New findings are `open`. `fixed` means the reported problem has been resolved and may be set by the fixer or a reviewer who verifies the resolution. `accepted` means a valid finding will not be fixed and may be set only by the user or a developer making that decision. `dismissed` means concrete evidence disproves the original finding and may be set by a reviewer.
* List findings by severity; within the same severity, list architecture-level findings before code-organization findings.
* Finding IDs are stable. When re-reviewing a section, retain existing findings and IDs, re-verify `open` and `fixed` findings, and update their statuses using the definitions above. Reopen a `fixed` or `dismissed` finding when concrete evidence establishes that it is currently valid and unresolved. If a status cannot be verified, retain it and record the gap under Evidence gaps. Number new findings after the highest existing ID, and update Scope, Conclusion, Evidence gaps, and Fix order.
* Record the previous and new statuses and the supporting evidence for the latest status change in `Status note`. Do not replace `Problem` or `Impact` with resolution or acceptance notes. For findings that remain or become `open`, update `Location`, `Problem`, `Impact`, and `Minimal fix` as needed to reflect current evidence.
* Only `open` findings count as unresolved. Base Conclusion, open-finding counts, and Fix order on the updated statuses; Fix order contains only `open` finding IDs.
* Base fix order only on necessary implementation or validation dependencies supported by evidence. A preferred remediation approach alone does not make one finding a prerequisite for another.
* Limit any "no issues found" conclusion to the material actually reviewed. If no worthwhile issues are found, say so directly. Do not manufacture findings to make the review appear more complete.

## Output

After writing `review_doc`, reply with its path, the overall conclusion, the number of open findings by severity, and the fix order. Include a concise explanation of each open finding following Review Writing; do not return only finding IDs or titles.

Unless explicitly requested, do not modify source code or any document other than `review_doc`. Do not run builds, tests, or other checks unless the project instruction file or the user allows it; record verification that matters but was not run under Evidence gaps.
