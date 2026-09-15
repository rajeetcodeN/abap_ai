# Antigravity SAP ABAP Development Guidelines

This repository (`d:\SAP`) is an abapGit project connected to an SAP DEV system via the **sap-adt** MCP Server. All agents and subagents operating in this workspace must adhere to the following conventions.

---

## 1. abapGit File Structure & Serialization
- All ABAP source files are located in `/src/` as defined in `.abapgit.xml`.
- Standard object naming patterns:
  - Main Class Definition & Global Implementation: `src/<class_name>.clas.abap`
  - Local Class Implementations & Test Classes: `src/<class_name>.clas.locals_imp.abap`
  - Class Metadata & Transport Headers: `src/<class_name>.clas.xml`
  - Package Definition: `src/package.devc.xml`
- Never place non-ABAP code in `/src/`. Place tool configs or server scripts in their dedicated root directories (e.g., `/mcp-sap-adt/`).

---

## 2. ABAP Coding Standards (Modern & Clean ABAP)
- **Target Syntax:** ABAP 7.40+ / 7.50+ / ABAP Cloud (for SAP BTP).
- **Constructs:**
  - Use inline declarations (`DATA(lv_var) = ...`) instead of top-level `DATA:` blocks.
  - Use constructor expressions: `VALUE #()`, `CORRESPONDING #()`, `REF #()`, `NEW #()`.
  - Use string templates `|Hello { lv_name }|` instead of `CONCATENATE`.
  - Use table expressions `lt_table[ key = value ]` instead of `READ TABLE ... WITH KEY ... ASSIGNING ...`.
- **Clean ABAP Guidelines:**
  - Keep methods short and focused on a single responsibility.
  - Descriptive, camelCase or snake_case identifiers; avoid legacy Hungarian notation prefixes for local variables.
  - Fail fast with exceptions (`CX_STATIC_CHECK` / `CX_NO_CHECK`) instead of returning arbitrary integer sy-subrc codes.

---

## 3. Quality & Security Safeguards
- **SQL Injection Prevention:** Never concatenate user input directly into dynamic Open SQL statements. Use parameterized queries or sanitize with `CL_ABAP_DYN_PRG`.
- **Authorization Checks:** Any public method or service exposing sensitive business data must perform explicit `AUTHORITY-CHECK` statements.
- **Performance:** Avoid `SELECT` statements inside loops. Prefer CDS views, inner/outer joins, or `FOR ALL ENTRIES`.
- **Client Handling:** Do not hardcode client (`MANDT`) values. Rely on automatic SAP client handling.

---

## 4. MCP Tools & Safety Governance
- **Syntax Pre-check:** Always validate ABAP code using the MCP tool `sap_check_syntax` before proposing commits or activations.
- **Unit Tests:** Always implement ABAP Unit tests in `.clas.locals_imp.abap` and execute them with `sap_run_unit_tests` to verify test coverage.
- **Activation Gate:** **Never activate code on the live SAP instance without explicit user review.** Use `sap_activate_class` only after user confirmation.
