include: "/01_views/sources/gold_dim_fact_req_tc.view.lkml"

# =============================================================================
# REFINEMENT VIEW: +gold_dim_fact_req_tc (FACT_Requirement_TestCase)
# Functional Order: Keys -> Dimensions -> Measures -> Filters -> Sets
# =============================================================================

view: +gold_dim_fact_req_tc {
  label: "gold_dim_fact_req_tc (REQ-TC Bridge)"

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS (Grouped & Enriched)
  # ---------------------------------------------------------------------------

  dimension: is_req_covered {
    label: "Is Requirement Covered by TC"
    group_label: "1. Coverage Status & Scope"
    type: yesno
    sql: ${pk2_tc_id} IS NOT NULL ;;
    description: "True when the Requirement has a non-null Test Case ID linked in gold_dim_fact_req_tc."
  }

  dimension: req_mysf {
    label: "Requirement MySF"
    group_label: "1. Coverage Status & Scope"
  }

  dimension: req_baseline {
    label: "Requirement Baseline"
    group_label: "1. Coverage Status & Scope"
  }

  dimension: req_feature_cbid {
    label: "Requirement Feature CB IDs"
    group_label: "1. Coverage Status & Scope"
  }

  dimension: req_allocation {
    label: "Requirement Allocation"
    group_label: "1. Coverage Status & Scope"
  }

  dimension: req_asil {
    label: "Requirement ASIL"
    group_label: "1. Coverage Status & Scope"
  }

  dimension: req_regulation {
    label: "Requirement Regulation"
    group_label: "1. Coverage Status & Scope"
  }

  dimension: tc_domain {
    label: "Test Case Domain"
    group_label: "2. Covering Test Case Scope"
  }

  dimension: tc_engineering_level {
    label: "Test Case Engineering Level"
    group_label: "2. Covering Test Case Scope"
  }

  dimension: tc_system_owner {
    label: "Test Case System Owner"
    group_label: "2. Covering Test Case Scope"
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Rule 5, 6, 7, 8 & LAMS F3)
  # ---------------------------------------------------------------------------

  measure: req_tc_link_count {
    label: "REQ-TC Coverage Links"
    group_label: "Horizontal Traceability Metrics"
    type: count
    filters: [pk_req_tc_id: "-NULL"]
    value_format_name: decimal_0
    description: "Total count of Requirement-to-TestCase bridge rows in gold_dim_fact_req_tc."
    drill_fields: [detail*]
  }

  measure: distinct_req_count {
    label: "Distinct Requirements (Bridge)"
    group_label: "Horizontal Traceability Metrics"
    type: count_distinct
    sql: ${pk2_req_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Requirements present in gold_dim_fact_req_tc."
    drill_fields: [detail*]
  }

  measure: covered_distinct_req_count {
    label: "Covered Requirements (Bridge)"
    group_label: "Horizontal Traceability Metrics"
    type: count_distinct
    sql: ${pk2_req_id} ;;
    filters: [is_req_covered: "yes"]
    value_format_name: decimal_0
    description: "Count of distinct Requirements that have at least one covering Test Case."
    drill_fields: [detail*]
  }

  measure: distinct_tc_count {
    label: "Distinct Covering Test Cases"
    group_label: "Horizontal Traceability Metrics"
    type: count_distinct
    sql: ${pk2_tc_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Test Cases covering Requirements."
    drill_fields: [detail*]
  }

  measure: horizontal_coverage_rate {
    label: "Horizontal REQ-TC Coverage Rate"
    group_label: "Horizontal Traceability Metrics"
    type: number
    sql: SAFE_DIVIDE(${covered_distinct_req_count}, ${distinct_req_count}) ;;
    value_format_name: percent_1
    description: "Percentage of distinct Requirements covered by at least one Test Case."
    drill_fields: [detail*]
    link: {
      label: "Coverage by Requirement ASIL (Column)"
      url: "@{DRILL_COLUMN_VIZ}{{ link }}&fields=gold_dim_fact_req_tc.req_asil,gold_dim_fact_req_tc.horizontal_coverage_rate&sorts=gold_dim_fact_req_tc.horizontal_coverage_rate+desc&limit=10&toggle=vis"
    }
  }

  # ---------------------------------------------------------------------------
  # 5. SETS (Reusable Drill Path - lookml-sets)
  # ---------------------------------------------------------------------------

  set: detail {
    fields: [
      req_mysf,
      req_baseline,
      req_asil,
      req_allocation,
      tc_domain,
      tc_engineering_level,
      tc_system_owner,
      is_req_covered
    ]
  }
}
