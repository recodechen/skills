---
name: implementation-step
description: Implement a specified step from a development plan according to explicit project constraints, the existing architecture, and the intended design. Use when asked to complete a planned development step, or fix findings recorded by implementation-review, with the smallest correct change and necessary validation.
---

# Implementation Step

Implement the development step identified by the user.

The request should identify:

- the development plan file;
- the target: a step to implement, or findings to fix from the review document written by implementation-review (default: `<plan file stem>_review.md` in the same directory as the plan file). For findings, the reviewed section serves as the target step in the rules below.

Accept these in natural language; do not require a fixed argument format.

If the plan file or target cannot be identified unambiguously from the request and available context, ask the user for clarification before editing; do not guess.

Read the target step or findings first, then read only the relevant design, instruction, source, and test files needed to implement it correctly. If a finding requires a design decision or work outside the reviewed section, do not implement it; report that it needs a plan revision first.

Retrieve context selectively. Prefer targeted symbol, reference, text, or file searches over broadly reading unrelated files or large documents.

Before changing code, understand the existing implementation and the actual intent of the target step.

Preserve established architecture boundaries, ownership, lifecycle, state, data flow, concurrency, and failure semantics unless the target step or a clearly better implementation requires changing them.

## Implementation Principles

- Explicit project constraints override generic best practices. The project instruction file (for example `AGENTS.md`) governs task scope, permissions, test design, and validation; where this skill's generic guidance differs, follow the project instruction file.
- Treat project design as the implementation baseline, not as an immutable rule. Understand the design intent instead of mechanically reproducing the written design.
- If current implementation conditions support a simpler, more correct, or more coherent solution, the design may be adjusted when the change is evidence-based, scoped, and consistent with Occam's razor.
- Do not introduce extra complexity merely to preserve an existing design, but do not change the design merely because another approach exists.
- Implement the target step completely, but do not expand its scope into later development stages.
- Do not invent requirements that are not supported by the project.
- If the target step conflicts with explicit project constraints, do not bypass, weaken, or silently reinterpret those constraints; report the conflict clearly.
- If the existing design no longer fits the current implementation conditions, compare adapting the design with preserving it and choose the simpler, more correct, and more coherent solution. When adjusting the design, explain the reason and the affected scope.
- If a design adjustment changes documented decisions, acceptance criteria, or assumptions of later plan steps, update the affected authoritative documents and plan sections as part of the implementation. If project constraints or task scope prevent the required updates, do not implement a divergent design; report the conflict.
- Prefer the simplest correct implementation that satisfies the current requirement.
- Apply Occam's razor: do not introduce abstractions, layers, mechanisms, configuration, or extensibility without a current requirement.
- Reuse existing mechanisms when they already satisfy the requirement; do not create parallel implementations or duplicate sources of truth.
- Avoid unnecessary data movement or repeated work, including redundant copies, conversions, temporary intermediates, recomputation, or repeated traversals, unless removing them would reduce clarity, weaken correctness, or break clear responsibility boundaries.
- Prefer fixing the underlying cause over adding compensating logic around it.
- Make only the changes required by the target step; avoid unrelated refactoring, cleanup, or formatting.
- Preserve existing user changes and do not revert unrelated modifications.
- Add or update tests only as the project's test policy requires: cover important behavior, boundary conditions, and failure paths introduced or changed by the implementation that existing tests do not already verify. If the project defers formal tests to a stage or group closure, follow that timing instead of adding tests for every step.

## Review Size Guard

Keep each step's diff small enough for a reviewer to fully understand in one sitting. Unless the user explicitly authorizes a larger step, treat the step as oversized when:

- non-test, non-generated, non-documentation code changes are expected to exceed roughly 400 changed lines (added plus deleted);
- the step introduces more than one new core invariant, state machine, or ownership relationship;
- completing the step requires mixing behavior changes with an unplanned refactor, move, or mechanical migration that needs its own review. Small local adjustments required by the behavior change itself are part of that change.

Before editing, estimate the change scale from the code the step will actually touch. During implementation, re-check the actual diff (for example with `git diff --numstat`) whenever the work grows beyond the estimate; count only this step's changes and exclude pre-existing modifications in the working tree.

When the step is or becomes oversized:

- stop coding instead of finishing the oversized step;
- do not shrink the diff by dropping required behavior, failure handling, wiring, or old-path removal;
- keep any partial changes already made; do not revert or continue them;
- report the current change state: which proposed sub-step each partial change belongs to, and whether the changes are known to build (do not start a build only to answer this);
- propose a split into named sub-steps, ordered as preparatory refactors and mechanical migrations first, contract freezes only where the contract is itself a review decision point, then vertical behavior slices; a contract sub-step may contain only definitions that stand without placeholder implementations, such as types, enums, descriptors, and documentation, otherwise merge the contract into the first behavior slice; each sub-step must build on its own and leave no stub or other temporary construct;
- do not rewrite the plan or continue with any sub-step until the user confirms the split; after confirmation, write the confirmed sub-steps into the plan following its numbering convention, then implement only the first sub-step.

## Validation

Run the relevant build and tests within the validation levels, commands, and permissions defined by the project instructions; do not cross a validation boundary the project reserves for the user.

If validation fails:

- diagnose the root cause before changing code;
- make only evidence-based minimal fixes;
- do not make speculative or random changes;
- do not hide an unresolved problem behind repeated trial-and-error edits;
- if the failure is caused by the environment, missing dependencies, unavailable tooling, or an unresolved design conflict, stop further speculative changes and report the cause clearly.

Before concluding, inspect the final changes for:

- accidental scope expansion;
- duplicate logic or duplicate state;
- unnecessary complexity;
- unnecessary copies, conversions, intermediate structures, recomputation, or repeated traversals;
- unintended modifications;
- missing required behavior or critical tests.

When the target is complete under the rule at the end of this skill, record it: mark a completed step using the plan's completion convention without deleting or summarizing its text (if the plan defines no convention, leave the plan unchanged and state completion in the output); set each fixed finding's status to `fixed` in the review document.

## Output

After implementation, provide a concise summary containing:

- what was implemented;
- files materially changed and the approximate change scale, counted as in the Review Size Guard;
- whether the original design was adjusted, and if so, why and within what scope;
- validation performed and its result;
- any requirement not completed and the concrete reason.

Do not list routine edits line by line.

Use plain, direct language while preserving precise project terminology. Respond in the user's language unless explicitly requested otherwise.

Do not claim the step is complete unless the required behavior has been implemented and the relevant validation actually performed passes. If any limitation, conflict, or incomplete item remains, state it clearly.
