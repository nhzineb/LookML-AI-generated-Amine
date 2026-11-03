# =============================================================================
# MODEL FILE: ampere_sdv_analytics.model.lkml
# Clean Model File Pattern (lookml-model & looker-architect Rule 1 & Rule 9)
# =============================================================================

connection: "@{CONNECTION_NAME}"
label: "Ampere SDV Analytics"
week_start_day: monday

# -----------------------------------------------------------------------------
# EXPLICIT GRANULAR INCLUDES (No broad wildcards - lookml-modeling-guidelines)
# -----------------------------------------------------------------------------

# 00_adm: Administration & Datagroups
include: "/00_adm/datagroup/datagroups.lkml"

# 03_explores: Modular Explore & Quick Start Queries
include: "/03_explores/traceability.explore.lkml"
include: "/03_explores/quick_start_queries/traceability_quick_start.lkml"

# 02_data_tests: Automated LookML Test Suite
include: "/02_data_tests/traceability.test.lkml"

# 05_dashboards: Native LookML Dashboards
include: "/05_dashboards/sdv_traceability_execution.dashboard.lookml"

# -----------------------------------------------------------------------------
# DEFAULT CACHING POLICY
# -----------------------------------------------------------------------------

persist_with: ampere_sdv_gold_etl_datagroup
