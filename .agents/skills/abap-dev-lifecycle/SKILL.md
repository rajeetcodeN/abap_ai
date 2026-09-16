---
name: abap-dev-lifecycle
description: >-
  Executes the autonomous end-to-end development lifecycle for SAP ABAP code in this workspace.
  Triggers when the user requests an ABAP feature, bug fix, refactor, performance optimization,
  or unit test authoring. Manages requirements clarification, Clean ABAP code generation, in-memory
  compiler syntax verification, automated ABAP Unit testing with self-healing, and human-in-the-loop
  activation gates. Do NOT use for generic read-only questions where no code modifications are requested.
---

# Autonomous ABAP Development Lifecycle Specification

This skill prescribes the exact operational protocol, state machine transitions, and error-recovery procedures for generating, verifying, and activating ABAP software using the `sap-adt` MCP server and abapGit.

---

## 1. Lifecycle State Machine

The agent must advance through the lifecycle sequentially according to the following state transitions:

```text
[STATE: RECEIVE_REQUEST]
           │
           ▼
[STATE: CLARIFY_REQUIREMENTS] ──(Ambiguities resolved)──┐
           ▲                                             ▼
           │ (Clarification needed)          [STATE: CODE_GENERATION]
           └─────────────────────────────────────────────┤
                                                         ▼
                                             [STATE: SYNTAX_VERIFICATION]
                                                         │
                                           ┌─────────────┴─────────────┐
                                     (Syntax OK)                 (Syntax Error)
                                           │                           │
                                           ▼                           ▼
                               [STATE: TEST_VERIFICATION]   [Auto-Fix & Retry (Max 3)]
                                           │
                             ┌─────────────┴─────────────┐
                        (All Passed)                (Test Failed)
                             │                           │
                             ▼                           ▼
                 [STATE: HUMAN_APPROVAL_GATE]       [Auto-Fix & Retry (Max 3)]
                             │
                      (User Approves)
                             │
                             ▼
                 [STATE: ACTIVATE_AND_COMMIT]
```

---

## 2. Stage-by-Stage Operational Protocol

### Stage 1: Requirements Breakdown and Clarification (`STATE: CLARIFY_REQUIREMENTS`)
* **Objective:** Prevent defective implementations by disambiguating business rules upfront.
* **Protocol:**
  1. Summarize the functional scope, target tables/entities, and business logic.
  2. Ask 1 to 3 targeted clarifying questions regarding:
     * Boundary conditions (e.g. zero, negative, or null values).
     * Error behavior (e.g. custom exception class vs system error).
     * Security authorization objects required (`AUTHORITY-CHECK`).
  3. Await user confirmation before writing any code.

### Stage 2: Code and Unit Test Generation (`STATE: CODE_GENERATION`)
* **Objective:** Produce high-quality, maintainable ABAP conforming to 7.50+ standards.
* **File Separation:**
  * **Main Class Definition & Implementation:** `src/<class_name>.clas.abap`
  * **Local Helpers & Test Classes:** `src/<class_name>.clas.locals_imp.abap`
  * **Class Metadata & Transport Headers:** `src/<class_name>.clas.xml`
* **Clean ABAP Standards Checklist:**
  * Use inline declarations `DATA(var) = ...` at point of assignment.
  * Use constructor expressions: `VALUE #()`, `COND #()`, `SWITCH #()`, `CORRESPONDING #()`.
  * Use string templates `|Text { var }|` instead of `CONCATENATE`.
  * Use table expressions `lt_table[ key = value ]` instead of `READ TABLE`.
  * Implement short, focused methods adhering to the Single Responsibility Principle.
  * *Deep Reference:* See [Clean ABAP Patterns Reference](./references/clean-abap-patterns.md).

### Stage 3: Autonomous Self-Healing Verification Loop (`STATE: SYNTAX_VERIFICATION` and `STATE: TEST_VERIFICATION`)
* **Objective:** Validate code against the live SAP DEV compiler and unit test runner without human intervention.
* **Loop Constraints:** Maximum 3 autonomous remediation iterations per failure mode.

#### Step 3.1: In-Memory Syntax Verification
1. Call MCP tool `sap_check_syntax` with target class name and source code.
2. **If compiler returns errors (`isValid: false`):**
   * Extract error line, offset, and compiler message.
   * Apply matching remediation strategy from the [Error Recovery Matrix](./references/error-recovery-matrix.md).
   * Update source code and call `sap_check_syntax` again.
   * If error persists after 3 iterations, escalate to the user with diagnostic logs.
3. **If compiler returns clean (`isValid: true`):** Advance to Step 3.2.

#### Step 3.2: Inactive Buffer Write
1. Call MCP tool `sap_write_class` to update the inactive buffer on SAP DEV.
2. Verify lock acquisition and buffer persistence.

#### Step 3.3: ABAP Unit Test Execution
1. Call MCP tool `sap_run_unit_tests` for the class.
2. **If any test fails (`failed > 0` or `errors > 0`):**
   * Parse the failing test method and assertion message (`failureMessage`).
   * Diagnose root cause (calculation error, boundary miss, or fixture issue).
   * Modify the implementation in `src/<class_name>.clas.abap` or test double in `src/<class_name>.clas.locals_imp.abap`.
   * Call `sap_write_class` and re-execute `sap_run_unit_tests`.
   * Repeat until `failed == 0` and `errors == 0`.
3. **If all tests pass:** Advance to Stage 4.

### Stage 4: Human-in-the-Loop Activation Gate (`STATE: HUMAN_APPROVAL_GATE`)
* **Mandatory Constraint:** The agent must NEVER call `sap_activate_class` without explicit human confirmation.
* **Protocol:**
  1. Present a concise summary containing:
     * Verification status: Compiler Syntax Valid, Unit Tests Passed (total count).
     * Diff of modified lines.
  2. Prompt the user: *"All compiler syntax checks and ABAP Unit tests passed on SAP DEV. May I proceed with activating the object in SAP and committing to Git?"*

### Stage 5: Activation and Version Control (`STATE: ACTIVATE_AND_COMMIT`)
* **Protocol on User Approval:**
  1. Call MCP tool `sap_activate_class` to activate the inactive buffer in the SAP Data Dictionary.
  2. Verify activation result (`success: true`).
  3. Execute Git commands to stage and commit modified files:
     ```bash
     git add src/
     git commit -m "feat(<scope>): <concise description of verified change>"
     ```
  4. Confirm completion to the user.

---

## 3. Negative Boundaries

* Do NOT use this skill for generic architectural questions that do not involve modifying code.
* Do NOT bypass the syntax check step (`sap_check_syntax`) before writing to the SAP buffer.
* Do NOT commit code to Git if unit tests have not passed.
* Do NOT activate inactive objects on SAP DEV without explicit user approval.
