---
name: abap-dev-lifecycle
description: >-
  Use this skill whenever the user requests an ABAP feature, bug fix, refactor, or test creation.
  It executes an autonomous 4-stage lifecycle: Requirements Clarification -> Clean ABAP Coding -> 
  Automated Self-Healing Loop (Syntax & Unit Tests on SAP DEV via MCP) -> User Review & Activation Gate.
---

# Autonomous ABAP Development Lifecycle & Self-Healing Loop

This skill guides the agent through an automated, closed-loop development process for SAP ABAP code using the `sap-adt` MCP server and abapGit.

---

## The 4-Stage Lifecycle

```
[ User Prompt ]
       │
       ▼
Stage 1: Requirements Breakdown & Clarifying Questions
       │ (Explain requirement, ask edge-case questions, await user alignment)
       ▼
Stage 2: Code Generation & Unit Test Authoring
       │ (Write src/*.clas.abap and src/*.clas.locals_imp.abap)
       ▼
Stage 3: Automated Self-Healing Loop (via MCP tools)
  ┌──▶ 1. Call sap_check_syntax on SAP DEV
  │    ├─ Syntax Error? ──▶ Inspect error line & fix code ──┐
  │    └─ Syntax OK?                                        │
  │    2. Call sap_write_class (to inactive buffer)         │
  │    3. Call sap_run_unit_tests on SAP DEV                │
  │    ├─ Test Failed?  ──▶ Inspect assertion & fix code ───┘
  │    └─ All Passed?   ──▶ Exit loop
  ▼
Stage 4: Review & Activation Gate
       │ (Present diff, syntax check & test report to user)
       ▼
[ User Confirms -> sap_activate_class -> Git commit ]
```

---

## Execution Instructions for the Agent

### Stage 1: Requirements Breakdown & Clarification
1. When a user requests a feature or change, **DO NOT immediately write final code**.
2. **Explain the requirement:** Summarize the functional scope, target tables/entities, and business logic.
3. **Ask targeted clarifying questions:**
   - What are the boundary conditions (null/empty inputs, negative values)?
   - Which error/exception behavior is expected (raise custom exception or return status)?
   - Are there specific SAP authorization checks (`AUTHORITY-CHECK`) needed?
4. Once the user aligns or confirms, proceed immediately to Stage 2.

### Stage 2: Code Generation (Clean ABAP)
1. Write the main class definition and implementation in `src/<class_name>.clas.abap`.
   - Use ABAP 7.40+/7.50+ constructs (`VALUE #()`, `CORRESPONDING #()`, inline `DATA(...)`).
   - Keep methods short and focused on single responsibility.
2. Write corresponding ABAP Unit test cases in `src/<class_name>.clas.locals_imp.abap`.
   - Use `FOR TESTING` with `CL_AUNIT_ASSERT`.
   - Include tests for both the happy path and edge cases.

### Stage 3: Automated Self-Healing Verification Loop
Execute this automated loop without asking the user at every step:

1. **Syntax Check:**
   - Call the MCP tool `sap_check_syntax` with the class name and generated code.
   - **If syntax errors exist:** Read the compiler message, line number, and offset. Modify the source code to resolve the syntax error, and call `sap_check_syntax` again.
   - Repeat until `isValid: true`.

2. **Inactive Buffer Write:**
   - Call `sap_write_class` to update the inactive version of the class on SAP DEV.

3. **ABAP Unit Tests:**
   - Call `sap_run_unit_tests` to execute the unit tests on SAP DEV.
   - **If any test fails:** Inspect the `failureMessage` and test method. Modify the code (or test double) to fix the failing assertion, write the buffer again, and re-run unit tests.
   - Repeat until all tests report `passed`.

### Stage 4: User Review & Activation Gate
1. Present the final code diff, the successful syntax status, and the unit test summary to the user.
2. Ask for explicit user confirmation: *"All syntax checks and unit tests passed on SAP DEV. May I proceed with activating the object on SAP and committing to Git?"*
3. **On user approval:**
   - Call `sap_activate_class` to activate the object in the SAP Data Dictionary.
   - Run `git add` and `git commit` to commit the verified changes to the repository.
