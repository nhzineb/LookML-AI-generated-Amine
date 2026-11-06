# -------------------------------------------------------------------------
# LookML Explore: requirements_traceability
# Purpose: Powers Board 1 (Requirements & Vertical Traceability),
#          Board 2.1 (Requirements Covered by Test Cases), and
#          Board 4 (Overall Requirement Validation Pass Rate).
# Grain: 1 row per Requirement (gold_dim_req.req_id), preserving 100% of
#        Requirements including uncovered / unlinked Requirements.
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/01_views/refinements/gold_dim_req_rfn.view.lkml"
include: "/ampere_ai_generated_lookml_v1/01_views/derived_tables/dt_req_coverage_and_validation.view.lkml"

explore: requirements_traceability {
  label: "Board 1, 2.1 & 4: Requirements & Vertical Traceability"
  description: "Requirement-grain Explore for Board 1 (Requirement Maturity, Vertical Traceability & Child Presence, SWC Child Coverage, MySF 26.2/27.2/28.2 Scope), Board 2.1 (Requirements Covered by Test Cases), and Board 4 (Requirement Validation Pass Rate)."
  view_name: gold_dim_req
  view_label: "1. Requirement Attributes (gold_dim_req)"

  join: dt_req_coverage_and_validation {
    view_label: "2. Requirement Coverage, Child & Validation KPIs"
    type: left_outer
    relationship: one_to_one
    sql_on: ${gold_dim_req.req_id} = ${dt_req_coverage_and_validation.req_id} ;;
  }

  join: parent_req {
    from: gold_dim_req
    view_label: "3. Primary Parent Requirement (Upward Traceability)"
    type: left_outer
    relationship: many_to_one
    sql_on: ${gold_dim_req.primary_parent_req_id} = ${parent_req.req_id} ;;
  }
}
