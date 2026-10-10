---
name: dev-plan-rr
description: Review and, when evidence permits, directly revise a specified development-plan section against the current implementation, core design, and only directly relevant industrial standards and mature engineering practices.
---

# Review Development Plan

## Inputs

- **Core Design Document**: path to the core design document.
- **Development Plan Document**: path to the development plan document to modify.
- **Target Section**: the chapter or section in the development plan to review and revise.

Determine all three inputs from the request and available context. If any remains ambiguous, ask the user before editing; do not guess. If a required document or target section cannot be read, report the blocker and do not revise the affected section.

## Instructions

Review the **Target Section** against the actual current implementation and the **Core Design Document**, then revise that section in the **Development Plan Document** where the evidence supports a final decision.

During the review:

- Treat the actual implementation as the factual baseline. Inspect relevant code and existing capabilities; do not infer implementation details from documentation alone.
- If implementation evidence required for a material technical decision cannot be inspected, do not infer the missing facts or fabricate a final revision for that decision. Report the missing evidence as a blocking condition.
- Check whether the plan correctly builds on the current implementation, duplicates existing capabilities, misses established constraints, or introduces unnecessary changes.
- Check alignment with the core design, but do not follow it mechanically. If engineering facts or a clearly better long-term solution show that the core design is wrong or incomplete, establish the necessary correction and update the Core Design Document; invoking this skill authorizes that update unless the user or project constraints restrict it. If the correction cannot be made, do not finalize a conflicting plan decision; report the blocker.
- Check industrial standards and mature engineering practices only when they are directly relevant to the solution's core correctness, safety, critical performance, lifecycle, or key contracts. Do not produce broad standards surveys, generic theory, or boilerplate best practices. Distinguish actual standard requirements from common practice and project-specific decisions.
- Verify the applicable version and relevant provision of any claimed standard requirement against an authoritative source, and cite it when it materially affects the plan. If the source cannot be verified, treat the claim as unconfirmed and do not base a final decision on it.
- Check whether implementation steps are ordered and sized for human review. Each step must represent a meaningful capability with clear dependencies and a diff a reviewer can fully understand in one sitting. Estimate each step's change scale from the code it will actually touch. Treat a step as oversized when it is expected to exceed roughly 400 changed lines (added plus deleted) of non-test, non-generated, non-documentation code, introduces more than one new core invariant, state machine, or ownership relationship, or mixes behavior changes with a refactor, move, or mechanical migration that needs its own review. Small local adjustments required by the behavior change itself are part of that change.
- Split oversized steps in this order: (1) separate preparatory refactors, moves, and mechanical migrations from behavior changes; (2) freeze a contract first only when the contract itself is a review decision point, such as Public API/ABI, cross-layer interfaces, or complex state models; a contract step may contain only definitions that stand without placeholder implementations, such as types, enums, descriptors, and documentation; if the contract includes operations that need implementation, merge it into the minimal working path; (3) slice behavior vertically: a minimal working path first, then additional operations, failure boundaries, and production consumers as separate steps.
- Do not split an ordinary internal class into declaration and implementation steps, and do not split by files or edit operations. Every resulting step must build successfully on its own. Do not require each step to add its own tests; test placement follows the project's test design rules.
- Do not introduce temporary solutions, stubs, intermediate architecture, or other constructs that are expected to be removed later.
- Preserve correct existing content. Change only what has a clear technical reason to change. Do not rewrite steps marked completed or closed-out summaries unless the current implementation contradicts them.

## Result

When evidence supports a final decision and authoritative documents can be kept consistent, do not stop at review comments. **Directly update the specified Target Section in the Development Plan Document into its final executable form.** If a material decision is blocked, complete only independent, supported revisions and report why the affected part cannot be finalized.

Do not substitute intermediate wording such as “to be confirmed,” “recommended option,” or “temporary solution” for a final decision. Do not invent a decision merely to remove an existing placeholder.

After editing, or if a blocker prevents revision, provide a concise summary of:

- key changes and reasons;
- required changes to the current implementation, if any;
- corrections made to the Core Design Document or blocked by scope or evidence, if any;
- material impact from industrial standards or mature practices, if any;
- changes to the implementation sequence, if any;
- unresolved decisions and blockers, if any.

Respond in the user's language unless explicitly requested otherwise.

## Principle

> Use the current implementation as the factual baseline, the core design as the architectural reference, and only directly relevant industrial standards and mature practices as validation. Where the evidence permits, produce the technically correct, executable, long-term development plan—not mechanical consistency, standards compliance for its own sake, or changes made merely to demonstrate review activity. Otherwise report the blocker rather than infer missing facts.
