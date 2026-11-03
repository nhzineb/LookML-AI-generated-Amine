# =============================================================================
# SOURCE VIEW: fact_tc_tr_ts_req (Physical Table: FACT_TC_TR_TS_REQ - 5 Columns)
# =============================================================================

view: fact_tc_tr_ts_req {
  sql_table_name: `@{DATASET_NAME}.FACT_TC_TR_TS_REQ` ;;

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
    description: "Composite primary key for FACT_TC_TR_TS_REQ."
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
  # ALL 5 COLUMNS FROM FACT_TC_TR_TS_REQ
  # ---------------------------------------------------------------------------

  dimension: tc_id {
    type: number
    hidden: yes
    sql: ${pk4_tc_id} ;;
    value_format_name: id
    description: "Test Case ID in FACT_TC_TR_TS_REQ."
  }

  dimension: tr_id {
    type: number
    hidden: yes
    sql: ${pk4_tr_id} ;;
    value_format_name: id
    description: "Test Run ID in FACT_TC_TR_TS_REQ."
  }

  dimension: ts_id {
    type: number
    hidden: yes
    sql: ${pk4_ts_id} ;;
    value_format_name: id
    description: "Test Set ID in FACT_TC_TR_TS_REQ."
  }

  dimension: req_id {
    type: number
    hidden: yes
    sql: ${pk4_req_id} ;;
    value_format_name: id
    description: "Requirement ID in FACT_TC_TR_TS_REQ."
  }

  dimension: tr_mysf {
    type: string
    sql: ${TABLE}.TR_MySF ;;
    description: "Derived MySystemFunction (TR_MySF) propagated from Requirement to Test Run execution."
  }
}
