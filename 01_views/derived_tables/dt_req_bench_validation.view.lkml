# =============================================================================
# DERIVED TABLE VIEW: dt_req_bench_validation
# Grain: 1 Row per (Req_Id, TS_Bench_Type)
# Purpose: Enables slicing Requirement Pass Rate (Board 4) by individual Test Bench
#          Type (HIL, EIPF, VHL, SIL, etc.) and V-Cycle Engineering Level without fan-out.
# Provenance: SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx (Board 4)
#             & Req_ADAS.txt (CTEs 6-9 & 14)
# =============================================================================

view: dt_req_bench_validation {
  label: "Requirement Pass Rate by Bench Type"

  derived_table: {
    sql:
      WITH
      req_runs_bench AS (
        SELECT
          f.Req_Id,
          f.TC_Id,
          f.TR_Id,
          TRIM(UPPER(bench)) AS TS_Bench_Type,
          CAST(COALESCE(tr.Completed_At, tr.Created) AS DATETIME) AS tr_run_date,
          CASE
            WHEN UPPER(TRIM(tr.Result)) IN ('PASSED', 'PASS', 'OK') THEN 'Passed'
            WHEN UPPER(TRIM(tr.Result)) IN ('FAILED', 'FAIL', 'KO', 'NOK') THEN 'Failed'
            WHEN UPPER(TRIM(tr.Result)) IN ('BLOCKED', 'BLOCK') THEN 'Blocked'
            ELSE 'Not Executed'
          END AS normalized_tr_result
        FROM `@{DATASET_NAME}.Fact_TC_TR_TS_Req` AS f
        LEFT JOIN `@{DATASET_NAME}.TBL_CB_SDV_Raw_TR_V2` AS tr
          ON f.TR_Id = tr.Id
        LEFT JOIN `@{DATASET_NAME}.gold_dim_ts` AS ts
          ON f.TS_Id = ts.TS_Id
        CROSS JOIN UNNEST(ts.TS_Bench_Types) AS bench
        WHERE f.Req_Id IS NOT NULL
          AND f.TC_Id IS NOT NULL
          AND TRIM(bench) != ''
      ),

      per_tc_bench AS (
        SELECT
          Req_Id,
          TC_Id,
          TS_Bench_Type,
          tr_run_date,
          IFNULL(normalized_tr_result, 'Not Executed') AS Last_TR_Result
        FROM req_runs_bench
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY Req_Id, TC_Id, TS_Bench_Type
          ORDER BY
            tr_run_date DESC NULLS LAST,
            CASE
              WHEN normalized_tr_result = 'Failed' THEN 4
              WHEN normalized_tr_result = 'Blocked' THEN 3
              WHEN normalized_tr_result = 'Passed' THEN 2
              WHEN normalized_tr_result = 'Not Executed' THEN 1
              ELSE 0
            END DESC,
            TR_Id DESC NULLS LAST
        ) = 1
      ),

      agg_by_req_bench AS (
        SELECT
          Req_Id,
          TS_Bench_Type,
          COUNT(DISTINCT TC_Id) AS count_tc_on_bench,
          COUNTIF(Last_TR_Result = 'Passed') AS count_passed_tc,
          COUNTIF(Last_TR_Result = 'Failed') AS count_failed_tc,
          COUNTIF(Last_TR_Result = 'Blocked') AS count_blocked_tc,
          COUNTIF(Last_TR_Result = 'Not Executed') AS count_not_executed_tc,
          MAX(tr_run_date) AS last_run_date_on_bench,
          CASE
            WHEN COUNTIF(Last_TR_Result = 'Failed') > 0 THEN 'Failed'
            WHEN COUNTIF(Last_TR_Result = 'Passed') = COUNT(*) THEN 'Passed'
            WHEN COUNTIF(Last_TR_Result = 'Not Executed') > 0 AND COUNTIF(Last_TR_Result = 'Passed') > 0 THEN 'Ongoing'
            WHEN COUNTIF(Last_TR_Result = 'Blocked') > 0 THEN 'Ongoing'
            ELSE 'Not Executed'
          END AS raw_bench_status
        FROM per_tc_bench
        GROUP BY Req_Id, TS_Bench_Type
      )

      SELECT
        CONCAT(CAST(r.Req_Id AS STRING), '-', COALESCE(b.TS_Bench_Type, 'NO_BENCH')) AS req_bench_pk,
        r.Req_Id AS req_id,
        COALESCE(b.TS_Bench_Type, 'NO_BENCH') AS ts_bench_type,
        IFNULL(b.count_tc_on_bench, 0) AS count_tc_on_bench,
        IFNULL(b.count_passed_tc, 0) AS count_passed_tc,
        IFNULL(b.count_failed_tc, 0) AS count_failed_tc,
        IFNULL(b.count_blocked_tc, 0) AS count_blocked_tc,
        IFNULL(b.count_not_executed_tc, 0) AS count_not_executed_tc,
        b.last_run_date_on_bench AS last_run_date_on_bench,
        CASE
          WHEN LOWER(TRIM(r.Req_Status)) LIKE '%rejected%' THEN 'Rejected'
          WHEN b.TS_Bench_Type IS NULL THEN 'Not covered'
          ELSE b.raw_bench_status
        END AS bench_validation_status
      FROM `@{DATASET_NAME}.gold_dim_req` AS r
      LEFT JOIN agg_by_req_bench AS b
        ON r.Req_Id = b.Req_Id
      WHERE r.Req_Id IS NOT NULL
    ;;
  }

  dimension: req_bench_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.req_bench_pk ;;
    description: "Composite primary key (Req_Id + TS_Bench_Type)."
  }

  dimension: req_id {
    hidden: yes
    type: number
    sql: ${TABLE}.req_id ;;
    description: "Foreign key to gold_dim_req (Req_Id)."
  }

  dimension: ts_bench_type {
    label: "Test Set Bench Type (Normalized)"
    group_label: "1. Bench Validation Scope"
    type: string
    sql: ${TABLE}.ts_bench_type ;;
    description: "Normalized uppercase Test Set Bench Type (e.g., HIL, EIPF, VHL, SIL, or NO_BENCH)."
  }

  dimension: bench_validation_status {
    label: "Requirement Status on Bench"
    group_label: "1. Bench Validation Scope"
    type: string
    sql: ${TABLE}.bench_validation_status ;;
    description: "Consolidated Requirement validation status on this specific Bench Type: 'Passed', 'Failed', 'Ongoing', 'Not Executed', 'Not covered', or 'Rejected' (Board 4)."
    html:
      {% if value == 'Passed' %}
        <span style="background-color:#e6f4ea; color:#137333; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Failed' %}
        <span style="background-color:#fce8e6; color:#c5221f; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Ongoing' %}
        <span style="background-color:#fef7e0; color:#b06000; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% else %}
        <span style="background-color:#f1f3f4; color:#5f6368; padding:2px 8px; border-radius:12px;">{{ rendered_value }}</span>
      {% endif %} ;;
  }

  dimension: count_tc_on_bench {
    label: "Linked TCs on Bench"
    group_label: "1. Bench Validation Scope"
    type: number
    sql: ${TABLE}.count_tc_on_bench ;;
    value_format_name: decimal_0
    description: "Count of distinct Test Cases verifying the Requirement on this Bench Type."
  }

  dimension_group: last_run_on_bench {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.last_run_date_on_bench ;;
    description: "Timestamp of the most recent Test Run for this Requirement on this Bench Type."
  }

  measure: count_requirements {
    label: "Total Requirements (Distinct)"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    value_format_name: decimal_0
    description: "Distinct count of Requirements."
  }

  measure: count_passed_requirements {
    label: "Passed Requirements on Bench"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [bench_validation_status: "Passed"]
    value_format_name: decimal_0
    description: "Distinct Requirements with Passed status on the selected Bench Type."
  }

  measure: count_failed_requirements {
    label: "Failed Requirements on Bench"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [bench_validation_status: "Failed"]
    value_format_name: decimal_0
    description: "Distinct Requirements with Failed status on the selected Bench Type."
  }

  measure: count_ongoing_requirements {
    label: "Ongoing Requirements on Bench"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [bench_validation_status: "Ongoing"]
    value_format_name: decimal_0
    description: "Distinct Requirements with Ongoing status on the selected Bench Type."
  }

  measure: count_not_executed_requirements {
    label: "Not Executed Requirements on Bench"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [bench_validation_status: "Not Executed"]
    value_format_name: decimal_0
    description: "Distinct Requirements with Not Executed status on the selected Bench Type."
  }

  measure: count_not_covered_requirements {
    label: "Not Covered Requirements on Bench"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [bench_validation_status: "Not covered"]
    value_format_name: decimal_0
    description: "Distinct Requirements not covered on the selected Bench Type."
  }

  measure: count_rejected_requirements {
    label: "Rejected Requirements on Bench"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [bench_validation_status: "Rejected"]
    value_format_name: decimal_0
    description: "Distinct Requirements with Rejected status."
  }

  measure: bench_requirement_pass_rate {
    label: "Requirement Pass Rate on Bench (%)"
    group_label: "Board 4 - Bench Pass Rate Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_passed_requirements}, NULLIF(${count_passed_requirements} + ${count_failed_requirements} + ${count_ongoing_requirements}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of executed Requirements on the Bench Type (Passed + Failed + Ongoing) that Passed."
  }
}
