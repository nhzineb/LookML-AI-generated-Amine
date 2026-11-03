include: "/01_views/sources/gold_dim_req.view.lkml"

# =============================================================================
# REFINEMENT VIEW: +gold_dim_req (Requirement_View)
# Functional Order: Keys -> Dimensions -> Measures -> Filters -> Sets
# =============================================================================

view: +gold_dim_req {
  label: "gold_dim_req (Requirement)"

  # ---------------------------------------------------------------------------
  # 1. KEYS & CORE IDENTIFIERS (Hoisted Labels - LAMS H1)
  # ---------------------------------------------------------------------------

  dimension: req_id {
    label: "[Requirement ID]"
    group_label: "1. Identity & Hierarchy"
  }

  dimension: req_name {
    label: "[Requirement Name]"
    group_label: "1. Identity & Hierarchy"
  }

  dimension: req_legacy_identifier {
    label: "Legacy Identifier"
    group_label: "1. Identity & Hierarchy"
  }

  dimension: req_requirement_parent_id {
    label: "Parent Requirement IDs"
    group_label: "1. Identity & Hierarchy"
  }

  dimension: req_child_required {
    label: "Child Decomposition Required"
    group_label: "1. Identity & Hierarchy"
  }

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS (Grouped & Enriched with Liquid HTML & Access Grants)
  # ---------------------------------------------------------------------------

  dimension: req_description {
    label: "Requirement Description"
    group_label: "2. Specification & Classification"
  }

  dimension: req_type {
    label: "Requirement Type"
    group_label: "2. Specification & Classification"
  }

  dimension: req_requirement_category {
    label: "Requirement Category"
    group_label: "2. Specification & Classification"
  }

  dimension: req_categories {
    label: "Categories List"
    group_label: "2. Specification & Classification"
  }

  dimension: req_status {
    label: "Requirement Status"
    group_label: "2. Specification & Classification"
    html:
      {% if value == 'Approved' or value == 'Accepted' or value == 'Released' %}
        <span style="background-color:#e6f4ea; color:#137333; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Obsolete' or value == 'Rejected' %}
        <span style="background-color:#fce8e6; color:#c5221f; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% else %}
        <span style="background-color:#fef7e0; color:#b06000; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% endif %} ;;
  }

  dimension: req_final_status {
    label: "Final Status"
    group_label: "2. Specification & Classification"
  }

  dimension: is_approved_or_accepted {
    label: "Is Approved or Accepted"
    group_label: "2. Specification & Classification"
    type: yesno
    sql: ${req_status} IN ('Approved', 'Accepted', 'Released') ;;
    description: "True when the Requirement status is Approved, Accepted, or Released."
  }

  dimension: is_covered_by_test_case {
    label: "Has Linked Test Case (Gold Array)"
    group_label: "2. Specification & Classification"
    type: yesno
    sql: ${req_test_cases} IS NOT NULL AND ${req_test_cases} != '' ;;
    description: "True when the Requirement has at least one Test Case ID in Req_Test_Cases."
  }

  dimension: req_mysf {
    label: "Consolidated MySF"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_baseline {
    label: "Consolidated Baselines"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_feature_cbid {
    label: "Feature CB IDs"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_sweet {
    label: "SWEET Versions"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_cb_project_name {
    label: "CodeBeamer Project Name"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_vehicle_project_id {
    label: "Vehicle Project IDs"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_planned_for {
    label: "Planned For Releases"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_target_planned_for {
    label: "Target Planned For"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_obsolete_from {
    label: "Obsolete From"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_sw_releases {
    label: "SW Releases"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_sw_components {
    label: "SW Components"
    group_label: "3. Scope, MySF & Baselines"
  }

  dimension: req_domain {
    label: "Engineering Domain"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_sub_domain {
    label: "Engineering Sub-Domain"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_system_owner {
    label: "System Owner"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_engineering_level {
    label: "Engineering Level"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_allocation {
    label: "System Allocation"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_supplier {
    label: "Supplier"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_tracker {
    label: "Tracker Name"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_asil {
    label: "ASIL Level"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: req_safety_related {
    label: "Safety Related"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: req_safety_derived_from {
    label: "Safety Derived From IDs"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: req_regulation {
    label: "Regulation"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: req_cyber {
    label: "Cybersecurity Relevant"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: req_security_level {
    label: "Security Level"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: req_validation_methods {
    label: "Validation Methods"
    group_label: "6. Validation & Test Scope"
  }

  dimension: req_validation_teams {
    label: "Validation Teams"
    group_label: "6. Validation & Test Scope"
  }

  dimension: req_bench_type {
    label: "Target Bench Types"
    group_label: "6. Validation & Test Scope"
  }

  dimension: req_items_under_test {
    label: "Items Under Test"
    group_label: "6. Validation & Test Scope"
  }

  dimension: req_test_cases {
    label: "Linked Test Case IDs"
    group_label: "6. Validation & Test Scope"
  }

  dimension: req_created_by {
    label: "Created By"
    group_label: "7. Audit & Lifecycle"
  }

  dimension: req_updated_by {
    label: "Updated By"
    group_label: "7. Audit & Lifecycle"
  }

  dimension: req_version {
    label: "Version Number"
    group_label: "7. Audit & Lifecycle"
    value_format_name: decimal_0
  }

  dimension: req_created_week {
    label: "Created ISO Week"
    group_label: "7. Audit & Lifecycle"
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Rule 5, 6, 7, 8 & LAMS F3)
  # ---------------------------------------------------------------------------

  measure: requirement_count {
    label: "Total Requirements"
    group_label: "Requirement Metrics"
    type: count
    filters: [pk1_req_id: "NOT NULL"]
    value_format_name: decimal_0
    description: "Total count of unique Requirements in gold_dim_req."
    drill_fields: [detail*]
    link: {
      label: "Requirements by Domain (Column)"
      url: "@{DRILL_COLUMN_VIZ}{{ link }}&fields=gold_dim_req.req_domain,gold_dim_req.requirement_count&sorts=gold_dim_req.requirement_count+desc&limit=20&toggle=vis"
    }
    link: {
      label: "Requirements by Status (Donut)"
      url: "@{DRILL_PIE_VIZ}{{ link }}&fields=gold_dim_req.req_status,gold_dim_req.requirement_count&sorts=gold_dim_req.requirement_count+desc&limit=10&toggle=vis"
    }
  }

  measure: approved_requirement_count {
    label: "Approved Requirements"
    group_label: "Requirement Metrics"
    type: count
    filters: [pk1_req_id: "NOT NULL", is_approved_or_accepted: "yes"]
    value_format_name: decimal_0
    description: "Total count of Requirements with Approved, Accepted, or Released status."
    drill_fields: [detail*]
  }

  measure: covered_requirement_count {
    label: "Covered Requirements"
    group_label: "Requirement Metrics"
    type: count
    filters: [pk1_req_id: "NOT NULL", is_covered_by_test_case: "yes"]
    value_format_name: decimal_0
    description: "Count of Requirements linked to at least one Test Case."
    drill_fields: [detail*]
  }

  measure: uncovered_requirement_count {
    label: "Uncovered Requirements"
    group_label: "Requirement Metrics"
    type: count
    filters: [pk1_req_id: "NOT NULL", is_covered_by_test_case: "no"]
    value_format_name: decimal_0
    description: "Count of Requirements with no linked Test Cases."
    drill_fields: [detail*]
  }

  measure: requirement_approval_rate {
    label: "Requirement Approval Rate"
    group_label: "Requirement Metrics"
    type: number
    sql: SAFE_DIVIDE(${approved_requirement_count}, ${requirement_count}) ;;
    value_format_name: percent_1
    description: "Percentage of total Requirements that are Approved, Accepted, or Released."
    drill_fields: [detail*]
  }

  measure: requirement_test_coverage_rate {
    label: "Requirement Test Coverage Rate"
    group_label: "Requirement Metrics"
    type: number
    sql: SAFE_DIVIDE(${covered_requirement_count}, ${requirement_count}) ;;
    value_format_name: percent_1
    description: "Percentage of total Requirements covered by at least one Test Case."
    drill_fields: [detail*]
  }

  # ---------------------------------------------------------------------------
  # 5. SETS (Reusable Drill Path - lookml-sets)
  # ---------------------------------------------------------------------------

  set: detail {
    fields: [
      req_id,
      req_name,
      req_status,
      req_domain,
      req_mysf,
      req_baseline,
      req_asil,
      req_engineering_level,
      req_system_owner,
      req_created_date
    ]
  }
}
