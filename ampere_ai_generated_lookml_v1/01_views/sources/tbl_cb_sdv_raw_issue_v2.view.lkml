# =============================================================================
# SOURCE VIEW: tbl_cb_sdv_raw_issue_v2 (Physical Table: TBL_CB_SDV_Raw_Issue_V2 - 18 Columns)
# =============================================================================

view: tbl_cb_sdv_raw_issue_v2 {
  sql_table_name: `@{DATASET_NAME}.TBL_CB_SDV_Raw_Issue_V2` ;;

  # ---------------------------------------------------------------------------
  # PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk1_issue_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.Issue_Id ;;
    description: "Primary key of TBL_CB_SDV_Raw_Issue_V2 (Issue_Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 18 COLUMNS FROM TBL_CB_SDV_Raw_Issue_V2
  # ---------------------------------------------------------------------------

  dimension: issue_id {
    type: string
    sql: ${pk1_issue_id} ;;
    description: "Unique Jira Issue key or identifier."
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}.Issue_Type ;;
    description: "Type of the Jira Issue (e.g., Bug, Defect, Anomaly, Task)."
  }

  dimension: summary {
    type: string
    sql: ${TABLE}.Summary ;;
    description: "Short summary title of the Issue."
  }

  dimension: priority {
    type: string
    sql: ${TABLE}.Priority ;;
    description: "Severity or priority level of the Issue (e.g., Blocker, Critical, Major, Minor)."
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Created_Datetime ;;
    description: "Timestamp when the Issue was created in Jira."
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Updated_Datetime ;;
    description: "Timestamp when the Issue was last updated in Jira."
  }

  dimension: issue_status {
    type: string
    sql: ${TABLE}.Issue_Status ;;
    description: "Current workflow status of the Issue (e.g., Open, In Progress, Resolved, Closed)."
  }

  dimension: issue_resolution {
    type: string
    sql: ${TABLE}.Issue_Resolution ;;
    description: "Resolution outcome of the Issue (e.g., Fixed, Unresolved, Won't Fix, Duplicate)."
  }

  dimension: components {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Components, ', ') ;;
    description: "System or software components impacted by the Issue."
  }

  dimension: labels {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Labels, ', ') ;;
    description: "Jira labels attached to the Issue."
  }

  dimension: fix_versions {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Fix_Versions, ', ') ;;
    description: "Target software Fix Versions in which the Issue is resolved."
  }

  dimension: affected_versions {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Affected_Versions, ', ') ;;
    description: "Software versions affected by the Issue."
  }

  dimension: my_feature {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.My_Feature, ', ') ;;
    description: "MyFeature identifiers linked to the Issue."
  }

  dimension: issue_links {
    type: string
    sql: TO_JSON_STRING(${TABLE}.Issue_Links) ;;
    description: "JSON payload of linked Jira and CodeBeamer issues."
  }

  dimension: history {
    type: string
    sql: TO_JSON_STRING(${TABLE}.History) ;;
    description: "JSON changelog history of status and field transitions for the Issue."
  }

  dimension: additional_fields {
    type: string
    sql: TO_JSON_STRING(${TABLE}.Additional_Fields) ;;
    description: "JSON payload containing custom Jira attributes for the Issue."
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.Project_Name ;;
    description: "Jira project name hosting the Issue."
  }

  dimension: project_key {
    type: string
    sql: ${TABLE}.Project_Key ;;
    description: "Jira project key prefix hosting the Issue."
  }
}
