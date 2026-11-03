# =============================================================================
# SOURCE VIEW: gold_dim_ts (Physical Table: gold_dim_ts - 41 Columns)
# =============================================================================

view: gold_dim_ts {
  sql_table_name: `@{DATASET_NAME}.gold_dim_ts` ;;

  # ---------------------------------------------------------------------------
  # PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk1_ts_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.TS_Id ;;
    description: "Primary key for gold_dim_ts (TS_Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 41 COLUMNS FROM gold_dim_ts
  # ---------------------------------------------------------------------------

  dimension: ts_id {
    type: number
    sql: ${pk1_ts_id} ;;
    value_format_name: id
    description: "Unique identifier of the Test Set in CodeBeamer."
  }

  dimension: ts_name {
    type: string
    sql: ${TABLE}.TS_Name ;;
    description: "Name of the Test Set campaign or execution group."
  }

  dimension: ts_description {
    type: string
    sql: ${TABLE}.TS_Description ;;
    description: "Detailed description of the Test Set scope and objectives."
  }

  dimension: ts_cb_type {
    type: string
    sql: ${TABLE}.TS_CBType ;;
    description: "CodeBeamer item type classification for the Test Set."
  }

  dimension_group: ts_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.TS_Created ;;
    description: "Timestamp when the Test Set was created."
  }

  dimension: ts_created_by {
    type: string
    sql: ${TABLE}.TS_Created_By ;;
    description: "User who created the Test Set."
  }

  dimension_group: ts_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.TS_Updated ;;
    description: "Timestamp when the Test Set was last modified."
  }

  dimension: ts_updated_by {
    type: string
    sql: ${TABLE}.TS_Updated_By ;;
    description: "User who last updated the Test Set."
  }

  dimension: ts_version {
    type: number
    sql: ${TABLE}.TS_Version ;;
    description: "Version number of the Test Set."
  }

  dimension: ts_assigned_to {
    type: string
    sql: ${TABLE}.TS_Assigned_To ;;
    description: "Engineer or team assigned to execute or manage the Test Set."
  }

  dimension: ts_parent {
    type: number
    hidden: yes
    sql: ${TABLE}.TS_Parent ;;
    value_format_name: id
    description: "Parent Test Set identifier in the hierarchy."
  }

  dimension: ts_tracker_id {
    type: number
    hidden: yes
    sql: ${TABLE}.TS_Tracker_Id ;;
    value_format_name: id
    description: "Internal numeric identifier of the CodeBeamer Test Set Tracker."
  }

  dimension: ts_tracker {
    type: string
    sql: ${TABLE}.TS_Tracker ;;
    description: "Name of the CodeBeamer Tracker containing the Test Set."
  }

  dimension: ts_status {
    type: string
    sql: ${TABLE}.TS_Status ;;
    description: "Current lifecycle status of the Test Set."
  }

  dimension: ts_categories {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Categories, ', ') ;;
    description: "Categories assigned to the Test Set."
  }

  dimension: ts_domain {
    type: string
    sql: ${TABLE}.TS_Domain ;;
    description: "Functional engineering domain associated with the Test Set."
  }

  dimension: ts_validation_team {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Validation_Team, ', ') ;;
    description: "Validation team(s) responsible for the Test Set."
  }

  dimension: ts_sweet {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_SWEET, ', ') ;;
    description: "SWEET architecture version(s) targeted by the Test Set."
  }

  dimension: ts_vehicle_project_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.TS_Vehicle_Project_Id) AS x), ', ') ;;
    description: "Numeric IDs of the Vehicle Projects linked to the Test Set."
  }

  dimension: ts_vehicle_project {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Vehicle_Project, ', ') ;;
    description: "Vehicle Project names associated with the Test Set."
  }

  dimension: ts_bench_type {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Bench_Type, ', ') ;;
    description: "Test bench environment types (e.g., HIL, SIL, Vehicle) used for the Test Set."
  }

  dimension: ts_items_under_test {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Items_Under_Test, ', ') ;;
    description: "Items Under Test (IUT) verified by the Test Set."
  }

  dimension: ts_estimated_duration {
    type: number
    sql: ${TABLE}.TS_Estimated_Duration ;;
    description: "Estimated execution duration for the Test Set."
  }

  dimension: ts_bench_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.TS_Bench_Id) AS x), ', ') ;;
    description: "Internal numeric identifiers of the assigned test benches."
  }

  dimension: ts_bench {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Bench, ', ') ;;
    description: "Names of the physical or virtual test benches assigned to the Test Set."
  }

  dimension: ts_test_cases_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.TS_Test_Cases_Id) AS x), ', ') ;;
    description: "Numeric IDs of the Test Cases included in the Test Set."
  }

  dimension: ts_test_case {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Test_Case, ', ') ;;
    description: "Names of the Test Cases included in the Test Set."
  }

  dimension: ts_type {
    type: string
    sql: ${TABLE}.TS_Type ;;
    description: "Functional or campaign type of the Test Set."
  }

  dimension: ts_sw_releases_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.TS_SW_Releases_Id) AS x), ', ') ;;
    description: "Numeric IDs of the software releases linked to the Test Set."
  }

  dimension: ts_sw_releases {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_SW_Releases, ', ') ;;
    description: "Software release names verified by the Test Set."
  }

  dimension: ts_isp_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.TS_ISP_Id) AS x), ', ') ;;
    description: "Linked Integrated Software Plan (ISP) IDs for the Test Set."
  }

  dimension: ts_security_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Security_level, ', ') ;;
    description: "Security classification level of the Test Set."
  }

  dimension: ts_planned_for {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.TS_PlannedFor) AS x), ', ') ;;
    description: "Planned milestone or release IDs for the Test Set."
  }

  dimension: ts_mysf {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_MySF, ', ') ;;
    description: "MySystemFunction (MySF) identifiers linked to the Test Set."
  }

  dimension: ts_baseline {
    type: string
    sql: ${TABLE}.TS_Baseline ;;
    description: "Consolidated Baseline associated with the Test Set."
  }

  dimension: bl_source {
    type: string
    sql: ${TABLE}.BL_Source ;;
    description: "Source of the consolidated Test Set Baseline (e.g., Direct vs. ISP-derived)."
  }

  dimension: ts_pcu_releases {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_PCU_Releases, ', ') ;;
    description: "PCU ECU software releases associated with the Test Set."
  }

  dimension: ts_piu_releases {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_PIU_Releases, ', ') ;;
    description: "PIU ECU software releases associated with the Test Set."
  }

  dimension: ts_ivc_releases {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_IVC_Releases, ', ') ;;
    description: "IVC ECU software releases associated with the Test Set."
  }

  dimension: ts_cdc_releases {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_CDC_Releases, ', ') ;;
    description: "CDC ECU software releases associated with the Test Set."
  }

  dimension: ts_other_releases {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TS_Other_Releases, ', ') ;;
    description: "Other ECU software releases associated with the Test Set."
  }
}
