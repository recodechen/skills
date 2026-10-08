---
name: implementation-review
description: Review a completed section of a development plan against project design, source code, and tests. Use to find real bugs, incomplete implementation, design deviations, unnecessary complexity or repeated work, and missing critical tests.
---

# Implementation Review

Review the completed implementation identified by the user.

The request should identify:

* the development plan file;
* the completed section to review.

Accept these in natural language; do not require a fixed argument format.

If the plan file or target section cannot be identified unambiguously from the request and available context, ask the user for clarification before reviewing; do not guess. If the identified section cannot be read, report the blocker rather than infer its content.

Read the target section first, then read only the relevant design, instruction, source, and test files needed to verify it.

Check for:

* real bugs, edge-case errors, or incomplete implementation;
* deviations from the target section or project design;
* ownership, lifecycle, state, concurrency, or failure-semantic problems;
* avoidable data movement or repeated work, including redundant copies, conversions, temporary intermediates, recomputation, or repeated traversals;
* unnecessary state, mechanisms, abstractions, or duplicate sources of truth;
* missing tests for important behavior or failure paths.

Principles:

* Project design and explicit project constraints override generic best practices.
* If the target section conflicts with current project design or explicit constraints, establish the applicable requirement from project evidence before judging the implementation. If the conflict remains unresolved, report it as a limitation rather than an implementation defect.
* Do not invent requirements that are not supported by the project.
* Report only issues supported by concrete evidence.
* Prefer the simplest correct implementation.
* Apply Occam's razor: do not add complexity for patterns, standards, theoretical purity, or hypothetical future needs.
* Repeated work is only a problem when it can be removed without making the implementation less clear, less correct, or harder to maintain.
* Do not require responsibilities that belong to later development stages.
* Recommend the smallest change that fully fixes the issue.
* Do not report style-only preferences unless they create a real correctness or maintenance problem.
* Use plain, direct language. Explain why each issue matters in practical terms while preserving precise project terminology.

## Output

Start with a concise overall conclusion and state the scope actually reviewed.

State material evidence gaps and unverified requirements separately from actionable findings. Limit any "no issues found" conclusion to the material actually reviewed.

Then list only actionable findings. Number each finding and include:

* severity: `critical`, `important`, or `suggestion`;
* location;
* problem;
* impact;
* minimal fix.

Classify by demonstrated impact: `critical` for confirmed issues with severe or broad consequences, such as unsafe behavior, data/state corruption, or a fundamental design violation; `important` for other actionable confirmed defects or material design and maintenance risks; `suggestion` for worthwhile improvements without a confirmed defect or material risk. Apply the same thresholds to edge cases and design deviations.

Reference the relevant design or plan requirement when it materially supports the finding.

If multiple findings exist, end with a concise fix order using issue numbers only, grouped by dependencies.

If no worthwhile issues are found, say so directly. Do not manufacture findings to make the review appear more complete.

Unless explicitly requested, review only; do not modify source code or documents.
