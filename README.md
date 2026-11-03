# Ampere SDV Traceability LookML Project (`ampere_lookml`)

Enterprise LookML semantic layer for **Ampere Software-Defined Vehicle (SDV)** Requirement, Test Case, Test Set, Test Run, and Issue traceability.

## 1. View-to-Table Mapping (1:1 Exact Table Name Alignment)

Every LookML view has the **exact same name** (in lowercase snake_case) as its underlying physical table:

| Physical Table Name | Schema Source | Mermaid LookML Node | LookML Base View (`01_views/sources/`) | LookML Refinement (`01_views/refinements/`) |
| :--- | :--- | :--- | :--- | :--- |
| `gold_dim_req` | `gold_tables_schema.csv` (48 cols) | `Requirement_View` | `gold_dim_req.view.lkml` | `gold_dim_req_rfn.view.lkml` |
| `gold_dim_ts` | `gold_tables_schema.csv` (41 cols) | `TestSet_View` | `gold_dim_ts.view.lkml` | `gold_dim_ts_rfn.view.lkml` |
| `gold_dim_fact_req_tc` | `gold_tables_schema.csv` (11 cols) | `FACT_Requirement_TestCase` | `gold_dim_fact_req_tc.view.lkml` | `gold_dim_fact_req_tc_rfn.view.lkml` |
| `FACT_TC_TR_TS_REQ` | `gold_tables_schema.csv` (5 cols) | `FACT_TC_TR_TS_REQ` | `fact_tc_tr_ts_req.view.lkml` | `fact_tc_tr_ts_req_rfn.view.lkml` |
| `FACT_TestRun_Issue` | `input_mermaid.mermaid.txt` (2 cols) | `FACT_TestRun_Issue` | `fact_testrun_issue.view.lkml` | `fact_testrun_issue_rfn.view.lkml` |
| `TBL_CB_SDV_Raw_TC_V2` | `raw_tables_schema.csv` (114 cols) | `TestCase_View` | `tbl_cb_sdv_raw_tc_v2.view.lkml` | `tbl_cb_sdv_raw_tc_v2_rfn.view.lkml` |
| `TBL_CB_SDV_Raw_TR_V2` | `raw_tables_schema.csv` (114 cols) | `TestRun_View` | `tbl_cb_sdv_raw_tr_v2.view.lkml` | `tbl_cb_sdv_raw_tr_v2_rfn.view.lkml` |
| `TBL_CB_SDV_Raw_Issue_V2` | `raw_tables_schema.csv` (18 cols) | `Issue_View` | `tbl_cb_sdv_raw_issue_v2.view.lkml` | `tbl_cb_sdv_raw_issue_v2_rfn.view.lkml` |

> **Why are upstream Silver tables (`TBL_CB_SDV_Raw_Req_V2`, `TBL_CB_SDV_Raw_TS_V2`, `TBL_CB_SDV_Raw_ISP_V2`, `TBL_CB_SDV_Raw_Initiative_V2`) NOT in LookML?**
> Those Silver tables are already consolidated upstream into `gold_dim_req` and `gold_dim_ts` in the Gold layer. Only the tables that directly feed the LookML layer in `input_mermaid.mermaid.txt` are modeled as LookML views.

## 2. Folder Structure (`Renault LookML Standard`)

```text
ampere_lookml/
├── manifest.lkml
├── README.md
├── 00_adm/
│   └── datagroup/
│       └── datagroups.lkml
├── 01_views/
│   ├── sources/
│   │   ├── gold_dim_req.view.lkml
│   │   ├── gold_dim_ts.view.lkml
│   │   ├── gold_dim_fact_req_tc.view.lkml
│   │   ├── fact_tc_tr_ts_req.view.lkml
│   │   ├── fact_testrun_issue.view.lkml
│   │   ├── tbl_cb_sdv_raw_tc_v2.view.lkml
│   │   ├── tbl_cb_sdv_raw_tr_v2.view.lkml
│   │   └── tbl_cb_sdv_raw_issue_v2.view.lkml
│   ├── refinements/
│   │   ├── gold_dim_req_rfn.view.lkml
│   │   ├── gold_dim_ts_rfn.view.lkml
│   │   ├── gold_dim_fact_req_tc_rfn.view.lkml
│   │   ├── fact_tc_tr_ts_req_rfn.view.lkml
│   │   ├── fact_testrun_issue_rfn.view.lkml
│   │   ├── tbl_cb_sdv_raw_tc_v2_rfn.view.lkml
│   │   ├── tbl_cb_sdv_raw_tr_v2_rfn.view.lkml
│   │   └── tbl_cb_sdv_raw_issue_v2_rfn.view.lkml
│   └── derived_tables/
├── 02_data_tests/
│   └── traceability.test.lkml
├── 03_explores/
│   ├── traceability.explore.lkml
│   └── quick_start_queries/
│       └── traceability_quick_start.lkml
├── 04_models/
│   └── ampere_sdv_traceability.model.lkml
├── 05_dashboards/
│   └── sdv_traceability_execution.dashboard.lookml
└── 06_translations/
    └── en.strings.json
```
