# =============================================================================
# ADMINISTRATION & GOVERNANCE: DATAGROUPS & CACHE POLICIES
# =============================================================================

datagroup: ampere_sdv_gold_etl_datagroup {
  label: "Ampere SDV Gold ETL Datagroup"
  description: "Triggers cache invalidation and NDT rebuilds when gold_dim_req is updated."
  sql_trigger: SELECT MAX(Req_Updated) FROM `@{DATASET_NAME}.gold_dim_req` ;;
  max_cache_age: "12 hours"
}

datagroup: ampere_sdv_execution_datagroup {
  label: "Ampere SDV Execution Datagroup"
  description: "Triggers cache invalidation when new Test Runs are completed or updated."
  sql_trigger: SELECT MAX(Updated) FROM `@{DATASET_NAME}.TBL_CB_SDV_Raw_TR_V2` ;;
  max_cache_age: "4 hours"
}
