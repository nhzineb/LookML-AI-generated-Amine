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

# 03_explores: Modular Explores for All 4 SDV Generic KPI Dashboard Boards
include: "/ampere_ai_generated_lookml_v1/03_explores/traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/requirements_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/tc_horizontal_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/req_tc_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/ts_pass_rate_by_sw_version.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/req_pass_rate_by_bench.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/test_run_issue_analysis.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/quick_start_queries/traceability_quick_start.lkml"

# 02_data_tests: Automated LookML Test Suite
include: "/ampere_ai_generated_lookml_v1/02_data_tests/traceability.test.lkml"

# 05_dashboards: Native LookML Dashboards
include: "/ampere_ai_generated_lookml_v1/05_dashboards/sdv_traceability_execution.dashboard.lookml"
