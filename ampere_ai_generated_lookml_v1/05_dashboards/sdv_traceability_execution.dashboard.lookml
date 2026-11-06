- dashboard: sdv_traceability_execution
  title: "GENERIC KPI DASHBOARD - Codebeamer/GCP/Looker"
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: true
  description: "Migrated from Data Studio / Looker Studio Generic KPI Dashboard (42ed0726-7d3f-4b38-81d1-8c9bf6924d93 / page p_yqnvw7yq0d) documented in SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx. Full KPI report: https://lookerstudio.google.com/reporting/c0ca38bd-ae83-450d-8246-ea0c219f1cc7/page/p_yqnvw7yq0d | Looker support through JIRA: https://jira.dt.renault.com/issues/?filter=208735"

  tabs:
  - name: tab_overview
    label: "Overview: Generic KPI Dashboard (All 4 Boards)"
  - name: tab_1_req_vertical
    label: "Board 1: Reqs & Vertical Traceability"
  - name: tab_2_tc_horizontal
    label: "Board 2: TC & Horizontal Traceability"
  - name: tab_3_ts_pass_rate
    label: "Board 3: TS Pass Rate by Bench & SW Version"
  - name: tab_4_req_pass_rate
    label: "Board 4: Requirement Pass Rate"

  filters:
  - name: req_domain
    title: "Req_Domain"
    type: field_filter
    default_value: "ADAS"
    allow_multiple_values: true
    required: false
    model: ampere_sdv_analytics
    explore: requirements_traceability
    field: gold_dim_req.req_domain

  - name: tc_domain
    title: "TC_Domain"
    type: field_filter
    default_value: "ADAS"
    allow_multiple_values: true
    required: false
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    field: tbl_cb_sdv_raw_tc_v2.domain

  - name: ts_domain
    title: "TS_Domain"
    type: field_filter
    default_value: "ADAS"
    allow_multiple_values: true
    required: false
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    field: dt_ts_release_execution.ts_domain

  - name: req_mysf
    title: "Req_MySF"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: ampere_sdv_analytics
    explore: requirements_traceability
    field: gold_dim_req.req_mysf_any

  - name: req_baseline
    title: "Req_Baseline"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: ampere_sdv_analytics
    explore: requirements_traceability
    field: gold_dim_req.req_baseline_any

  elements:
  # ===========================================================================
  # TAB 1: OVERVIEW - GENERIC KPI DASHBOARD (4 BOARDS x 5 KPI COLUMNS = 20 PIES)
  # Mirrors the exact single-page 4x5 layout of Data Studio report 42ed0726-7d3f
  # ===========================================================================

  # --- ROW 0: BOARD 1 (Reqs & Vertical Traceability) ---
  - title: "B1.1 Regulatory, Customer Performance, Cyber"
    name: ov_b1_1_reg_cp_cyber_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "04-CP,05-REG,06-CyberG"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Accepted: "#00a651"
      Approved: "#00a651"
      Released: "#00a651"
      Submitted: "#f9ab00"
      Draft: "#ff0000"
      Rejected: "#b7b7b7"
      Obsolete: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 0
    width: 5
    height: 6

  - title: "B1.2 Overall Domain and System Safety Requirements"
    name: ov_b1_2_domain_safety_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "01-SG,02-FSR,03-TSR,11-VOREQ,12-SOREQ,13-SFREQ,21-SRS,22-SCRS"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Accepted: "#00a651"
      Approved: "#00a651"
      Released: "#00a651"
      Submitted: "#f9ab00"
      Draft: "#ff0000"
      Rejected: "#b7b7b7"
      Obsolete: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 5
    width: 5
    height: 6

  - title: "B1.3 Supplier Status"
    name: ov_b1_3_supplier_status_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    filters:
      gold_dim_req.is_supplier_req: "yes"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Accepted: "#00a651"
      Approved: "#00a651"
      Released: "#00a651"
      Submitted: "#f9ab00"
      Draft: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 10
    width: 5
    height: 6

  - title: "B1.4 Make Missing Childs"
    name: ov_b1_4_make_missing_childs_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_linked_child
      - gold_dim_req.requirement_count
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Linked to a child: "#00a651"
      No child required: "#8ce232"
      Not linked to a child: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 15
    width: 5
    height: 6

  - title: "B1.5 Cross System Missing Childs"
    name: ov_b1_5_cross_system_missing_childs_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.child_presence_for_each_swc
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.is_sfreq: "yes"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Linked to all required children: "#00a651"
      No child required: "#8ce232"
      Linked to some children but not: "#f9ab00"
      Not linked to a child: "#ff0000"
      No SWC present: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 20
    width: 4
    height: 6

  # --- ROW 6: BOARD 2 (TC & Horizontal Traceability) ---
  - title: "B2.1 Reqs Covered by TC"
    name: ov_b2_1_reqs_covered_by_tc_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.covered_status
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.covered_status: "Covered,Not covered"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Covered: "#00a651"
      Not covered: "#ff0000"
      Supplier: "#f9ab00"
      No test expected: "#8ce232"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 0
    width: 5
    height: 6

  - title: "B2.2 TC Coverage by Bench Type"
    name: ov_b2_2_tc_bench_type_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.bench_type_documented
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Documented: "#00a651"
      Not documented: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 5
    width: 5
    height: 6

  - title: "B2.3 TC Deployment in TS Generic (PVAL)"
    name: ov_b2_3_tc_in_ts_generic_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.tc_is_in_ts_generic
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Linked to TS Generic: "#00a651"
      Not Linked to TS Generic: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 10
    width: 5
    height: 6

  - title: "B2.4 TC Deployment in TS Execution"
    name: ov_b2_4_tc_in_ts_execution_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.tc_is_in_ts_execution
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Linked to TS Execution: "#00a651"
      Not Linked to TS Execution: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 15
    width: 5
    height: 6

  - title: "B2.5 TC Execution"
    name: ov_b2_5_tc_execution_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.last_tr_result
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not executed: "#b7b7b7"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 20
    width: 4
    height: 6

  # --- ROW 12: BOARD 3 (TS Pass Rate by Bench Type & SW Version) ---
  - title: "B3.1 TS Pass Rate SWE.6"
    name: ov_b3_1_ts_pass_rate_swe6_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_swe6_scope: "yes"
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 12
    col: 0
    width: 5
    height: 6

  - title: "B3.2 TS Pass Rate C3V"
    name: ov_b3_2_ts_pass_rate_c3v_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_c3v_scope: "yes"
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 12
    col: 5
    width: 5
    height: 6

  - title: "B3.3 TS Pass Rate HIL BL6/BL7"
    name: ov_b3_3_ts_pass_rate_hil_bl6_bl7_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_hil_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 12
    col: 10
    width: 5
    height: 6

  - title: "B3.4 TS Pass Rate EIPF BL6/BL7"
    name: ov_b3_4_ts_pass_rate_eipf_bl6_bl7_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_eipf_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 12
    col: 15
    width: 5
    height: 6

  - title: "B3.5 TS Pass Rate VHL BL6/BL7"
    name: ov_b3_5_ts_pass_rate_vhl_bl6_bl7_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_vhl_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 12
    col: 20
    width: 4
    height: 6

  # --- ROW 18: BOARD 4 (Requirement Pass Rate) ---
  - title: "B4.1 SCRS"
    name: ov_b4_1_scrs_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "22-SCRS"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 18
    col: 0
    width: 5
    height: 6

  - title: "B4.2 SRS"
    name: ov_b4_2_srs_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "21-SRS"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 18
    col: 5
    width: 5
    height: 6

  - title: "B4.3 SFREQ White Box"
    name: ov_b4_3_sfreq_white_box_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "13-SFREQ"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 18
    col: 10
    width: 5
    height: 6

  - title: "B4.4 SOREQ"
    name: ov_b4_4_soreq_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "12-SOREQ"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 18
    col: 15
    width: 5
    height: 6

  - title: "B4.5 VOREQ"
    name: ov_b4_5_voreq_pie
    tab_name: tab_overview
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "11-VOREQ"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    inner_radius: 0
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 18
    col: 20
    width: 4
    height: 6

  # ===========================================================================
  # TAB 2: BOARD 1 - REQS & VERTICAL TRACEABILITY (Figure 2: 5 Pies + 5 Bars + Drill)
  # ===========================================================================

  # --- Row 0: 5 Pie Charts (Percentage Share) ---
  - title: "Regulatory, Customer Performance, Cyber"
    name: b1_1_reg_cp_cyber_pie
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "04-CP,05-REG,06-CyberG"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Accepted: "#00a651"
      Approved: "#00a651"
      Released: "#00a651"
      Submitted: "#f9ab00"
      Draft: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 0
    width: 5
    height: 6

  - title: "Overall Domain and System Safety Requirements"
    name: b1_2_domain_safety_pie
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "01-SG,02-FSR,03-TSR,11-VOREQ,12-SOREQ,13-SFREQ,21-SRS,22-SCRS"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Accepted: "#00a651"
      Approved: "#00a651"
      Released: "#00a651"
      Submitted: "#f9ab00"
      Draft: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 5
    width: 5
    height: 6

  - title: "Supplier Status"
    name: b1_3_supplier_status_pie
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    filters:
      gold_dim_req.is_supplier_req: "yes"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Accepted: "#00a651"
      Approved: "#00a651"
      Released: "#00a651"
      Submitted: "#f9ab00"
      Draft: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 10
    width: 5
    height: 6

  - title: "Make Missing Childs"
    name: b1_4_make_missing_childs_pie
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_linked_child
      - gold_dim_req.requirement_count
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Linked to a child: "#00a651"
      No child required: "#8ce232"
      Not linked to a child: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 15
    width: 5
    height: 6

  - title: "Cross System Missing Childs"
    name: b1_5_cross_system_missing_childs_pie
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
    value_labels: labels
    label_type: labPer
    series_colors:
      Linked to all required children: "#00a651"
      No child required: "#8ce232"
      Linked to some children but not: "#f9ab00"
      Not linked to a child: "#ff0000"
      No SWC present: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 20
    width: 4
    height: 6

  # --- Row 6: 5 Horizontal Stacked Bar Charts (Item Counts Underneath Each Pie) ---
  - title: "Regulatory, CP, Cyber - Count"
    name: b1_1_reg_cp_cyber_bar
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    pivots: [gold_dim_req.req_status]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "04-CP,05-REG,06-CyberG"
    sorts: [gold_dim_req.req_status]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Accepted - gold_dim_req.requirement_count: "#00a651"
      Approved - gold_dim_req.requirement_count: "#00a651"
      Submitted - gold_dim_req.requirement_count: "#f9ab00"
      Draft - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 0
    width: 5
    height: 3

  - title: "Overall Domain & Safety - Count"
    name: b1_2_domain_safety_bar
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    pivots: [gold_dim_req.req_status]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "01-SG,02-FSR,03-TSR,11-VOREQ,12-SOREQ,13-SFREQ,21-SRS,22-SCRS"
    sorts: [gold_dim_req.req_status]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Accepted - gold_dim_req.requirement_count: "#00a651"
      Approved - gold_dim_req.requirement_count: "#00a651"
      Submitted - gold_dim_req.requirement_count: "#f9ab00"
      Draft - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 5
    width: 5
    height: 3

  - title: "Supplier Status - Count"
    name: b1_3_supplier_status_bar
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - gold_dim_req.req_status
      - gold_dim_req.requirement_count
    pivots: [gold_dim_req.req_status]
    filters:
      gold_dim_req.is_supplier_req: "yes"
    sorts: [gold_dim_req.req_status]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Accepted - gold_dim_req.requirement_count: "#00a651"
      Approved - gold_dim_req.requirement_count: "#00a651"
      Submitted - gold_dim_req.requirement_count: "#f9ab00"
      Draft - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 10
    width: 5
    height: 3

  - title: "Make Missing Childs - Count"
    name: b1_4_make_missing_childs_bar
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.req_linked_child
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_linked_child]
    sorts: [dt_req_coverage_and_validation.req_linked_child]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Linked to a child - gold_dim_req.requirement_count: "#00a651"
      No child required - gold_dim_req.requirement_count: "#8ce232"
      Not linked to a child - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 15
    width: 5
    height: 3

  - title: "Cross System Missing Childs - Count"
    name: b1_5_cross_system_missing_childs_bar
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.child_presence_for_each_swc
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.child_presence_for_each_swc]
    filters:
      dt_req_coverage_and_validation.is_sfreq: "yes"
    sorts: [dt_req_coverage_and_validation.child_presence_for_each_swc]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Linked to all required children - gold_dim_req.requirement_count: "#00a651"
      No child required - gold_dim_req.requirement_count: "#8ce232"
      Linked to some children but not - gold_dim_req.requirement_count: "#f9ab00"
      Not linked to a child - gold_dim_req.requirement_count: "#ff0000"
      No SWC present - gold_dim_req.requirement_count: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 20
    width: 4
    height: 3

  # --- Row 9: V-Cycle Engineering Level Breakdown & Detail Explorer ---
  - title: "Requirement Status by V-Cycle Engineering Level (01-SG to 23-SURS)"
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
    sorts: [dt_req_coverage_and_validation.req_engineering_level_normalized asc]
    stacking: normal
    show_value_labels: true
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 9
    col: 0
    width: 12
    height: 7

  - title: "Make Missing Childs by Engineering Level"
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
    sorts: [dt_req_coverage_and_validation.req_engineering_level_normalized asc]
    stacking: normal
    show_value_labels: true
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 9
    col: 12
    width: 12
    height: 7

  - title: "Board 1 Detail Table: Requirements & Vertical Traceability Explorer"
    name: b1_grid_requirements_detail
    tab_name: tab_1_req_vertical
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_grid
    fields:
      - gold_dim_req.req_id
      - gold_dim_req.req_name
      - gold_dim_req.req_domain
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - gold_dim_req.req_status
      - gold_dim_req.req_supplier
      - dt_req_coverage_and_validation.req_linked_child
      - dt_req_coverage_and_validation.child_presence_for_each_swc
      - dt_req_coverage_and_validation.count_child
      - dt_req_coverage_and_validation.count_tc
    sorts: [dt_req_coverage_and_validation.req_engineering_level_normalized asc]
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 16
    col: 0
    width: 24
    height: 8

  # ===========================================================================
  # TAB 3: BOARD 2 - TC & HORIZONTAL TRACEABILITY (Figure 3: 5 Pies + 5 Bars + Drill)
  # ===========================================================================

  # --- Row 0: 5 Pie Charts (Percentage Share) ---
  - title: "Reqs Covered by TC"
    name: b2_1_reqs_covered_by_tc_pie
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.covered_status
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.covered_status: "Covered,Not covered"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Covered: "#00a651"
      Not covered: "#ff0000"
      Supplier: "#f9ab00"
      No test expected: "#8ce232"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 0
    width: 5
    height: 6

  - title: "TC Coverage by Bench Type"
    name: b2_2_tc_bench_type_pie
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.bench_type_documented
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Documented: "#00a651"
      Not documented: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 0
    col: 5
    width: 5
    height: 6

  - title: "TC Deployment in TS Generic (PVAL)"
    name: b2_3_tc_in_ts_generic_pie
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.tc_is_in_ts_generic
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Linked to TS Generic: "#00a651"
      Not Linked to TS Generic: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 0
    col: 10
    width: 5
    height: 6

  - title: "TC Deployment in TS Execution"
    name: b2_4_tc_in_ts_execution_pie
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.tc_is_in_ts_execution
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Linked to TS Execution: "#00a651"
      Not Linked to TS Execution: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 0
    col: 15
    width: 5
    height: 6

  - title: "TC Execution"
    name: b2_5_tc_execution_pie
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_pie
    fields:
      - dt_tc_execution_status.last_tr_result
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.total_tc_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not executed: "#b7b7b7"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 0
    col: 20
    width: 4
    height: 6

  # --- Row 6: 5 Horizontal Stacked Bar Charts (Item Counts Underneath Each Pie) ---
  - title: "Reqs Covered by TC - Count"
    name: b2_1_reqs_covered_by_tc_bar
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.covered_status
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.covered_status]
    filters:
      dt_req_coverage_and_validation.covered_status: "Covered,Not covered"
    sorts: [dt_req_coverage_and_validation.covered_status]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Covered - gold_dim_req.requirement_count: "#00a651"
      Not covered - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 0
    width: 5
    height: 3

  - title: "TC Coverage by Bench Type - Count"
    name: b2_2_tc_bench_type_bar
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_bar
    fields:
      - dt_tc_execution_status.bench_type_documented
      - dt_tc_execution_status.total_tc_count
    pivots: [dt_tc_execution_status.bench_type_documented]
    sorts: [dt_tc_execution_status.bench_type_documented]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Documented - dt_tc_execution_status.total_tc_count: "#00a651"
      Not documented - dt_tc_execution_status.total_tc_count: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 5
    width: 5
    height: 3

  - title: "TC Deployment in TS Generic - Count"
    name: b2_3_tc_in_ts_generic_bar
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_bar
    fields:
      - dt_tc_execution_status.tc_is_in_ts_generic
      - dt_tc_execution_status.total_tc_count
    pivots: [dt_tc_execution_status.tc_is_in_ts_generic]
    sorts: [dt_tc_execution_status.tc_is_in_ts_generic]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Linked to TS Generic - dt_tc_execution_status.total_tc_count: "#00a651"
      Not Linked to TS Generic - dt_tc_execution_status.total_tc_count: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 10
    width: 5
    height: 3

  - title: "TC Deployment in TS Execution - Count"
    name: b2_4_tc_in_ts_execution_bar
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_bar
    fields:
      - dt_tc_execution_status.tc_is_in_ts_execution
      - dt_tc_execution_status.total_tc_count
    pivots: [dt_tc_execution_status.tc_is_in_ts_execution]
    sorts: [dt_tc_execution_status.tc_is_in_ts_execution]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Linked to TS Execution - dt_tc_execution_status.total_tc_count: "#00a651"
      Not Linked to TS Execution - dt_tc_execution_status.total_tc_count: "#ff0000"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 15
    width: 5
    height: 3

  - title: "TC Execution - Count"
    name: b2_5_tc_execution_bar
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_bar
    fields:
      - dt_tc_execution_status.last_tr_result
      - dt_tc_execution_status.total_tc_count
    pivots: [dt_tc_execution_status.last_tr_result]
    sorts: [dt_tc_execution_status.last_tr_result]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - dt_tc_execution_status.total_tc_count: "#00a651"
      Failed - dt_tc_execution_status.total_tc_count: "#ff0000"
      Blocked - dt_tc_execution_status.total_tc_count: "#f9ab00"
      Not executed - dt_tc_execution_status.total_tc_count: "#b7b7b7"
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 6
    col: 20
    width: 4
    height: 3

  # --- Row 9: Retest Readiness (7-Bucket) & Detail Explorer ---
  - title: "Reqs Covered by TC (All 4 Statuses by Engineering Level)"
    name: b2_chart_req_covered_status_by_level
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_coverage_and_validation.covered_status
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.covered_status]
    sorts: [dt_req_coverage_and_validation.req_engineering_level_normalized asc]
    stacking: normal
    show_value_labels: true
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 9
    col: 0
    width: 12
    height: 7

  - title: "TC Execution & Jira Derogation Retest Readiness (7-Bucket)"
    name: b2_chart_tc_7bucket_readiness
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_bar
    fields:
      - dt_tc_execution_status.last_tr_result_ready_to_be_tested
      - dt_tc_execution_status.total_tc_count
    sorts: [dt_tc_execution_status.last_tr_result_ready_to_be_tested asc]
    show_value_labels: true
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 9
    col: 12
    width: 12
    height: 7

  - title: "Board 2 Detail Table: Test Cases Horizontal Traceability & Defect Readiness"
    name: b2_grid_tc_horizontal_detail
    tab_name: tab_2_tc_horizontal
    model: ampere_sdv_analytics
    explore: tc_horizontal_traceability
    type: looker_grid
    fields:
      - tbl_cb_sdv_raw_tc_v2.id
      - tbl_cb_sdv_raw_tc_v2.name
      - tbl_cb_sdv_raw_tc_v2.domain
      - tbl_cb_sdv_raw_tc_v2.status
      - dt_tc_execution_status.bench_type_documented
      - dt_tc_execution_status.bench_type_ordered
      - dt_tc_execution_status.req_link_status
      - dt_tc_execution_status.tc_is_in_ts_generic
      - dt_tc_execution_status.tc_is_in_ts_execution
      - dt_tc_execution_status.last_tr_result
      - dt_tc_execution_status.last_tr_result_ready_to_be_tested
      - dt_tc_execution_status.last_tr_open_issue_count
    sorts: [dt_tc_execution_status.last_tr_open_issue_count desc]
    listen:
      tc_domain: tbl_cb_sdv_raw_tc_v2.domain
      req_mysf: dt_tc_execution_status.req_mysf_agg
      req_baseline: dt_tc_execution_status.req_baseline_agg
    row: 16
    col: 0
    width: 24
    height: 8

  # ===========================================================================
  # TAB 4: BOARD 3 - TS PASS RATE BY BENCH TYPE & SW VERSION (Figure 4: 5 Pies + 5 Bars)
  # ===========================================================================

  # --- Row 0: 5 Pie Charts (Percentage Share) ---
  - title: "TS Pass Rate SWE.6"
    name: b3_1_ts_pass_rate_swe6_pie
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_swe6_scope: "yes"
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 0
    col: 0
    width: 5
    height: 6

  - title: "TS Pass Rate C3V"
    name: b3_2_ts_pass_rate_c3v_pie
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_c3v_scope: "yes"
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 0
    col: 5
    width: 5
    height: 6

  - title: "TS Pass Rate HIL BL6/BL7"
    name: b3_3_ts_pass_rate_hil_bl6_bl7_pie
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_hil_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 0
    col: 10
    width: 5
    height: 6

  - title: "TS Pass Rate EIPF BL6/BL7"
    name: b3_4_ts_pass_rate_eipf_bl6_bl7_pie
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_eipf_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 0
    col: 15
    width: 5
    height: 6

  - title: "TS Pass Rate VHL BL6/BL7"
    name: b3_5_ts_pass_rate_vhl_bl6_bl7_pie
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_pie
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    filters:
      dt_ts_release_execution.is_vhl_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Blocked: "#f9ab00"
      Not Executed: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 0
    col: 20
    width: 4
    height: 6

  # --- Row 6: 5 Horizontal Stacked Bar Charts (Item Counts Underneath Each Pie) ---
  - title: "TS Pass Rate SWE.6 - Count"
    name: b3_1_ts_pass_rate_swe6_bar
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_bar
    fields:
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_release]
    filters:
      dt_ts_release_execution.is_swe6_scope: "yes"
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.last_result_on_release]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - dt_ts_release_execution.count_distinct_test_cases: "#00a651"
      Failed - dt_ts_release_execution.count_distinct_test_cases: "#ff0000"
      Blocked - dt_ts_release_execution.count_distinct_test_cases: "#f9ab00"
      Not Executed - dt_ts_release_execution.count_distinct_test_cases: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 6
    col: 0
    width: 5
    height: 3

  - title: "TS Pass Rate C3V - Count"
    name: b3_2_ts_pass_rate_c3v_bar
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_bar
    fields:
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_release]
    filters:
      dt_ts_release_execution.is_c3v_scope: "yes"
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.last_result_on_release]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - dt_ts_release_execution.count_distinct_test_cases: "#00a651"
      Failed - dt_ts_release_execution.count_distinct_test_cases: "#ff0000"
      Blocked - dt_ts_release_execution.count_distinct_test_cases: "#f9ab00"
      Not Executed - dt_ts_release_execution.count_distinct_test_cases: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 6
    col: 5
    width: 5
    height: 3

  - title: "TS Pass Rate HIL BL6/BL7 - Count"
    name: b3_3_ts_pass_rate_hil_bl6_bl7_bar
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_bar
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_bl]
    filters:
      dt_ts_release_execution.is_hil_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.last_result_on_bl]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - dt_ts_release_execution.count_distinct_test_cases: "#00a651"
      Failed - dt_ts_release_execution.count_distinct_test_cases: "#ff0000"
      Blocked - dt_ts_release_execution.count_distinct_test_cases: "#f9ab00"
      Not Executed - dt_ts_release_execution.count_distinct_test_cases: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 6
    col: 10
    width: 5
    height: 3

  - title: "TS Pass Rate EIPF BL6/BL7 - Count"
    name: b3_4_ts_pass_rate_eipf_bl6_bl7_bar
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_bar
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_bl]
    filters:
      dt_ts_release_execution.is_eipf_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.last_result_on_bl]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - dt_ts_release_execution.count_distinct_test_cases: "#00a651"
      Failed - dt_ts_release_execution.count_distinct_test_cases: "#ff0000"
      Blocked - dt_ts_release_execution.count_distinct_test_cases: "#f9ab00"
      Not Executed - dt_ts_release_execution.count_distinct_test_cases: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 6
    col: 15
    width: 5
    height: 3

  - title: "TS Pass Rate VHL BL6/BL7 - Count"
    name: b3_5_ts_pass_rate_vhl_bl6_bl7_bar
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_bar
    fields:
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_bl]
    filters:
      dt_ts_release_execution.is_vhl_bench: "yes"
      dt_ts_release_execution.bl_family: "BL6,BL7,BL6_BL7"
    sorts: [dt_ts_release_execution.last_result_on_bl]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - dt_ts_release_execution.count_distinct_test_cases: "#00a651"
      Failed - dt_ts_release_execution.count_distinct_test_cases: "#ff0000"
      Blocked - dt_ts_release_execution.count_distinct_test_cases: "#f9ab00"
      Not Executed - dt_ts_release_execution.count_distinct_test_cases: "#b7b7b7"
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 6
    col: 20
    width: 4
    height: 3

  # --- Row 9: SW Version & Baseline Breakdown + Detail Table ---
  - title: "TS Execution Verdict by SW Release Version (TS_Release)"
    name: b3_chart_release_verdict_by_sw_version
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_column
    fields:
      - dt_ts_release_execution.ts_release
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_release]
    filters:
      dt_ts_release_execution.is_virtual_bl6_bl7: "no"
    sorts: [dt_ts_release_execution.count_distinct_test_cases desc 0]
    stacking: normal
    show_value_labels: true
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 9
    col: 0
    width: 12
    height: 7

  - title: "TS Execution Verdict by Baseline Family (BL6 vs BL7 vs Combined BL6_BL7)"
    name: b3_chart_bl_family_comparison
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_column
    fields:
      - dt_ts_release_execution.bl_family
      - dt_ts_release_execution.last_result_on_bl
      - dt_ts_release_execution.count_distinct_test_cases
    pivots: [dt_ts_release_execution.last_result_on_bl]
    sorts: [dt_ts_release_execution.bl_family asc]
    stacking: normal
    show_value_labels: true
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 9
    col: 12
    width: 12
    height: 7

  - title: "Board 3 Detail Table: Test Set SW Release & Baseline Execution Explorer"
    name: b3_grid_ts_release_detail
    tab_name: tab_3_ts_pass_rate
    model: ampere_sdv_analytics
    explore: ts_pass_rate_by_sw_version
    type: looker_grid
    fields:
      - dt_ts_release_execution.ts_id
      - dt_ts_release_execution.tc_id
      - dt_ts_release_execution.tc_name
      - dt_ts_release_execution.ts_domain
      - dt_ts_release_execution.release_type
      - dt_ts_release_execution.ts_release
      - dt_ts_release_execution.bl
      - dt_ts_release_execution.bl_family
      - dt_ts_release_execution.ts_bench_type
      - dt_ts_release_execution.last_result_on_release
      - dt_ts_release_execution.last_result_on_bl
    sorts: [dt_ts_release_execution.bl asc, dt_ts_release_execution.ts_release asc]
    listen:
      ts_domain: dt_ts_release_execution.ts_domain
      req_mysf: dt_ts_release_execution.req_mysf
      req_baseline: dt_ts_release_execution.req_baseline
    row: 16
    col: 0
    width: 24
    height: 8

  # ===========================================================================
  # TAB 5: BOARD 4 - REQUIREMENT PASS RATE (Figure 5: 5 Pies + 5 Bars + Bench Drill)
  # ===========================================================================

  # --- Row 0: 5 Pie Charts (Percentage Share) ---
  - title: "SCRS"
    name: b4_1_scrs_pie
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "22-SCRS"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 0
    width: 5
    height: 6

  - title: "SRS"
    name: b4_2_srs_pie
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "21-SRS"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 5
    width: 5
    height: 6

  - title: "SFREQ White Box"
    name: b4_3_sfreq_white_box_pie
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "13-SFREQ"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 10
    width: 5
    height: 6

  - title: "SOREQ"
    name: b4_4_soreq_pie
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "12-SOREQ"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 15
    width: 5
    height: 6

  - title: "VOREQ"
    name: b4_5_voreq_pie
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_pie
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "11-VOREQ"
    sorts: [gold_dim_req.requirement_count desc]
    value_labels: labels
    label_type: labPer
    series_colors:
      Passed: "#00a651"
      Failed: "#ff0000"
      Ongoing: "#f9ab00"
      Not Executed: "#b7b7b7"
      Not covered: "#ff0000"
      Rejected: "#b7b7b7"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 0
    col: 20
    width: 4
    height: 6

  # --- Row 6: 5 Horizontal Stacked Bar Charts (Item Counts Underneath Each Pie) ---
  - title: "SCRS - Count"
    name: b4_1_scrs_bar
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "22-SCRS"
    sorts: [dt_req_coverage_and_validation.req_last_results]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - gold_dim_req.requirement_count: "#00a651"
      Failed - gold_dim_req.requirement_count: "#ff0000"
      Ongoing - gold_dim_req.requirement_count: "#f9ab00"
      Not Executed - gold_dim_req.requirement_count: "#b7b7b7"
      Not covered - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 0
    width: 5
    height: 3

  - title: "SRS - Count"
    name: b4_2_srs_bar
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "21-SRS"
    sorts: [dt_req_coverage_and_validation.req_last_results]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - gold_dim_req.requirement_count: "#00a651"
      Failed - gold_dim_req.requirement_count: "#ff0000"
      Ongoing - gold_dim_req.requirement_count: "#f9ab00"
      Not Executed - gold_dim_req.requirement_count: "#b7b7b7"
      Not covered - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 5
    width: 5
    height: 3

  - title: "SFREQ White Box - Count"
    name: b4_3_sfreq_white_box_bar
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "13-SFREQ"
    sorts: [dt_req_coverage_and_validation.req_last_results]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - gold_dim_req.requirement_count: "#00a651"
      Failed - gold_dim_req.requirement_count: "#ff0000"
      Ongoing - gold_dim_req.requirement_count: "#f9ab00"
      Not Executed - gold_dim_req.requirement_count: "#b7b7b7"
      Not covered - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 10
    width: 5
    height: 3

  - title: "SOREQ - Count"
    name: b4_4_soreq_bar
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "12-SOREQ"
    sorts: [dt_req_coverage_and_validation.req_last_results]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - gold_dim_req.requirement_count: "#00a651"
      Failed - gold_dim_req.requirement_count: "#ff0000"
      Ongoing - gold_dim_req.requirement_count: "#f9ab00"
      Not Executed - gold_dim_req.requirement_count: "#b7b7b7"
      Not covered - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 15
    width: 5
    height: 3

  - title: "VOREQ - Count"
    name: b4_5_voreq_bar
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_bar
    fields:
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    filters:
      dt_req_coverage_and_validation.req_engineering_level_normalized: "11-VOREQ"
    sorts: [dt_req_coverage_and_validation.req_last_results]
    stacking: percent
    show_value_labels: true
    hide_legend: true
    series_colors:
      Passed - gold_dim_req.requirement_count: "#00a651"
      Failed - gold_dim_req.requirement_count: "#ff0000"
      Ongoing - gold_dim_req.requirement_count: "#f9ab00"
      Not Executed - gold_dim_req.requirement_count: "#b7b7b7"
      Not covered - gold_dim_req.requirement_count: "#ff0000"
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 6
    col: 20
    width: 4
    height: 3

  # --- Row 9: Engineering Level & Bench Type Breakdown + Detail Table ---
  - title: "Requirement Validation Result across All Engineering Levels"
    name: b4_chart_req_pass_rate_by_level
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_column
    fields:
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - dt_req_coverage_and_validation.req_last_results
      - gold_dim_req.requirement_count
    pivots: [dt_req_coverage_and_validation.req_last_results]
    sorts: [dt_req_coverage_and_validation.req_engineering_level_normalized asc]
    stacking: normal
    show_value_labels: true
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 9
    col: 0
    width: 12
    height: 7

  - title: "Requirement Validation Result by Test Bench Type (HIL / EIPF / VHL / SIL)"
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
    stacking: normal
    show_value_labels: true
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 9
    col: 12
    width: 12
    height: 7

  - title: "Board 4 Detail Table: Requirement Validation & Per-Bench Status Explorer"
    name: b4_grid_req_validation_detail
    tab_name: tab_4_req_pass_rate
    model: ampere_sdv_analytics
    explore: requirements_traceability
    type: looker_grid
    fields:
      - gold_dim_req.req_id
      - gold_dim_req.req_name
      - gold_dim_req.req_domain
      - dt_req_coverage_and_validation.req_engineering_level_normalized
      - gold_dim_req.req_status
      - dt_req_coverage_and_validation.covered_status
      - dt_req_coverage_and_validation.req_last_results
      - dt_req_coverage_and_validation.req_last_results_by_bench_type
      - dt_req_coverage_and_validation.count_tc
    sorts: [dt_req_coverage_and_validation.req_engineering_level_normalized asc]
    listen:
      req_domain: gold_dim_req.req_domain
      req_mysf: gold_dim_req.req_mysf_any
      req_baseline: gold_dim_req.req_baseline_any
    row: 16
    col: 0
    width: 24
    height: 8
