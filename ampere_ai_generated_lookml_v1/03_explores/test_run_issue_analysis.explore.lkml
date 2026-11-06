# -------------------------------------------------------------------------
# LookML Explore: test_run_issue_analysis
# Purpose: Powers Defect, Blocker & Jira Derogation Triage (Board 2.4 drill-down)
# Grain: 1 row per Test Run x Issue link (fact_testrun_issue)
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/fact_testrun_issue_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/tbl_cb_sdv_raw_tr_v2_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/tbl_cb_sdv_raw_issue_v2_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/tbl_cb_sdv_raw_tc_v2_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/gold_dim_ts_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/derived_tables/dt_tc_execution_status.view.lkml"

explore: test_run_issue_analysis {
  label: "Defect & Jira Derogation Triage (Test Run - Issue)"
  description: "Analyzes Test Runs linked to Jira Issues/Defects, including open vs resolved defects, Jira derogations, fix versions, and resolution duration."
  view_name: fact_testrun_issue
  view_label: "1. Test Run - Issue Link (fact_testrun_issue)"

  join: tbl_cb_sdv_raw_tr_v2 {
    view_label: "2. Test Run (tbl_cb_sdv_raw_tr_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_testrun_issue.tr_id} = ${tbl_cb_sdv_raw_tr_v2.id} ;;
  }

  join: tbl_cb_sdv_raw_issue_v2 {
    view_label: "3. Issue / Defect (tbl_cb_sdv_raw_issue_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_testrun_issue.issue_id} = ${tbl_cb_sdv_raw_issue_v2.id} ;;
  }

  join: tbl_cb_sdv_raw_tc_v2 {
    view_label: "4. Test Case (tbl_cb_sdv_raw_tc_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${tbl_cb_sdv_raw_tr_v2.primary_test_case_id} = ${tbl_cb_sdv_raw_tc_v2.id} ;;
  }

  join: dt_tc_execution_status {
    view_label: "4b. Test Case Retest & Derogation Status"
    type: left_outer
    relationship: many_to_one
    sql_on: ${tbl_cb_sdv_raw_tr_v2.primary_test_case_id} = ${dt_tc_execution_status.tc_id} ;;
  }

  join: gold_dim_ts {
    view_label: "5. Test Set (gold_dim_ts)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${tbl_cb_sdv_raw_tr_v2.test_set} = ${gold_dim_ts.ts_id} ;;
  }
}
