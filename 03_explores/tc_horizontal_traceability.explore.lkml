# -------------------------------------------------------------------------
# LookML Explore: tc_horizontal_traceability
# Purpose: Powers Board 2 (Test Cases & Horizontal Traceability):
#   - TC Bench Type & Feature Documentation Status
#   - TC Linked to Requirement Status (Linked / Not linked / No req available)
#   - TC Included in Test Set (Any TS / Generic TS / Execution TS)
#   - Latest Test Run Verdict per TC (Passed / Failed / Blocked / Not Executed)
#   - 7-Bucket Retest & Jira Derogation Readiness
# Grain: 1 row per Test Case (tbl_cb_sdv_raw_tc_v2.id), preserving 100% of
#        Test Cases including unexecuted and unlinked Test Cases.
# -------------------------------------------------------------------------
include: "/01_views/refinements/tbl_cb_sdv_raw_tc_v2_rfn.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_tr_v2_rfn.view.lkml"
include: "/01_views/refinements/gold_dim_ts_rfn.view.lkml"
include: "/01_views/derived_tables/dt_tc_execution_status.view.lkml"

explore: tc_horizontal_traceability {
  label: "Board 2: Test Cases & Horizontal Traceability"
  description: "Test-Case-grain Explore for Board 2 (TC Bench Type & Feature Documentation, Req Link Status, Generic vs Execution Test Set Deployment, Latest TR Result, and 7-Bucket Retest & Jira Derogation Readiness)."
  view_name: tbl_cb_sdv_raw_tc_v2
  view_label: "1. Test Case Attributes (tbl_cb_sdv_raw_tc_v2)"

  join: dt_tc_execution_status {
    view_label: "2. TC Horizontal Traceability & Retest KPIs (Board 2)"
    type: left_outer
    relationship: one_to_one
    sql_on: ${tbl_cb_sdv_raw_tc_v2.id} = ${dt_tc_execution_status.tc_id} ;;
  }

  join: latest_test_run {
    from: tbl_cb_sdv_raw_tr_v2
    view_label: "3. Latest Test Run Details (tbl_cb_sdv_raw_tr_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_tc_execution_status.last_tr_id} = ${latest_test_run.id} ;;
  }

  join: latest_test_set {
    from: gold_dim_ts
    view_label: "4. Latest Test Set Details (gold_dim_ts)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_tc_execution_status.last_ts_id} = ${latest_test_set.ts_id} ;;
  }
}
