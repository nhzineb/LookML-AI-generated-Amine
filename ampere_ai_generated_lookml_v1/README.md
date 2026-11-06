# Ampere SDV Traceability LookML Project (`ampere_sdv_analytics`)

Enterprise LookML semantic layer for **Ampere Software-Defined Vehicle (SDV)** Requirement, Test Case, Test Set, Test Run, and Issue traceability, implementing all business logic calculations, dimensions, and measures required to migrate the **SDV Generic KPI Dashboard** (`SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx`).

---

## 1. View-to-Table Mapping (1:1 Physical Table Alignment + Pre-Aggregated Derived Views)

Every physical table in the Gold/Silver BigQuery layer has a **1:1 base view** (`01_views/sources/`) and a **refinement view** (`01_views/refinements/`). In addition, **4 pre-aggregated derived table views** (`01_views/derived_tables/`) implement the cross-entity and multi-grain Looker Studio SQL calculations (`Req_ADAS.txt`, `TC_ADAS.txt`, `TS_ADAS.txt`) with strict `many_to_one` / `one_to_one` join semantics.

### 1.1 Physical Table Views (`01_views/sources/` & `01_views/refinements/`)

| Physical Table Name | Mermaid Node | Base View (`01_views/sources/`) | Refinement View (`01_views/refinements/`) |
| :--- | :--- | :--- | :--- |
| `gold_dim_req` | `Requirement_View` | `gold_dim_req.view.lkml` | `gold_dim_req_rfn.view.lkml` |
| `gold_dim_ts` | `TestSet_View` | `gold_dim_ts.view.lkml` | `gold_dim_ts_rfn.view.lkml` |
| `gold_dim_fact_req_tc` | `FACT_Requirement_TestCase` | `gold_dim_fact_req_tc.view.lkml` | `gold_dim_fact_req_tc_rfn.view.lkml` |
| `FACT_TC_TR_TS_REQ` | `FACT_TC_TR_TS_REQ` | `fact_tc_tr_ts_req.view.lkml` | `fact_tc_tr_ts_req_rfn.view.lkml` |
| `FACT_TestRun_Issue` | `FACT_TestRun_Issue` | `fact_testrun_issue.view.lkml` | `fact_testrun_issue_rfn.view.lkml` |
| `TBL_CB_SDV_Raw_TC_V2` | `TestCase_View` | `tbl_cb_sdv_raw_tc_v2.view.lkml` | `tbl_cb_sdv_raw_tc_v2_rfn.view.lkml` |
| `TBL_CB_SDV_Raw_TR_V2` | `TestRun_View` | `tbl_cb_sdv_raw_tr_v2.view.lkml` | `tbl_cb_sdv_raw_tr_v2_rfn.view.lkml` |
| `TBL_CB_SDV_Raw_Issue_V2` | `Issue_View` | `tbl_cb_sdv_raw_issue_v2.view.lkml` | `tbl_cb_sdv_raw_issue_v2_rfn.view.lkml` |

### 1.2 Pre-Aggregated Derived Views (`01_views/derived_tables/`)

| Derived View Name | Primary Key / Grain | Target Dashboard Boards & Business Logic |
| :--- | :--- | :--- |
| `dt_req_coverage_and_validation` | `req_id` (1:1 with `gold_dim_req`) | **Board 1, Board 2.1 & Board 4**: V-Cycle ordered Engineering Level (`01-SG`..`23-SURS`), `req_linked_child` (*No child required*, *Linked to a child*, *Not linked to a child*), SFReq SWC child coverage (`child_presence_for_each_swc`), `covered_status` (*Covered*, *Not covered*, *Supplier*, *No test expected*), `req_last_results` (*Passed*, *Failed*, *Ongoing*, *Not Executed*, *Not covered*, *Rejected*), and MySF 26.2 / 27.2-only / 28.2-only scope flags. |
| `dt_req_bench_validation` | `req_bench_pk` (`Req_Id × TS_Bench_Type`) | **Board 4**: Per-Bench Requirement validation status (`bench_validation_status`: *Passed*, *Failed*, *Ongoing*, *Not Executed*, *Not covered*, *Rejected*) across SIL, HIL, EIPF, VHL, and SW_Component benches. |
| `dt_tc_execution_status` | `tc_id` (1:1 with `tbl_cb_sdv_raw_tc_v2`) | **Board 2**: `bench_type_documented`, `bench_type_ordered`, `req_link_status` (*Linked*, *Not linked*, *No requirement available*), `tc_is_in_ts`, `tc_is_in_ts_generic`, `tc_is_in_ts_execution`, latest Test Run tie-breaking (`Failed > Blocked > Passed`), and the 7-bucket Retest & Jira Derogation readiness classification (`last_tr_result_ready_to_be_tested`: `1. Passed` .. `7. Failed with Jira derogation`). |
| `dt_ts_release_execution` | `ts_release_exec_pk` (`TC_Id × TS_Id × Release_Type × TS_Release × BL`) | **Board 3**: Unpivots `TS_PCU_Releases`, `TS_PIU_Releases`, `TS_IVC_Releases`, `TS_CDC_Releases`, and `TS_Other_Releases`, extracts Baseline (`BL6`, `BL7`, and combined `BL6_BL7`), computes `last_result_on_release` and `last_result_on_bl`, and provides `COUNT_DISTINCT(TC_Id)` Pass Rate measures for **SWE.6**, **C3V**, **HIL**, **EIPF**, and **VHL**. |

---

## 2. Purpose-Built Explores (`03_explores/`)

All 7 Explores enforce strict `type: left_outer` and `relationship: many_to_one` / `one_to_one` joins (zero fan-out / Chasm Traps):

| Explore Name | File (`03_explores/`) | Base View | Target Dashboard Board / Use Case |
| :--- | :--- | :--- | :--- |
| `requirements_traceability` | `requirements_traceability.explore.lkml` | `gold_dim_req` | **Board 1** (Requirements & Vertical Traceability), **Board 2.1** (Reqs Covered by TC), **Board 4** (Overall Requirement Pass Rate) |
| `tc_horizontal_traceability` | `tc_horizontal_traceability.explore.lkml` | `tbl_cb_sdv_raw_tc_v2` | **Board 2** (TC Bench & Feature Documentation, Req Link Status, TS Generic/Execution Deployment, Latest TR Result & 7-Bucket Retest Readiness) |
| `req_tc_traceability` | `req_tc_traceability.explore.lkml` | `gold_dim_fact_req_tc` | **Board 2 Matrix** (Cross-Entity Requirement × Test Case Traceability Matrix) |
| `ts_pass_rate_by_sw_version` | `ts_pass_rate_by_sw_version.explore.lkml` | `dt_ts_release_execution` | **Board 3** (TS Pass Rate by Bench Type & SW Version: SWE.6, C3V, HIL BL6/BL7, EIPF BL6/BL7, VHL BL6/BL7) |
| `req_pass_rate_by_bench` | `req_pass_rate_by_bench.explore.lkml` | `dt_req_bench_validation` | **Board 4** (Requirement Pass Rate by Engineering Level & Bench Type) |
| `test_run_issue_analysis` | `test_run_issue_analysis.explore.lkml` | `fact_testrun_issue` | **Board 2.4 Drill-Down** (Test Run Defect, Blocker & Jira Derogation Triage) |
| `traceability` | `traceability.explore.lkml` | `fact_tc_tr_ts_req` | **End-to-End Star/Constellation Explore** joining all 8 physical views + 2 1:1 pre-aggregated summary views |

---

## 3. Folder Structure (`Renault LookML Standard`)

```text
LookML-AI-generated-Amine/
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
│       ├── dt_req_coverage_and_validation.view.lkml
│       ├── dt_req_bench_validation.view.lkml
│       ├── dt_tc_execution_status.view.lkml
│       └── dt_ts_release_execution.view.lkml
├── 02_data_tests/
│   └── traceability.test.lkml
├── 03_explores/
│   ├── traceability.explore.lkml
│   ├── requirements_traceability.explore.lkml
│   ├── tc_horizontal_traceability.explore.lkml
│   ├── req_tc_traceability.explore.lkml
│   ├── ts_pass_rate_by_sw_version.explore.lkml
│   ├── req_pass_rate_by_bench.explore.lkml
│   ├── test_run_issue_analysis.explore.lkml
│   └── quick_start_queries/
│       └── traceability_quick_start.lkml
├── 04_models/
│   └── ampere_sdv_analytics.model.lkml
├── 05_dashboards/
│   └── sdv_traceability_execution.dashboard.lookml
└── 06_translations/
    ├── en.strings.json
    └── fr.strings.json
```
