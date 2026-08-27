# SAP ABAP Project & Development Workspace

Welcome to your SAP ABAP workspace. This repository contains starter templates and sample code for ABAP development on SAP ECC and SAP S/4HANA.

---

## Supported ABAP Flavors & Patterns

1. **Executable Reports (ALV / OpenSQL)**
   - Selection screen with `SELECT-OPTIONS` / `PARAMETERS`
   - Data fetching with Modern ABAP 7.40+ / 7.50+ Syntax (`NEW`, `VALUE`, `SELECT FROM ... FIELDS ...`)
   - Presentation with `CL_SALV_TABLE` / ALV Grid with custom toolbar actions

2. **Object-Oriented ABAP (OO-ABAP)**
   - Modular Classes (`ZCL_*`) & Interfaces (`ZIF_*`)
   - Clean ABAP patterns, Unit Testing (`CL_AUNIT_ASSERT`), Factory design patterns
   - Custom Exception classes inheriting from `CX_STATIC_CHECK` / `CX_NO_CHECK`

3. **SAP S/4HANA & Modern Cloud ABAP (RAP & CDS)**
   - Core Data Services (`DEFINE VIEW ENTITY ...`)
   - ABAP RESTful Application Programming Model (RAP)
   - OData V2 / V4 Service Definitions and Bindings

4. **Integration & Interface Development**
   - RFC / BAPI Function Modules
   - REST / HTTP Services via `IF_HTTP_EXTENSION`
   - File handling (Application server `OPEN DATASET` & Presentation server `CL_GUI_FRONTEND_SERVICES`)

