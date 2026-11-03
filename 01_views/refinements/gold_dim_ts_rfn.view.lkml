include: "/01_views/sources/gold_dim_ts.view.lkml"

# =============================================================================
# REFINEMENT VIEW: +gold_dim_ts (TestSet_View)
# Functional Order: Keys -> Dimensions -> Measures -> Filters -> Sets
# =============================================================================

view: +gold_dim_ts {
  label: "gold_dim_ts (Test Set)"

  # ---------------------------------------------------------------------------
  # 1. KEYS & CORE IDENTIFIERS (Hoisted Labels - LAMS H1)
  # ---------------------------------------------------------------------------

  dimension: ts_id {
    label: "[Test Set ID]"
    group_label: "1. Identity & Hierarchy"
  }

  dimension: ts_name {
    label: "[Test Set Name]"
    group_label: "1. Identity & Hierarchy"
  }

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS (Grouped by Functional Domain - LAMS H2)
  # ---------------------------------------------------------------------------

  dimension: ts_description {
    label: "Test Set Description"
    group_label: "2. Classification & Status"
  }

  dimension: ts_cb_type {
    label: "CodeBeamer Item Type"
    group_label: "2. Classification & Status"
  }

  dimension: ts_type {
    label: "Test Set Campaign Type"
    group_label: "2. Classification & Status"
  }

  dimension: ts_status {
    label: "Test Set Status"
    group_label: "2. Classification & Status"
  }

  dimension: ts_categories {
    label: "Categories"
    group_label: "2. Classification & Status"
  }

  dimension: ts_tracker {
    label: "Tracker Name"
    group_label: "2. Classification & Status"
  }

  dimension: ts_baseline {
    label: "Consolidated Baseline"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: bl_source {
    label: "Baseline Source"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_mysf {
    label: "Test Set MySF"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_sweet {
    label: "SWEET Versions"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_vehicle_project {
    label: "Vehicle Projects"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_planned_for {
    label: "Planned For Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_sw_releases {
    label: "SW Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_isp_id {
    label: "Linked ISP IDs"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_pcu_releases {
    label: "PCU ECU Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_piu_releases {
    label: "PIU ECU Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_ivc_releases {
    label: "IVC ECU Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_cdc_releases {
    label: "CDC ECU Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_other_releases {
    label: "Other ECU Releases"
    group_label: "3. Baselines, MySF & Releases"
  }

  dimension: ts_domain {
    label: "Engineering Domain"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_validation_team {
    label: "Validation Teams"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_assigned_to {
    label: "Assigned To"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_bench_type {
    label: "Bench Types"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_bench {
    label: "Bench Names"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_items_under_test {
    label: "Items Under Test"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_estimated_duration {
    label: "Estimated Duration"
    group_label: "4. Ownership, Bench & Scope"
    value_format_name: decimal_2
  }

  dimension: ts_test_cases_id {
    label: "Included Test Case IDs"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_test_case {
    label: "Included Test Case Names"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_security_level {
    label: "Security Level"
    group_label: "4. Ownership, Bench & Scope"
  }

  dimension: ts_created_by {
    label: "Created By"
    group_label: "5. Audit & Lifecycle"
  }

  dimension: ts_updated_by {
    label: "Updated By"
    group_label: "5. Audit & Lifecycle"
  }

  dimension: ts_version {
    label: "Version Number"
    group_label: "5. Audit & Lifecycle"
    value_format_name: decimal_0
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Rule 5, 6, 7, 8 & LAMS F3)
  # ---------------------------------------------------------------------------

  measure: test_set_count {
    label: "Total Test Sets"
    group_label: "Test Set Metrics"
    type: count
    filters: [pk1_ts_id: "NOT NULL"]
    value_format_name: decimal_0
    description: "Total count of unique Test Sets in gold_dim_ts."
    drill_fields: [detail*]
    link: {
      label: "Test Sets by Baseline (Column)"
      url: "@{DRILL_COLUMN_VIZ}{{ link }}&fields=gold_dim_ts.ts_baseline,gold_dim_ts.test_set_count&sorts=gold_dim_ts.test_set_count+desc&limit=20&toggle=vis"
    }
    link: {
      label: "Test Sets by Domain (Donut)"
      url: "@{DRILL_PIE_VIZ}{{ link }}&fields=gold_dim_ts.ts_domain,gold_dim_ts.test_set_count&sorts=gold_dim_ts.test_set_count+desc&limit=10&toggle=vis"
    }
  }

  measure: ts_estimated_duration_total {
    label: "Total Estimated Duration"
    group_label: "Test Set Metrics"
    type: sum
    sql: ${ts_estimated_duration} ;;
    value_format_name: decimal_2
    description: "Total estimated duration across selected Test Sets."
    drill_fields: [detail*]
  }

  # ---------------------------------------------------------------------------
  # 5. SETS (Reusable Drill Path - lookml-sets)
  # ---------------------------------------------------------------------------

  set: detail {
    fields: [
      ts_id,
      ts_name,
      ts_status,
      ts_domain,
      ts_baseline,
      bl_source,
      ts_mysf,
      ts_bench_type,
      ts_created_date
    ]
  }
}
