include: "/01_views/sources/fact_tc_tr_ts_req.view.lkml"

# =============================================================================
# REFINEMENT VIEW: +fact_tc_tr_ts_req (FACT_TC_TR_TS_REQ)
# Functional Order: Keys -> Dimensions -> Measures -> Filters -> Sets
# =============================================================================

view: +fact_tc_tr_ts_req {
  label: "[FACT_TC_TR_TS_REQ]"

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: tr_mysf {
    label: "Derived Test Run MySF (TR_MySF)"
    group_label: "1. Derived Execution Scope"
  }

  dimension: is_executed_tc {
    label: "Has Executed Test Run"
    group_label: "1. Derived Execution Scope"
    type: yesno
    sql: ${pk4_tr_id} IS NOT NULL ;;
    description: "True when the Test Case has an associated Test Run execution (TR_Id IS NOT NULL)."
  }

  dimension: is_planned_in_ts {
    label: "Is Assigned to Test Set"
    group_label: "1. Derived Execution Scope"
    type: yesno
    sql: ${pk4_ts_id} IS NOT NULL ;;
    description: "True when the execution row is linked to a Test Set (TS_Id IS NOT NULL)."
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Rule 5, 6, 7, 8 & LAMS F3)
  # ---------------------------------------------------------------------------

  measure: execution_bridge_row_count {
    label: "Total Execution Bridge Rows"
    group_label: "Execution & Traceability Fact Metrics"
    type: count
    filters: [pk_tc_tr_ts_req_id: "-NULL"]
    value_format_name: decimal_0
    description: "Total count of rows in FACT_TC_TR_TS_REQ."
    drill_fields: [detail*]
  }

  measure: distinct_executed_tr_count {
    label: "Distinct Test Runs (Bridge)"
    group_label: "Execution & Traceability Fact Metrics"
    type: count_distinct
    sql: ${pk4_tr_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Test Runs in FACT_TC_TR_TS_REQ."
    drill_fields: [detail*]
    link: {
      label: "Test Runs by Derived TR_MySF (Column)"
      url: "@{DRILL_COLUMN_VIZ}{{ link }}&fields=fact_tc_tr_ts_req.tr_mysf,fact_tc_tr_ts_req.distinct_executed_tr_count&sorts=fact_tc_tr_ts_req.distinct_executed_tr_count+desc&limit=20&toggle=vis"
    }
  }

  measure: distinct_tc_in_bridge_count {
    label: "Distinct Test Cases (Bridge)"
    group_label: "Execution & Traceability Fact Metrics"
    type: count_distinct
    sql: ${pk4_tc_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Test Cases in FACT_TC_TR_TS_REQ."
    drill_fields: [detail*]
  }

  measure: distinct_executed_tc_count {
    label: "Distinct Executed Test Cases"
    group_label: "Execution & Traceability Fact Metrics"
    type: count_distinct
    sql: ${pk4_tc_id} ;;
    filters: [is_executed_tc: "yes"]
    value_format_name: decimal_0
    description: "Count of distinct Test Cases that have at least one executed Test Run."
    drill_fields: [detail*]
  }

  measure: distinct_ts_in_bridge_count {
    label: "Distinct Test Sets (Bridge)"
    group_label: "Execution & Traceability Fact Metrics"
    type: count_distinct
    sql: ${pk4_ts_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Test Sets in FACT_TC_TR_TS_REQ."
    drill_fields: [detail*]
  }

  measure: distinct_req_in_bridge_count {
    label: "Distinct Requirements (Bridge)"
    group_label: "Execution & Traceability Fact Metrics"
    type: count_distinct
    sql: ${pk4_req_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Requirements linked in FACT_TC_TR_TS_REQ."
    drill_fields: [detail*]
  }

  measure: tc_execution_coverage_rate {
    label: "Test Case Execution Rate"
    group_label: "Execution & Traceability Fact Metrics"
    type: number
    sql: SAFE_DIVIDE(${distinct_executed_tc_count}, ${distinct_tc_in_bridge_count}) ;;
    value_format_name: percent_1
    description: "Percentage of distinct Test Cases in the bridge that have been executed by at least one Test Run."
    drill_fields: [detail*]
  }

  # ---------------------------------------------------------------------------
  # 5. SETS (Reusable Drill Path - lookml-sets)
  # ---------------------------------------------------------------------------

  set: detail {
    fields: [
      tr_mysf,
      is_executed_tc,
      is_planned_in_ts,
      distinct_tc_in_bridge_count,
      distinct_executed_tr_count,
      distinct_ts_in_bridge_count,
      distinct_req_in_bridge_count
    ]
  }
}
