# -------------------------------------------------------------------------
# LookML Explore: req_pass_rate_by_bench
# Purpose: Powers Board 4 (Requirement Pass Rate by Engineering Level & Bench Type)
# Grain: 1 row per (Req_Id x TS_Bench_Type) pair
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/01_views/derived_tables/dt_req_bench_validation.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/gold_dim_req_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/derived_tables/dt_req_coverage_and_validation.view.lkml"

explore: req_pass_rate_by_bench {
  label: "Board 4: Requirement Pass Rate by Engineering Level & Bench Type"
  description: "Requirement-by-Bench-Type Explore for Board 4 evaluating worst-case Test Run validation verdicts (Passed, Failed, Ongoing, Not Executed, Not covered, Rejected) per Requirement and individual Bench Type (SIL, HIL, EIPF, VHL, SW_Component)."
  view_name: dt_req_bench_validation
  view_label: "1. Requirement Validation by Bench Type (Board 4)"

  join: gold_dim_req {
    view_label: "2. Requirement Attributes (gold_dim_req)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_req_bench_validation.req_id} = ${gold_dim_req.req_id} ;;
  }

  join: dt_req_coverage_and_validation {
    view_label: "3. Overall Requirement Coverage & Validation Summary"
    type: left_outer
    relationship: many_to_one
    sql_on: ${dt_req_bench_validation.req_id} = ${dt_req_coverage_and_validation.req_id} ;;
  }
}
