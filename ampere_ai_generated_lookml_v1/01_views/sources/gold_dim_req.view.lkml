# =============================================================================
# SOURCE VIEW: gold_dim_req (Physical Table: gold_dim_req - 48 Columns)
# =============================================================================

view: gold_dim_req {
  sql_table_name: `@{DATASET_NAME}.gold_dim_req` ;;

  # ---------------------------------------------------------------------------
  # PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk1_req_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.Req_Id ;;
    description: "Primary key for gold_dim_req (Req_Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 48 COLUMNS FROM gold_dim_req
  # ---------------------------------------------------------------------------

  dimension: req_id {
    type: number
    sql: ${pk1_req_id} ;;
    value_format_name: id
    description: "Unique identifier of the Requirement in CodeBeamer."
  }

  dimension: req_name {
    type: string
    sql: ${TABLE}.Req_Name ;;
    description: "Name or short title of the Requirement."
  }

  dimension: req_description {
    type: string
    sql: ${TABLE}.Req_Description ;;
    description: "Full textual specification and description of the Requirement."
  }

  dimension: req_type {
    type: string
    sql: ${TABLE}.Req_Type ;;
    description: "Classification type of the Requirement."
  }

  dimension_group: req_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Req_Created ;;
    description: "Timestamp when the Requirement was initially created."
  }

  dimension_group: req_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Req_Updated ;;
    description: "Timestamp when the Requirement was last updated."
  }

  dimension: req_created_by {
    type: string
    sql: ${TABLE}.Req_Created_By ;;
    description: "User who originally authored the Requirement."
  }

  dimension: req_updated_by {
    type: string
    sql: ${TABLE}.Req_Updated_By ;;
    description: "User who last modified the Requirement."
  }

  dimension: req_version {
    type: number
    sql: ${TABLE}.Req_Version ;;
    description: "Version number of the Requirement item."
  }

  dimension: req_tracker_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Req_Tracker_Id ;;
    value_format_name: id
    description: "Internal numeric identifier of the CodeBeamer Tracker."
  }

  dimension: req_tracker {
    type: string
    sql: ${TABLE}.Req_Tracker ;;
    description: "Name of the CodeBeamer Tracker hosting the Requirement."
  }

  dimension: req_status {
    type: string
    sql: ${TABLE}.Req_Status ;;
    description: "Current workflow lifecycle status of the Requirement (e.g., Approved, Accepted, Draft, Obsolete)."
  }

  dimension: req_child_required {
    type: string
    sql: ${TABLE}.Req_Child_Required ;;
    description: "Indicates whether downstream child requirement decomposition is mandatory."
  }

  dimension: req_categories {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Categories, ', ') ;;
    description: "Comma-separated list of functional categories assigned to the Requirement."
  }

  dimension: req_engineering_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Engineering_Level, ', ') ;;
    description: "Engineering V-cycle level(s) of the Requirement."
  }

  dimension: req_regulation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Regulation, ', ') ;;
    description: "Regulatory standards applicable to the Requirement."
  }

  dimension: req_asil {
    type: string
    sql: ${TABLE}.Req_ASIL ;;
    description: "Automotive Safety Integrity Level (ASIL) classification of the Requirement."
  }

  dimension: req_safety_related {
    type: string
    sql: ${TABLE}.Req_Safety_Related ;;
    description: "Flag indicating whether the Requirement is safety-related."
  }

  dimension: req_domain {
    type: string
    sql: ${TABLE}.Req_Domain ;;
    description: "Functional engineering domain owning the Requirement."
  }

  dimension: req_sub_domain {
    type: string
    sql: ${TABLE}.Req_Sub_Domain ;;
    description: "Functional engineering sub-domain of the Requirement."
  }

  dimension: req_allocation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Allocation, ', ') ;;
    description: "System or architectural component allocation of the Requirement."
  }

  dimension: req_validation_teams {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Validation_Teams, ', ') ;;
    description: "Validation teams responsible for verifying the Requirement."
  }

  dimension: req_sweet {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_SWEET, ', ') ;;
    description: "SWEET electrical/electronic architecture milestone releases for the Requirement."
  }

  dimension: req_vehicle_project_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Vehicle_Project_Id) AS x), ', ') ;;
    description: "Vehicle project IDs associated with the Requirement."
  }

  dimension: req_system_owner {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_System_Owner, ', ') ;;
    description: "System Owner(s) accountable for the Requirement."
  }

  dimension: req_requirement_parent_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Requirement_Parent_Id) AS x), ', ') ;;
    description: "Upstream parent Requirement IDs linked in the traceability hierarchy."
  }

  dimension: req_safety_derived_from {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Safety_Derived_From) AS x), ', ') ;;
    description: "IDs of upstream safety items from which this Requirement is derived."
  }

  dimension: req_feature_cbid {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Feature_CBId, ', ') ;;
    description: "CodeBeamer Feature identifiers linked to the Requirement."
  }

  dimension: req_cb_project_name {
    type: string
    sql: ${TABLE}.Req_CBProjectName ;;
    description: "CodeBeamer project name containing the Requirement."
  }

  dimension: req_security_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Security_level, ', ') ;;
    description: "Cybersecurity / Confidentiality level assigned to the Requirement."
  }

  dimension: req_validation_methods {
    type: string
    sql: ${TABLE}.Req_ValidationMethods ;;
    description: "Specified method(s) of validation (e.g., Test, Analysis, Inspection, Demonstration)."
  }

  dimension: req_requirement_category {
    type: string
    sql: ${TABLE}.Req_RequirementCategory ;;
    description: "Primary category classification of the Requirement."
  }

  dimension: req_final_status {
    type: string
    sql: ${TABLE}.Req_FinalStatus ;;
    description: "Consolidated final approval status of the Requirement."
  }

  dimension: req_supplier {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Supplier, ', ') ;;
    description: "External or internal supplier(s) associated with the Requirement."
  }

  dimension: req_planned_for {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_PlannedFor) AS x), ', ') ;;
    description: "Planned release or milestone IDs for the Requirement."
  }

  dimension: req_baseline {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Baseline, ', ') ;;
    description: "Consolidated Requirement Baselines (derived across direct Req and ISP links)."
  }

  dimension: req_mysf_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_MySF_Id) AS x), ', ') ;;
    description: "Internal numeric identifiers for MySystemFunction (MySF) linked to the Requirement."
  }

  dimension: req_mysf {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_MySF, ', ') ;;
    description: "Consolidated MySystemFunction (MySF) identifiers for the Requirement."
  }

  dimension: req_sw_components {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_SW_Components) AS x), ', ') ;;
    description: "Software component IDs allocated to the Requirement."
  }

  dimension: req_legacy_identifier {
    type: string
    sql: ${TABLE}.Req_Legacy_Identifier ;;
    description: "Legacy system identifier (e.g., DOORS ID) for migrated Requirements."
  }

  dimension: req_cyber {
    type: string
    sql: ${TABLE}.Req_Cyber ;;
    description: "Indicates whether the Requirement is cybersecurity-relevant."
  }

  dimension: req_target_planned_for {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_TargetPlannedFor, ', ') ;;
    description: "Target release milestones planned for Requirement delivery."
  }

  dimension: req_obsolete_from {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_ObsoleteFrom, ', ') ;;
    description: "Release or milestone from which the Requirement becomes obsolete."
  }

  dimension: req_bench_type {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Bench_Type, ', ') ;;
    description: "Target test bench environment types (e.g., HIL, SIL, Vehicle) for the Requirement."
  }

  dimension: req_items_under_test {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Items_Under_Test, ', ') ;;
    description: "Hardware or software Items Under Test (IUT) associated with the Requirement."
  }

  dimension: req_test_cases {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Test_Cases) AS x), ', ') ;;
    description: "Comma-separated list of Test Case IDs verifying this Requirement."
  }

  dimension: req_sw_releases {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_SW_Releases) AS x), ', ') ;;
    description: "Software release IDs associated with the Requirement."
  }

  dimension: req_created_week {
    type: string
    sql: ${TABLE}.Req_CreatedWeek ;;
    description: "ISO creation week string of the Requirement (YYYY-Wxx)."
  }
}
