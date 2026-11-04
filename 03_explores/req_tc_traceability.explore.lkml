# -------------------------------------------------------------------------
# LookML Explore: req_tc_traceability
# Purpose: Powers Board 2 Cross-Entity Requirement x Test Case Matrix
# Grain: 1 row per Requirement-to-Test-Case link (gold_dim_fact_req_tc)
# -------------------------------------------------------------------------
include: "/01_views/refinements/gold_dim_fact_req_tc_rfn.view.lkml"
include: "/01_views/refinements/gold_dim_req_rfn.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_tc_v2_rfn.view.lkml"
include: "/01_views/derived_tables/dt_req_coverage_and_validation.view.lkml"
include: "/01_views/derived_tables/dt_tc_execution_status.view.lkml"

explore: req_tc_traceability {
  label: "Board 2 Matrix: Requirement to Test Case Link Analysis"
  description: "Bridge-grain Explore joining Requirements (gold_dim_req) and Test Cases (tbl_cb_sdv_raw_tc_v2) with their pre-aggregated Coverage and Execution status views using strict N:1 joins."
  view_name: gold_dim_fact_req_tc
  view_label: "1. Req - TC Bridge (gold_dim_fact_req_tc)"
  persist_with: ampere_sdv_gold_etl_datagroup

  join: gold_dim_req {
    view_label: "2. Requirement (gold_dim_req)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${gold_dim_fact_req_tc.req_id} = ${gold_dim_req.req_id} ;;
  }

  join: dt_req_coverage_and_validation {
    view_label: "2b. Requirement Coverage & Validation KPIs"
    type: left_outer
    relationship: many_to_one
    sql_on: ${gold_dim_fact_req_tc.req_id} = ${dt_req_coverage_and_validation.req_id} ;;
  }

  join: tbl_cb_sdv_raw_tc_v2 {
    view_label: "3. Test Case (tbl_cb_sdv_raw_tc_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${gold_dim_fact_req_tc.tc_id} = ${tbl_cb_sdv_raw_tc_v2.id} ;;
  }

  join: dt_tc_execution_status {
    view_label: "3b. Test Case Execution & Retest KPIs"
    type: left_outer
    relationship: many_to_one
    sql_on: ${gold_dim_fact_req_tc.tc_id} = ${dt_tc_execution_status.tc_id} ;;
  }
}
