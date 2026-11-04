# -------------------------------------------------------------------------
# LookML Refinement View: +tbl_cb_sdv_raw_tc_v2 (Test Case Business Logic & Metrics)
# Physical Table: TBL_CB_SDV_Raw_TC_V2 (TestCase_View in Mermaid)
# -------------------------------------------------------------------------
include: "/01_views/sources/tbl_cb_sdv_raw_tc_v2.view.lkml"

view: +tbl_cb_sdv_raw_tc_v2 {
  label: "Test Case (TBL_CB_SDV_Raw_TC_V2)"

  # =======================================================================
  # 1. REFINED PRIMARY KEY & CORE ATTRIBUTES
  # =======================================================================

  dimension: id {
    label: "Test Case ID"
    description: "Unique identifier of the Test Case (TBL_CB_SDV_Raw_TC_V2.Id)"
    value_format_name: id
    link: {
      label: "Open Test Case #{{ value }} in Codebeamer"
      url: "@{codebeamer_base_url}/item/{{ value }}"
    }
  }

  dimension: name {
    label: "Test Case Name"
    description: "Short title/summary of the Test Case"
  }

  dimension: status {
    label: "Test Case Status"
    description: "Lifecycle status of the Test Case in Codebeamer"
  }

  dimension: domain {
    label: "Test Case Domain"
    description: "Functional engineering domain of the Test Case"
    drill_fields: [sub_domain, status, name]
  }

  dimension: sub_domain {
    label: "Test Case Sub-Domain"
    description: "Sub-domain of the Test Case"
  }

  dimension: type {
    label: "Test Case Type"
    description: "Classification type of the Test Case (TBL_CB_SDV_Raw_TC_V2.Type)"
  }

  dimension: automation_status {
    label: "Automation Status (Raw)"
    description: "Test automation status (TBL_CB_SDV_Raw_TC_V2.Automation_Status)"
  }

  dimension: estimated_duration {
    label: "Estimated Duration (Raw)"
    description: "Estimated execution duration (TBL_CB_SDV_Raw_TC_V2.Estimated_Duration)"
    value_format_name: decimal_1
  }

  dimension: test_case_nature {
    label: "Test Case Nature"
    description: "Nature/type of the test case mapped from TBL_CB_SDV_Raw_TC_V2.Type"
    type: string
    sql: ${type} ;;
  }

  dimension: automated {
    label: "Automation Status"
    description: "Indicates whether the Test Case is automated, mapped from TBL_CB_SDV_Raw_TC_V2.Automation_Status"
    type: string
    sql: ${automation_status} ;;
  }

  dimension: estimated_running_time {
    label: "Estimated Running Time (min)"
    description: "Estimated duration to execute the Test Case, mapped from TBL_CB_SDV_Raw_TC_V2.Estimated_Duration"
    type: number
    sql: ${estimated_duration} ;;
    value_format_name: decimal_1
  }

  # =======================================================================
  # 2. DERIVED BUSINESS DIMENSIONS (Board 2 PVAL Bench & Feature Coverage)
  # =======================================================================

  dimension: is_accepted_or_approved {
    group_label: "Test Case Flags"
    label: "Is Accepted / Approved"
    description: "True when the Test Case status is Accepted, Approved, or Released"
    type: yesno
    sql: UPPER(${status}) IN ('ACCEPTED', 'APPROVED', 'RELEASED', 'VALIDATED') ;;
  }

  dimension: is_automated_flag {
    group_label: "Test Case Flags"
    label: "Is Automated"
    description: "True when the Test Case is marked as Automated / Yes"
    type: yesno
    sql: UPPER(${automation_status}) IN ('YES', 'TRUE', 'AUTOMATED', '1') ;;
  }

  dimension: has_verifies_requirement {
    group_label: "Test Case Flags"
    label: "Has Direct Verifies Link"
    description: "True when the Test Case has at least one linked Requirement in verifies_id"
    type: yesno
    sql: ARRAY_LENGTH(${verifies_id}) > 0 ;;
  }

  dimension: bench_type_documented {
    group_label: "Board 2.2 - Bench & Feature Documentation"
    label: "Bench Type Documented (Documented / Not documented)"
    description: "'Documented' when Bench_Type array is non-empty, else 'Not documented' (Board 2 Section 2 & TC_ADAS.txt)"
    type: string
    sql: IF(ARRAY_LENGTH(${bench_type_list}) > 0, 'Documented', 'Not documented') ;;
  }

  dimension: bench_type_ordered {
    group_label: "Board 2.2 - Bench & Feature Documentation"
    label: "Bench Type Ordered (Normalized)"
    description: "Uppercase, alphabetically ordered comma-separated list of Bench Types (TC_ADAS.txt bench_norm)"
    type: string
    sql: (SELECT STRING_AGG(DISTINCT TRIM(UPPER(b)), ', ' ORDER BY TRIM(UPPER(b))) FROM UNNEST(${bench_type_list}) AS b WHERE TRIM(b) != '') ;;
  }

  dimension: feature_documented {
    group_label: "Board 2.2 - Bench & Feature Documentation"
    label: "Feature Documented (Documented / Not documented)"
    description: "'Documented' when Feature_Id array is non-empty, else 'Not documented' (TC_ADAS.txt)"
    type: string
    sql: IF(ARRAY_LENGTH(${feature_id_list}) > 0, 'Documented', 'Not documented') ;;
  }

  # =======================================================================
  # 3. ZERO-FANOUT ARRAY FILTERS (EXISTS UNNEST)
  # =======================================================================

  filter: bench_type_any {
    type: string
    group_label: "Board 2.2 - Bench & Feature Documentation"
    label: "Filter: TC Bench Type (Array Item)"
    description: "Zero-fanout correlated EXISTS filter on Test Case Bench_Type array."
    sql: EXISTS (SELECT 1 FROM UNNEST(${bench_type_list}) AS x WHERE {% condition bench_type_any %} x {% endcondition %}) ;;
  }

  filter: feature_id_any {
    type: string
    group_label: "Board 2.2 - Bench & Feature Documentation"
    label: "Filter: TC Feature ID (Array Item)"
    description: "Zero-fanout correlated EXISTS filter on Test Case Feature_Id array."
    sql: EXISTS (SELECT 1 FROM UNNEST(${feature_id_list}) AS x WHERE {% condition feature_id_any %} x {% endcondition %}) ;;
  }

  filter: validation_teams_any {
    type: string
    group_label: "Test Case Flags"
    label: "Filter: TC Validation Team (Array Item)"
    description: "Zero-fanout correlated EXISTS filter on Test Case Validation_Teams array."
    sql: EXISTS (SELECT 1 FROM UNNEST(${validation_teams_list}) AS x WHERE {% condition validation_teams_any %} x {% endcondition %}) ;;
  }

  filter: mysf_any {
    type: string
    group_label: "Test Case Flags"
    label: "Filter: TC Direct MySF (Array Item)"
    description: "Zero-fanout correlated EXISTS filter on Test Case MySF array."
    sql: EXISTS (SELECT 1 FROM UNNEST(${mysf_list}) AS x WHERE {% condition mysf_any %} x {% endcondition %}) ;;
  }

  # =======================================================================
  # 4. MEASURES (KPIs)
  # =======================================================================

  measure: count_test_cases {
    label: "Total Test Cases"
    description: "Distinct count of Test Cases (TBL_CB_SDV_Raw_TC_V2)"
    type: count_distinct
    sql: ${id} ;;
    value_format_name: decimal_0
    drill_fields: [tc_default_drill*]
  }

  measure: count_accepted_test_cases {
    group_label: "Maturity & Automation Metrics"
    label: "Accepted Test Cases"
    description: "Count of Test Cases in Accepted/Approved/Released status"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_accepted_or_approved: "yes"]
    value_format_name: decimal_0
    drill_fields: [tc_default_drill*]
  }

  measure: count_automated_test_cases {
    group_label: "Maturity & Automation Metrics"
    label: "Automated Test Cases"
    description: "Count of automated Test Cases"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_automated_flag: "yes"]
    value_format_name: decimal_0
    drill_fields: [tc_default_drill*]
  }

  measure: automation_rate {
    group_label: "Maturity & Automation Metrics"
    label: "Test Automation Rate (%)"
    description: "Percentage of Test Cases that are automated"
    type: number
    sql: SAFE_DIVIDE(${count_automated_test_cases}, ${count_test_cases}) ;;
    value_format_name: percent_1
    drill_fields: [tc_default_drill*]
  }

  measure: count_bench_documented_test_cases {
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    label: "Bench-Documented Test Cases"
    description: "Distinct count of Test Cases with Bench_Type documented (Board 2 Section 2)"
    type: count_distinct
    sql: ${id} ;;
    filters: [bench_type_documented: "Documented"]
    value_format_name: decimal_0
    drill_fields: [tc_default_drill*]
  }

  measure: count_bench_not_documented_test_cases {
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    label: "Bench-Undocumented Test Cases"
    description: "Distinct count of Test Cases with Bench_Type not documented (Board 2 Section 2)"
    type: count_distinct
    sql: ${id} ;;
    filters: [bench_type_documented: "Not documented"]
    value_format_name: decimal_0
    drill_fields: [tc_default_drill*]
  }

  measure: bench_documentation_rate {
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    label: "Bench Documentation Rate (%)"
    description: "Percentage of Test Cases that have a documented Bench Type"
    type: number
    sql: SAFE_DIVIDE(${count_bench_documented_test_cases}, ${count_test_cases}) ;;
    value_format_name: percent_1
    drill_fields: [tc_default_drill*]
  }

  measure: count_verifies_linked_test_cases {
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    label: "Test Cases with Direct Verifies Link"
    description: "Distinct count of Test Cases linked to at least one Requirement in Verifies_Id"
    type: count_distinct
    sql: ${id} ;;
    filters: [has_verifies_requirement: "yes"]
    value_format_name: decimal_0
    drill_fields: [tc_default_drill*]
  }

  measure: total_estimated_running_time {
    group_label: "Effort Metrics"
    label: "Total Estimated Running Time"
    description: "Sum of estimated running time across Test Cases"
    type: sum
    sql: ${estimated_running_time} ;;
    value_format_name: decimal_1
  }

  measure: avg_estimated_running_time {
    group_label: "Effort Metrics"
    label: "Average Estimated Running Time"
    description: "Average estimated running time per Test Case"
    type: average
    sql: ${estimated_running_time} ;;
    value_format_name: decimal_1
  }

  # =======================================================================
  # 5. FIELD SETS
  # =======================================================================

  set: tc_default_drill {
    fields: [
      id,
      name,
      status,
      domain,
      sub_domain,
      test_case_nature,
      automated,
      bench_type_documented,
      bench_type_ordered,
      estimated_running_time,
      created_date
    ]
  }
}
