# -------------------------------------------------------------------------
# LookML Explore: traceability (Traceability_Explore in Mermaid)
# Joins all Gold & LookML views using exact table-matched view names:
#   - gold_dim_req          (gold_dim_req)
#   - gold_dim_fact_req_tc  (gold_dim_fact_req_tc)
#   - tbl_cb_sdv_raw_tc_v2  (TBL_CB_SDV_Raw_TC_V2 -> TestCase_View)
#   - fact_tc_tr_ts_req     (FACT_TC_TR_TS_REQ)
#   - gold_dim_ts           (gold_dim_ts)
#   - tbl_cb_sdv_raw_tr_v2  (TBL_CB_SDV_Raw_TR_V2 -> TestRun_View)
#   - fact_testrun_issue    (FACT_TestRun_Issue)
#   - tbl_cb_sdv_raw_issue_v2 (TBL_CB_SDV_Raw_Issue_V2 -> Issue_View)
# -------------------------------------------------------------------------
include: "/01_views/refinements/gold_dim_req_rfn.view.lkml"
include: "/01_views/refinements/gold_dim_ts_rfn.view.lkml"
include: "/01_views/refinements/gold_dim_fact_req_tc_rfn.view.lkml"
include: "/01_views/refinements/fact_tc_tr_ts_req_rfn.view.lkml"
include: "/01_views/refinements/fact_testrun_issue_rfn.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_tc_v2_rfn.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_tr_v2_rfn.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_issue_v2_rfn.view.lkml"

explore: traceability {
  label: "SDV End-to-End Traceability (Req - TC - TS - TR - Issue)"
  description: "End-to-end Software-Defined Vehicle (SDV) traceability across Requirements (gold_dim_req), Test Cases (tbl_cb_sdv_raw_tc_v2), Test Sets (gold_dim_ts), Test Runs (tbl_cb_sdv_raw_tr_v2), and Issues (tbl_cb_sdv_raw_issue_v2)."
  view_name: gold_dim_req
  view_label: "1. Requirement (gold_dim_req)"
  persist_with: ampere_sdv_gold_etl_datagroup

  # =======================================================================
  # 1. BRIDGE: gold_dim_req -> gold_dim_fact_req_tc -> tbl_cb_sdv_raw_tc_v2
  # =======================================================================

  join: gold_dim_fact_req_tc {
    view_label: "2. Bridge: Requirement - Test Case (gold_dim_fact_req_tc)"
    type: left_outer
    relationship: one_to_many
    sql_on: ${gold_dim_req.req_id} = ${gold_dim_fact_req_tc.req_id} ;;
  }

  join: tbl_cb_sdv_raw_tc_v2 {
    view_label: "3. Test Case (tbl_cb_sdv_raw_tc_v2)"
    type: full_outer
    relationship: many_to_one
    sql_on: ${gold_dim_fact_req_tc.tc_id} = ${tbl_cb_sdv_raw_tc_v2.id} ;;
  }

  # =======================================================================
  # 2. BRIDGE: fact_tc_tr_ts_req -> gold_dim_ts & tbl_cb_sdv_raw_tr_v2
  # =======================================================================

  join: fact_tc_tr_ts_req {
    view_label: "4. Bridge: TC - TR - TS - Req (fact_tc_tr_ts_req)"
    type: left_outer
    relationship: many_to_many
    sql_on:
      ${fact_tc_tr_ts_req.tc_id} = ${tbl_cb_sdv_raw_tc_v2.id}
      AND (
        ${fact_tc_tr_ts_req.req_id} = ${gold_dim_req.req_id}
        OR ${fact_tc_tr_ts_req.req_id} IS NULL
      ) ;;
  }

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
  # 3. BRIDGE: tbl_cb_sdv_raw_tr_v2 -> fact_testrun_issue -> tbl_cb_sdv_raw_issue_v2
  # =======================================================================

  join: fact_testrun_issue {
    view_label: "7. Bridge: Test Run - Issue (fact_testrun_issue)"
    type: left_outer
    relationship: one_to_many
    sql_on: ${tbl_cb_sdv_raw_tr_v2.id} = ${fact_testrun_issue.tr_id} ;;
  }

  join: tbl_cb_sdv_raw_issue_v2 {
    view_label: "8. Issue / Defect (tbl_cb_sdv_raw_issue_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_testrun_issue.issue_id} = ${tbl_cb_sdv_raw_issue_v2.id} ;;
  }
}
