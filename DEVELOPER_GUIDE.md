# Developer Guide: abap_ai Onboarding, Setup, and Daily Workflow

This handbook provides comprehensive instructions for developers and administrators using the **abap_ai** development engine. It covers setup for both **Windows** and **macOS**, roles and responsibilities, everyday usage, and troubleshooting.

---

## Table of Contents
1. [Roles and Responsibilities (Who Does What)](#roles-and-responsibilities-who-does-what)
2. [Prerequisites: What You Need vs What You Do Not Need](#prerequisites-what-you-need-vs-what-you-do-not-need)
3. [Setup for Windows Developers](#setup-for-windows-developers)
4. [Setup for macOS Developers](#setup-for-macos-developers)
5. [Connecting to Your SAP DEV System](#connecting-to-your-sap-dev-system)
6. [Capabilities Catalog (What You Can Do)](#capabilities-catalog-what-you-can-do)
7. [Step-by-Step Daily Workflow](#step-by-step-daily-workflow)
8. [Example Prompts and Real Scenarios](#example-prompts-and-real-scenarios)
9. [Troubleshooting and FAQ](#troubleshooting-and-faq)

---

## Roles and Responsibilities (Who Does What)

### 1. SAP Basis Administrator (or Lead Developer with SICF access)
* **What they do:** Verify that the built-in SAP ADT service is active in transaction `SICF`.
* **What they do NOT do:** They do not install any custom software, transport requests, or third-party code on the SAP server.
* **Information they provide to the team:**
  * SAP Application Server URL (e.g. `http://sapdev.company.corp:8000` or `https://sapdev.company.corp:44300`)
  * SAP Client number (e.g. `100`, `200`, `300`)

### 2. The Developer (Windows or macOS)
* **What they do:**
  1. Clone this Git repository.
  2. Run the automated 1-click setup script (`setup.ps1` on Windows or `setup.sh` on macOS).
  3. Enter their individual SAP developer username and password in `mcp-sap-adt/.env`.
  4. Open Antigravity and start developing with AI assistance.
* **Time required:** Under 5 minutes.

---

## Prerequisites: What You Need vs What You Do Not Need

### What You Need on Your Computer
* **Antigravity:** The AI development environment.
* **Node.js:** v18.0.0 or higher (free from https://nodejs.org), required to run the local MCP bridge process.
* **Git:** For version control and team synchronization.
* **Network Connectivity:** Access to your corporate network or VPN to reach the SAP DEV server.

### What You DO NOT Need
* **No Eclipse or ABAP Development Tools (ADT) plugin:** You do not need to install Eclipse, Java JDKs, or Eclipse plugins. The local MCP server handles all ADT communication directly.
* **No SAP GUI required for coding:** Writing code, checking syntax, and running unit tests happen inside Antigravity. (Mac users do not need SAP GUI for Java).
* **No local SAP NetWeaver installation:** SAP runs on your company's server, not your laptop.
* **No paid commercial licenses:** This setup is 100% free and open-source.

---

## Setup for Windows Developers

### Step 1: Clone the Repository
Open PowerShell and clone the repository:
```powershell
git clone https://github.com/rajeetcodeN/abap_ai.git
cd abap_ai
```

### Step 2: Run the Automated Setup Script
Run the automated installer:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

The script automatically:
* Verifies Node.js is installed.
* Installs dependencies and compiles TypeScript in `mcp-sap-adt/`.
* Creates `mcp-sap-adt/.env` from `.env.example` if it does not already exist.
* Automatically registers the `sap-adt` server into your Antigravity configuration (`C:\Users\<username>\.gemini\config\mcp_config.json`) with the correct local path.

---

## Setup for macOS Developers

Mac users can develop ABAP without touching SAP GUI for Java or Windows virtual machines.

### Step 1: Clone the Repository
Open Terminal and clone the repository:
```bash
git clone https://github.com/rajeetcodeN/abap_ai.git
cd abap_ai
```

### Step 2: Run the Automated Setup Script
Make the script executable and run it:
```bash
chmod +x ./setup.sh && ./setup.sh
```

The script automatically:
* Verifies Node.js is installed.
* Installs dependencies and compiles TypeScript in `mcp-sap-adt/`.
* Creates `mcp-sap-adt/.env`.
* Registers the `sap-adt` server into your Mac Antigravity configuration (`~/.gemini/config/mcp_config.json`).

---

## Connecting to Your SAP DEV System

Both Windows and macOS users configure their connection in `mcp-sap-adt/.env`:

1. Open `mcp-sap-adt/.env` in your editor.
2. Fill in your SAP system parameters:
   ```env
   SAP_URL=http://your-sap-host.company.corp:8000
   SAP_CLIENT=100
   SAP_USER=YOUR_SAP_USERNAME
   SAP_PASSWORD=YOUR_SAP_PASSWORD
   SAP_LANGUAGE=EN
   SAP_ALLOW_SELF_SIGNED=true
   ```
   *(Note: `mcp-sap-adt/.env` is git-ignored and will never be committed to Git).*

3. Test your connection:
   ```bash
   cd mcp-sap-adt
   npm run test:ping
   ```

**Successful Output:**
```json
{
  "success": true,
  "url": "http://your-sap-host.company.corp:8000",
  "client": "100",
  "user": "YOUR_SAP_USERNAME",
  "csrfReceived": true,
  "message": "Successfully connected to SAP ADT service and acquired CSRF session token."
}
```

---

## Capabilities Catalog (What You Can Do)

| Capability | Description | How It Works |
|---|---|---|
| **1. Autonomous Feature Creation** | The AI writes ABAP classes and comprehensive ABAP Unit test suites based on plain English requirements. | Implemented via Clean ABAP 7.50+ patterns in `src/`. |
| **2. Real-Time Compiler Syntax Checking** | Validates code against the SAP compiler in memory without saving broken code to the SAP database. | Uses MCP tool `sap_check_syntax`. |
| **3. Automated Self-Healing Loop** | If syntax check or unit tests fail, the AI automatically analyzes the compiler error or assertion failure, fixes the code, and re-tests until all tests pass. | Managed by `.agents/skills/abap-dev-lifecycle`. |
| **4. Live Object Retrieval** | Reads existing custom (`ZCL_*`) or standard (`CL_*`) classes directly from SAP DEV into your workspace. | Uses MCP tool `sap_read_class`. |
| **5. Automated Unit Test Execution** | Executes test suites on the SAP server and parses pass/fail results, assertion messages, and execution times. | Uses MCP tool `sap_run_unit_tests`. |
| **6. Safe Inactive Buffer Activation** | Writes updated code to the SAP inactive buffer and activates it only after developer review and approval. | Uses MCP tools `sap_write_class` and `sap_activate_class`. |
| **7. Code Modernization** | Refactors legacy ECC constructs (`TABLES:`, header lines, nested `SELECT` loops) into high-performance Clean ABAP. | Enforced by workspace rules in `GEMINI.md`. |
| **8. Security and Authority Auditing** | Scans for SQL injection risks, missing `AUTHORITY-CHECK` statements, and client handling. | Evaluated during every code change. |
| **9. Git and abapGit Synchronization** | Tracks all code in Git branches, enables Pull Requests, and syncs to SAP packages using transaction `ZABAPGIT`. | Handled via local Git and `.abapgit.xml`. |

---

## Step-by-Step Daily Workflow

### Phase 1: Give a Requirement
Open the Antigravity chat and describe what you want in plain English:
> *"Create an ABAP class ZCL_DISCOUNT_ENGINE. It should take order value and customer tier, apply 10% discount for Gold and 5% for Silver, and throw an exception if amount is negative."*

### Phase 2: Clarification
The AI summarizes the requirement and asks edge-case questions (e.g., boundary values, exception types). You confirm or refine the rules.

### Phase 3: Autonomous Coding and Self-Healing Loop
1. The AI generates the class in `src/<class_name>.clas.abap`.
2. The AI generates the unit tests in `src/<class_name>.clas.locals_imp.abap`.
3. The AI calls `sap_check_syntax` on your SAP system.
   * If a syntax error occurs, the AI diagnoses the error and automatically fixes the code.
4. The AI writes the inactive buffer via `sap_write_class` and executes `sap_run_unit_tests`.
   * If an assertion fails, the AI adjusts the logic and re-runs tests until 100% pass.

### Phase 4: Developer Approval Gate
The AI displays the verified code diff and test report:
> *"All syntax checks and 4 unit tests passed on SAP DEV. May I proceed with activating this object on SAP and committing to Git?"*

### Phase 5: Activation and Version Control
When you approve:
1. The AI calls `sap_activate_class` to activate the object in the SAP Data Dictionary.
2. The AI commits the change to your Git branch.

---

## Example Prompts and Real Scenarios

### Scenario A: Refactoring Legacy ECC Code
> *"Read class ZCL_LEGACY_REPORT from SAP DEV. Modernize it to Clean ABAP 7.50: remove obsolete header lines, replace nested SELECT...ENDSELECT with an inner join, and verify syntax against the compiler."*

### Scenario B: Adding Unit Tests to Existing Code
> *"Inspect class ZCL_TAX_CALCULATOR. Write a comprehensive ABAP Unit test class covering normal calculation, zero tax exemption, and rounding edge cases. Run the tests on SAP DEV and report the results."*

### Scenario C: Developing a New Business Service
> *"Create class ZCL_CUSTOMER_SERVICE with a method to retrieve open delivery items. Ensure an explicit AUTHORITY-CHECK on authorization object V_VBAK_VKO is performed before querying database tables."*

---

## Troubleshooting and FAQ

### 1. Ping test returns: `HTTP 401 Not authorized`
* **Cause:** Wrong username or password in `mcp-sap-adt/.env`, or the user password expired in SAP.
* **Fix:** Verify credentials by logging into SAP GUI or web interface, update `mcp-sap-adt/.env`, and re-test with `npm run test:ping`.

### 2. Ping test returns: `Connection refused` or `ETIMEDOUT`
* **Cause:** Your computer cannot reach the SAP host URL or port.
* **Fix:** Ensure you are connected to the corporate VPN. Verify host and port with your Basis team (default HTTP is `8000`, HTTPS is `44300`).

### 3. Ping test returns: `HTTP 403 Forbidden` or `Service not active`
* **Cause:** The ICF node `/sap/bc/adt` is inactive in SAP.
* **Fix:** Have your Basis administrator activate `/sap/bc/adt` in transaction `SICF`.

### 4. SSL Certificate Error: `SELF_SIGNED_CERT_IN_CHAIN`
* **Cause:** Your on-premise SAP server uses an internal corporate SSL certificate.
* **Fix:** Ensure `SAP_ALLOW_SELF_SIGNED=true` is set in `mcp-sap-adt/.env`.

### 5. Does the MCP server need to be started manually?
* **No.** Antigravity automatically starts and stops the MCP server process over standard input/output (stdio) when needed.
