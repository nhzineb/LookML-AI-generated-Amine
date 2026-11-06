# -------------------------------------------------------------------------
# LookML Data Tests for SDV Explores:
#   - traceability
#   - requirements_traceability (Board 1, 2.1, 4)
#   - tc_horizontal_traceability (Board 2)
#   - ts_pass_rate_by_sw_version (Board 3)
#   - req_pass_rate_by_bench (Board 4)
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/03_explores/traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/requirements_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/tc_horizontal_traceability.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/ts_pass_rate_by_sw_version.explore.lkml"
include: "/ampere_ai_generated_lookml_v1/03_explores/req_pass_rate_by_bench.explore.lkml"

test: gold_dim_req_pk_not_null {
  explore_source: requirements_traceability {
    column: req_id { field: gold_dim_req.req_id }
    filters: [gold_dim_req.req_id: "NULL"]
    limit: 1
  }
  assert: req_id_is_never_null {
    expression: is_null(${gold_dim_req.req_id}) = no ;;
  }
}

test: gold_dim_ts_pk_not_null {
  explore_source: traceability {
    column: ts_id { field: gold_dim_ts.ts_id }
    filters: [gold_dim_ts.ts_id: "NULL"]
    limit: 1
  }
  assert: ts_id_is_never_null {
    expression: is_null(${gold_dim_ts.ts_id}) = no ;;
  }
}

test: req_coverage_rate_within_valid_bounds {
  explore_source: requirements_traceability {
    column: req_domain { field: gold_dim_req.req_domain }
    column: coverage_rate { field: dt_req_coverage_and_validation.horizontal_tc_coverage_rate }
  }
  assert: coverage_rate_between_0_and_1 {
    expression:
      is_null(${dt_req_coverage_and_validation.horizontal_tc_coverage_rate})
      OR (${dt_req_coverage_and_validation.horizontal_tc_coverage_rate} >= 0 AND ${dt_req_coverage_and_validation.horizontal_tc_coverage_rate} <= 1) ;;
  }
}

test: tc_execution_pass_rate_within_valid_bounds {
  explore_source: tc_horizontal_traceability {
    column: bench_type { field: dt_tc_execution_status.bench_type_ordered }
    column: pass_rate { field: dt_tc_execution_status.tc_latest_pass_rate }
  }
  assert: tc_pass_rate_between_0_and_1 {
    expression:
      is_null(${dt_tc_execution_status.tc_latest_pass_rate})
      OR (${dt_tc_execution_status.tc_latest_pass_rate} >= 0 AND ${dt_tc_execution_status.tc_latest_pass_rate} <= 1) ;;
  }
}

test: ts_release_pass_rate_within_valid_bounds {
  explore_source: ts_pass_rate_by_sw_version {
    column: bl_family { field: dt_ts_release_execution.bl_family }
    column: pass_rate { field: dt_ts_release_execution.ts_release_pass_rate }
  }
  assert: ts_release_pass_rate_between_0_and_1 {
    expression:
      is_null(${dt_ts_release_execution.ts_release_pass_rate})
      OR (${dt_ts_release_execution.ts_release_pass_rate} >= 0 AND ${dt_ts_release_execution.ts_release_pass_rate} <= 1) ;;
  }
}

test: req_bench_pass_rate_within_valid_bounds {
  explore_source: req_pass_rate_by_bench {
    column: ts_bench_type { field: dt_req_bench_validation.ts_bench_type }
    column: pass_rate { field: dt_req_bench_validation.bench_requirement_pass_rate }
  }
  assert: req_bench_pass_rate_between_0_and_1 {
    expression:
      is_null(${dt_req_bench_validation.bench_requirement_pass_rate})
      OR (${dt_req_bench_validation.bench_requirement_pass_rate} >= 0 AND ${dt_req_bench_validation.bench_requirement_pass_rate} <= 1) ;;
  }
}
