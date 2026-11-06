# =============================================================================
# SOURCE VIEW: fact_testrun_issue (Physical Table: Fact_TR_Issue - 24 Columns)
# =============================================================================

view: fact_testrun_issue {
  sql_table_name: `@{DATASET_NAME}.Fact_TR_Issue` ;;

  # ---------------------------------------------------------------------------
  # COMPOSITE PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk_tr_issue_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(IFNULL(CAST(${TABLE}.TR_ID AS STRING), 'NO_TR'), '-', IFNULL(${TABLE}.Issue_Id, 'NO_ISSUE')) ;;
    description: "Composite primary key for Fact_TR_Issue."
  }

  dimension: pk2_tr_id {
    hidden: yes
    type: number
    sql: ${TABLE}.TR_ID ;;
    description: "Foreign key to Test Run (TR_ID)."
  }

  dimension: pk2_issue_id {
    hidden: yes
    type: string
    sql: ${TABLE}.Issue_Id ;;
    description: "Foreign key to Jira Issue (Issue_Id)."
  }

  # ---------------------------------------------------------------------------
  # KEY COLUMNS FROM Fact_TR_Issue
  # ---------------------------------------------------------------------------

  dimension: tr_id {
    type: number
    hidden: yes
    sql: ${pk2_tr_id} ;;
    value_format_name: id
    description: "Test Run ID that reported or is blocked by the Issue."
  }

  dimension: issue_id {
    type: string
    hidden: yes
    sql: ${pk2_issue_id} ;;
    description: "Jira Issue ID linked to the failed or blocked Test Run."
  }

  dimension: tr_name {
    type: string
    sql: ${TABLE}.TR_Name ;;
    description: "Name of the Test Run on the Fact_TR_Issue bridge."
  }

  dimension: issue_type {
    type: string
    sql: ${TABLE}.Issue_Type ;;
    description: "Type of the linked Jira Issue on Fact_TR_Issue."
  }

  dimension: issue_status {
    type: string
    sql: ${TABLE}.Issue_Status ;;
    description: "Current workflow status of the linked Jira Issue on Fact_TR_Issue."
  }

  dimension: issue_resolution {
    type: string
    sql: ${TABLE}.Issue_Resolution ;;
    description: "Resolution outcome of the linked Jira Issue on Fact_TR_Issue."
  }

  dimension: issue_priority {
    type: string
    sql: ${TABLE}.Issue_Priority ;;
    description: "Priority of the linked Jira Issue on Fact_TR_Issue."
  }

  dimension: issue_criticity {
    type: string
    sql: ${TABLE}.Issue_Criticity ;;
    description: "Criticality of the linked Jira Issue on Fact_TR_Issue."
  }

  dimension: issue_summary {
    type: string
    sql: ${TABLE}.Issue_Summary ;;
    description: "Summary title of the linked Jira Issue on Fact_TR_Issue."
  }

  dimension: issue_domain_in_charge {
    type: string
    sql: ${TABLE}.Issue_Domain_in_charge ;;
    description: "Engineering domain in charge of resolving the Issue."
  }

  dimension: issue_validation_team {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Issue_Validation_Team, ', ') ;;
    description: "Validation team associated with the Issue."
  }
}
