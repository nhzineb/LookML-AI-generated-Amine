# =============================================================================
# DERIVED TABLE VIEW: dt_tc_execution_status
# Grain: 1 Row per Test Case (TC_Id)
# Purpose: Pre-computes Test Case horizontal traceability attributes, Test Set
#          deployment flags (Generic vs. Execution), latest Test Run verdict
#          (with Failed > Blocked > Passed tie-breaking), and Defect / Jira
#          derogation readiness (Last_TR_Result_ready_to_be_tested).
# Provenance: SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx (Board 2)
#             & TC_ADAS.txt
# =============================================================================

view: dt_tc_execution_status {
  label: "Test Case Deployment & Latest Execution Status"

  derived_table: {
    sql:
      WITH
      -- 1. Normalized Bench_Type per Test Case (TC_ADAS.txt CTEs bench_exploded & bench_norm)
      tc_bench_norm AS (
        SELECT
          tc.Id AS TC_Id,
          STRING_AGG(DISTINCT TRIM(UPPER(b)), ', ') AS bench_type_norm,
          STRING_AGG(DISTINCT TRIM(UPPER(b)), ', ' ORDER BY TRIM(UPPER(b))) AS bench_type_ordered,
          COUNT(DISTINCT TRIM(UPPER(b))) AS bench_count
        FROM `@{DATASET_NAME}.TBL_CB_SDV_Raw_TC_V2` AS tc
        CROSS JOIN UNNEST(tc.Bench_Type) AS b
        WHERE tc.Id IS NOT NULL
          AND TRIM(b) != ''
        GROUP BY tc.Id
      ),

      -- 2. Linked Requirement rollup per Test Case from Fact_Req_TC + gold_dim_req
      tc_req_links AS (
        SELECT DISTINCT
          b.TC_Id,
          b.Req_Id,
          r.Req_Name,
          r.Req_ASIL,
          ARRAY_TO_STRING(r.Req_Regulations, ', ') AS req_regulation_str,
          ARRAY_TO_STRING(r.Req_MySF, ', ') AS req_mysf_str,
          ARRAY_TO_STRING(r.Req_Baseline, ', ') AS req_baseline_str
        FROM `@{DATASET_NAME}.Fact_Req_TC` AS b
        LEFT JOIN `@{DATASET_NAME}.gold_dim_req` AS r
          ON b.Req_Id = r.Req_Id
        WHERE b.TC_Id IS NOT NULL
          AND b.Req_Id IS NOT NULL
      ),

      tc_req_agg AS (
        SELECT
          TC_Id,
          COUNT(DISTINCT Req_Id) AS count_linked_reqs,
          STRING_AGG(DISTINCT CAST(Req_Id AS STRING), ', ' ORDER BY CAST(Req_Id AS STRING)) AS aggregated_req_id,
          STRING_AGG(DISTINCT NULLIF(TRIM(Req_ASIL), ''), ', ' ORDER BY NULLIF(TRIM(Req_ASIL), '')) AS req_asil_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(req_regulation_str), ''), ', ' ORDER BY NULLIF(TRIM(req_regulation_str), '')) AS req_regulation_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(req_mysf_str), ''), ', ' ORDER BY NULLIF(TRIM(req_mysf_str), '')) AS req_mysf_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(req_baseline_str), ''), ', ' ORDER BY NULLIF(TRIM(req_baseline_str), '')) AS req_baseline_agg,
          MAX(IF(LOWER(IFNULL(Req_Name, '')) LIKE '%requirements are not available%', 1, 0)) AS has_unavailable_req_name,
          MAX(IF(REGEXP_CONTAINS(IFNULL(req_mysf_str, ''), r'(^|, )MySF26\.2($|, )'), 1, 0)) AS has_mysf_26_2,
          MAX(IF(REGEXP_CONTAINS(IFNULL(req_mysf_str, ''), r'(^|, )MySF27\.2($|, )'), 1, 0)) AS has_mysf_27_2,
          MAX(IF(REGEXP_CONTAINS(IFNULL(req_mysf_str, ''), r'(^|, )MySF28\.2($|, )'), 1, 0)) AS has_mysf_28_2
        FROM tc_req_links
        GROUP BY TC_Id
      ),

      -- 3. Test Set deployment per Test Case (Board 2 Sections 3 & 4, TC_ADAS.txt lines 274-290)
      tc_ts_links AS (
        SELECT DISTINCT
          f.TC_Id,
          f.TS_Id,
          ts.TS_Type,
          ARRAY_TO_STRING(ts.TS_MySF, ', ') AS ts_mysf_str,
          ARRAY_TO_STRING(ts.TS_Vehicle_Project, ', ') AS ts_vehicle_project_str,
          ARRAY_TO_STRING(ts.TS_PCU_Releases, ', ') AS ts_pcu_str,
          ARRAY_TO_STRING(ts.TS_PIU_Releases, ', ') AS ts_piu_str,
          ARRAY_TO_STRING(ts.TS_IVC_Releases, ', ') AS ts_ivc_str,
          ARRAY_TO_STRING(ts.TS_CDC_Releases, ', ') AS ts_cdc_str,
          ARRAY_TO_STRING(ts.TS_Other_Releases, ', ') AS ts_other_str
        FROM `@{DATASET_NAME}.Fact_TC_TR_TS_Req` AS f
        INNER JOIN `@{DATASET_NAME}.gold_dim_ts` AS ts
          ON f.TS_Id = ts.TS_Id
        WHERE f.TC_Id IS NOT NULL
          AND f.TS_Id IS NOT NULL
      ),

      tc_ts_agg AS (
        SELECT
          TC_Id,
          COUNT(DISTINCT TS_Id) AS count_ts,
          COUNT(DISTINCT IF(LOWER(TRIM(TS_Type)) = 'generic', TS_Id, NULL)) AS count_ts_generic,
          COUNT(DISTINCT IF(LOWER(TRIM(TS_Type)) IN ('automatic execution', 'manual execution'), TS_Id, NULL)) AS count_ts_execution,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_mysf_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_mysf_str), '')) AS ts_mysf_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_vehicle_project_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_vehicle_project_str), '')) AS ts_vehicle_project_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_pcu_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_pcu_str), '')) AS ts_pcu_releases_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_piu_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_piu_str), '')) AS ts_piu_releases_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_ivc_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_ivc_str), '')) AS ts_ivc_releases_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_cdc_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_cdc_str), '')) AS ts_cdc_releases_agg,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_other_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_other_str), '')) AS ts_other_releases_agg
        FROM tc_ts_links
        GROUP BY TC_Id
      ),

      -- 4. Latest Test Run per Test Case (Board 2 Section 5: ordered by TR_RunDate DESC, Failed > Blocked > Passed > Other, TR_Id DESC)
      tc_latest_tr AS (
        SELECT
          f.TC_Id,
          f.TR_Id AS last_tr_id,
          f.TS_Id AS last_ts_id,
          CAST(COALESCE(tr.Completed_At, tr.Created) AS DATETIME) AS last_tr_run_date,
          tr.Result AS last_tr_raw_result,
          CASE
            WHEN UPPER(TRIM(tr.Result)) IN ('PASSED', 'PASS', 'OK') THEN 'Passed'
            WHEN UPPER(TRIM(tr.Result)) IN ('FAILED', 'FAIL', 'KO', 'NOK') THEN 'Failed'
            WHEN UPPER(TRIM(tr.Result)) IN ('BLOCKED', 'BLOCK') THEN 'Blocked'
            ELSE 'Not executed'
          END AS last_tr_result
        FROM `@{DATASET_NAME}.Fact_TC_TR_TS_Req` AS f
        INNER JOIN `@{DATASET_NAME}.TBL_CB_SDV_Raw_TR_V2` AS tr
          ON f.TR_Id = tr.Id
        WHERE f.TC_Id IS NOT NULL
          AND f.TR_Id IS NOT NULL
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY f.TC_Id
          ORDER BY
            COALESCE(tr.Completed_At, tr.Created) DESC NULLS LAST,
            CASE
              WHEN UPPER(TRIM(tr.Result)) IN ('FAILED', 'FAIL', 'KO', 'NOK') THEN 3
              WHEN UPPER(TRIM(tr.Result)) IN ('BLOCKED', 'BLOCK') THEN 2
              WHEN UPPER(TRIM(tr.Result)) IN ('PASSED', 'PASS', 'OK') THEN 1
              ELSE 0
            END DESC,
            f.TR_Id DESC
        ) = 1
      ),

      -- 5. Linked Jira Defect / Blocker & Derogation status for the Latest Test Run (Board 2 Section 5)
      tr_issue_agg AS (
        SELECT
          tri.TR_ID AS TR_Id,
          COUNT(DISTINCT tri.Issue_Id) AS total_issues,
          COUNT(DISTINCT IF(UPPER(TRIM(COALESCE(iss.Issue_Status, tri.Issue_Status))) IN ('CLOSED', 'RESOLVED', 'DONE', 'VERIFIED'), tri.Issue_Id, NULL)) AS closed_issues,
          COUNT(DISTINCT IF(COALESCE(UPPER(TRIM(COALESCE(iss.Issue_Status, tri.Issue_Status))), 'OPEN') NOT IN ('CLOSED', 'RESOLVED', 'DONE', 'VERIFIED', 'REJECTED', 'CANCELLED'), tri.Issue_Id, NULL)) AS open_issues,
          MAX(
            IF(
              REGEXP_CONTAINS(
                LOWER(CONCAT(COALESCE(ARRAY_TO_STRING(iss.Labels, ' '), tri.Issue_Label, ''), ' ', IFNULL(COALESCE(iss.Summary, tri.Issue_Summary), ''), ' ', IFNULL(COALESCE(iss.Issue_Resolution, tri.Issue_Resolution), ''))),
                r'derogat'
              ),
              1,
              0
            )
          ) AS has_derogation
        FROM `@{DATASET_NAME}.Fact_TR_Issue` AS tri
        LEFT JOIN `@{DATASET_NAME}.TBL_CB_SDV_Raw_Issues_V2` AS iss
          ON tri.Issue_Id = iss.Issue_Id
        WHERE tri.TR_ID IS NOT NULL
        GROUP BY tri.TR_ID
      )

      SELECT
        tc.Id AS tc_id,
        COALESCE(bn.bench_type_norm, 'NULL') AS bench_type_normalized,
        COALESCE(bn.bench_type_ordered, 'NULL') AS bench_type_ordered,
        IF(IFNULL(bn.bench_count, 0) > 0, 'Documented', 'Not documented') AS bench_type_documented,
        IF(ARRAY_LENGTH(tc.Feature_Id) > 0 OR ARRAY_LENGTH(tc.Feature) > 0, 'Documented', 'Not documented') AS feature_documented,

        -- Requirement Linkage Status (TC_ADAS.txt lines 248-272)
        IFNULL(ra.count_linked_reqs, 0) AS count_linked_reqs,
        COALESCE(ra.aggregated_req_id, 'NULL') AS aggregated_req_id,
        CASE
          WHEN IFNULL(ra.has_unavailable_req_name, 0) = 1 THEN 'No requirement available'
          WHEN IFNULL(ra.count_linked_reqs, 0) = 0 AND ARRAY_LENGTH(tc.Requirements) = 0 THEN 'Not linked'
          ELSE 'Linked'
        END AS req_link_status,
        COALESCE(ra.req_mysf_agg, 'NULL') AS req_mysf_agg,
        COALESCE(ra.req_baseline_agg, 'NULL') AS req_baseline_agg,
        COALESCE(ra.req_asil_agg, 'NULL') AS req_asil_agg,
        COALESCE(ra.req_regulation_agg, 'NULL') AS req_regulation_agg,
        IF(ra.req_mysf_agg IS NOT NULL AND TRIM(ra.req_mysf_agg) != '', 'Documented', 'Not documented') AS req_mysf_documented,
        IF(ra.req_baseline_agg IS NOT NULL AND TRIM(ra.req_baseline_agg) != '', 'Documented', 'Not documented') AS req_baseline_documented,

        -- MySF Scope Flags
        IFNULL(ra.has_mysf_26_2, 0) = 1 AS has_mysf_26_2,
        IFNULL(ra.has_mysf_27_2, 0) = 1 AS has_mysf_27_2,
        IFNULL(ra.has_mysf_28_2, 0) = 1 AS has_mysf_28_2,
        (IFNULL(ra.has_mysf_27_2, 0) = 1 AND IFNULL(ra.has_mysf_26_2, 0) = 0) AS is_mysf_27_2_only,
        (IFNULL(ra.has_mysf_28_2, 0) = 1 AND IFNULL(ra.has_mysf_26_2, 0) = 0) AS is_mysf_28_2_only,

        -- Test Set Deployment Flags (Board 2 Sections 3 & 4, TC_ADAS.txt lines 274-290)
        IFNULL(tsa.count_ts, 0) AS count_ts,
        IFNULL(tsa.count_ts_generic, 0) AS count_ts_generic,
        IFNULL(tsa.count_ts_execution, 0) AS count_ts_execution,
        IF(IFNULL(tsa.count_ts, 0) > 0, 'Linked to TS', 'Not Linked to TS') AS tc_is_in_ts,
        IF(IFNULL(tsa.count_ts_generic, 0) > 0, 'Linked to TS Generic', 'Not Linked to TS Generic') AS tc_is_in_ts_generic,
        IF(IFNULL(tsa.count_ts_execution, 0) > 0, 'Linked to TS Execution', 'Not Linked to TS Execution') AS tc_is_in_ts_execution,
        COALESCE(tsa.ts_mysf_agg, 'NULL') AS ts_mysf_agg,
        COALESCE(tsa.ts_vehicle_project_agg, 'NULL') AS ts_vehicle_project_agg,
        COALESCE(tsa.ts_pcu_releases_agg, 'NULL') AS ts_pcu_releases_agg,
        COALESCE(tsa.ts_piu_releases_agg, 'NULL') AS ts_piu_releases_agg,
        COALESCE(tsa.ts_ivc_releases_agg, 'NULL') AS ts_ivc_releases_agg,
        COALESCE(tsa.ts_cdc_releases_agg, 'NULL') AS ts_cdc_releases_agg,
        COALESCE(tsa.ts_other_releases_agg, 'NULL') AS ts_other_releases_agg,

        -- Latest Test Run Verdict & Defect Readiness (Board 2 Section 5)
        ltr.last_tr_id AS last_tr_id,
        ltr.last_ts_id AS last_ts_id,
        ltr.last_tr_run_date AS last_tr_run_date,
        COALESCE(ltr.last_tr_result, 'Not executed') AS last_tr_result,
        IFNULL(iss.total_issues, 0) AS last_tr_issue_count,
        IFNULL(iss.open_issues, 0) AS last_tr_open_issue_count,
        IFNULL(iss.closed_issues, 0) AS last_tr_closed_issue_count,
        IFNULL(iss.has_derogation, 0) = 1 AS has_jira_derogation,
        (IFNULL(iss.total_issues, 0) > 0 AND IFNULL(iss.open_issues, 0) = 0) AS is_ready_for_retest,

        -- 7-Bucket Readiness Classification (Last_TR_Result_ready_to_be_tested - Board 2 Section 5)
        CASE
          WHEN COALESCE(ltr.last_tr_result, 'Not executed') = 'Passed'
            THEN '1. Passed'
          WHEN COALESCE(ltr.last_tr_result, 'Not executed') = 'Failed' AND IFNULL(iss.has_derogation, 0) = 1
            THEN '7. Failed with Jira derogation'
          WHEN COALESCE(ltr.last_tr_result, 'Not executed') = 'Failed' AND IFNULL(iss.total_issues, 0) > 0 AND IFNULL(iss.open_issues, 0) = 0
            THEN '3. Ready to be retested failed'
          WHEN COALESCE(ltr.last_tr_result, 'Not executed') = 'Failed'
            THEN '2. Failed'
          WHEN COALESCE(ltr.last_tr_result, 'Not executed') = 'Blocked' AND IFNULL(iss.total_issues, 0) > 0 AND IFNULL(iss.open_issues, 0) = 0
            THEN '4. Ready to be tested blocked'
          WHEN COALESCE(ltr.last_tr_result, 'Not executed') = 'Blocked'
            THEN '5. Blocked'
          ELSE '6. Not executed'
        END AS last_tr_result_ready_to_be_tested

      FROM `@{DATASET_NAME}.TBL_CB_SDV_Raw_TC_V2` AS tc
      LEFT JOIN tc_bench_norm AS bn
        ON tc.Id = bn.TC_Id
      LEFT JOIN tc_req_agg AS ra
        ON tc.Id = ra.TC_Id
      LEFT JOIN tc_ts_agg AS tsa
        ON tc.Id = tsa.TC_Id
      LEFT JOIN tc_latest_tr AS ltr
        ON tc.Id = ltr.TC_Id
      LEFT JOIN tr_issue_agg AS iss
        ON ltr.last_tr_id = iss.TR_Id
      WHERE tc.Id IS NOT NULL
    ;;
  }

  # ---------------------------------------------------------------------------
  # 1. PRIMARY KEY & FOREIGN KEYS
  # ---------------------------------------------------------------------------

  dimension: tc_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.tc_id ;;
    description: "Primary key (TC_Id) for 1:1 join with tbl_cb_sdv_raw_tc_v2."
  }

  dimension: last_tr_id {
    hidden: yes
    type: number
    sql: ${TABLE}.last_tr_id ;;
    description: "Foreign key to latest Test Run (tbl_cb_sdv_raw_tr_v2.id)."
  }

  dimension: last_ts_id {
    hidden: yes
    type: number
    sql: ${TABLE}.last_ts_id ;;
    description: "Foreign key to latest Test Set (gold_dim_ts.ts_id)."
  }

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS (Board 2 Sections 2, 3, 4, 5)
  # ---------------------------------------------------------------------------

  dimension: bench_type_documented {
    label: "Bench Type Documented (PVAL)"
    group_label: "1. Bench & Feature Documentation (Board 2.2)"
    type: string
    sql: ${TABLE}.bench_type_documented ;;
    description: "'Documented' when TC Bench_Type is populated, else 'Not documented' (Board 2 Section 2)."
  }

  dimension: bench_type_ordered {
    label: "Bench Type Ordered (Normalized)"
    group_label: "1. Bench & Feature Documentation (Board 2.2)"
    type: string
    sql: ${TABLE}.bench_type_ordered ;;
    description: "Uppercase, alphabetically sorted comma-separated list of Bench Types on the Test Case (TC_ADAS.txt)."
  }

  dimension: feature_documented {
    label: "Feature Documented"
    group_label: "1. Bench & Feature Documentation (Board 2.2)"
    type: string
    sql: ${TABLE}.feature_documented ;;
    description: "'Documented' when TC Feature is populated, else 'Not documented'."
  }

  dimension: req_link_status {
    label: "Requirement Link Status (Req_Link_Status)"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_link_status ;;
    description: "'Linked', 'Not linked', or 'No requirement available' (TC_ADAS.txt lines 248-252)."
  }

  dimension: count_linked_reqs {
    label: "Linked Requirements Count"
    group_label: "2. Requirement Linkage & Scope"
    type: number
    sql: ${TABLE}.count_linked_reqs ;;
    value_format_name: decimal_0
    description: "Count of distinct Requirements verified by this Test Case."
  }

  dimension: aggregated_req_id {
    label: "Aggregated Requirement IDs"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.aggregated_req_id ;;
    description: "Comma-separated list of Requirement IDs verified by this Test Case."
  }

  dimension: req_mysf_agg {
    label: "Propagated Requirement MySF"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_mysf_agg ;;
    description: "Aggregated Requirement MySF values linked to this Test Case."
  }

  dimension: req_baseline_agg {
    label: "Propagated Requirement Baselines"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_baseline_agg ;;
    description: "Aggregated Requirement Baselines linked to this Test Case."
  }

  dimension: req_asil_agg {
    label: "Propagated Requirement ASIL"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_asil_agg ;;
    description: "Aggregated Requirement ASIL classifications linked to this Test Case."
  }

  dimension: req_regulation_agg {
    label: "Propagated Requirement Regulation"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_regulation_agg ;;
    description: "Aggregated Requirement Regulations linked to this Test Case."
  }

  dimension: req_mysf_documented {
    label: "Requirement MySF Documented"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_mysf_documented ;;
    description: "'Documented' when linked Requirement MySF is populated, else 'Not documented'."
  }

  dimension: req_baseline_documented {
    label: "Requirement Baseline Documented"
    group_label: "2. Requirement Linkage & Scope"
    type: string
    sql: ${TABLE}.req_baseline_documented ;;
    description: "'Documented' when linked Requirement Baseline is populated, else 'Not documented'."
  }

  dimension: tc_is_in_ts {
    label: "TC Deployment in Any TS (TC_is_in_TS)"
    group_label: "3. Test Set Deployment (Board 2.3 & 2.4)"
    type: string
    sql: ${TABLE}.tc_is_in_ts ;;
    description: "'Linked to TS' when the Test Case belongs to at least one Test Set, else 'Not Linked to TS'."
  }

  dimension: tc_is_in_ts_generic {
    label: "TC Deployment in TS Generic (TC_is_in_TS_generic)"
    group_label: "3. Test Set Deployment (Board 2.3 & 2.4)"
    type: string
    sql: ${TABLE}.tc_is_in_ts_generic ;;
    description: "'Linked to TS Generic' when linked to any Test Set with TS_Type = 'Generic', else 'Not Linked to TS Generic' (Board 2 Section 3)."
  }

  dimension: tc_is_in_ts_execution {
    label: "TC Deployment in TS Execution (TC_is_in_TS_execution)"
    group_label: "3. Test Set Deployment (Board 2.3 & 2.4)"
    type: string
    sql: ${TABLE}.tc_is_in_ts_execution ;;
    description: "'Linked to TS Execution' when linked to any Test Set with TS_Type IN ('Automatic execution', 'Manual execution'), else 'Not Linked to TS Execution' (Board 2 Section 4)."
  }

  dimension: ts_mysf_agg {
    label: "Propagated Test Set MySF (TS_MySF)"
    group_label: "3. Test Set Deployment (Board 2.3 & 2.4)"
    type: string
    sql: ${TABLE}.ts_mysf_agg ;;
    description: "Comma-separated list of Test Set MySF values linked to this Test Case."
  }

  dimension: ts_vehicle_project_agg {
    label: "Propagated TS Vehicle Project"
    group_label: "3. Test Set Deployment (Board 2.3 & 2.4)"
    type: string
    sql: ${TABLE}.ts_vehicle_project_agg ;;
    description: "Vehicle Projects from linked Test Sets."
  }

  dimension: last_tr_result {
    label: "Latest Test Run Verdict (Last_TR_Result)"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: string
    sql: ${TABLE}.last_tr_result ;;
    description: "Latest Test Run result for the Test Case ('Passed', 'Failed', 'Blocked', 'Not executed'), tie-broken by Failed > Blocked > Passed (Board 2 Section 5)."
    html:
      {% if value == 'Passed' %}
        <span style="background-color:#e6f4ea; color:#137333; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Failed' %}
        <span style="background-color:#fce8e6; color:#c5221f; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Blocked' %}
        <span style="background-color:#fef7e0; color:#b06000; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% else %}
        <span style="background-color:#f1f3f4; color:#5f6368; padding:2px 8px; border-radius:12px;">{{ rendered_value }}</span>
      {% endif %} ;;
  }

  dimension: last_tr_result_ready_to_be_tested {
    label: "Latest Execution & Retest Readiness (7-Bucket)"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: string
    sql: ${TABLE}.last_tr_result_ready_to_be_tested ;;
    description: "7-bucket execution and Jira defect readiness status: '1. Passed', '2. Failed', '3. Ready to be retested failed', '4. Ready to be tested blocked', '5. Blocked', '6. Not executed', '7. Failed with Jira derogation' (Board 2 Section 5)."
  }

  dimension_group: last_tr_run {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.last_tr_run_date ;;
    description: "Execution timestamp of the latest Test Run for this Test Case."
  }

  dimension: has_jira_derogation {
    label: "Has Jira Derogation on Latest TR"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: yesno
    sql: ${TABLE}.has_jira_derogation ;;
    description: "True when the latest Test Run is linked to a Jira Issue carrying a derogation label/summary."
  }

  dimension: is_ready_for_retest {
    label: "Is Ready for Retest (All Linked Issues Closed)"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: yesno
    sql: ${TABLE}.is_ready_for_retest ;;
    description: "True when the latest Failed/Blocked Test Run has linked Jira Issues and all of them are Resolved/Closed."
  }

  dimension: is_mysf_27_2_only {
    label: "Is MySF27.2-only"
    group_label: "2. Requirement Linkage & Scope"
    type: yesno
    sql: ${TABLE}.is_mysf_27_2_only ;;
    description: "True when the Test Case is linked to MySF27.2 and NOT MySF26.2."
  }

  dimension: is_mysf_28_2_only {
    label: "Is MySF28.2-only"
    group_label: "2. Requirement Linkage & Scope"
    type: yesno
    sql: ${TABLE}.is_mysf_28_2_only ;;
    description: "True when the Test Case is linked to MySF28.2 and NOT MySF26.2."
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Board 2 KPIs)
  # ---------------------------------------------------------------------------

  measure: count_tc_bench_documented {
    label: "Test Cases with Bench Documented"
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [bench_type_documented: "Documented"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with a documented Bench_Type."
  }

  measure: count_tc_bench_not_documented {
    label: "Test Cases with Bench Not Documented"
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [bench_type_documented: "Not documented"]
    value_format_name: decimal_0
    description: "Distinct Test Cases missing a Bench_Type."
  }

  measure: tc_bench_documentation_rate {
    label: "TC Bench Documentation Rate (%)"
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_tc_bench_documented}, NULLIF(${count_tc_bench_documented} + ${count_tc_bench_not_documented}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of Test Cases with a documented Bench Type."
  }

  measure: count_tc_in_ts_generic {
    label: "TCs Linked to TS Generic"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [tc_is_in_ts_generic: "Linked to TS Generic"]
    value_format_name: decimal_0
    description: "Distinct Test Cases deployed in at least one Generic Test Set."
  }

  measure: count_tc_not_in_ts_generic {
    label: "TCs Not Linked to TS Generic"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [tc_is_in_ts_generic: "Not Linked to TS Generic"]
    value_format_name: decimal_0
    description: "Distinct Test Cases not deployed in any Generic Test Set."
  }

  measure: tc_ts_generic_deployment_rate {
    label: "TS Generic Deployment Rate (%)"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_tc_in_ts_generic}, NULLIF(${count_tc_in_ts_generic} + ${count_tc_not_in_ts_generic}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of Test Cases deployed in a Generic Test Set (Board 2 Section 3)."
  }

  measure: count_tc_in_ts_execution {
    label: "TCs Linked to TS Execution"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [tc_is_in_ts_execution: "Linked to TS Execution"]
    value_format_name: decimal_0
    description: "Distinct Test Cases deployed in an Automatic or Manual Execution Test Set."
  }

  measure: count_tc_not_in_ts_execution {
    label: "TCs Not Linked to TS Execution"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [tc_is_in_ts_execution: "Not Linked to TS Execution"]
    value_format_name: decimal_0
    description: "Distinct Test Cases not deployed in any Execution Test Set."
  }

  measure: tc_ts_execution_deployment_rate {
    label: "TS Execution Deployment Rate (%)"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_tc_in_ts_execution}, NULLIF(${count_tc_in_ts_execution} + ${count_tc_not_in_ts_execution}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of Test Cases deployed in an Execution Test Set (Board 2 Section 4)."
  }

  measure: count_tc_latest_passed {
    label: "TCs Passed (Latest TR)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result: "Passed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases whose latest Test Run verdict is Passed."
  }

  measure: count_tc_latest_failed {
    label: "TCs Failed (Latest TR)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result: "Failed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases whose latest Test Run verdict is Failed."
  }

  measure: count_tc_latest_blocked {
    label: "TCs Blocked (Latest TR)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result: "Blocked"]
    value_format_name: decimal_0
    description: "Distinct Test Cases whose latest Test Run verdict is Blocked."
  }

  measure: count_tc_latest_not_executed {
    label: "TCs Not Executed (Latest TR)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result: "Not executed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with no executed Test Run."
  }

  measure: count_tc_ready_to_retest_failed {
    label: "TCs Ready to be Retested (Failed -> Defect Closed)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result_ready_to_be_tested: "3. Ready to be retested failed"]
    value_format_name: decimal_0
    description: "Distinct Failed Test Cases whose linked Jira Issues are all Closed/Resolved and ready for retest."
  }

  measure: count_tc_ready_to_test_blocked {
    label: "TCs Ready to be Tested (Blocked -> Blocker Closed)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result_ready_to_be_tested: "4. Ready to be tested blocked"]
    value_format_name: decimal_0
    description: "Distinct Blocked Test Cases whose blocking Jira Issues are all Closed/Resolved and ready for testing."
  }

  measure: count_tc_failed_with_derogation {
    label: "TCs Failed with Jira Derogation"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_tr_result_ready_to_be_tested: "7. Failed with Jira derogation"]
    value_format_name: decimal_0
    description: "Distinct Failed Test Cases covered by a Jira derogation."
  }

  dimension: last_tr_issue_count {
    label: "Linked Jira Issues on Latest TR"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: number
    sql: ${TABLE}.last_tr_issue_count ;;
    value_format_name: decimal_0
    description: "Total Jira Issues linked to the latest Test Run of this Test Case."
  }

  dimension: last_tr_open_issue_count {
    label: "Open Blocking Jira Issues on Latest TR"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: number
    sql: ${TABLE}.last_tr_open_issue_count ;;
    value_format_name: decimal_0
    description: "Open (unresolved) Jira Issues linked to the latest Test Run of this Test Case."
  }

  dimension: last_tr_closed_issue_count {
    label: "Closed Jira Issues on Latest TR"
    group_label: "4. Latest Execution & Retest Readiness (Board 2.5)"
    type: number
    sql: ${TABLE}.last_tr_closed_issue_count ;;
    value_format_name: decimal_0
    description: "Closed/Resolved Jira Issues linked to the latest Test Run of this Test Case."
  }

  measure: total_tc_count {
    label: "Total Test Cases (Distinct)"
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    value_format_name: decimal_0
    description: "Total distinct count of Test Cases."
  }

  measure: count_tc_req_linked {
    label: "TCs Linked to Requirement"
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [req_link_status: "Linked"]
    value_format_name: decimal_0
    description: "Distinct Test Cases linked to at least one Requirement."
  }

  measure: tc_req_linked_rate {
    label: "TC Linked to Requirement Rate (%)"
    group_label: "Board 2.2 - Bench & Feature Coverage Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_tc_req_linked}, NULLIF(${total_tc_count}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of Test Cases linked to at least one Requirement."
  }

  measure: count_tc_in_ts {
    label: "TCs Linked to Any TS"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [tc_is_in_ts: "Linked to TS"]
    value_format_name: decimal_0
    description: "Distinct Test Cases deployed in at least one Test Set."
  }

  measure: count_tc_not_in_ts {
    label: "TCs Not Linked to Any TS"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [tc_is_in_ts: "Not Linked to TS"]
    value_format_name: decimal_0
    description: "Distinct Test Cases not deployed in any Test Set."
  }

  measure: tc_in_ts_rate {
    label: "TC Deployed in Any TS Rate (%)"
    group_label: "Board 2.3 & 2.4 - TS Deployment Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_tc_in_ts}, NULLIF(${total_tc_count}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of Test Cases deployed in at least one Test Set."
  }

  measure: tc_latest_pass_rate {
    label: "TC Latest Execution Pass Rate (%)"
    group_label: "Board 2.5 - Latest TC Execution & Retest Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_tc_latest_passed}, NULLIF(${count_tc_latest_passed} + ${count_tc_latest_failed} + ${count_tc_latest_blocked}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of executed Test Cases (Passed + Failed + Blocked) that Passed on their latest Test Run."
  }
}
