# -------------------------------------------------------------------------
# LookML Explore: traceability (Traceability_Explore in Mermaid)
# Central N:1 Star/Constellation Explore anchored on fact_tc_tr_ts_req
# Joins all Gold, Raw & Pre-Aggregated Derived Views using strict N:1 / 1:1
# relationships to prevent fan-out (Chasm Trap) while preserving all view names:
#   - fact_tc_tr_ts_req               (FACT_TC_TR_TS_REQ - Central Bridge Fact)
#   - gold_dim_req                    (gold_dim_req)
#   - dt_req_coverage_and_validation  (Pre-aggregated 1:1 Req Coverage & Validation)
#   - gold_dim_fact_req_tc            (gold_dim_fact_req_tc)
#   - tbl_cb_sdv_raw_tc_v2            (TBL_CB_SDV_Raw_TC_V2 -> TestCase_View)
#   - dt_tc_execution_status          (Pre-aggregated 1:1 TC Execution & 7-Bucket Retest)
#   - gold_dim_ts                     (gold_dim_ts)
#   - tbl_cb_sdv_raw_tr_v2            (TBL_CB_SDV_Raw_TR_V2 -> TestRun_View)
#   - fact_testrun_issue              (FACT_TestRun_Issue)
#   - tbl_cb_sdv_raw_issue_v2         (TBL_CB_SDV_Raw_Issue_V2 -> Issue_View)
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/gold_dim_req_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/gold_dim_ts_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/gold_dim_fact_req_tc_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/fact_tc_tr_ts_req_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/fact_testrun_issue_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/tbl_cb_sdv_raw_tc_v2_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/tbl_cb_sdv_raw_tr_v2_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/tbl_cb_sdv_raw_issue_v2_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/derived_tables/dt_req_coverage_and_validation.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/derived_tables/dt_tc_execution_status.view.lkml"

explore: traceability {
  label: "SDV End-to-End Traceability (Req - TC - TS - TR - Issue)"
  description: "End-to-end Software-Defined Vehicle (SDV) traceability across Requirements (gold_dim_req), Test Cases (tbl_cb_sdv_raw_tc_v2), Test Sets (gold_dim_ts), Test Runs (tbl_cb_sdv_raw_tr_v2), and Issues (tbl_cb_sdv_raw_issue_v2) with strict N:1 join semantics."
  view_name: fact_tc_tr_ts_req
  view_label: "4. Bridge: TC - TR - TS - Req (fact_tc_tr_ts_req)"

  # =======================================================================
  # 1. REQUIREMENT & DERIVED REQ COVERAGE / VALIDATION (many_to_one / one_to_one)
  # =======================================================================

  join: gold_dim_req {
    view_label: "1. Requirement (gold_dim_req)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tc_tr_ts_req.req_id} = ${gold_dim_req.req_id} ;;
  }

  join: dt_req_coverage_and_validation {
    view_label: "1b. Requirement Coverage & Validation KPIs (Board 1, 2.1, 4)"
    type: left_outer
    relationship: one_to_one
    sql_on: ${gold_dim_req.req_id} = ${dt_req_coverage_and_validation.req_id} ;;
  }

  # =======================================================================
  # 2. REQ-TC LINK & TEST CASE + DERIVED TC EXECUTION STATUS (many_to_one / one_to_one)
  # =======================================================================

  join: gold_dim_fact_req_tc {
    view_label: "2. Bridge: Requirement - Test Case (gold_dim_fact_req_tc)"
    type: left_outer
    relationship: many_to_one
    sql_on:
      ${fact_tc_tr_ts_req.req_id} = ${gold_dim_fact_req_tc.req_id}
      AND ${fact_tc_tr_ts_req.tc_id} = ${gold_dim_fact_req_tc.tc_id} ;;
  }

  join: tbl_cb_sdv_raw_tc_v2 {
    view_label: "3. Test Case (tbl_cb_sdv_raw_tc_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tc_tr_ts_req.tc_id} = ${tbl_cb_sdv_raw_tc_v2.id} ;;
  }

  join: dt_tc_execution_status {
    view_label: "3b. Test Case Execution & Retest KPIs (Board 2)"
    type: left_outer
    relationship: one_to_one
    sql_on: ${tbl_cb_sdv_raw_tc_v2.id} = ${dt_tc_execution_status.tc_id} ;;
  }

  # =======================================================================
  # 3. TEST SET & TEST RUN (many_to_one)
  # =======================================================================

  join: gold_dim_ts {
    view_label: "5. Test Set (gold_dim_ts)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tc_tr_ts_req.ts_id} = ${gold_dim_ts.ts_id} ;;
  }

  join: tbl_cb_sdv_raw_tr_v2 {
    view_label: "6. Test Run (tbl_cb_sdv_raw_tr_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_tc_tr_ts_req.tr_id} = ${tbl_cb_sdv_raw_tr_v2.id} ;;
  }

  # =======================================================================
  # 4. TEST RUN ISSUE BRIDGE & ISSUE / DEFECT (many_to_one)
  # =======================================================================

  join: fact_testrun_issue {
    view_label: "7. Bridge: Test Run - Issue (fact_testrun_issue)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${tbl_cb_sdv_raw_tr_v2.id} = ${fact_testrun_issue.tr_id} ;;
  }

  join: tbl_cb_sdv_raw_issue_v2 {
    view_label: "8. Issue / Defect (tbl_cb_sdv_raw_issue_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_testrun_issue.issue_id} = ${tbl_cb_sdv_raw_issue_v2.id} ;;
  }
}
