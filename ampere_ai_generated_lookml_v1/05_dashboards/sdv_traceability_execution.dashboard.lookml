- dashboard: sdv_traceability_execution
  title: "Ampere SDV - End-to-End Requirement & Test Traceability"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "End-to-end traceability across Requirements (gold_dim_req), Test Cases (tbl_cb_sdv_raw_tc_v2), Test Sets (gold_dim_ts), Test Runs (tbl_cb_sdv_raw_tr_v2), and Issues (tbl_cb_sdv_raw_issue_v2)."

  filters:
  - name: req_domain
    title: "Requirement Domain"
    type: field_filter
    model: ampere_sdv_analytics
    explore: traceability
    field: gold_dim_req.req_domain

  - name: ts_baseline
    title: "Test Set Baseline"
    type: field_filter
    model: ampere_sdv_analytics
    explore: traceability
    field: gold_dim_ts.ts_baseline

  - name: tr_my_sf
    title: "TR MySF"
    type: field_filter
    model: ampere_sdv_analytics
    explore: traceability
    field: fact_tc_tr_ts_req.tr_my_sf

  elements:
  - title: "Total Requirements"
    name: kpi_total_requirements
    model: ampere_sdv_analytics
    explore: traceability
    type: single_value
    fields: [gold_dim_req.count_requirements]
    listen:
      req_domain: gold_dim_req.req_domain
      ts_baseline: gold_dim_ts.ts_baseline
      tr_my_sf: fact_tc_tr_ts_req.tr_my_sf
    row: 0
    col: 0
    width: 6
    height: 4

  - title: "Requirement Test Coverage (%)"
    name: kpi_req_coverage_rate
    model: ampere_sdv_analytics
    explore: traceability
    type: single_value
    fields: [gold_dim_req.requirement_test_coverage_rate]
    listen:
      req_domain: gold_dim_req.req_domain
      ts_baseline: gold_dim_ts.ts_baseline
      tr_my_sf: fact_tc_tr_ts_req.tr_my_sf
    row: 0
    col: 6
    width: 6
    height: 4

  - title: "Test Run Pass Rate (%)"
    name: kpi_tr_pass_rate
    model: ampere_sdv_analytics
    explore: traceability
    type: single_value
    fields: [tbl_cb_sdv_raw_tr_v2.pass_rate]
    listen:
      req_domain: gold_dim_req.req_domain
      ts_baseline: gold_dim_ts.ts_baseline
      tr_my_sf: fact_tc_tr_ts_req.tr_my_sf
    row: 0
    col: 12
    width: 6
    height: 4

  - title: "Open Defects / Issues"
    name: kpi_open_issues
    model: ampere_sdv_analytics
    explore: traceability
    type: single_value
    fields: [tbl_cb_sdv_raw_issue_v2.count_open_issues]
    listen:
      req_domain: gold_dim_req.req_domain
      ts_baseline: gold_dim_ts.ts_baseline
      tr_my_sf: fact_tc_tr_ts_req.tr_my_sf
    row: 0
    col: 18
    width: 6
    height: 4

  - title: "Requirement Coverage & Test Cases by Domain"
    name: chart_coverage_by_domain
    model: ampere_sdv_analytics
    explore: traceability
    type: looker_column
    fields:
      - gold_dim_req.req_domain
      - gold_dim_req.count_requirements
      - gold_dim_req.count_covered_requirements
      - tbl_cb_sdv_raw_tc_v2.count_test_cases
    sorts: [gold_dim_req.count_requirements desc]
    listen:
      req_domain: gold_dim_req.req_domain
      ts_baseline: gold_dim_ts.ts_baseline
      tr_my_sf: fact_tc_tr_ts_req.tr_my_sf
    row: 4
    col: 0
    width: 12
    height: 8

  - title: "Test Run Execution Verdicts by Test Set Baseline"
    name: chart_verdicts_by_baseline
    model: ampere_sdv_analytics
    explore: traceability
    type: looker_bar
    fields:
      - gold_dim_ts.ts_baseline
      - tbl_cb_sdv_raw_tr_v2.count_passed_test_runs
      - tbl_cb_sdv_raw_tr_v2.count_failed_test_runs
      - tbl_cb_sdv_raw_tr_v2.count_blocked_test_runs
    sorts: [tbl_cb_sdv_raw_tr_v2.count_passed_test_runs desc]
    listen:
      req_domain: gold_dim_req.req_domain
      ts_baseline: gold_dim_ts.ts_baseline
      tr_my_sf: fact_tc_tr_ts_req.tr_my_sf
    row: 4
    col: 12
    width: 12
    height: 8
