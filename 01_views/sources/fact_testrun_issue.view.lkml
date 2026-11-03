# =============================================================================
# SOURCE VIEW: fact_testrun_issue (Physical Table: FACT_TestRun_Issue - 2 Columns)
# =============================================================================

view: fact_testrun_issue {
  sql_table_name: `@{DATASET_NAME}.FACT_TestRun_Issue` ;;

  # ---------------------------------------------------------------------------
  # COMPOSITE PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk_tr_issue_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(IFNULL(CAST(${TABLE}.TR_Id AS STRING), 'NO_TR'), '-', IFNULL(${TABLE}.Issue_Id, 'NO_ISSUE')) ;;
    description: "Composite primary key for FACT_TestRun_Issue."
  }

  dimension: pk2_tr_id {
    hidden: yes
    type: number
    sql: ${TABLE}.TR_Id ;;
    description: "Foreign key to Test Run (TR_Id)."
  }

  dimension: pk2_issue_id {
    hidden: yes
    type: string
    sql: ${TABLE}.Issue_Id ;;
    description: "Foreign key to Jira Issue (Issue_Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 2 COLUMNS FROM FACT_TestRun_Issue
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
}
