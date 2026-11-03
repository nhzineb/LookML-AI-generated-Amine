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

  dimension: test_case_nature {
    label: "Test Case Nature"
    description: "Nature of the test case (e.g., Functional, Performance, Robustness)"
  }

  dimension: automated {
    label: "Automation Status"
    description: "Indicates whether the Test Case is automated"
  }

  dimension: estimated_running_time {
    label: "Estimated Running Time (min)"
    description: "Estimated duration to execute the Test Case"
    value_format_name: decimal_1
  }

  # =======================================================================
  # 2. DERIVED BUSINESS DIMENSIONS
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
    sql: UPPER(${automated}) IN ('YES', 'TRUE', 'AUTOMATED', '1') ;;
  }

  dimension: has_verifies_requirement {
    group_label: "Test Case Flags"
    label: "Has Direct Verifies Link"
    description: "True when the Test Case has at least one linked Requirement in verifies_id"
    type: yesno
    sql: ARRAY_LENGTH(${verifies_id}) > 0 ;;
  }

  # =======================================================================
  # 3. MEASURES (KPIs)
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
  # 4. FIELD SETS
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
      estimated_running_time,
      created_date
    ]
  }
}
