# -------------------------------------------------------------------------
# LookML Data Tests for Explore: traceability
# -------------------------------------------------------------------------
include: "/03_explores/traceability.explore.lkml"

test: gold_dim_req_pk_not_null {
  explore_source: traceability {
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
  explore_source: traceability {
    column: req_domain { field: gold_dim_req.req_domain }
    column: coverage_rate { field: gold_dim_req.requirement_test_coverage_rate }
  }
  assert: coverage_rate_between_0_and_1 {
    expression: ${gold_dim_req.requirement_test_coverage_rate} >= 0 AND ${gold_dim_req.requirement_test_coverage_rate} <= 1 ;;
  }
}

test: test_run_pass_rate_within_valid_bounds {
  explore_source: traceability {
    column: ts_baseline { field: gold_dim_ts.ts_baseline }
    column: pass_rate { field: tbl_cb_sdv_raw_tr_v2.pass_rate }
  }
  assert: pass_rate_between_0_and_1 {
    expression:
      is_null(${tbl_cb_sdv_raw_tr_v2.pass_rate})
      OR (${tbl_cb_sdv_raw_tr_v2.pass_rate} >= 0 AND ${tbl_cb_sdv_raw_tr_v2.pass_rate} <= 1) ;;
  }
}
