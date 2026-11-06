# -------------------------------------------------------------------------
# Quick Start Queries for SDV Explores
#   - +traceability
#   - +requirements_traceability (Board 1, 2.1, 4)
#   - +tc_horizontal_traceability (Board 2)
#   - +ts_pass_rate_by_sw_version (Board 3)
#   - +req_pass_rate_by_bench (Board 4)
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/03_explores/traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/requirements_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/tc_horizontal_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/ts_pass_rate_by_sw_version.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/req_pass_rate_by_bench.explore.lkml"

explore: +traceability {

  query: req_coverage_by_domain {
    label: "1. Requirement Test Case Coverage by Domain"
    description: "Compares total requirements vs. test-covered requirements across engineering domains."
    dimensions: [
      gold_dim_req.req_domain,
      gold_dim_req.req_asil
    ]
    measures: [
      gold_dim_req.requirement_count,
      dt_req_coverage_and_validation.count_requirements_covered,
      dt_req_coverage_and_validation.horizontal_tc_coverage_rate,
      gold_dim_fact_req_tc.distinct_tc_count
    ]
    sorts: [gold_dim_req.requirement_count: desc]
  }

  query: test_execution_verdict_by_testset_baseline {
    label: "2. Test Execution Pass Rate by Test Set Baseline & MySF"
    description: "Analyzes Test Run execution progress and Pass/Fail verdicts by Test Set Baseline and TR MySF."
    dimensions: [
      gold_dim_ts.ts_baseline,
      fact_tc_tr_ts_req.tr_mysf,
      tbl_cb_sdv_raw_tr_v2.normalized_result
    ]
    measures: [
      gold_dim_ts.test_set_count,
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

explore: +requirements_traceability {

  query: board1_req_status_and_child_presence {
    label: "Board 1: Requirement Maturity & Vertical Child Traceability"
    description: "Breakdown of Requirements by Engineering Level, Maturity Status, and Linked Child Presence."
    dimensions: [
      dt_req_coverage_and_validation.req_engineering_level_normalized,
      gold_dim_req.req_status,
      dt_req_coverage_and_validation.req_linked_child
    ]
    measures: [
      gold_dim_req.requirement_count,
      dt_req_coverage_and_validation.count_req_linked_to_child,
      dt_req_coverage_and_validation.vertical_child_coverage_rate
    ]
    sorts: [gold_dim_req.requirement_count: desc]
  }

  query: board2_1_req_covered_by_tc {
    label: "Board 2.1: Requirements Covered by Test Cases"
    description: "Evaluates Covered vs. Not covered vs. Supplier vs. No test expected Requirements by Engineering Level."
    dimensions: [
      dt_req_coverage_and_validation.req_engineering_level_normalized,
      dt_req_coverage_and_validation.covered_status
    ]
    measures: [
      gold_dim_req.requirement_count,
      dt_req_coverage_and_validation.count_requirements_covered,
      dt_req_coverage_and_validation.count_requirements_not_covered,
      dt_req_coverage_and_validation.horizontal_tc_coverage_rate
    ]
    sorts: [gold_dim_req.requirement_count: desc]
  }
}

explore: +tc_horizontal_traceability {

  query: board2_tc_retest_readiness_7_buckets {
    label: "Board 2.4: TC Latest Execution & 7-Bucket Retest Readiness"
    description: "Categorizes Test Cases into the 7 Retest & Jira Derogation Readiness buckets."
    dimensions: [
      dt_tc_execution_status.bench_type_ordered,
      dt_tc_execution_status.last_tr_result_ready_to_be_tested
    ]
    measures: [
      dt_tc_execution_status.total_tc_count,
      dt_tc_execution_status.count_tc_latest_passed,
      dt_tc_execution_status.count_tc_ready_to_retest_failed,
      dt_tc_execution_status.count_tc_failed_with_derogation,
      dt_tc_execution_status.tc_latest_pass_rate
    ]
    sorts: [dt_tc_execution_status.last_tr_result_ready_to_be_tested: asc]
  }
}

explore: +ts_pass_rate_by_sw_version {

  query: board3_swe6_c3v_pass_rate_by_sw_release {
    label: "Board 3: SWE.6 & C3V Pass Rate by SW Version & Baseline"
    description: "Tracks Distinct Test Case execution Pass Rate by Validation Team, Bench Type, Baseline (BL), and SW Version."
    dimensions: [
      gold_dim_ts.ts_validation_team,
      dt_ts_release_execution.bl,
      dt_ts_release_execution.ts_release,
      dt_ts_release_execution.last_result_on_release
    ]
    measures: [
      dt_ts_release_execution.count_distinct_test_cases,
      dt_ts_release_execution.count_passed_tc_on_release,
      dt_ts_release_execution.count_failed_tc_on_release,
      dt_ts_release_execution.ts_release_pass_rate
    ]
    sorts: [dt_ts_release_execution.count_distinct_test_cases: desc]
  }
}

explore: +req_pass_rate_by_bench {

  query: board4_req_pass_rate_by_bench_type {
    label: "Board 4: Requirement Validation Pass Rate by Engineering Level & Bench Type"
    description: "Analyzes Requirement validation verdicts (Passed, Failed, Ongoing, Not Executed, Not covered, Rejected) across Test Bench Types."
    dimensions: [
      dt_req_coverage_and_validation.req_engineering_level_normalized,
      dt_req_bench_validation.ts_bench_type,
      dt_req_bench_validation.bench_validation_status
    ]
    measures: [
      dt_req_bench_validation.count_requirements,
      dt_req_bench_validation.count_passed_requirements,
      dt_req_bench_validation.count_failed_requirements,
      dt_req_bench_validation.bench_requirement_pass_rate
    ]
    sorts: [dt_req_bench_validation.count_requirements: desc]
  }
}
