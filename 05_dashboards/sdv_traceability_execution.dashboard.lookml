- dashboard: sdv_traceability_execution
  title: "Ampere SDV - Generic KPI Dashboard (4-Board End-to-End Traceability)"
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: true
  description: "Migrated Looker Dashboard for the Ampere SDV Generic KPI Business Case across Board 1 (Requirements & Vertical Traceability), Board 2 (Test Cases & Horizontal Traceability), Board 3 (TS Pass Rate by Bench Type & SW Version), and Board 4 (Requirement Pass Rate by Engineering Level & Bench Type)."

  tabs:
  - name: tab_1_req_vertical
    label: "Board 1: Requirements & Vertical Traceability"
  - name: tab_2_tc_horizontal
    label: "Board 2: Test Cases & Horizontal Traceability"
  - name: tab_3_ts_pass_rate
    label: "Board 3: TS Pass Rate by Bench & SW Version"
  - name: tab_4_req_pass_rate
    label: "Board 4: Requirement Pass Rate"

  filters:
  - name: req_domain
    title: "Requirement Domain"
    type: field_filter
    model: ampere_sdv_analytics
    explore: requirements_traceability
    field: gold_dim_req.req_domain

  - name: req_engineering_level
    title: "Engineering Level"
    type: field_filter
    model: ampere_sdv_analytics
    explore: requirements_traceability
    field: dt_req_coverage_and_validation.req_engineering_level_normalized

  - name: req_mysf_any
    title: "MySF Scope (Multi-Value Array Filter)"
    type: field_filter
    model: ampere_sdv_analytics
    explore: requirements_traceability
    field: gold_dim_req.req_mysf_any

  - name: ts_baseline
    title: "Test Set Baseline (BL)"
    type: field_filter
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    field: dt_ts_release_execution.bl

  elements:
  # =========================================================================
  # TAB 1: BOARD 1 - REQUIREMENTS & VERTICAL TRACEABILITY
  # =========================================================================
  - title: "Total Requirements"
    name: b1_kpi_total_requirements
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [gold_dim_req.requirement_count]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 0
    width: 6
    height: 4

  - title: "Approved / Validated Requirements"
    name: b1_kpi_approved_requirements
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [gold_dim_req.approved_requirement_count]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 6
    width: 6
    height: 4

  - title: "Requirements Linked to Child"
    name: b1_kpi_linked_child_requirements
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.count_req_linked_to_child]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 12
    width: 6
    height: 4

  - title: "Vertical Child Traceability Rate (%)"
    name: b1_kpi_vertical_child_coverage_rate
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.vertical_child_coverage_rate]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 18
    width: 6
    height: 4

  - title: "Board 1.1: Requirement Maturity Status by Engineering Level"
    name: b1_chart_req_status_by_level
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    pivots: [gold_dim_req.req_status]
    sorts: [gold_dim_req.requirement_count desc 0]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 4
    col: 0
    width: 12
    height: 8

  - title: "Board 1.2: Vertical Child Presence by Engineering Level"
    name: b1_chart_child_presence_by_level
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_coverage_and_validation.req_linked_child
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_linked_child]
    sorts: [gold_dim_req.requirement_count desc 0]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 4
    col: 12
    width: 12
    height: 8

  - title: "Board 1.3: SFReq Child Presence for Each SW Component (SWC)"
    name: b1_chart_sfreq_swc_child_presence
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.child_presence_for_each_swc
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.is_sfreq: "yes"
    sorts: [gold_dim_req.requirement_count desc]
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 12
    col: 0
    width: 12
    height: 8

  - title: "Board 1.4: Requirement Scope Evolution by MySF Release (26.2 vs 27.2 vs 28.2)"
    name: b1_chart_mysf_scope_evolution
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_coverage_and_validation.count_req_mysf_26_2
      - dt_req_coverage_and_validation.count_req_mysf_27_2_only
      - dt_req_coverage_and_validation.count_req_mysf_28_2_only
    sorts: [dt_req_coverage_and_validation.count_req_mysf_26_2 desc]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 12
    col: 12
    width: 12
    height: 8

  - title: "Board 1 Detail Table: Requirements & Vertical Traceability Explorer"
    name: b1_grid_requirements_detail
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_grid
    fields:
      - gold_dim_req.req_id
      - gold_dim_req.req_name
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - gold_dim_req.req_status
      - dt_req_coverage_and_validation.req_linked_child
      - dt_req_coverage_and_validation.child_presence_for_each_swc
      - dt_req_coverage_and_validation.count_child
      - dt_req_coverage_and_validation.count_tc
    sorts: [dt_req_coverage_and_validation.count_child desc]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 20
    col: 0
    width: 24
    height: 8

  # =========================================================================
  # TAB 2: BOARD 2 - TEST CASES & HORIZONTAL TRACEABILITY
  # =========================================================================
  - title: "Horizontal TC Coverage Rate (%)"
    name: b2_kpi_req_coverage_rate
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.horizontal_tc_coverage_rate]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 0
    width: 6
    height: 4

  - title: "Total Test Cases"
    name: b2_kpi_total_test_cases
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: single_value
    fields: [dt_tc_execution_status.total_tc_count]
    row: 0
    col: 6
    width: 6
    height: 4

  - title: "TC Linked to Requirement Rate (%)"
    name: b2_kpi_tc_req_linked_rate
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: single_value
    fields: [dt_tc_execution_status.tc_req_linked_rate]
    row: 0
    col: 12
    width: 6
    height: 4

  - title: "TC Deployed in Test Set Rate (%)"
    name: b2_kpi_tc_in_ts_rate
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: single_value
    fields: [dt_tc_execution_status.tc_in_ts_rate]
    row: 0
    col: 18
    width: 6
    height: 4

  - title: "Board 2.1: Requirements Covered by Test Cases by Engineering Level"
    name: b2_chart_req_covered_by_tc
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_coverage_and_validation.covered_status
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.covered_status]
    sorts: [gold_dim_req.requirement_count desc 0]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 4
    col: 0
    width: 12
    height: 8

  - title: "Board 2.2: Test Case Bench Type & Requirement Link Status"
    name: b2_chart_tc_bench_and_req_link
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_column
    fields:
      - dt_tc_execution_status.bench_type_ordered
      - dt_tc_execution_status.req_link_status
      - dt_tc_execution_status.total_tc_count
    pivots: [dt_tc_execution_status.req_link_status]
    sorts: [dt_tc_execution_status.bench_type_ordered asc]
    row: 4
    col: 12
    width: 12
    height: 8

  - title: "Board 2.3: Test Case Deployment in Generic vs Execution Test Sets"
    name: b2_chart_tc_in_ts_generic_execution
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_column
    fields:
      - dt_tc_execution_status.bench_type_ordered
      - dt_tc_execution_status.count_tc_in_ts_generic
      - dt_tc_execution_status.count_tc_in_ts_execution
      - dt_tc_execution_status.count_tc_not_in_ts
    sorts: [dt_tc_execution_status.bench_type_ordered asc]
    row: 12
    col: 0
    width: 12
    height: 8

  - title: "Board 2.4: TC Latest Execution & 7-Bucket Retest / Jira Derogation Readiness"
    name: b2_chart_tc_7_bucket_retest_readiness
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_bar
    fields:
      - dt_tc_execution_status.bench_type_ordered
      - dt_tc_execution_status.last_tr_result_ready_to_be_tested
      - dt_tc_execution_status.total_tc_count
    pivots: [dt_tc_execution_status.last_tr_result_ready_to_be_tested]
    sorts: [dt_tc_execution_status.bench_type_ordered asc]
    row: 12
    col: 12
    width: 12
    height: 8

  - title: "Board 2 Detail Table: Test Case Horizontal Traceability & Retest Readiness"
    name: b2_grid_tc_horizontal_details
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_grid
    fields:
      - tbl_cb_sdv_raw_tc_v2.id
      - tbl_cb_sdv_raw_tc_v2.name
      - dt_tc_execution_status.bench_type_ordered
      - dt_tc_execution_status.req_link_status
      - dt_tc_execution_status.tc_is_in_ts_generic
      - dt_tc_execution_status.tc_is_in_ts_execution
      - dt_tc_execution_status.last_tr_result_ready_to_be_tested
      - dt_tc_execution_status.last_tr_open_issue_count
      - dt_tc_execution_status.has_jira_derogation
    sorts: [dt_tc_execution_status.last_tr_result_ready_to_be_tested asc]
    row: 20
    col: 0
    width: 24
    height: 8

  # =========================================================================
  # TAB 3: BOARD 3 - TS PASS RATE BY BENCH TYPE & SW VERSION
  # =========================================================================
  - title: "Distinct TCs on SW Releases"
    name: b3_kpi_distinct_tc_on_release
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: single_value
    fields: [dt_ts_release_execution.count_distinct_test_cases]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 0
    col: 0
    width: 6
    height: 4

  - title: "SWE.6 Validation Pass Rate (%)"
    name: b3_kpi_swe6_pass_rate
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: single_value
    fields: [dt_ts_release_execution.swe6_pass_rate_on_release]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 0
    col: 6
    width: 6
    height: 4

  - title: "C3V Integration Pass Rate (%)"
    name: b3_kpi_c3v_pass_rate
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: single_value
    fields: [dt_ts_release_execution.c3v_pass_rate_on_release]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 0
    col: 12
    width: 6
    height: 4

  - title: "Overall SW Release Pass Rate (%)"
    name: b3_kpi_overall_release_pass_rate
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: single_value
    fields: [dt_ts_release_execution.ts_release_pass_rate]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 0
    col: 18
    width: 6
    height: 4

  - title: "Board 3.1: SWE.6 Validation Pass Rate by SW Release & ECU Release Type"
    name: b3_chart_swe6_pass_rate_by_release
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_column
    fields:
      - dt_ts_release_execution.ts_release
      - dt_ts_release_execution.count_passed_tc_on_release
      - dt_ts_release_execution.count_failed_tc_on_release
      - dt_ts_release_execution.count_blocked_tc_on_release
      - dt_ts_release_execution.count_not_executed_tc_on_release
    filters:
      dt_ts_release_execution.is_swe6_scope: "yes"
    sorts: [dt_ts_release_execution.count_passed_tc_on_release desc]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 4
    col: 0
    width: 12
    height: 8

  - title: "Board 3.2: C3V Integration Pass Rate by Baseline (BL6, BL7, BL6+BL7) & Bench Type"
    name: b3_chart_c3v_pass_rate_by_bl_and_bench
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_column
    fields:
      - dt_ts_release_execution.bl_family
      - dt_ts_release_execution.ts_bench_type
      - dt_ts_release_execution.count_passed_tc_on_bl
      - dt_ts_release_execution.count_failed_tc_on_bl
      - dt_ts_release_execution.count_blocked_tc_on_bl
    filters:
      dt_ts_release_execution.is_c3v_scope: "yes"
    sorts: [dt_ts_release_execution.bl_family asc]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 4
    col: 12
    width: 12
    height: 8

  - title: "Board 3.3: HIL, EIPF & VHL Bench Pass Rate by SW Version"
    name: b3_chart_hil_eipf_vhl_pass_rate
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_line
    fields:
      - dt_ts_release_execution.ts_release
      - dt_ts_release_execution.hil_pass_rate_on_release
      - dt_ts_release_execution.eipf_pass_rate_on_release
      - dt_ts_release_execution.vhl_pass_rate_on_release
    sorts: [dt_ts_release_execution.ts_release asc]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 12
    col: 0
    width: 24
    height: 8

  - title: "Board 3 Detail Table: Test Set SW Version & Baseline Execution Matrix"
    name: b3_grid_ts_release_details
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_grid
    fields:
      - dt_ts_release_execution.ts_id
      - gold_dim_ts.ts_name
      - gold_dim_ts.ts_validation_team
      - dt_ts_release_execution.ts_bench_type
      - dt_ts_release_execution.release_type
      - dt_ts_release_execution.ts_release
      - dt_ts_release_execution.bl
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    listen:
      ts_baseline: dt_ts_release_execution.bl
    row: 20
    col: 0
    width: 24
    height: 8

  # =========================================================================
  # TAB 4: BOARD 4 - REQUIREMENT PASS RATE BY ENG LEVEL & BENCH TYPE
  # =========================================================================
  - title: "Requirements Passed (Fully Validated)"
    name: b4_kpi_req_passed
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.count_req_validation_passed]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 0
    width: 6
    height: 4

  - title: "Requirements Failed"
    name: b4_kpi_req_failed
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.count_req_validation_failed]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 6
    width: 6
    height: 4

  - title: "Requirements Ongoing (Partial Execution)"
    name: b4_kpi_req_ongoing
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.count_req_validation_ongoing]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 12
    width: 6
    height: 4

  - title: "Requirement Validation Pass Rate (%)"
    name: b4_kpi_req_validation_pass_rate
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: single_value
    fields: [dt_req_coverage_and_validation.requirement_validation_pass_rate]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 0
    col: 18
    width: 6
    height: 4

  - title: "Board 4.1: Overall Requirement Validation Status by Engineering Level"
    name: b4_chart_req_last_results_by_level
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    sorts: [gold_dim_req.requirement_count desc 0]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 4
    col: 0
    width: 12
    height: 8

  - title: "Board 4.2: Requirement Pass Rate by Engineering Level & Bench Type"
    name: b4_chart_req_pass_rate_by_bench
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: req_pass_rate_by_bench
    type: looker_column
    fields:
      - dt_req_bench_validation.ts_bench_type
      - dt_req_bench_validation.bench_validation_status
      - dt_req_bench_validation.count_requirements
    pivots: [dt_req_bench_validation.bench_validation_status]
    sorts: [dt_req_bench_validation.count_requirements desc 0]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 4
    col: 12
    width: 12
    height: 8

  - title: "Board 4 Detail Table: Requirement Validation Verdict by Bench Type"
    name: b4_grid_req_bench_validation_details
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: req_pass_rate_by_bench
    type: looker_grid
    fields:
      - dt_req_bench_validation.req_id
      - gold_dim_req.req_name
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_bench_validation.ts_bench_type
      - dt_req_bench_validation.bench_validation_status
      - dt_req_bench_validation.count_tc_on_bench
      - dt_req_bench_validation.count_passed_requirements
      - dt_req_bench_validation.count_failed_requirements
    sorts: [dt_req_bench_validation.count_failed_requirements desc]
    listen:
      req_domain: gold_dim_req.req_domain
      req_engineering_level: dt_req_coverage_and_validation.req_engineering_level_normalized
      req_mysf_any: gold_dim_req.req_mysf_any
    row: 12
    col: 0
    width: 24
    height: 8
