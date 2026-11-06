# -------------------------------------------------------------------------
# LookML Explore: ts_pass_rate_by_sw_version
# Purpose: Powers Board 3 (Test Set Pass Rate by Bench Type & SW Version):
#   - SWE.6 Validation Pass Rate by SW Version (PCU/PIU/IVC/CDC/OTHER) & BL
#   - C3V Integration Pass Rate by Bench Type (HIL, EIPF, VHL) & Baseline
#     (BL6, BL7, and combined BL6+BL7)
# Grain: TC_Id x TS_Id x Release_Type x TS_Release x BL
#        (measures use count_distinct on tc_id to match Looker Studio)
# -------------------------------------------------------------------------
include: "/01_views/derived_tables/dt_ts_release_execution.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_tc_v2_rfn.view.lkml"
include: "/01_views/refinements/gold_dim_ts_rfn.view.lkml"
include: "/01_views/refinements/tbl_cb_sdv_raw_tr_v2_rfn.view.lkml"
include: "/01_views/derived_tables/dt_tc_execution_status.view.lkml"

explore: ts_pass_rate_by_sw_version {
  label: "Board 3: TS Pass Rate by Bench Type & SW Version (SWE.6 & C3V)"
  description: "Software-Release-grain Explore for Board 3 tracking Test Case execution verdicts across PCU, PIU, IVC, CDC, and OTHER releases, extracted Baselines (BL6, BL7, BL6+BL7), Validation Teams (SWE.6, C3V), and Bench Types (HIL, EIPF, VHL, SIL)."
  view_name: dt_ts_release_execution
  view_label: "1. TS SW Release & Baseline Execution (Board 3)"

  join: gold_dim_ts {
    view_label: "2. Test Set Attributes (gold_dim_ts)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_ts_release_execution.ts_id} = ${gold_dim_ts.ts_id} ;;
  }

  join: tbl_cb_sdv_raw_tc_v2 {
    view_label: "3. Test Case Attributes (tbl_cb_sdv_raw_tc_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_ts_release_execution.tc_id_int} = ${tbl_cb_sdv_raw_tc_v2.id} ;;
  }

  join: dt_tc_execution_status {
    view_label: "4. Overall TC Execution & Retest Status"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_ts_release_execution.tc_id_int} = ${dt_tc_execution_status.tc_id} ;;
  }

  join: latest_test_run {
    from: tbl_cb_sdv_raw_tr_v2
    view_label: "5. Latest Test Run for TC (tbl_cb_sdv_raw_tr_v2)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_tc_execution_status.last_tr_id} = ${latest_test_run.id} ;;
  }
}
