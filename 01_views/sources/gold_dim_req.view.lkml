# =============================================================================
# SOURCE VIEW: gold_dim_req (Physical Table: gold_dim_req - 39 Columns)
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
  # ALL 39 COLUMNS FROM gold_dim_req (New Schema v2)
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

  dimension: req_classification {
    type: string
    sql: ${TABLE}.Req_Classification ;;
    description: "Classification of the Requirement (Req_Classification)."
  }

  dimension: req_type {
    type: string
    sql: ${TABLE}.Req_Classification ;;
    description: "Classification type of the Requirement (mapped to Req_Classification)."
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
    sql: ${TABLE}.Req_Tracker_Name ;;
    description: "Name of the CodeBeamer Tracker hosting the Requirement (Req_Tracker_Name)."
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

  dimension: req_engineering_level {
    type: string
    sql: ${TABLE}.Req_Engineering_Level ;;
    description: "Engineering V-cycle level of the Requirement (Req_Engineering_Level)."
  }

  dimension: req_regulation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Regulations, ', ') ;;
    description: "Regulatory standards applicable to the Requirement (Req_Regulations)."
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
    sql: ARRAY_TO_STRING(${TABLE}.Req_Allocations, ', ') ;;
    description: "System or architectural component allocation of the Requirement (Req_Allocations)."
  }

  dimension: req_validation_teams {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Validation_Teams, ', ') ;;
    description: "Validation teams responsible for verifying the Requirement."
  }

  dimension: req_sweet {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_SWEETs, ', ') ;;
    description: "SWEET electrical/electronic architecture milestone releases for the Requirement (Req_SWEETs)."
  }

  dimension: req_vehicle_project_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Vehicle_Project_Ids) AS x), ', ') ;;
    description: "Vehicle project IDs associated with the Requirement (Req_Vehicle_Project_Ids)."
  }

  dimension: req_system_owner {
    type: string
    sql: ${TABLE}.Req_System_Owner ;;
    description: "System Owner accountable for the Requirement."
  }

  dimension: req_requirement_parent_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Parent_Ids) AS x), ', ') ;;
    description: "Upstream parent Requirement IDs linked in the traceability hierarchy (Req_Parent_Ids)."
  }

  dimension: req_feature_cbid {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_Feature_CB_Ids) AS x), ', ') ;;
    description: "CodeBeamer Feature identifiers linked to the Requirement (Req_Feature_CB_Ids)."
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
    sql: ${TABLE}.Req_Classification ;;
    description: "Primary category classification of the Requirement (mapped to Req_Classification)."
  }

  dimension: req_final_status {
    type: string
    sql: ${TABLE}.Req_FinalStatus ;;
    description: "Consolidated final approval status of the Requirement."
  }

  dimension: req_supplier {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Suppliers, ', ') ;;
    description: "External or internal supplier(s) associated with the Requirement (Req_Suppliers)."
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
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_MySFs) AS x), ', ') ;;
    description: "Internal numeric identifiers for MySystemFunction (Req_MySFs) linked to the Requirement."
  }

  dimension: req_mysf {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_MySF, ', ') ;;
    description: "Consolidated MySystemFunction (MySF) identifiers for the Requirement."
  }

  dimension: req_sw_components {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_SW_Component_Ids) AS x), ', ') ;;
    description: "Software component IDs allocated to the Requirement (Req_SW_Component_Ids)."
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
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_TargetPlannedFor) AS x), ', ') ;;
    description: "Target release milestones planned for Requirement delivery."
  }

  dimension: req_obsolete_from {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Req_ObsoleteFrom) AS x), ', ') ;;
    description: "Release or milestone from which the Requirement becomes obsolete."
  }

  dimension: req_created_iso_week {
    type: string
    sql: ${TABLE}.Req_CreatedWeek ;;
    description: "ISO creation week string of the Requirement (YYYY-Wxx)."
  }

  # Hidden raw ARRAY dimensions for zero-fanout EXISTS filtering and ARRAY_LENGTH calculations
  dimension: req_mysf_list {
    hidden: yes
    description: "Raw ARRAY column Req_MySF for UNNEST EXISTS filtering."
    sql: ${TABLE}.Req_MySF ;;
  }

  dimension: req_baseline_list {
    hidden: yes
    description: "Raw ARRAY column Req_Baseline for UNNEST EXISTS filtering."
    sql: ${TABLE}.Req_Baseline ;;
  }

  dimension: req_engineering_level_list {
    hidden: yes
    description: "1-element ARRAY wrapper over scalar Req_Engineering_Level for UNNEST EXISTS filtering."
    sql: IF(${TABLE}.Req_Engineering_Level IS NULL, ARRAY<STRING>[], [${TABLE}.Req_Engineering_Level]) ;;
  }

  dimension: req_regulation_list {
    hidden: yes
    description: "Raw ARRAY column Req_Regulations for UNNEST EXISTS filtering."
    sql: ${TABLE}.Req_Regulations ;;
  }

  dimension: req_allocation_list {
    hidden: yes
    description: "Raw ARRAY column Req_Allocations for UNNEST EXISTS filtering."
    sql: ${TABLE}.Req_Allocations ;;
  }

  dimension: req_validation_teams_list {
    hidden: yes
    description: "Raw ARRAY column Req_Validation_Teams for UNNEST EXISTS filtering."
    sql: ${TABLE}.Req_Validation_Teams ;;
  }

  dimension: req_supplier_list {
    hidden: yes
    description: "Raw ARRAY column Req_Suppliers for UNNEST EXISTS filtering."
    sql: ${TABLE}.Req_Suppliers ;;
  }

  dimension: req_feature_cbid_list {
    hidden: yes
    description: "Raw ARRAY column Req_Feature_CB_Ids for UNNEST EXISTS filtering and ARRAY_LENGTH."
    sql: ${TABLE}.Req_Feature_CB_Ids ;;
  }

  dimension: req_requirement_parent_id_list {
    hidden: yes
    description: "Raw ARRAY column Req_Parent_Ids for UNNEST EXISTS filtering and ARRAY_LENGTH."
    sql: ${TABLE}.Req_Parent_Ids ;;
  }

  dimension: req_sw_components_list {
    hidden: yes
    description: "Raw ARRAY column Req_SW_Component_Ids for UNNEST EXISTS filtering and ARRAY_LENGTH."
    sql: ${TABLE}.Req_SW_Component_Ids ;;
  }
}
