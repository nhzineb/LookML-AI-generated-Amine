# =============================================================================
# SOURCE VIEW: fact_tc_tr_ts_req (Physical Table: Fact_TC_TR_TS_Req - 5 Columns)
# =============================================================================

view: fact_tc_tr_ts_req {
  sql_table_name: `@{DATASET_NAME}.Fact_TC_TR_TS_Req` ;;

  # ---------------------------------------------------------------------------
  # COMPOSITE PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk_tc_tr_ts_req_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(
      IFNULL(CAST(${TABLE}.TC_Id AS STRING), 'NO_TC'), '-',
      IFNULL(CAST(${TABLE}.TR_Id AS STRING), 'NO_TR'), '-',
      IFNULL(CAST(${TABLE}.TS_Id AS STRING), 'NO_TS'), '-',
      IFNULL(CAST(${TABLE}.Req_Id AS STRING), 'NO_REQ')
    ) ;;
    description: "Composite primary key for Fact_TC_TR_TS_Req."
  }

  dimension: pk4_tc_id {
    hidden: yes
    type: number
    sql: ${TABLE}.TC_Id ;;
    description: "Foreign key to Test Case (TC_Id)."
  }

  dimension: pk4_tr_id {
    hidden: yes
    type: number
    sql: ${TABLE}.TR_Id ;;
    description: "Foreign key to Test Run (TR_Id)."
  }

  dimension: pk4_ts_id {
    hidden: yes
    type: number
    sql: ${TABLE}.TS_Id ;;
    description: "Foreign key to Test Set (TS_Id)."
  }

  dimension: pk4_req_id {
    hidden: yes
    type: number
    sql: ${TABLE}.Req_Id ;;
    description: "Foreign key to Requirement (Req_Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 5 COLUMNS FROM Fact_TC_TR_TS_Req (including TR_MySF STRUCT fields)
  # ---------------------------------------------------------------------------

  dimension: tc_id {
    type: number
    hidden: yes
    sql: ${pk4_tc_id} ;;
    value_format_name: id
    description: "Test Case ID in Fact_TC_TR_TS_Req."
  }

  dimension: tr_id {
    type: number
    hidden: yes
    sql: ${pk4_tr_id} ;;
    value_format_name: id
    description: "Test Run ID in Fact_TC_TR_TS_Req."
  }

  dimension: ts_id {
    type: number
    hidden: yes
    sql: ${pk4_ts_id} ;;
    value_format_name: id
    description: "Test Set ID in Fact_TC_TR_TS_Req."
  }

  dimension: req_id {
    type: number
    hidden: yes
    sql: ${pk4_req_id} ;;
    value_format_name: id
    description: "Requirement ID in Fact_TC_TR_TS_Req."
  }

  dimension: tr_mysf {
    type: string
    sql: ${TABLE}.TR_MySF.TR_MySF ;;
    description: "Derived MySystemFunction (TR_MySF.TR_MySF) propagated from Requirement to Test Run execution."
  }

  dimension: tc_mysf {
    type: string
    sql: ${TABLE}.TR_MySF.TC_MySF ;;
    description: "Test Case MySystemFunction (TR_MySF.TC_MySF) from the TR_MySF struct."
  }

  dimension: ts_mysf {
    type: string
    sql: ${TABLE}.TR_MySF.TS_MySF ;;
    description: "Test Set MySystemFunction (TR_MySF.TS_MySF) from the TR_MySF struct."
  }
}
