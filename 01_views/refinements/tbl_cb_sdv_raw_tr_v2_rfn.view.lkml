# -------------------------------------------------------------------------
# LookML Refinement View: +tbl_cb_sdv_raw_tr_v2 (Test Run Business Logic & Metrics)
# Physical Table: TBL_CB_SDV_Raw_TR_V2 (TestRun_View in Mermaid)
# -------------------------------------------------------------------------
include: "/01_views/sources/tbl_cb_sdv_raw_tr_v2.view.lkml"

view: +tbl_cb_sdv_raw_tr_v2 {
  label: "Test Run (TBL_CB_SDV_Raw_TR_V2)"

  # =======================================================================
  # 1. REFINED PRIMARY KEY & CORE ATTRIBUTES
  # =======================================================================

  dimension: id {
    label: "Test Run ID"
    description: "Unique identifier of the Test Run (TBL_CB_SDV_Raw_TR_V2.Id)"
    value_format_name: id
    link: {
      label: "Open Test Run #{{ value }} in Codebeamer"
      url: "@{codebeamer_base_url}/item/{{ value }}"
    }
  }

  dimension: name {
    label: "Test Run Name"
    description: "Short title/summary of the Test Run"
  }

  dimension: status {
    label: "Test Run Status"
    description: "Lifecycle status of the Test Run (e.g., Finished, In Progress, Suspended)"
  }

  dimension: result {
    label: "Test Run Result"
    description: "Execution verdict of the Test Run (Passed, Failed, Blocked, Not Run)"
    html:
      {% if value == 'Passed' or value == 'PASSED' %}
        <span style="color: #1e8e3e; font-weight: bold;">&#10004; {{ rendered_value }}</span>
      {% elsif value == 'Failed' or value == 'FAILED' %}
        <span style="color: #d93025; font-weight: bold;">&#10008; {{ rendered_value }}</span>
      {% elsif value == 'Blocked' or value == 'BLOCKED' %}
        <span style="color: #f9ab00; font-weight: bold;">&#9888; {{ rendered_value }}</span>
      {% else %}
        <span>{{ rendered_value }}</span>
      {% endif %} ;;
  }

  dimension: domain {
    label: "Test Run Domain"
    description: "Functional engineering domain of the Test Run"
    drill_fields: [sub_domain, result, status, name]
  }

  dimension: running_time {
    label: "Actual Running Time"
    description: "Actual execution duration of the Test Run"
    value_format_name: decimal_1
  }

  # =======================================================================
  # 2. DERIVED BUSINESS DIMENSIONS
  # =======================================================================

  dimension: normalized_result {
    group_label: "Execution Verdict Flags"
    label: "Normalized Result"
    description: "Standardized execution verdict bucket (Passed, Failed, Blocked, Not Run / Other)"
    type: string
    sql:
      CASE
        WHEN UPPER(${result}) IN ('PASSED', 'PASS', 'OK') THEN 'Passed'
        WHEN UPPER(${result}) IN ('FAILED', 'FAIL', 'KO', 'NOK') THEN 'Failed'
        WHEN UPPER(${result}) IN ('BLOCKED', 'BLOCK') THEN 'Blocked'
        ELSE 'Not Run / Other'
      END ;;
  }

  dimension: is_passed {
    group_label: "Execution Verdict Flags"
    label: "Is Passed"
    description: "True when the Test Run execution verdict is Passed"
    type: yesno
    sql: UPPER(${result}) IN ('PASSED', 'PASS', 'OK') ;;
  }

  dimension: is_failed {
    group_label: "Execution Verdict Flags"
    label: "Is Failed"
    description: "True when the Test Run execution verdict is Failed"
    type: yesno
    sql: UPPER(${result}) IN ('FAILED', 'FAIL', 'KO', 'NOK') ;;
  }

  dimension: is_blocked {
    group_label: "Execution Verdict Flags"
    label: "Is Blocked"
    description: "True when the Test Run execution verdict is Blocked"
    type: yesno
    sql: UPPER(${result}) IN ('BLOCKED', 'BLOCK') ;;
  }

  dimension: is_executed {
    group_label: "Execution Verdict Flags"
    label: "Is Executed (Passed or Failed)"
    description: "True when the Test Run finished with an active verdict (Passed, Failed, or Blocked)"
    type: yesno
    sql: UPPER(${result}) IN ('PASSED', 'PASS', 'OK', 'FAILED', 'FAIL', 'KO', 'NOK', 'BLOCKED', 'BLOCK') ;;
  }

  dimension: has_reported_bug {
    group_label: "Execution Verdict Flags"
    label: "Has Reported Bug (Array)"
    description: "True when the Test Run has at least one reported bug in reported_bugs_id"
    type: yesno
    sql: ARRAY_LENGTH(${reported_bugs_id}) > 0 ;;
  }

  # =======================================================================
  # 3. MEASURES (KPIs)
  # =======================================================================

  measure: count_test_runs {
    label: "Total Test Runs"
    description: "Distinct count of Test Runs (TBL_CB_SDV_Raw_TR_V2)"
    type: count_distinct
    sql: ${id} ;;
    value_format_name: decimal_0
    drill_fields: [tr_default_drill*]
  }

  measure: count_executed_test_runs {
    group_label: "Execution Verdict Metrics"
    label: "Executed Test Runs"
    description: "Count of Test Runs with an execution verdict (Passed, Failed, or Blocked)"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_executed: "yes"]
    value_format_name: decimal_0
    drill_fields: [tr_default_drill*]
  }

  measure: count_passed_test_runs {
    group_label: "Execution Verdict Metrics"
    label: "Passed Test Runs"
    description: "Count of Test Runs with Passed result"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_passed: "yes"]
    value_format_name: decimal_0
    drill_fields: [tr_default_drill*]
  }

  measure: count_failed_test_runs {
    group_label: "Execution Verdict Metrics"
    label: "Failed Test Runs"
    description: "Count of Test Runs with Failed result"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_failed: "yes"]
    value_format_name: decimal_0
    drill_fields: [tr_default_drill*]
  }

  measure: count_blocked_test_runs {
    group_label: "Execution Verdict Metrics"
    label: "Blocked Test Runs"
    description: "Count of Test Runs with Blocked result"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_blocked: "yes"]
    value_format_name: decimal_0
    drill_fields: [tr_default_drill*]
  }

  measure: pass_rate {
    group_label: "Execution Verdict Metrics"
    label: "Test Run Pass Rate (%)"
    description: "Percentage of executed Test Runs that passed"
    type: number
    sql: SAFE_DIVIDE(${count_passed_test_runs}, ${count_executed_test_runs}) ;;
    value_format_name: percent_1
    drill_fields: [tr_default_drill*]
  }

  measure: execution_rate {
    group_label: "Execution Verdict Metrics"
    label: "Test Run Execution Rate (%)"
    description: "Percentage of total Test Runs that have been executed"
    type: number
    sql: SAFE_DIVIDE(${count_executed_test_runs}, ${count_test_runs}) ;;
    value_format_name: percent_1
    drill_fields: [tr_default_drill*]
  }

  measure: total_running_time {
    group_label: "Execution Effort Metrics"
    label: "Total Actual Running Time"
    description: "Sum of actual running time across Test Runs"
    type: sum
    sql: ${running_time} ;;
    value_format_name: decimal_1
  }

  # =======================================================================
  # 4. FIELD SETS
  # =======================================================================

  set: tr_default_drill {
    fields: [
      id,
      name,
      status,
      result,
      domain,
      sub_domain,
      assigned_to,
      running_time,
      created_date
    ]
  }
}
