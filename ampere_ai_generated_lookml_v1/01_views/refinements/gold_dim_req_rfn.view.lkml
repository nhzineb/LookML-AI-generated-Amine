include: "/ampere_ai_generated_lookml_v1/01_views/sources/gold_dim_req.view.lkml"

# =============================================================================
# REFINEMENT VIEW: +gold_dim_req (Requirement_View)
# Functional Order: Keys -> Dimensions -> Filters -> Measures -> Sets
# =============================================================================

view: +gold_dim_req {
  label: "gold_dim_req (Requirement)"

  # ---------------------------------------------------------------------------
  # 1. KEYS & CORE IDENTIFIERS (Hoisted Labels - LAMS H1)
  # ---------------------------------------------------------------------------

  dimension: req_id {
    label: "[Requirement ID]"
    group_label: "1. Identity & Hierarchy"
    link: {
      label: "Open Requirement #{{ value }} in Codebeamer"
      url: "@{codebeamer_base_url}/item/{{ value }}"
    }
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

  dimension: has_parent_requirement {
    label: "Has Parent Requirement"
    group_label: "1. Identity & Hierarchy"
    type: yesno
    sql: ARRAY_LENGTH(${req_requirement_parent_id_list}) > 0 ;;
    description: "True when the Requirement has at least one upstream Parent Requirement ID."
  }

  dimension: primary_parent_req_id {
    label: "Primary Parent Requirement ID"
    group_label: "1. Identity & Hierarchy"
    type: number
    sql: ${req_requirement_parent_id_list}[SAFE_OFFSET(0)] ;;
    value_format_name: id
    description: "Primary (first) upstream Parent Requirement ID for N:1 upward traceability."
  }

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS (Grouped & Enriched with Board 1 & Board 4 Logic)
  # ---------------------------------------------------------------------------

  dimension: req_description {
    label: "Requirement Description"
    group_label: "2. Specification & Classification"
  }

  dimension: req_type {
    label: "Requirement Type"
    group_label: "2. Specification & Classification"
  }

  dimension: req_classification {
    label: "Requirement Classification"
    group_label: "2. Specification & Classification"
  }

  dimension: req_requirement_category {
    label: "Requirement Category"
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

  dimension: is_draft_status {
    label: "Is Draft Status"
    group_label: "2. Specification & Classification"
    type: yesno
    sql: LOWER(TRIM(${req_status})) = 'draft' ;;
    description: "True when the Requirement status is Draft (excluded from Covered in Board 2.1)."
  }

  dimension: is_rejected_status {
    label: "Is Rejected Status"
    group_label: "2. Specification & Classification"
    type: yesno
    sql: LOWER(TRIM(${req_status})) LIKE '%rejected%' ;;
    description: "True when the Requirement status is Rejected."
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

  dimension: feature_documented {
    label: "Feature Documented (Documented / Not documented)"
    group_label: "3. Scope, MySF & Baselines"
    type: string
    sql: IF(ARRAY_LENGTH(${req_feature_cbid_list}) > 0, 'Documented', 'Not documented') ;;
    description: "'Documented' when Req_Feature_CBId has at least one feature, else 'Not documented' (Req_ADAS.txt)."
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

  dimension: req_engineering_level_normalized {
    label: "Engineering Level (Normalized V-Cycle)"
    group_label: "4. Ownership & Architecture"
    type: string
    sql:
      COALESCE(
        (
          SELECT v
          FROM UNNEST([
            STRUCT('SG' AS k, '01-SG' AS v),
            STRUCT('FSR', '02-FSR'),
            STRUCT('TSR', '03-TSR'),
            STRUCT('CP', '04-CP'),
            STRUCT('REG', '05-REG'),
            STRUCT('CyberG', '06-CyberG'),
            STRUCT('VOReq', '11-VOREQ'),
            STRUCT('SOReq', '12-SOREQ'),
            STRUCT('SFReq', '13-SFREQ'),
            STRUCT('HWR', '14-HWR'),
            STRUCT('SPREQ', '15-SPREQ'),
            STRUCT('SRS', '21-SRS'),
            STRUCT('SCRS', '22-SCRS'),
            STRUCT('SURS', '23-SURS')
          ])
          WHERE LOWER(k) = LOWER(TRIM(${req_engineering_level_list}[SAFE_OFFSET(0)]))
        ),
        TRIM(${req_engineering_level})
      ) ;;
    description: "Normalized V-Cycle Engineering Level with numeric sort prefix (01-SG to 23-SURS) from SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx Board 1."
  }

  dimension: req_allocation {
    label: "System Allocation"
    group_label: "4. Ownership & Architecture"
  }

  dimension: req_supplier {
    label: "Supplier"
    group_label: "4. Ownership & Architecture"
  }

  dimension: is_supplier_req {
    label: "Is External Supplier Requirement (Non-AST)"
    group_label: "4. Ownership & Architecture"
    type: yesno
    sql: ${req_supplier} IS NOT NULL AND TRIM(${req_supplier}) != '' AND LOWER(TRIM(${req_supplier})) != 'ast' ;;
    description: "True when Req_Supplier is populated and not equal to 'AST' (Board 1 Section 4)."
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

  dimension: is_safety_req {
    label: "Is Safety / ASIL Requirement"
    group_label: "5. Safety, Cyber & Regulation"
    type: yesno
    sql:
      UPPER(TRIM(IFNULL(${req_safety_related}, ''))) IN ('YES', 'TRUE', '1')
      OR (
        ${req_asil} IS NOT NULL
        AND TRIM(${req_asil}) != ''
        AND UPPER(TRIM(${req_asil})) NOT IN ('QM', 'NO', 'NONE', 'NA', 'N/A', 'NULL')
      ) ;;
    description: "True when the Requirement is marked Safety Related or carries an active ASIL classification (Board 1 Section 3)."
  }

  dimension: req_regulation {
    label: "Regulation"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: is_regulatory_req {
    label: "Is Regulatory Requirement (05-REG)"
    group_label: "5. Safety, Cyber & Regulation"
    type: yesno
    sql:
      REGEXP_CONTAINS(UPPER(IFNULL(${req_engineering_level}, '')), r'\bREG\b')
      OR (
        ${req_regulation} IS NOT NULL
        AND TRIM(${req_regulation}) != ''
        AND UPPER(TRIM(${req_regulation})) NOT IN ('NO', 'NONE', 'NA', 'N/A', 'NULL')
      ) ;;
    description: "True when the Requirement is a Regulatory Requirement (05-REG or non-empty Req_Regulation, Board 1 Section 2)."
  }

  dimension: is_customer_performance_req {
    label: "Is Customer Performance Requirement (04-CP)"
    group_label: "5. Safety, Cyber & Regulation"
    type: yesno
    sql:
      REGEXP_CONTAINS(UPPER(IFNULL(${req_engineering_level}, '')), r'\bCP\b')
      OR UPPER(IFNULL(${req_requirement_category}, '')) LIKE '%CUSTOMER PERFORMANCE%' ;;
    description: "True when the Requirement is a Customer Performance Requirement (04-CP, Board 1 Section 2)."
  }

  dimension: req_cyber {
    label: "Cybersecurity Relevant"
    group_label: "5. Safety, Cyber & Regulation"
  }

  dimension: is_cyber_req {
    label: "Is Cybersecurity Requirement (06-CyberG)"
    group_label: "5. Safety, Cyber & Regulation"
    type: yesno
    sql:
      REGEXP_CONTAINS(UPPER(IFNULL(${req_engineering_level}, '')), r'\bCYBERG\b')
      OR UPPER(TRIM(IFNULL(${req_cyber}, ''))) IN ('YES', 'TRUE', '1', 'CYBER') ;;
    description: "True when the Requirement is a Cybersecurity Requirement (06-CyberG or Req_Cyber = Yes, Board 1 Section 2)."
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

  dimension: req_created_iso_week {
    label: "Created ISO Week"
    group_label: "7. Audit & Lifecycle"
  }

  # ---------------------------------------------------------------------------
  # 3. ZERO-FANOUT ARRAY FILTERS (EXISTS UNNEST)
  # ---------------------------------------------------------------------------

  filter: req_mysf_any {
    type: string
    label: "Filter: Requirement MySF (Array Item)"
    group_label: "3. Scope, MySF & Baselines"
    description: "Zero-fanout correlated EXISTS filter on Req_MySF array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_mysf_list}) AS x WHERE {% condition req_mysf_any %} x {% endcondition %}) ;;
  }

  filter: req_baseline_any {
    type: string
    label: "Filter: Requirement Baseline (Array Item)"
    group_label: "3. Scope, MySF & Baselines"
    description: "Zero-fanout correlated EXISTS filter on Req_Baseline array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_baseline_list}) AS x WHERE {% condition req_baseline_any %} x {% endcondition %}) ;;
  }

  filter: req_engineering_level_any {
    type: string
    label: "Filter: Requirement Engineering Level (Array Item)"
    group_label: "4. Ownership & Architecture"
    description: "Zero-fanout correlated EXISTS filter on Req_Engineering_Level array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_engineering_level_list}) AS x WHERE {% condition req_engineering_level_any %} x {% endcondition %}) ;;
  }

  filter: req_regulation_any {
    type: string
    label: "Filter: Requirement Regulation (Array Item)"
    group_label: "5. Safety, Cyber & Regulation"
    description: "Zero-fanout correlated EXISTS filter on Req_Regulation array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_regulation_list}) AS x WHERE {% condition req_regulation_any %} x {% endcondition %}) ;;
  }

  filter: req_allocation_any {
    type: string
    label: "Filter: Requirement Allocation (Array Item)"
    group_label: "4. Ownership & Architecture"
    description: "Zero-fanout correlated EXISTS filter on Req_Allocation array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_allocation_list}) AS x WHERE {% condition req_allocation_any %} x {% endcondition %}) ;;
  }

  filter: req_validation_teams_any {
    type: string
    label: "Filter: Requirement Validation Team (Array Item)"
    group_label: "6. Validation & Test Scope"
    description: "Zero-fanout correlated EXISTS filter on Req_Validation_Teams array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_validation_teams_list}) AS x WHERE {% condition req_validation_teams_any %} x {% endcondition %}) ;;
  }

  filter: req_supplier_any {
    type: string
    label: "Filter: Requirement Supplier (Array Item)"
    group_label: "4. Ownership & Architecture"
    description: "Zero-fanout correlated EXISTS filter on Req_Supplier array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_supplier_list}) AS x WHERE {% condition req_supplier_any %} x {% endcondition %}) ;;
  }

  filter: req_feature_cbid_any {
    type: string
    label: "Filter: Requirement Feature CBID (Array Item)"
    group_label: "3. Scope, MySF & Baselines"
    description: "Zero-fanout correlated EXISTS filter on Req_Feature_CB_Ids array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_feature_cbid_list}) AS x WHERE {% condition req_feature_cbid_any %} CAST(x AS STRING) {% endcondition %}) ;;
  }

  filter: req_requirement_parent_id_any {
    type: string
    label: "Filter: Parent Requirement ID (Array Item)"
    group_label: "1. Identity & Hierarchy"
    description: "Zero-fanout correlated EXISTS filter on Req_Parent_Ids array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_requirement_parent_id_list}) AS x WHERE {% condition req_requirement_parent_id_any %} CAST(x AS STRING) {% endcondition %}) ;;
  }

  filter: req_sw_components_any {
    type: string
    label: "Filter: Requirement SW Component (Array Item)"
    group_label: "3. Scope, MySF & Baselines"
    description: "Zero-fanout correlated EXISTS filter on Req_SW_Component_Ids array elements."
    sql: EXISTS (SELECT 1 FROM UNNEST(${req_sw_components_list}) AS x WHERE {% condition req_sw_components_any %} CAST(x AS STRING) {% endcondition %}) ;;
  }

  # ---------------------------------------------------------------------------
  # 4. MEASURES (COUNT_DISTINCT on Req_Id for Fan-Out Resilience)
  # ---------------------------------------------------------------------------

  measure: requirement_count {
    label: "Total Requirements"
    group_label: "Requirement Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    value_format_name: decimal_0
    description: "Distinct count of unique Requirements (COUNT_DISTINCT(Req_Id)) in gold_dim_req."
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
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_approved_or_accepted: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Requirements with Approved, Accepted, or Released status."
    drill_fields: [detail*]
  }

  measure: draft_requirement_count {
    label: "Draft Requirements"
    group_label: "Requirement Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_draft_status: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Requirements in Draft status."
    drill_fields: [detail*]
  }

  measure: rejected_requirement_count {
    label: "Rejected Requirements"
    group_label: "Requirement Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_rejected_status: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Requirements in Rejected status."
    drill_fields: [detail*]
  }

  measure: regulatory_requirement_count {
    label: "Regulatory Requirements (05-REG)"
    group_label: "Board 1 - Category & Safety Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_regulatory_req: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Regulatory Requirements (Board 1 Section 2)."
    drill_fields: [detail*]
  }

  measure: customer_performance_requirement_count {
    label: "Customer Performance Requirements (04-CP)"
    group_label: "Board 1 - Category & Safety Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_customer_performance_req: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Customer Performance Requirements (Board 1 Section 2)."
    drill_fields: [detail*]
  }

  measure: cyber_requirement_count {
    label: "Cybersecurity Requirements (06-CyberG)"
    group_label: "Board 1 - Category & Safety Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_cyber_req: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Cybersecurity Requirements (Board 1 Section 2)."
    drill_fields: [detail*]
  }

  measure: safety_requirement_count {
    label: "Safety / ASIL Requirements"
    group_label: "Board 1 - Category & Safety Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_safety_req: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Safety-Related / ASIL Requirements (Board 1 Section 3)."
    drill_fields: [detail*]
  }

  measure: supplier_requirement_count {
    label: "External Supplier Requirements"
    group_label: "Board 1 - Category & Safety Metrics"
    type: count_distinct
    sql: ${pk1_req_id} ;;
    filters: [is_supplier_req: "yes"]
    value_format_name: decimal_0
    description: "Distinct count of Requirements allocated to an external Supplier (non-AST, Board 1 Section 4)."
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
      req_engineering_level_normalized,
      req_system_owner,
      req_created_date
    ]
  }
}
