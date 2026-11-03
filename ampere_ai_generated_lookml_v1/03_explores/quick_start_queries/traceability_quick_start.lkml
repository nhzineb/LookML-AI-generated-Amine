# -------------------------------------------------------------------------
# Quick Start Queries for Explore: +traceability
# -------------------------------------------------------------------------
include: "/03_explores/traceability.explore.lkml"

explore: +traceability {

  query: req_coverage_by_domain {
    label: "1. Requirement Test Case Coverage by Domain"
    description: "Compares total requirements vs. test-covered requirements across engineering domains."
    dimensions: [
      gold_dim_req.req_domain,
      gold_dim_req.req_asil
    ]
    measures: [
      gold_dim_req.count_requirements,
      gold_dim_req.count_covered_requirements,
      gold_dim_req.requirement_test_coverage_rate,
      gold_dim_fact_req_tc.count_covered_test_cases
    ]
    sorts: [gold_dim_req.count_requirements: desc]
  }

  query: test_execution_verdict_by_testset_baseline {
    label: "2. Test Execution Pass Rate by Test Set Baseline & MySF"
    description: "Analyzes Test Run execution progress and Pass/Fail verdicts by Test Set Baseline and TR MySF."
    dimensions: [
      gold_dim_ts.ts_baseline,
      fact_tc_tr_ts_req.tr_my_sf,
      tbl_cb_sdv_raw_tr_v2.normalized_result
    ]
    measures: [
      gold_dim_ts.count_test_sets,
      tbl_cb_sdv_raw_tr_v2.count_test_runs,
      tbl_cb_sdv_raw_tr_v2.count_executed_test_runs,
      tbl_cb_sdv_raw_tr_v2.count_passed_test_runs,
      tbl_cb_sdv_raw_tr_v2.count_failed_test_runs,
      tbl_cb_sdv_raw_tr_v2.pass_rate
    ]
    sorts: [tbl_cb_sdv_raw_tr_v2.count_test_runs: desc]
  }

  query: failed_test_runs_and_open_issues {
    label: "3. Failed Test Runs & Linked Open Defects"
    description: "Tracks failed Test Runs, linked Issues/Defects, and resolution duration."
    dimensions: [
      gold_dim_req.req_domain,
      tbl_cb_sdv_raw_tr_v2.name,
      tbl_cb_sdv_raw_tr_v2.result,
      tbl_cb_sdv_raw_issue_v2.status,
      tbl_cb_sdv_raw_issue_v2.resolution
    ]
    measures: [
      tbl_cb_sdv_raw_tr_v2.count_failed_test_runs,
      tbl_cb_sdv_raw_issue_v2.count_issues,
      tbl_cb_sdv_raw_issue_v2.count_open_issues,
      tbl_cb_sdv_raw_issue_v2.avg_resolution_duration_days
    ]
    filters: [tbl_cb_sdv_raw_tr_v2.is_failed: "yes"]
    sorts: [tbl_cb_sdv_raw_issue_v2.count_open_issues: desc]
  }
}
