---
name: implementation-closeout
description: Close out a developer-selected development-plan stage or section using only the plan and core design documents. Summarize the recorded final state, preserve recorded remaining issues and register those affecting later work in the design document, and synchronize confirmed design decisions.
---

# Implementation Closeout

## Inputs

Required:

* `plan_doc`: development-plan document path
* `plan_section`: stage or section selected by the developer for closeout; it may contain multiple groups of steps
* `design_doc`: core design document path

Optional:

* `design_hint`: chapter, module, or keywords that help locate related design content

If `design_hint` is not provided, locate the relevant design sections from the plan content and the two documents' headings and terminology.

## Workflow

1. Read `plan_section` and identify its recorded final solution, completed capabilities, key decisions, validation conclusions and their limits, constraints, and remaining issues.

2. Compare these records with the related content in `design_doc` before editing either document:

   * distinguish confirmed design changes, recorded implementation deviations, and unclear differences using the decisions recorded in the two documents;
   * do not infer passing validation from a completion marker, or treat a recorded implementation deviation as an approved design change;
   * if the documents lack the basis for a material conclusion or design update, report the gap and leave the affected claims unchanged; complete independent, supported edits without inventing missing facts.

3. Close out `plan_section`:

   * remove fine-grained implementation steps, task checklists, chronological execution records, temporary debugging notes, and obsolete alternatives;
   * mark the selected stage or section as closed out using the document's existing convention, without treating remaining issues as resolved;
   * restructure it as a concise, self-contained summary of the recorded final state, retaining internal capability or group structure where useful;
   * preserve, when applicable, the final component/module structure, stable dependencies and contracts, completed capabilities, recorded validation evidence and its limits, recorded verified causes of significant anomalies, downstream handoff constraints, and remaining issues;
   * retain critical decisions and conclusions without preserving the implementation process;
   * preserve remaining issues already recorded in `plan_doc`, including their stated status and constraints; they do not block closeout;
   * apply the plan's document completion conventions within the two-document scope, such as removing a completed capability from a pending-work registry.

4. Update the related content in `design_doc` according to the pre-edit classification:

   * leave correct design unchanged;
   * correct the design only for approved changes;
   * fill important design gaps when `plan_doc` records the confirmed intended behavior;
   * replace original design assumptions when the plan records a different stable solution as confirmed and intended;
   * register remaining issues that affect later work in the part of `design_doc` that tracks pending or unresolved work, following its existing structure and without presenting them as settled design; if `design_doc` has no such part, report the issues instead of creating a new structure.

5. Prefer updating existing design sections instead of creating duplicate descriptions.

## Rules

* The developer decides the timing and scope of closeout. Do not prescribe an implementation, review, or repair schedule.
* Read and edit only `plan_doc` and `design_doc` for closeout, following the project's document ownership rules. Do not inspect review documents or source code, run implementation validation, or fix implementation issues.
* The developer decides which unresolved review issues to record in `plan_doc` and instructs the AI to add them separately; collecting or migrating review findings is outside closeout.
* Use the final state and decisions recorded in the plan together with the authoritative design. Do not rewrite the target design to endorse a remaining implementation deviation.
* Do not redesign the system during closeout.
* Do not copy task breakdowns, debugging history, or implementation chronology into the core design document.
* Convert completed plan sections from execution-oriented descriptions into structural, capability-oriented summaries.
* Preserve the existing terminology, structure, style, and abstraction level of both documents.
* Inspect only the parts of the two documents relevant to `plan_section`.
* Avoid unnecessary edits when the existing design already matches confirmed intended behavior.

## Completion

For a completed closeout, ensure that:

* `plan_section` is a concise record of the documented final state, capabilities, constraints, validation conclusions and their stated limits, and remaining issues;
* `design_doc` reflects the confirmed intended design, including approved changes recorded in the plan, and tracks remaining issues that affect later work;
* known differences are accurately classified and recorded, with remaining implementation deviations distinguished from approved design changes and unresolved matters not presented as settled.

After completion, briefly report:

* what was retained in the plan section;
* what was corrected or added in the design document;
* any significant difference between the original design and final implementation;
* remaining issues preserved from the plan, and which were registered in the design document or reported because it has no place for them;
* any unresolved inconsistency.

Respond in the user's language unless explicitly requested otherwise.
