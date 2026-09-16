# Autonomous Error Recovery Matrix

This reference documents automated diagnostic and remediation protocols used during Stage 3 (Self-Healing Verification Loop).

---

## 1. Compiler Syntax Errors (`sap_check_syntax`)

| Error Pattern | Root Cause | Automated Remediation Strategy |
|---|---|---|
| `Field <NAME> is unknown` | Variable declared after usage or typo in identifier. | 1. Check if identifier was declared in `DATA(...)` later in scope.<br>2. Move inline declaration above first usage.<br>3. Re-run `sap_check_syntax`. |
| `DECIMALS <N> is not allowed for type P` | Obsolete or unsupported decimal syntax in ABAP release. | Replace `TYPE p DECIMALS <N>` with `TYPE decfloat16` or standard data element (e.g. `CURR15_2`). |
| `Type <TYPENAME> is unknown` | Missing DDIC type, non-existent interface, or unimported dictionary element. | 1. Verify standard types (e.g. `STRING`, `I`, `D`, `T`, `DECFLOAT16`).<br>2. Define type locally in `TYPES:` block if custom. |
| `Method <NAME> is not declared in class` | Implementation exists without matching definition in `PUBLIC/PROTECTED/PRIVATE SECTION`. | Ensure method signature is added to class definition before implementing. |
| `The row cannot be placed into the target table` | Incompatible structure type in table insert or `VALUE` expression. | Use `CORRESPONDING #( ... )` or align field types explicitly. |

---

## 2. Inactive Buffer and Locking Errors (`sap_write_class`)

| Error Pattern | Root Cause | Automated Remediation Strategy |
|---|---|---|
| `Object is currently locked by user <USER>` | Previous session held stateful lock or another developer is editing. | Wait 3 seconds, retry `sap_write_class`. If persistent, notify developer. |
| `CSRF token validation failed` | Session expired or CSRF token invalidated. | The MCP client automatically refreshes CSRF token via `/sap/bc/adt/core/discovery` on retry. |

---

## 3. ABAP Unit Test Assertion Failures (`sap_run_unit_tests`)

| Failure Pattern | Root Cause | Automated Remediation Strategy |
|---|---|---|
| `Assertion failed: expected [<EXP>], actual [<ACT>]` | Business logic calculation discrepancy or incorrect expected fixture. | 1. Compare actual return value with calculation formula.<br>2. Determine whether the formula or test fixture has rounding/edge-case discrepancy.<br>3. Adjust logic in `src/<class>.clas.abap`.<br>4. Re-run `sap_write_class` and `sap_run_unit_tests`. |
| `Expected exception <CX_CLASS> was not raised` | Missing boundary validation in business method. | Add input validation condition (e.g., `IF iv_param <= 0. RAISE EXCEPTION ... ENDIF.`). |
| `Unexpected exception <CX_CLASS> was raised` | Unhandled edge condition (e.g., divide by zero, null reference, table key not found). | Wrap vulnerable statement in `TRY...CATCH` or add pre-condition guard (`IF iv_max > 0`). |
