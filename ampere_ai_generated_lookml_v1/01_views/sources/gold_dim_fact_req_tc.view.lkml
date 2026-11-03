# =============================================================================
# SOURCE VIEW: gold_dim_fact_req_tc (Physical Table: gold_dim_fact_req_tc - 11 Columns)
# =============================================================================

view: gold_dim_fact_req_tc {
  sql_table_name: `@{DATASET_NAME}.gold_dim_fact_req_tc` ;;

  # ---------------------------------------------------------------------------
  # COMPOSITE PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk_req_tc_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(IFNULL(CAST(${TABLE}.Req_Id AS STRING), 'UNLINKED_REQ'), '-', IFNULL(CAST(${TABLE}.TC_Id AS STRING), 'UNCOUNTED_TC')) ;;
    description: "Composite primary key combining Requirement ID and Test Case ID."
  }

  dimension: pk2_req_id {
    hidden: yes
    type: number
    sql: ${TABLE}.Req_Id ;;
    description: "Foreign key to gold_dim_req (Req_Id)."
  }

  dimension: pk2_tc_id {
    hidden: yes
    type: number
    sql: ${TABLE}.TC_Id ;;
    description: "Foreign key to tbl_cb_sdv_raw_tc_v2 (TC_Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 11 COLUMNS FROM gold_dim_fact_req_tc
  # ---------------------------------------------------------------------------

  dimension: req_id {
    type: number
    hidden: yes
    sql: ${pk2_req_id} ;;
    value_format_name: id
    description: "Requirement ID in gold_dim_fact_req_tc."
  }

  dimension: tc_id {
    type: number
    hidden: yes
    sql: ${pk2_tc_id} ;;
    value_format_name: id
    description: "Test Case ID covering the Requirement (NULL if Requirement is uncovered)."
  }

  dimension: req_mysf {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_MySF, ', ') ;;
    description: "Consolidated MySystemFunction (MySF) list on the Requirement-TC coverage bridge."
  }

  dimension: req_baseline {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Baseline, ', ') ;;
    description: "Consolidated Requirement Baselines on the Requirement-TC coverage bridge."
  }

  dimension: tc_domain {
    type: string
    sql: ${TABLE}.TC_Domain ;;
    description: "Engineering domain of the covering Test Case."
  }

  dimension: req_feature_cbid {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Feature_CBId, ', ') ;;
    description: "CodeBeamer Feature IDs associated with the Requirement."
  }

  dimension: req_allocation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Allocation, ', ') ;;
    description: "Architectural allocation of the Requirement."
  }

  dimension: req_asil {
    type: string
    sql: ${TABLE}.Req_ASIL ;;
    description: "ASIL safety level of the Requirement."
  }

  dimension: req_regulation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Req_Regulation, ', ') ;;
    description: "Regulations applicable to the Requirement."
  }

  dimension: tc_engineering_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TC_Engineering_Level, ', ') ;;
    description: "Engineering level(s) of the covering Test Case."
  }

  dimension: tc_system_owner {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.TC_System_Owner, ', ') ;;
    description: "System Owner(s) of the covering Test Case."
  }
}
