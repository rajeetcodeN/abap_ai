# abap_ai: End-to-End Architecture, Antigravity Processes, and Capabilities Guide

This guide provides a comprehensive technical and operational breakdown of the **abap_ai** platform. It details the end-to-end workflow, explains each internal process inside Antigravity, outlines SAP connectivity requirements, and explicitly documents the boundary matrix of what the system can and cannot do.

---

## Table of Contents
1. [End-to-End System Workflow](#1-end-to-end-system-workflow)
2. [Internal Processes Inside Antigravity](#2-internal-processes-inside-antigravity)
3. [Connecting to Your On-Premise SAP System](#3-connecting-to-your-on-premise-sap-system)
4. [Dual-Mode Operation: Live SAP vs Offline Simulation](#4-dual-mode-operation-live-sap-vs-offline-simulation)
5. [Capabilities Matrix: What It CAN DO vs What It CANNOT DO](#5-capabilities-matrix-what-it-can-do-vs-what-it-cannot-do)

---

## 1. End-to-End System Workflow

The lifecycle connects the initial business request directly to the SAP DEV system while maintaining strict quality gates and version control.

```text
[ Business Requester ] ──(Voice or Text Requirement)──> [ n8n Intake Webhook ]
                                                              │
                                                              ▼
                                                 [ Standardized JSON Ticket ]
                                                              │
                                                              ▼
                                                   [ SAP Lead / Expert ]
                                              (Enriches tables, BAdIs, scope)
                                                              │
                                                              ▼
                                                    [ Antigravity AI Engine ]
                                                  (Mounts abap-dev-lifecycle)
                                                              │
                                                              ▼
                                                  [ Generates Clean ABAP in src/ ]
                                                              │
                                                              ▼
                                        ┌──────────────────────────────────────────────┐
                                        │ Autonomous Self-Healing Loop (mcp-sap-adt)   │
                                        │ 1. Calls /sap/bc/adt/syntaxcheck             │
                                        │ 2. Calls /sap/bc/adt/oo/classes (buffer)     │
                                        │ 3. Calls /sap/bc/adt/abapunit/testruns       │
                                        │ 4. Auto-fixes errors until 100% passed       │
                                        └──────────────────────┬───────────────────────┘
                                                              │
                                                              ▼
                                                   [ Human Approval Gate ]
                                               (Lead Developer reviews diff)
                                                              │
                                                              ▼
                                              [ Activation on SAP DEV & Git Push ]
                                                              │
                                                              ▼
                                              [ abapGit Pulls into SAP Package ]
                                                              │
                                                              ▼
                                              [ Manual CTS Transport Release ]
```

---

## 2. Internal Processes Inside Antigravity

When a prompt enters Antigravity, the AI assistant executes five distinct internal subsystems:

### Process 2.1: Progressive Disclosure and Skill Mounting
* **What happens:** Antigravity reads the frontmatter of `.agents/skills/abap-dev-lifecycle/SKILL.md`.
* **Behavior:** The skill description serves as a trigger classifier. When a user prompt requests an ABAP feature, bug fix, or refactor, Antigravity mounts the lifecycle state machine and applies the rules in `GEMINI.md`.

### Process 2.2: The 4-Stage State Machine
The agent progresses through a formal sequential state machine:
1. **`STATE: CLARIFY_REQUIREMENTS`:**
   * Summarizes the functional scope and data entities.
   * Asks 1 to 3 targeted boundary questions (handling null/zero values, return types, exception classes).
   * Holds execution until the user confirms rules.
2. **`STATE: CODE_GENERATION`:**
   * Produces the main class definition and implementation in `src/<class_name>.clas.abap`.
   * Produces the local test class in `src/<class_name>.clas.locals_imp.abap`.
   * Generates abapGit XML metadata in `src/<class_name>.clas.xml`.
3. **`STATE: SYNTAX_VERIFICATION` & `STATE: TEST_VERIFICATION`:**
   * Orchestrates the autonomous testing loop without asking the developer at each iteration.
4. **`STATE: HUMAN_APPROVAL_GATE`:**
   * Halts execution and presents the verified diff and test report to the user.
5. **`STATE: ACTIVATE_AND_COMMIT`:**
   * Executes activation in the SAP Dictionary and commits changes to Git.

### Process 2.3: Stdio MCP Protocol Layer
* **How it communicates:** Antigravity spawns the local process `node d:/SAP/mcp-sap-adt/dist/index.js` over standard input/output (stdio).
* **Security:** Tool requests and responses are sent as JSON-RPC messages. Credentials stored in `mcp-sap-adt/.env` never leave the local machine.

### Process 2.4: Bounded Self-Healing Loop
* If `sap_check_syntax` returns compiler errors, the agent parses the line number, offset, and error code.
* It consults `.agents/skills/abap-dev-lifecycle/references/error-recovery-matrix.md` to select the exact remediation strategy.
* The agent applies the fix and re-checks the syntax.
* **Safety Bound:** The loop allows a maximum of 3 autonomous retries per failure mode. If an issue is not resolved in 3 iterations, the agent halts and escalates full diagnostic logs to the developer.

---

## 3. Connecting to Your On-Premise SAP System

### 3.1 SAP-Side Requirements (One-Time Check in SAP GUI)
No custom transports or basis modifications are needed. Only verify two standard settings:
1. **Transaction `SICF`:**
   * Path: `/default_host/sap/bc/adt`
   * Ensure the service and all child nodes (`discovery`, `oo/classes`, `syntaxcheck`, `activation`, `abapunit`) are active.
2. **Transaction `SU01`:**
   * Developer user must have authorization object `S_DEVELOP` (`OBJTYPE: CLAS, PROG, INTF`, `ACTVT: 01, 02, 03`).
   * Authorization object `S_RFC_ADM` or `S_ICF` for HTTP connectivity.

### 3.2 Workstation Configuration (`mcp-sap-adt/.env`)
Set your on-premise connection parameters in `mcp-sap-adt/.env`:
```env
SAP_URL=http://sapdev.company.corp:8000
SAP_CLIENT=100
SAP_USER=YOUR_USERNAME
SAP_PASSWORD=YOUR_PASSWORD
SAP_LANGUAGE=EN
SAP_ALLOW_SELF_SIGNED=true
```

Test connection:
```powershell
cd mcp-sap-adt
npm run test:ping
```

---

## 4. Dual-Mode Operation: Live SAP vs Offline Simulation

The platform dynamically operates in two modes without requiring code changes:

### Mode A: Live SAP DEV Mode
* **When active:** When `SAP_PASSWORD` is provided and the SAP host is reachable over the network or VPN.
* **What happens:** All compiler checks and unit tests run directly on your live SAP NetWeaver / S/4HANA application server.
* **Result:** 100% identical compiler feedback to Eclipse or SAP GUI.

### Mode B: Offline Simulation Mode
* **When active:** When `SAP_PASSWORD` is empty or `SAP_OFFLINE_MODE=true` is set.
* **What happens:** 
  * `sap_read_class` reads from local `src/`.
  * `sap_check_syntax` validates class structure, statement endings, and Clean ABAP rules locally.
  * `sap_run_unit_tests` parses test classes in `locals_imp.abap` and reports execution results.
  * `sap_write_class` updates local files directly.
* **Value:** Developers can build, test, and refactor ABAP code anywhere without network or VPN access.

---

## 5. Capabilities Matrix: What It CAN DO vs What It CANNOT DO

To maintain enterprise safety, strict governance boundaries are enforced:

### What the Platform CAN DO
* **Generate Clean ABAP 7.50+:** Generates modern object-oriented ABAP using inline declarations, constructor expressions (`VALUE #()`, `COND #()`), and string templates.
* **In-Memory Syntax Checking:** Validates code against the SAP compiler in memory without saving incomplete versions to the database.
* **Automated Unit Testing:** Executes ABAP Unit test suites (`CL_AUNIT_ASSERT`) on the SAP server and returns execution times and assertion failure traces.
* **Self-Healing Error Correction:** Diagnoses compiler messages and failed unit tests, adjusts the code, and re-verifies automatically.
* **Stateful Session Management:** Manages CSRF token handshakes, session cookies, object locking, buffer updates, and unlocks.
* **Dictionary Activation:** Activates inactive objects in the SAP Data Dictionary after developer confirmation.
* **Git Version Control:** Structures code according to abapGit schema (`src/*.clas.abap`, `src/*.clas.locals_imp.abap`, `src/*.clas.xml`), manages branches, and handles commits.
* **Two-Way abapGit Synchronization:** Pulls and pushes changes between GitHub and SAP packages via transaction `ZABAPGIT`.
* **Security Auditing:** Evaluates code for SQL injection hazards, enforces `CL_ABAP_DYN_PRG` sanitization, and verifies `AUTHORITY-CHECK` statements.

### What the Platform CANNOT DO (Strict Safety Boundaries)
* **CANNOT Deploy Directly to QA or Production:** The toolset has no access to QA or Production environments. All interactions are restricted strictly to the development client configured in `.env`.
* **CANNOT Release Transports Automatically:** Releasing Workbench Transport Requests (`SE09`/`SE10`) to transport code out of DEV requires manual review and release by an authorized SAP developer or Basis administrator.
* **CANNOT Bypass SAP Security Roles:** The MCP server executes strictly under the authenticated user's SAP developer credentials. It cannot perform any operation that the user's SAP profile does not permit.
* **CANNOT Execute Arbitrary OS Commands on SAP:** The tool communicates exclusively over standard HTTP/HTTPS REST endpoints under `/sap/bc/adt`. It cannot execute OS commands, access the file system of the SAP host, or touch internal database schemas.
* **CANNOT Activate Code Without Human Approval:** The AI is strictly barred by system rules from activating objects in the SAP dictionary without explicit developer confirmation in the chat.
* **CANNOT Leak Credentials to Git:** Secrets stored in `.env` are protected by `.gitignore` and are never committed to version control.

