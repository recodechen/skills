---
name: implementation-closeout
description: Close out a completed development-plan section and reconcile the final implementation with the project's authoritative core design document. Use after a planned section has been implemented and its plan and design records need review.
---

# Implementation Closeout

## Inputs

Required:

* `plan_doc`: development-plan document path
* `plan_section`: completed section to close out
* `design_doc`: core design document path

Optional:

* `design_hint`: chapter, module, or keywords that help locate related design content

If `design_hint` is not provided, locate the relevant design sections from the plan content, headings, terminology, and source code.

## Workflow

1. Read `plan_section` and identify the final solution, key decisions, validation conclusions, constraints, and unresolved items.

2. Before editing either document, inspect the relevant source code, tests, existing validation evidence, and related design content:

   * confirm the implementation and the section's required outcomes without inferring a passing validation result from the presence of a test;
   * classify each design/implementation difference as an approved design change, an implementation deviation, or unresolved, using the project's authoritative design decisions;
   * if a required outcome remains unmet, completion cannot be confirmed, or an implementation deviation remains, do not mark the section complete or update affected design claims; report the gap and stop affected edits. If classification is unclear, stop affected edits and request a decision.

3. Close out `plan_section`:

   * remove fine-grained implementation steps, task checklists, chronological execution records, temporary debugging notes, and obsolete alternatives;
   * mark the section as completed using the document's existing convention;
   * restructure it as a concise, self-contained summary of the final implemented state;
   * preserve, when applicable, the final component/module structure, stable dependencies and contracts, completed capabilities, important validation evidence, verified causes of significant anomalies, downstream handoff constraints, and remaining issues;
   * retain critical decisions and conclusions without preserving the implementation process.

4. Update the related content in `design_doc` according to the pre-edit classification:

   * leave correct design unchanged;
   * correct the design only for approved changes;
   * fill important design gaps exposed by the implementation when consistent with confirmed intended behavior;
   * replace original design assumptions when a different stable solution is confirmed as intended.

5. Prefer updating existing design sections instead of creating duplicate descriptions.

## Rules

* Treat the verified current implementation as evidence of what exists; use the project's authoritative design and confirmed decisions to determine intended behavior.
* Use the completed plan, source code, and existing validation evidence together when correcting the design document.
* Do not redesign the system during closeout.
* Do not copy task breakdowns, debugging history, or implementation chronology into the core design document.
* Convert completed plan sections from execution-oriented descriptions into structural, capability-oriented summaries.
* Preserve the existing terminology, structure, style, and abstraction level of both documents.
* Inspect only code and documentation relevant to `plan_section`.
* Avoid unnecessary edits when the existing design already matches confirmed intended behavior.

## Completion

For a completed closeout, ensure that:

* `plan_section` is a concise record of the completed implementation, capabilities, constraints, validation conclusions supported by available evidence, and remaining nonblocking issues;
* `design_doc` reflects the confirmed intended design, including approved changes exposed by the final implementation;
* no known contradiction remains between the plan, design document, and implementation.

Edit only the parts of `plan_doc` or `design_doc` that need correction.

After completion, briefly report:

* what was retained in the plan section;
* what was corrected or added in the design document;
* any significant difference between the original design and final implementation;
* any unresolved inconsistency.