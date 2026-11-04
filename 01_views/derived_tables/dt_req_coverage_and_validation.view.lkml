# =============================================================================
# DERIVED TABLE VIEW: dt_req_coverage_and_validation
# Grain: 1 Row per Requirement (Req_Id)
# Purpose: Pre-computes Requirement-grain coverage classifications (Covered_Status),
#          Vertical Traceability child & SWC decomposition flags (Req_linked_child,
#          child_presence_for_each_swc), and Requirement Validation Pass Rate rollups
#          (Req_last_results, Req_last_results_by_bench_type) without join fan-out.
# Provenance: SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx (Boards 1, 2.1, 4)
#             & Req_ADAS.txt
# =============================================================================

view: dt_req_coverage_and_validation {
  label: "Requirement Coverage & Validation Rollup"

  derived_table: {
    sql:
      WITH
      -- 1. Requirement base metadata from gold_dim_req
      req_base AS (
        SELECT
          r.Req_Id,
          r.Req_Status,
          r.Req_Domain,
          r.Req_Child_Required,
          r.Req_ValidationMethods,
          ARRAY_TO_STRING(r.Req_Engineering_Level, ', ') AS req_eng_level_str,
          r.Req_Engineering_Level[SAFE_OFFSET(0)] AS req_eng_level_primary,
          ARRAY_TO_STRING(r.Req_Supplier, ', ') AS req_supplier_str,
          ARRAY_TO_STRING(r.Req_MySF, ', ') AS req_mysf_str,
          ARRAY_TO_STRING(r.Req_Feature_CBId, ', ') AS req_feature_str,
          ARRAY_TO_STRING(r.Req_Bench_Type, ', ') AS req_bench_type_str,
          ARRAY_LENGTH(r.Req_Requirement_Parent_Id) AS parent_req_count,
          ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(r.Req_Requirement_Parent_Id) AS x), ', ') AS parent_req_ids_str,
          r.Req_SW_Components AS req_swc_array,
          r.Req_Test_Cases AS req_tc_array
        FROM `@{DATASET_NAME}.gold_dim_req` AS r
        WHERE r.Req_Id IS NOT NULL
      ),

      -- 2. Parent-to-Child Requirement links derived from Req_Requirement_Parent_Id
      parent_child_links AS (
        SELECT DISTINCT
          parent_id AS Parent_Req_Id,
          child.Req_Id AS Child_Req_Id
        FROM `@{DATASET_NAME}.gold_dim_req` AS child
        CROSS JOIN UNNEST(child.Req_Requirement_Parent_Id) AS parent_id
        WHERE child.Req_Id IS NOT NULL
          AND parent_id IS NOT NULL
      ),

      child_counts AS (
        SELECT
          Parent_Req_Id AS Req_Id,
          COUNT(DISTINCT Child_Req_Id) AS count_child
        FROM parent_child_links
        GROUP BY Parent_Req_Id
      ),

      -- 3. SWC Cross-System Coverage for SFReq (Board 1 Section 6 & Req_ADAS.txt CTE 15)
      swc_exploded AS (
        SELECT DISTINCT
          r.Req_Id,
          r.Req_Engineering_Level[SAFE_OFFSET(0)] AS req_eng_level_primary,
          LOWER(TRIM(CAST(swc AS STRING))) AS swc
        FROM `@{DATASET_NAME}.gold_dim_req` AS r
        CROSS JOIN UNNEST(r.Req_SW_Components) AS swc
        WHERE r.Req_Id IS NOT NULL
          AND TRIM(CAST(swc AS STRING)) != ''
      ),

      sfreq_swc_summary AS (
        SELECT
          parent_swc.Req_Id,
          COUNT(DISTINCT parent_swc.swc) AS total_swc,
          COUNT(DISTINCT IF(child_swc.swc IS NOT NULL, parent_swc.swc, NULL)) AS covered_swc
        FROM swc_exploded AS parent_swc
        LEFT JOIN parent_child_links AS pcl
          ON pcl.Parent_Req_Id = parent_swc.Req_Id
        LEFT JOIN swc_exploded AS child_swc
          ON child_swc.Req_Id = pcl.Child_Req_Id
         AND child_swc.swc = parent_swc.swc
        WHERE UPPER(IFNULL(parent_swc.req_eng_level_primary, '')) = 'SFREQ'
        GROUP BY parent_swc.Req_Id
      ),

      -- 4. Distinct Test Cases linked per Requirement (from gold_dim_fact_req_tc and FACT_TC_TR_TS_REQ)
      req_tc_links AS (
        SELECT DISTINCT Req_Id, TC_Id
        FROM `@{DATASET_NAME}.gold_dim_fact_req_tc`
        WHERE Req_Id IS NOT NULL AND TC_Id IS NOT NULL
        UNION DISTINCT
        SELECT DISTINCT Req_Id, TC_Id
        FROM `@{DATASET_NAME}.FACT_TC_TR_TS_REQ`
        WHERE Req_Id IS NOT NULL AND TC_Id IS NOT NULL
        UNION DISTINCT
        SELECT DISTINCT r.Req_Id, tc_id AS TC_Id
        FROM `@{DATASET_NAME}.gold_dim_req` AS r
        CROSS JOIN UNNEST(r.Req_Test_Cases) AS tc_id
        WHERE r.Req_Id IS NOT NULL AND tc_id IS NOT NULL
      ),

      req_tc_agg AS (
        SELECT
          Req_Id,
          COUNT(DISTINCT TC_Id) AS count_tc,
          STRING_AGG(DISTINCT CAST(TC_Id AS STRING), ', ' ORDER BY CAST(TC_Id AS STRING)) AS aggregated_tc_id
        FROM req_tc_links
        GROUP BY Req_Id
      ),

      -- 5. Requirement Runs & Latest TR Result per (Req_Id, TC_Id) (Board 4 & Req_ADAS.txt CTEs 1-11)
      req_runs_base AS (
        SELECT
          f.Req_Id,
          f.TC_Id,
          f.TS_Id,
          f.TR_Id,
          ts.TS_Bench_Type AS ts_bench_array,
          ARRAY_TO_STRING(ts.TS_MySF, ', ') AS ts_mysf_str,
          COALESCE(tr.Completed_At, tr.Created) AS tr_run_date,
          CASE
            WHEN UPPER(TRIM(tr.Result)) IN ('PASSED', 'PASS', 'OK') THEN 'Passed'
            WHEN UPPER(TRIM(tr.Result)) IN ('FAILED', 'FAIL', 'KO', 'NOK') THEN 'Failed'
            WHEN UPPER(TRIM(tr.Result)) IN ('BLOCKED', 'BLOCK') THEN 'Blocked'
            ELSE 'Not Executed'
          END AS normalized_tr_result
        FROM `@{DATASET_NAME}.FACT_TC_TR_TS_REQ` AS f
        LEFT JOIN `@{DATASET_NAME}.TBL_CB_SDV_Raw_TR_V2` AS tr
          ON f.TR_Id = tr.Id
        LEFT JOIN `@{DATASET_NAME}.gold_dim_ts` AS ts
          ON f.TS_Id = ts.TS_Id
        WHERE f.Req_Id IS NOT NULL
          AND f.TC_Id IS NOT NULL
      ),

      req_ts_mysf_agg AS (
        SELECT
          Req_Id,
          STRING_AGG(DISTINCT NULLIF(TRIM(ts_mysf_str), ''), ', ' ORDER BY NULLIF(TRIM(ts_mysf_str), '')) AS ts_mysf
        FROM req_runs_base
        WHERE ts_mysf_str IS NOT NULL AND TRIM(ts_mysf_str) != ''
        GROUP BY Req_Id
      ),

      -- Latest TR verdict per (Req_Id, TC_Id) using QUALIFY tie-breaker: Failed (4) > Blocked (3) > Passed (2) > Not Executed (1)
      per_tc AS (
        SELECT
          Req_Id,
          TC_Id,
          IFNULL(normalized_tr_result, 'Not Executed') AS Last_TR_Result
        FROM req_runs_base
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY Req_Id, TC_Id
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

      -- Latest TR verdict per (Req_Id, TC_Id, TS_Bench_Type)
      per_tc_bench AS (
        SELECT
          b.Req_Id,
          b.TC_Id,
          TRIM(UPPER(bench)) AS TS_Bench_Type,
          IFNULL(b.normalized_tr_result, 'Not Executed') AS Last_TR_Result
        FROM req_runs_base AS b
        CROSS JOIN UNNEST(b.ts_bench_array) AS bench
        WHERE TRIM(bench) != ''
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY b.Req_Id, b.TC_Id, TRIM(UPPER(bench))
          ORDER BY
            b.tr_run_date DESC NULLS LAST,
            CASE
              WHEN b.normalized_tr_result = 'Failed' THEN 4
              WHEN b.normalized_tr_result = 'Blocked' THEN 3
              WHEN b.normalized_tr_result = 'Passed' THEN 2
              WHEN b.normalized_tr_result = 'Not Executed' THEN 1
              ELSE 0
            END DESC,
            b.TR_Id DESC NULLS LAST
        ) = 1
      ),

      req_by_bench_type AS (
        SELECT
          Req_Id,
          TS_Bench_Type,
          CASE
            WHEN COUNTIF(Last_TR_Result = 'Failed') > 0 THEN 'Failed'
            WHEN COUNTIF(Last_TR_Result = 'Passed') = COUNT(*) THEN 'Passed'
            WHEN COUNTIF(Last_TR_Result = 'Not Executed') > 0 AND COUNTIF(Last_TR_Result = 'Passed') > 0 THEN 'Ongoing'
            WHEN COUNTIF(Last_TR_Result = 'Blocked') > 0 THEN 'Ongoing'
            ELSE 'Not Executed'
          END AS Bench_Status
        FROM per_tc_bench
        GROUP BY Req_Id, TS_Bench_Type
      ),

      req_bench_status AS (
        SELECT
          Req_Id,
          STRING_AGG(CONCAT(TS_Bench_Type, ':', Bench_Status), ', ' ORDER BY TS_Bench_Type) AS bench_status_string,
          CASE
            WHEN COUNTIF(Bench_Status = 'Failed') > 0 THEN 'Failed'
            WHEN COUNTIF(Bench_Status = 'Passed') = COUNT(*) THEN 'Passed'
            WHEN COUNTIF(Bench_Status = 'Ongoing') > 0 THEN 'Ongoing'
            WHEN COUNTIF(Bench_Status = 'Not Executed') > 0 THEN 'Not Executed'
            ELSE 'Not covered'
          END AS overall_status
        FROM req_by_bench_type
        GROUP BY Req_Id
      ),

      req_tc_status AS (
        SELECT
          Req_Id,
          COUNT(*) AS count_tc_runs,
          CASE
            WHEN COUNTIF(Last_TR_Result = 'Failed') > 0 THEN 'Failed'
            WHEN COUNTIF(Last_TR_Result = 'Not Executed') > 0 AND COUNTIF(Last_TR_Result = 'Passed') > 0 THEN 'Ongoing'
            WHEN COUNTIF(Last_TR_Result = 'Blocked') > 0 THEN 'Ongoing'
            WHEN COUNTIF(Last_TR_Result = 'Passed') = COUNT(*) THEN 'Passed'
            ELSE 'Not Executed'
          END AS fallback_status
        FROM per_tc
        GROUP BY Req_Id
      )

      SELECT
        rb.Req_Id AS req_id,
        IFNULL(tc_agg.count_tc, 0) AS count_tc,
        IFNULL(cc.count_child, 0) AS count_child,
        IFNULL(rb.parent_req_count, 0) AS count_parent,
        tc_agg.aggregated_tc_id AS aggregated_tc_id,
        ts_m.ts_mysf AS ts_mysf,

        -- Normalized Engineering Level (Board 1 Section 1 & Req_ADAS.txt lines 451-467)
        CASE TRIM(rb.req_eng_level_primary)
          WHEN 'SG'     THEN '01-SG'
          WHEN 'FSR'    THEN '02-FSR'
          WHEN 'TSR'    THEN '03-TSR'
          WHEN 'CP'     THEN '04-CP'
          WHEN 'REG'    THEN '05-REG'
          WHEN 'CyberG' THEN '06-CyberG'
          WHEN 'VOReq'  THEN '11-VOREQ'
          WHEN 'SOReq'  THEN '12-SOREQ'
          WHEN 'SFReq'  THEN '13-SFREQ'
          WHEN 'HWR'    THEN '14-HWR'
          WHEN 'SPREQ'  THEN '15-SPREQ'
          WHEN 'SRS'    THEN '21-SRS'
          WHEN 'SCRS'   THEN '22-SCRS'
          WHEN 'SURS'   THEN '23-SURS'
          ELSE IFNULL(TRIM(rb.req_eng_level_primary), 'NULL')
        END AS req_engineering_level_normalized,

        -- Test Expected flag (ValidationMethods is NULL, empty, or 'test')
        (
          rb.Req_ValidationMethods IS NULL
          OR TRIM(rb.Req_ValidationMethods) = ''
          OR LOWER(TRIM(rb.Req_ValidationMethods)) = 'test'
          OR LOWER(TRIM(rb.Req_ValidationMethods)) LIKE '%test%'
        ) AS is_test_expected,

        -- Covered_Status (Board 2 Section 1 & Board 1 Section 4 & Req_ADAS.txt lines 862-907)
        CASE
          WHEN (
            rb.Req_ValidationMethods IS NULL
            OR TRIM(rb.Req_ValidationMethods) = ''
            OR LOWER(TRIM(rb.Req_ValidationMethods)) = 'test'
            OR LOWER(TRIM(rb.Req_ValidationMethods)) LIKE '%test%'
          )
          AND IFNULL(tc_agg.count_tc, 0) > 0
          AND LOWER(TRIM(rb.Req_Status)) = 'draft'
            THEN 'Not covered'

          WHEN (
            rb.Req_ValidationMethods IS NULL
            OR TRIM(rb.Req_ValidationMethods) = ''
            OR LOWER(TRIM(rb.Req_ValidationMethods)) = 'test'
            OR LOWER(TRIM(rb.Req_ValidationMethods)) LIKE '%test%'
          )
          AND IFNULL(tc_agg.count_tc, 0) > 0
          AND (LOWER(TRIM(rb.Req_Status)) != 'draft' OR rb.Req_Status IS NULL)
            THEN 'Covered'

          WHEN (
            rb.Req_ValidationMethods IS NULL
            OR TRIM(rb.Req_ValidationMethods) = ''
            OR LOWER(TRIM(rb.Req_ValidationMethods)) = 'test'
            OR LOWER(TRIM(rb.Req_ValidationMethods)) LIKE '%test%'
          )
          AND (
            LOWER(TRIM(rb.req_supplier_str)) = 'ast'
            OR rb.req_supplier_str IS NULL
            OR TRIM(rb.req_supplier_str) = ''
          )
          AND IFNULL(tc_agg.count_tc, 0) = 0
            THEN 'Not covered'

          WHEN (
            rb.Req_ValidationMethods IS NULL
            OR TRIM(rb.Req_ValidationMethods) = ''
            OR LOWER(TRIM(rb.Req_ValidationMethods)) = 'test'
            OR LOWER(TRIM(rb.Req_ValidationMethods)) LIKE '%test%'
          )
          AND LOWER(TRIM(rb.req_supplier_str)) != 'ast'
          AND rb.req_supplier_str IS NOT NULL
          AND TRIM(rb.req_supplier_str) != ''
          AND IFNULL(tc_agg.count_tc, 0) = 0
            THEN 'Supplier'

          ELSE 'No test expected'
        END AS covered_status,

        -- Make Missing Childs (Board 1 Section 5 & Req_ADAS.txt lines 832-840)
        CASE
          WHEN LOWER(TRIM(rb.Req_Child_Required)) = 'no' THEN 'No child required'
          WHEN IFNULL(cc.count_child, 0) > 0 THEN 'Linked to a child'
          ELSE 'Not linked to a child'
        END AS req_linked_child,

        -- Cross System Missing Childs for SFReq (Board 1 Section 6 & Req_ADAS.txt lines 842-860)
        IFNULL(swc.total_swc, 0) AS total_swc_count,
        IFNULL(swc.covered_swc, 0) AS covered_swc_count,
        CASE
          WHEN UPPER(IFNULL(TRIM(rb.req_eng_level_primary), '')) != 'SFREQ' THEN NULL
          WHEN LOWER(TRIM(rb.Req_Child_Required)) = 'no' THEN 'No child required'
          WHEN IFNULL(swc.total_swc, 0) = 0 THEN 'No SWC present'
          WHEN IFNULL(swc.covered_swc, 0) = 0 THEN 'Not linked to a child'
          WHEN IFNULL(swc.covered_swc, 0) = IFNULL(swc.total_swc, 0) THEN 'Linked to all required children'
          ELSE 'Linked to some children but not'
        END AS child_presence_for_each_swc,

        -- Requirement Validation Pass Rate Rollup (Board 4 & Req_ADAS.txt lines 805-821)
        CASE
          WHEN LOWER(TRIM(rb.Req_Status)) LIKE '%rejected%' THEN 'Rejected'
          WHEN IFNULL(tc_agg.count_tc, 0) = 0 THEN 'Not covered'
          ELSE COALESCE(rbs.overall_status, rts.fallback_status, 'Not Executed')
        END AS req_last_results,

        CASE
          WHEN LOWER(TRIM(rb.Req_Status)) LIKE '%rejected%' THEN 'Rejected'
          WHEN rbs.bench_status_string IS NULL OR LOWER(TRIM(rbs.bench_status_string)) = 'null' THEN 'Not covered'
          ELSE rbs.bench_status_string
        END AS req_last_results_by_bench_type,

        -- Feature & Parent documentation flags (Req_ADAS.txt lines 909-921)
        IF(rb.req_feature_str IS NOT NULL AND TRIM(rb.req_feature_str) != '', 'Documented', 'Not documented') AS feature_documented,
        IF(IFNULL(rb.parent_req_count, 0) > 0, 'Yes', 'No') AS req_requirement_parent_exist,

        -- MySF Scope Flags (Req_ADAS.txt lines 634-714: MySF26.2, MySF27.2, MySF28.2, MySF27.2-only, MySF28.2-only)
        REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF26\.2($|, )') AS has_mysf_26_2,
        REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF27\.2($|, )') AS has_mysf_27_2,
        REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF28\.2($|, )') AS has_mysf_28_2,
        (
          REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF27\.2($|, )')
          AND NOT REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF26\.2($|, )')
        ) AS is_mysf_27_2_only,
        (
          REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF28\.2($|, )')
          AND NOT REGEXP_CONTAINS(IFNULL(rb.req_mysf_str, ''), r'(^|, )MySF26\.2($|, )')
        ) AS is_mysf_28_2_only

      FROM req_base AS rb
      LEFT JOIN req_tc_agg AS tc_agg
        ON rb.Req_Id = tc_agg.Req_Id
      LEFT JOIN child_counts AS cc
        ON rb.Req_Id = cc.Req_Id
      LEFT JOIN sfreq_swc_summary AS swc
        ON rb.Req_Id = swc.Req_Id
      LEFT JOIN req_bench_status AS rbs
        ON rb.Req_Id = rbs.Req_Id
      LEFT JOIN req_tc_status AS rts
        ON rb.Req_Id = rts.Req_Id
      LEFT JOIN req_ts_mysf_agg AS ts_m
        ON rb.Req_Id = ts_m.Req_Id
    ;;
  }

  # ---------------------------------------------------------------------------
  # 1. PRIMARY KEY
  # ---------------------------------------------------------------------------

  dimension: req_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.req_id ;;
    description: "Primary key (Req_Id) for 1:1 join with gold_dim_req."
  }

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS (Board 1, Board 2.1, and Board 4 Classifications)
  # ---------------------------------------------------------------------------

  dimension: req_engineering_level_normalized {
    label: "Engineering Level (Ordered V-Cycle)"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: string
    sql: ${TABLE}.req_engineering_level_normalized ;;
    description: "Normalized V-Cycle Engineering Level with numeric sort prefix (01-SG through 23-SURS) from Req_ADAS.txt."
  }

  dimension: req_linked_child {
    label: "Make Missing Childs Status (Req_linked_child)"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: string
    sql: ${TABLE}.req_linked_child ;;
    description: "Vertical decomposition status: 'No child required', 'Linked to a child', or 'Not linked to a child' (Board 1 Section 5)."
  }

  dimension: child_presence_for_each_swc {
    label: "Cross-System SWC Child Coverage (SFReq)"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: string
    sql: ${TABLE}.child_presence_for_each_swc ;;
    description: "For SFReq requirements, checks whether every SW Component is covered by at least one linked child requirement (Board 1 Section 6)."
  }

  dimension: count_child {
    label: "Linked Child Requirements Count"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: number
    sql: ${TABLE}.count_child ;;
    value_format_name: decimal_0
    description: "Number of distinct downstream child Requirements linked to this Requirement."
  }

  dimension: count_parent {
    label: "Linked Parent Requirements Count"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: number
    sql: ${TABLE}.count_parent ;;
    value_format_name: decimal_0
    description: "Number of distinct upstream parent Requirements linked to this Requirement."
  }

  dimension: req_requirement_parent_exist {
    label: "Has Parent Requirement (Yes/No)"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: string
    sql: ${TABLE}.req_requirement_parent_exist ;;
    description: "'Yes' when the Requirement has at least one upstream Parent Requirement ID, else 'No'."
  }

  dimension: total_swc_count {
    label: "Total Allocated SW Components"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: number
    sql: ${TABLE}.total_swc_count ;;
    value_format_name: decimal_0
    description: "Distinct count of SW Components allocated to an SFReq Requirement."
  }

  dimension: covered_swc_count {
    label: "Child-Covered SW Components"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: number
    sql: ${TABLE}.covered_swc_count ;;
    value_format_name: decimal_0
    description: "Distinct count of parent SW Components also present on linked child Requirements."
  }

  dimension: covered_status {
    label: "Horizontal TC Coverage Status (Covered_Status)"
    group_label: "2. Horizontal TC Coverage (Board 2.1)"
    type: string
    sql: ${TABLE}.covered_status ;;
    description: "Classifies each Requirement into 'Covered', 'Not covered', 'Supplier', or 'No test expected' based on ValidationMethods, Req_Status, Req_Supplier, and linked TC count (Board 2 Section 1)."
    html:
      {% if value == 'Covered' %}
        <span style="background-color:#e6f4ea; color:#137333; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Not covered' %}
        <span style="background-color:#fce8e6; color:#c5221f; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% elsif value == 'Supplier' %}
        <span style="background-color:#e8f0fe; color:#1967d2; padding:2px 8px; border-radius:12px; font-weight:600;">{{ rendered_value }}</span>
      {% else %}
        <span style="background-color:#f1f3f4; color:#5f6368; padding:2px 8px; border-radius:12px;">{{ rendered_value }}</span>
      {% endif %} ;;
  }

  dimension: is_test_expected {
    label: "Is Test Expected"
    group_label: "2. Horizontal TC Coverage (Board 2.1)"
    type: yesno
    sql: ${TABLE}.is_test_expected ;;
    description: "True when Req_ValidationMethods is null, empty, or contains 'test'."
  }

  dimension: count_tc {
    label: "Linked Test Cases Count (count_TC)"
    group_label: "2. Horizontal TC Coverage (Board 2.1)"
    type: number
    sql: ${TABLE}.count_tc ;;
    value_format_name: decimal_0
    description: "Number of distinct Test Cases linked to this Requirement."
  }

  dimension: aggregated_tc_id {
    label: "Aggregated Linked TC IDs"
    group_label: "2. Horizontal TC Coverage (Board 2.1)"
    type: string
    sql: ${TABLE}.aggregated_tc_id ;;
    description: "Comma-separated list of distinct Test Case IDs verifying this Requirement."
  }

  dimension: feature_documented {
    label: "Feature Documented Status"
    group_label: "2. Horizontal TC Coverage (Board 2.1)"
    type: string
    sql: ${TABLE}.feature_documented ;;
    description: "'Documented' when Req_Feature_CBId is non-empty, else 'Not documented'."
  }

  dimension: req_last_results {
    label: "Requirement Validation Result (Req_last_results)"
    group_label: "3. Requirement Pass Rate (Board 4)"
    type: string
    sql: ${TABLE}.req_last_results ;;
    description: "Consolidated Requirement validation status across latest Test Runs per TC & Bench: 'Passed', 'Failed', 'Ongoing', 'Not Executed', 'Not covered', or 'Rejected' (Board 4)."
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

  dimension: req_last_results_by_bench_type {
    label: "Requirement Validation Result by Bench (String)"
    group_label: "3. Requirement Pass Rate (Board 4)"
    type: string
    sql: ${TABLE}.req_last_results_by_bench_type ;;
    description: "Concatenated per-bench validation statuses (e.g., 'HIL:Passed, VHL:Failed') or 'Not covered' / 'Rejected' (Board 4)."
  }

  dimension: ts_mysf {
    label: "Aggregated Test Set MySF (TS_MySF)"
    group_label: "4. MySF Scope & Variants"
    type: string
    sql: ${TABLE}.ts_mysf ;;
    description: "Distinct Test Set MySF values aggregated across Test Sets executing this Requirement."
  }

  dimension: has_mysf_26_2 {
    label: "In MySF26.2 Scope"
    group_label: "4. MySF Scope & Variants"
    type: yesno
    sql: ${TABLE}.has_mysf_26_2 ;;
    description: "True when the Requirement is in MySF26.2 scope."
  }

  dimension: has_mysf_27_2 {
    label: "In MySF27.2 Scope"
    group_label: "4. MySF Scope & Variants"
    type: yesno
    sql: ${TABLE}.has_mysf_27_2 ;;
    description: "True when the Requirement is in MySF27.2 scope."
  }

  dimension: has_mysf_28_2 {
    label: "In MySF28.2 Scope"
    group_label: "4. MySF Scope & Variants"
    type: yesno
    sql: ${TABLE}.has_mysf_28_2 ;;
    description: "True when the Requirement is in MySF28.2 scope."
  }

  dimension: is_mysf_27_2_only {
    label: "Is MySF27.2-only (Delta vs MySF26.2)"
    group_label: "4. MySF Scope & Variants"
    type: yesno
    sql: ${TABLE}.is_mysf_27_2_only ;;
    description: "True when the Requirement belongs to MySF27.2 and NOT MySF26.2 (Req_ADAS.txt MySF27.2-only rule)."
  }

  dimension: is_mysf_28_2_only {
    label: "Is MySF28.2-only (Delta vs MySF26.2)"
    group_label: "4. MySF Scope & Variants"
    type: yesno
    sql: ${TABLE}.is_mysf_28_2_only ;;
    description: "True when the Requirement belongs to MySF28.2 and NOT MySF26.2 (Req_ADAS.txt MySF28.2-only rule)."
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Boards 1, 2.1, and 4 KPIs)
  # ---------------------------------------------------------------------------

  measure: count_requirements_covered {
    label: "Covered Requirements (Covered_Status = Covered)"
    group_label: "Board 2.1 - Horizontal TC Coverage Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [covered_status: "Covered"]
    value_format_name: decimal_0
    description: "Distinct Requirements where Covered_Status = 'Covered' (test-expected, count_TC > 0, and status != Draft)."
  }

  measure: count_requirements_not_covered {
    label: "Not Covered Requirements (Covered_Status = Not covered)"
    group_label: "Board 2.1 - Horizontal TC Coverage Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [covered_status: "Not covered"]
    value_format_name: decimal_0
    description: "Distinct Requirements where Covered_Status = 'Not covered'."
  }

  measure: count_requirements_supplier {
    label: "Supplier Requirements (Covered_Status = Supplier)"
    group_label: "Board 2.1 - Horizontal TC Coverage Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [covered_status: "Supplier"]
    value_format_name: decimal_0
    description: "Distinct Requirements where Covered_Status = 'Supplier' (non-AST supplier with 0 internal TCs)."
  }

  measure: count_requirements_no_test_expected {
    label: "No Test Expected Requirements"
    group_label: "Board 2.1 - Horizontal TC Coverage Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [covered_status: "No test expected"]
    value_format_name: decimal_0
    description: "Distinct Requirements where Covered_Status = 'No test expected'."
  }

  measure: count_test_expected_requirements {
    label: "Test-Expected Requirements"
    group_label: "Board 2.1 - Horizontal TC Coverage Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [is_test_expected: "yes"]
    value_format_name: decimal_0
    description: "Distinct Requirements where validation method expects testing."
  }

  measure: horizontal_tc_coverage_rate {
    label: "Horizontal TC Coverage Rate (Covered / Internal Test-Expected)"
    group_label: "Board 2.1 - Horizontal TC Coverage Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_requirements_covered}, NULLIF(${count_requirements_covered} + ${count_requirements_not_covered}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of internal test-expected Requirements (Covered + Not covered) that are Covered by Test Cases."
  }

  measure: count_req_linked_to_child {
    label: "Requirements Linked to Child"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_linked_child: "Linked to a child"]
    value_format_name: decimal_0
    description: "Distinct Requirements with at least one linked child Requirement."
  }

  measure: count_req_missing_child {
    label: "Requirements Missing Child (Not linked to a child)"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_linked_child: "Not linked to a child"]
    value_format_name: decimal_0
    description: "Distinct Requirements requiring child decomposition that are not linked to any child Requirement."
  }

  measure: count_req_no_child_required {
    label: "Requirements No Child Required"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_linked_child: "No child required"]
    value_format_name: decimal_0
    description: "Distinct Requirements where Req_Child_Required = 'No'."
  }

  measure: vertical_child_coverage_rate {
    label: "Vertical Child Decomposition Rate (%)"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_req_linked_to_child}, NULLIF(${count_req_linked_to_child} + ${count_req_missing_child}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of child-required Requirements that are linked to at least one child Requirement."
  }

  measure: count_sfreq_all_swc_covered {
    label: "SFReq Linked to All Required Children (SWC)"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [child_presence_for_each_swc: "Linked to all required children"]
    value_format_name: decimal_0
    description: "Distinct SFReq Requirements where every allocated SW Component is covered by a child Requirement."
  }

  measure: count_sfreq_partial_swc_covered {
    label: "SFReq Linked to Some Children Only (SWC)"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [child_presence_for_each_swc: "Linked to some children but not"]
    value_format_name: decimal_0
    description: "Distinct SFReq Requirements where only part of the allocated SW Components are covered by children."
  }

  measure: count_req_validation_passed {
    label: "Passed Requirements (Req_last_results = Passed)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_last_results: "Passed"]
    value_format_name: decimal_0
    description: "Distinct Requirements where all linked Test Cases passed on their latest execution."
  }

  measure: count_req_validation_failed {
    label: "Failed Requirements (Req_last_results = Failed)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_last_results: "Failed"]
    value_format_name: decimal_0
    description: "Distinct Requirements where at least one linked Test Case failed on its latest execution."
  }

  measure: count_req_validation_ongoing {
    label: "Ongoing Requirements (Req_last_results = Ongoing)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_last_results: "Ongoing"]
    value_format_name: decimal_0
    description: "Distinct Requirements with mixed Passed and Not Executed/Blocked latest Test Case results."
  }

  measure: count_req_validation_not_executed {
    label: "Not Executed Requirements (Req_last_results = Not Executed)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_last_results: "Not Executed"]
    value_format_name: decimal_0
    description: "Distinct Requirements covered by Test Cases that have not yet been executed."
  }

  measure: count_req_validation_not_covered {
    label: "Not Covered Requirements (Req_last_results = Not covered)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_last_results: "Not covered"]
    value_format_name: decimal_0
    description: "Distinct Requirements with no linked Test Cases."
  }

  measure: count_req_validation_rejected {
    label: "Rejected Requirements (Req_last_results = Rejected)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [req_last_results: "Rejected"]
    value_format_name: decimal_0
    description: "Distinct Requirements with Rejected status."
  }

  dimension: is_sfreq {
    label: "Is SFReq (System Functional Requirement)"
    group_label: "1. Vertical Traceability & Hierarchy"
    type: yesno
    sql: ${req_engineering_level_normalized} = '13-SFREQ' ;;
    description: "True when the Requirement is a System Functional Requirement (13-SFREQ)."
  }

  measure: count_req_mysf_26_2 {
    label: "Requirements in MySF26.2"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [has_mysf_26_2: "yes"]
    value_format_name: decimal_0
    description: "Distinct Requirements in MySF26.2 scope."
  }

  measure: count_req_mysf_27_2_only {
    label: "Requirements in MySF27.2-only (Delta vs MySF26.2)"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [is_mysf_27_2_only: "yes"]
    value_format_name: decimal_0
    description: "Distinct Requirements in MySF27.2 scope that are not in MySF26.2."
  }

  measure: count_req_mysf_28_2_only {
    label: "Requirements in MySF28.2-only (Delta vs MySF26.2)"
    group_label: "Board 1 - Vertical Traceability Metrics"
    type: count_distinct
    sql: ${req_id} ;;
    filters: [is_mysf_28_2_only: "yes"]
    value_format_name: decimal_0
    description: "Distinct Requirements in MySF28.2 scope that are not in MySF26.2."
  }

  measure: requirement_validation_pass_rate {
    label: "Requirement Validation Pass Rate (%)"
    group_label: "Board 4 - Requirement Pass Rate Metrics"
    type: number
    sql: SAFE_DIVIDE(${count_req_validation_passed}, NULLIF(${count_req_validation_passed} + ${count_req_validation_failed} + ${count_req_validation_ongoing}, 0)) ;;
    value_format_name: percent_1
    description: "Percentage of actively validated Requirements (Passed + Failed + Ongoing) that are fully Passed (Board 4)."
  }
}
