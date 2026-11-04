# =============================================================================
# DERIVED TABLE VIEW: dt_ts_release_execution
# Grain: TC_Id x TS_Id x Release_Type x TS_Release x BL x TS_Bench_Type x Req_MySF
# Purpose: Implements Board 3 (TS Pass Rate by Bench Type & SW Version: SWE.6,
#          C3V, HIL BL6/BL7, EIPF BL6/BL7, VHL BL6/BL7) by unnesting ECU release
#          arrays (PCU, PIU, IVC, CDC, OTHER), extracting Baseline (BL) and
#          BL_FAMILY (BL6, BL7, plus virtual combined BL6_BL7 rows), and
#          selecting the latest execution verdict per release and per baseline.
# Provenance: SDV_Generic_KPI_dashboard_lookml_business_case_finale.docx (Board 3)
#             & TS_ADAS.txt
# =============================================================================

view: dt_ts_release_execution {
  label: "Test Set Pass Rate by Bench & SW Release (TS_ADAS)"

  derived_table: {
    sql:
      WITH
      base_runs AS (
        SELECT
          CAST(f.TC_Id AS STRING) AS TC_Id,
          f.TC_Id AS TC_Id_Int,
          f.TS_Id,
          f.TR_Id,
          COALESCE(tr.Completed_At, tr.Created) AS TR_RunDate,
          CASE
            WHEN UPPER(TRIM(tr.Result)) IN ('PASSED', 'PASS', 'OK') THEN 'Passed'
            WHEN UPPER(TRIM(tr.Result)) IN ('FAILED', 'FAIL', 'KO', 'NOK') THEN 'Failed'
            WHEN UPPER(TRIM(tr.Result)) IN ('BLOCKED', 'BLOCK') THEN 'Blocked'
            ELSE 'Not Executed'
          END AS TR_Result,
          COALESCE(ts.TS_Domain, tc.Domain) AS TS_Domain,
          COALESCE(f.TR_MySF, ARRAY_TO_STRING(r.Req_MySF, ', ')) AS Req_MySF,
          ARRAY_TO_STRING(ts.TS_MySF, ', ') AS TS_MySF,
          ts.TS_Type AS TS_Type,
          ARRAY_TO_STRING(tc.Validation_Teams, ', ') AS TC_Validation_Team,
          ARRAY_TO_STRING(r.Req_Regulation, ', ') AS Req_Regulation,
          r.Req_ASIL AS Req_ASIL,
          tc.Ownership AS TC_Execution_Organization_Arr,
          ARRAY_TO_STRING(tc.Ownership, ', ') AS TC_Execution_Organization,
          ARRAY_TO_STRING(ts.TS_Bench_Type, ', ') AS TS_Bench_Type,
          ARRAY_TO_STRING(tc.Feature_Id, ', ') AS TC_Feature,
          tc.Type AS TC_Type,
          ARRAY_TO_STRING(r.Req_Baseline, ', ') AS Req_Baseline,
          ARRAY_TO_STRING(ts.TS_Vehicle_Project, ', ') AS Vehicle_Project,
          tc.Name AS TC_Name,
          ts.TS_Baseline AS TS_Baseline_Fallback,
          ARRAY_TO_STRING(ts.TS_PCU_Releases, ', ') AS TS_PCU_Releases,
          ARRAY_TO_STRING(ts.TS_PIU_Releases, ', ') AS TS_PIU_Releases,
          ARRAY_TO_STRING(ts.TS_IVC_Releases, ', ') AS TS_IVC_Releases,
          ARRAY_TO_STRING(ts.TS_CDC_Releases, ', ') AS TS_CDC_Releases,
          ARRAY_TO_STRING(ts.TS_Other_Releases, ', ') AS TS_Other_Releases
        FROM `@{DATASET_NAME}.FACT_TC_TR_TS_REQ` AS f
        INNER JOIN `@{DATASET_NAME}.gold_dim_ts` AS ts
          ON f.TS_Id = ts.TS_Id
        LEFT JOIN `@{DATASET_NAME}.TBL_CB_SDV_Raw_TC_V2` AS tc
          ON f.TC_Id = tc.Id
        LEFT JOIN `@{DATASET_NAME}.TBL_CB_SDV_Raw_TR_V2` AS tr
          ON f.TR_Id = tr.Id
        LEFT JOIN `@{DATASET_NAME}.gold_dim_req` AS r
          ON f.Req_Id = r.Req_Id
        WHERE f.TC_Id IS NOT NULL
          AND f.TS_Id IS NOT NULL
      ),

      exploded_releases AS (
        SELECT
          b.TC_Id,
          b.TC_Id_Int,
          b.TS_Id,
          rel.release_type,
          TRIM(single_rel) AS TS_Release,
          COALESCE(
            REGEXP_EXTRACT(UPPER(TRIM(single_rel)), r'(BL[0-9]{1,2}(?:[._-][0-9]{1,2})?)'),
            REGEXP_EXTRACT(UPPER(IFNULL(rel.release_name, '')), r'(BL[0-9]{1,2}(?:[._-][0-9]{1,2})?)'),
            REGEXP_EXTRACT(UPPER(IFNULL(b.TS_Baseline_Fallback, '')), r'(BL[0-9]{1,2}(?:[._-][0-9]{1,2})?)'),
            b.TS_Baseline_Fallback
          ) AS BL,
          b.TS_PCU_Releases,
          b.TS_PIU_Releases,
          b.TS_IVC_Releases,
          b.TS_CDC_Releases,
          b.TS_Other_Releases,
          b.TR_Result,
          b.TR_RunDate,
          b.TS_Domain,
          b.Req_MySF,
          b.TS_MySF,
          b.TS_Type,
          b.TC_Validation_Team,
          b.Req_Regulation,
          b.Req_ASIL,
          b.TC_Execution_Organization,
          b.TS_Bench_Type,
          b.TC_Feature,
          b.TC_Type,
          b.Req_Baseline,
          b.Vehicle_Project,
          b.TC_Name
        FROM base_runs AS b
        CROSS JOIN UNNEST([
          STRUCT('PCU' AS release_type, b.TS_PCU_Releases AS release_name),
          STRUCT('PIU' AS release_type, b.TS_PIU_Releases AS release_name),
          STRUCT('IVC' AS release_type, b.TS_IVC_Releases AS release_name),
          STRUCT('CDC' AS release_type, b.TS_CDC_Releases AS release_name),
          STRUCT('OTHER' AS release_type, b.TS_Other_Releases AS release_name)
        ]) AS rel
        CROSS JOIN UNNEST(SPLIT(IFNULL(rel.release_name, ''), ',')) AS single_rel
        WHERE rel.release_name IS NOT NULL
          AND TRIM(rel.release_name) != ''
          AND TRIM(single_rel) != ''
      ),

      -- Latest execution per (TC_Id, release_type, TS_Release, BL, Req_MySF, TC_Feature, TS_Bench_Type)
      per_release AS (
        SELECT
          e.*
        FROM exploded_releases AS e
        WHERE e.BL IS NOT NULL
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY
            e.TC_Id,
            e.release_type,
            e.TS_Release,
            e.BL,
            IFNULL(e.Req_MySF, ''),
            IFNULL(e.TC_Feature, ''),
            IFNULL(e.TS_Bench_Type, '')
          ORDER BY
            e.TR_RunDate DESC NULLS LAST,
            e.TS_Id DESC
        ) = 1
      ),

      -- Latest result per BL prioritizing executed statuses (PASSED/FAILED/BLOCKED > NOT EXECUTED)
      per_bl AS (
        SELECT
          TC_Id,
          BL,
          IFNULL(Req_MySF, '') AS Req_MySF_Key,
          IFNULL(TC_Feature, '') AS TC_Feature_Key,
          IFNULL(TS_Bench_Type, '') AS TS_Bench_Type_Key,
          TR_Result AS Last_Result_on_BL
        FROM per_release
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY
            TC_Id,
            BL,
            IFNULL(Req_MySF, ''),
            IFNULL(TC_Feature, ''),
            IFNULL(TS_Bench_Type, '')
          ORDER BY
            CASE WHEN UPPER(TR_Result) IN ('PASSED', 'FAILED', 'BLOCKED') THEN 1 ELSE 0 END DESC,
            TR_RunDate DESC NULLS LAST,
            TS_Id DESC
        ) = 1
      ),

      -- Identify BL6 and BL7 families (TS_ADAS.txt lines 395-453)
      bl_family_source AS (
        SELECT
          pr.*,
          CASE
            WHEN REGEXP_CONTAINS(UPPER(IFNULL(pr.BL, '')), r'\bBL0*6(?:[._-]0+)?\b') THEN 'BL6'
            WHEN REGEXP_CONTAINS(UPPER(IFNULL(pr.BL, '')), r'\bBL0*7(?:[._-][0-9]+)?\b') THEN 'BL7'
            ELSE NULL
          END AS BL_FAMILY
        FROM per_release AS pr
      ),

      last_run_per_family AS (
        SELECT
          bfs.*
        FROM bl_family_source AS bfs
        WHERE bfs.BL_FAMILY IN ('BL6', 'BL7')
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY
            bfs.TC_Id,
            bfs.BL_FAMILY,
            IFNULL(bfs.Req_MySF, ''),
            IFNULL(bfs.TC_Feature, ''),
            IFNULL(bfs.TS_Bench_Type, '')
          ORDER BY
            CASE WHEN UPPER(bfs.TR_Result) IN ('PASSED', 'FAILED', 'BLOCKED') THEN 1 ELSE 0 END DESC,
            bfs.TR_RunDate DESC NULLS LAST,
            bfs.TS_Id DESC
        ) = 1
      ),

      -- Virtual BL6_BL7 rows: pick the winning family between BL6 and BL7 per (TC_Id, Req_MySF, TC_Feature, TS_Bench_Type)
      virtual_bl6_bl7 AS (
        SELECT
          lrf.* EXCEPT (BL, BL_FAMILY),
          'BL6_BL7' AS BL,
          'BL6_BL7' AS BL_FAMILY
        FROM last_run_per_family AS lrf
        QUALIFY ROW_NUMBER() OVER (
          PARTITION BY
            lrf.TC_Id,
            IFNULL(lrf.Req_MySF, ''),
            IFNULL(lrf.TC_Feature, ''),
            IFNULL(lrf.TS_Bench_Type, '')
          ORDER BY
            CASE WHEN UPPER(lrf.TR_Result) IN ('PASSED', 'FAILED', 'BLOCKED') THEN 1 ELSE 0 END DESC,
            lrf.TR_RunDate DESC NULLS LAST,
            CASE WHEN lrf.BL_FAMILY = 'BL7' THEN 2 ELSE 1 END DESC
        ) = 1
      ),

      real_rows AS (
        SELECT
          pr.TC_Id,
          pr.TC_Id_Int,
          pr.TS_Id,
          pr.TS_PCU_Releases,
          pr.TS_PIU_Releases,
          pr.TS_IVC_Releases,
          pr.TS_CDC_Releases,
          pr.TS_Other_Releases,
          pr.release_type AS Release_Type,
          pr.TS_Release,
          pr.BL,
          CASE
            WHEN REGEXP_CONTAINS(UPPER(IFNULL(pr.BL, '')), r'\bBL0*6(?:[._-]0+)?\b') THEN 'BL6'
            WHEN REGEXP_CONTAINS(UPPER(IFNULL(pr.BL, '')), r'\bBL0*7(?:[._-][0-9]+)?\b') THEN 'BL7'
            ELSE 'OTHER'
          END AS BL_Family,
          FALSE AS is_virtual_bl6_bl7,
          pr.TR_Result AS Last_Result_on_Release,
          COALESCE(pb.Last_Result_on_BL, pr.TR_Result) AS Last_Result_on_BL,
          pr.TS_Domain,
          pr.Req_MySF,
          pr.TS_MySF,
          pr.TS_Type,
          pr.TC_Validation_Team,
          pr.Req_Regulation,
          pr.Req_ASIL,
          pr.TC_Execution_Organization,
          pr.TS_Bench_Type,
          pr.TC_Feature AS Features,
          pr.TC_Type,
          pr.TR_RunDate AS Last_RunDate,
          pr.Req_Baseline,
          pr.Vehicle_Project,
          pr.TC_Name
        FROM per_release AS pr
        LEFT JOIN per_bl AS pb
          ON pr.TC_Id = pb.TC_Id
         AND pr.BL = pb.BL
         AND IFNULL(pr.Req_MySF, '') = pb.Req_MySF_Key
         AND IFNULL(pr.TC_Feature, '') = pb.TC_Feature_Key
         AND IFNULL(pr.TS_Bench_Type, '') = pb.TS_Bench_Type_Key
      ),

      virtual_rows AS (
        SELECT
          v.TC_Id,
          v.TC_Id_Int,
          v.TS_Id,
          v.TS_PCU_Releases,
          v.TS_PIU_Releases,
          v.TS_IVC_Releases,
          v.TS_CDC_Releases,
          v.TS_Other_Releases,
          v.release_type AS Release_Type,
          v.TS_Release,
          v.BL,
          v.BL_FAMILY AS BL_Family,
          TRUE AS is_virtual_bl6_bl7,
          v.TR_Result AS Last_Result_on_Release,
          v.TR_Result AS Last_Result_on_BL,
          v.TS_Domain,
          v.Req_MySF,
          v.TS_MySF,
          v.TS_Type,
          v.TC_Validation_Team,
          v.Req_Regulation,
          v.Req_ASIL,
          v.TC_Execution_Organization,
          v.TS_Bench_Type,
          v.TC_Feature AS Features,
          v.TC_Type,
          v.TR_RunDate AS Last_RunDate,
          v.Req_Baseline,
          v.Vehicle_Project,
          v.TC_Name
        FROM virtual_bl6_bl7 AS v
      ),

      combined_rows AS (
        SELECT * FROM real_rows
        UNION ALL
        SELECT * FROM virtual_rows
      )

      SELECT
        TO_HEX(MD5(CONCAT(
          IFNULL(TC_Id, ''), '|',
          IFNULL(CAST(TS_Id AS STRING), ''), '|',
          IFNULL(Release_Type, ''), '|',
          IFNULL(TS_Release, ''), '|',
          IFNULL(BL, ''), '|',
          IFNULL(Req_MySF, ''), '|',
          IFNULL(Features, ''), '|',
          IFNULL(TS_Bench_Type, '')
        ))) AS ts_release_exec_pk,
        c.*
      FROM combined_rows AS c
    ;;
  }

  # ---------------------------------------------------------------------------
  # 1. PRIMARY KEY & FOREIGN KEYS
  # ---------------------------------------------------------------------------

  dimension: ts_release_exec_pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.ts_release_exec_pk ;;
    description: "Deterministic hash primary key for dt_ts_release_execution."
  }

  dimension: tc_id_int {
    hidden: yes
    type: number
    sql: ${TABLE}.TC_Id_Int ;;
    description: "Numeric Test Case ID for joining to tbl_cb_sdv_raw_tc_v2."
  }

  dimension: tc_id {
    label: "[Test Case ID]"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TC_Id ;;
    description: "Test Case ID string (TS_ADAS.TC_Id)."
    link: {
      label: "Open Test Case #{{ value }} in Codebeamer"
      url: "https://codebeamer.al1.ope.gcp.renault.com/issue/{{ value }}"
    }
  }

  dimension: ts_id {
    label: "[Test Set ID]"
    group_label: "1. Identity & Scope"
    type: number
    sql: ${TABLE}.TS_Id ;;
    value_format_name: id
    description: "Test Set ID (TS_ADAS.TS_Id)."
  }

  dimension: tc_name {
    label: "Test Case Name"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TC_Name ;;
    description: "Name of the Test Case."
  }

  # ---------------------------------------------------------------------------
  # 2. ECU RELEASES & BASELINE FAMILIES (Board 3)
  # ---------------------------------------------------------------------------

  dimension: release_type {
    label: "ECU Release Type (PCU/PIU/IVC/CDC/OTHER)"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.Release_Type ;;
    description: "ECU software release family: 'PCU', 'PIU', 'IVC', 'CDC', or 'OTHER' (Board 3)."
  }

  dimension: ts_release {
    label: "SW Release Version (TS_Release)"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.TS_Release ;;
    description: "Individual software release identifier extracted from the Test Set release arrays."
  }

  dimension: bl {
    label: "Extracted Baseline (BL / BL6_BL7)"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.BL ;;
    description: "Normalized Baseline token (e.g., BL6, BL7, BL6.1) or virtual combined 'BL6_BL7' row (Board 3)."
  }

  dimension: bl_family {
    label: "Baseline Family (BL6 / BL7 / BL6_BL7)"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.BL_Family ;;
    description: "High-level Baseline family: 'BL6', 'BL7', 'BL6_BL7', or 'OTHER'."
  }

  dimension: is_virtual_bl6_bl7 {
    label: "Is Virtual Combined BL6_BL7 Row"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: yesno
    sql: ${TABLE}.is_virtual_bl6_bl7 ;;
    description: "True for synthetic 'BL6_BL7' combined baseline rows, False for real individual BL rows."
  }

  dimension: ts_pcu_releases {
    label: "TS PCU Releases"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.TS_PCU_Releases ;;
    description: "PCU releases on the Test Set."
  }

  dimension: ts_piu_releases {
    label: "TS PIU Releases"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.TS_PIU_Releases ;;
    description: "PIU releases on the Test Set."
  }

  dimension: ts_ivc_releases {
    label: "TS IVC Releases"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.TS_IVC_Releases ;;
    description: "IVC releases on the Test Set."
  }

  dimension: ts_cdc_releases {
    label: "TS CDC Releases"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.TS_CDC_Releases ;;
    description: "CDC releases on the Test Set."
  }

  dimension: ts_other_releases {
    label: "TS Other Releases"
    group_label: "2. SW Releases & Baselines (Board 3)"
    type: string
    sql: ${TABLE}.TS_Other_Releases ;;
    description: "Other ECU releases on the Test Set."
  }

  # ---------------------------------------------------------------------------
  # 3. EXECUTION VERDICTS & BENCH SCOPE FLAGS (Board 3 Sub-Views 1..5)
  # ---------------------------------------------------------------------------

  dimension: last_result_on_release {
    label: "Last Result on SW Release"
    group_label: "3. Execution Results & Bench Scope"
    type: string
    sql: ${TABLE}.Last_Result_on_Release ;;
    description: "Latest Test Run result for the Test Case on the specific SW Release ('Passed', 'Failed', 'Blocked', 'Not Executed')."
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

  dimension: last_result_on_bl {
    label: "Last Result on Baseline (BL)"
    group_label: "3. Execution Results & Bench Scope"
    type: string
    sql: ${TABLE}.Last_Result_on_BL ;;
    description: "Latest Test Run result for the Test Case on the Baseline (BL), prioritizing executed verdicts (Passed/Failed/Blocked) over Not Executed."
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

  dimension_group: last_run {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Last_RunDate ;;
    description: "Execution timestamp of the selected Test Run."
  }

  dimension: ts_bench_type {
    label: "Test Set Bench Type"
    group_label: "3. Execution Results & Bench Scope"
    type: string
    sql: ${TABLE}.TS_Bench_Type ;;
    description: "Bench Type of the Test Set (e.g., HIL, EIPF, VHL, SIL)."
  }

  dimension: is_hil_bench {
    label: "Is HIL Bench (Board 3.3)"
    group_label: "3. Execution Results & Bench Scope"
    type: yesno
    sql: UPPER(IFNULL(${ts_bench_type}, '')) LIKE '%HIL%' ;;
    description: "True when Test Set Bench Type contains HIL (Board 3 Section 3: TS Pass Rate HIL BL6/BL7)."
  }

  dimension: is_eipf_bench {
    label: "Is EIPF Bench (Board 3.4)"
    group_label: "3. Execution Results & Bench Scope"
    type: yesno
    sql: UPPER(IFNULL(${ts_bench_type}, '')) LIKE '%EIPF%' ;;
    description: "True when Test Set Bench Type contains EIPF (Board 3 Section 4: TS Pass Rate EIPF BL6/BL7)."
  }

  dimension: is_vhl_bench {
    label: "Is VHL / Vehicle Bench (Board 3.5)"
    group_label: "3. Execution Results & Bench Scope"
    type: yesno
    sql: UPPER(IFNULL(${ts_bench_type}, '')) LIKE '%VHL%' OR UPPER(IFNULL(${ts_bench_type}, '')) LIKE '%VEHICLE%' ;;
    description: "True when Test Set Bench Type contains VHL or Vehicle (Board 3 Section 5: TS Pass Rate VHL BL6/BL7)."
  }

  dimension: is_c3v_scope {
    label: "Is C3V Validation Scope (Board 3.2)"
    group_label: "3. Execution Results & Bench Scope"
    type: yesno
    sql: UPPER(IFNULL(${tc_validation_team}, '')) LIKE '%C3V%' OR UPPER(IFNULL(${tc_execution_organization}, '')) LIKE '%C3V%' OR UPPER(IFNULL(${ts_domain}, '')) LIKE '%C3V%' ;;
    description: "True when Validation Team, Execution Organization, or Domain is in C3V scope (Board 3 Section 2)."
  }

  dimension: is_swe6_scope {
    label: "Is SWE.6 Software Qualification Scope (Board 3.1)"
    group_label: "3. Execution Results & Bench Scope"
    type: yesno
    sql: UPPER(IFNULL(${ts_domain}, '')) LIKE '%SWE%' OR UPPER(IFNULL(${tc_validation_team}, '')) LIKE '%SWE%' OR UPPER(IFNULL(${ts_bench_type}, '')) LIKE '%SIL%' ;;
    description: "True when Test Set is in SWE.6 software qualification scope (Board 3 Section 1)."
  }

  dimension: ts_domain {
    label: "TS Domain"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TS_Domain ;;
    description: "Engineering domain of the Test Set."
  }

  dimension: req_mysf {
    label: "Requirement MySF"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.Req_MySF ;;
    description: "Requirement MySF scope."
  }

  dimension: ts_mysf {
    label: "Test Set MySF"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TS_MySF ;;
    description: "Test Set MySF scope."
  }

  dimension: ts_type {
    label: "Test Set Type"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TS_Type ;;
    description: "Test Set type (Generic, Automatic execution, Manual execution)."
  }

  dimension: tc_validation_team {
    label: "TC Validation Team"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TC_Validation_Team ;;
    description: "Validation Team owning the Test Case."
  }

  dimension: tc_execution_organization {
    label: "TC Execution Organization"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TC_Execution_Organization ;;
    description: "Organization executing the Test Case."
  }

  dimension: req_regulation {
    label: "Requirement Regulation"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.Req_Regulation ;;
    description: "Applicable Regulations."
  }

  dimension: req_asil {
    label: "Requirement ASIL"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.Req_ASIL ;;
    description: "Applicable ASIL safety level."
  }

  dimension: features {
    label: "Features"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.Features ;;
    description: "Feature identifiers linked to the Test Case."
  }

  dimension: tc_type {
    label: "TC Type"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.TC_Type ;;
    description: "Type classification of the Test Case."
  }

  dimension: req_baseline {
    label: "Requirement Baseline"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.Req_Baseline ;;
    description: "Requirement Baseline."
  }

  dimension: vehicle_project {
    label: "Vehicle Project"
    group_label: "1. Identity & Scope"
    type: string
    sql: ${TABLE}.Vehicle_Project ;;
    description: "Vehicle Project name."
  }

  # ---------------------------------------------------------------------------
  # 4. MEASURES (Board 3 Distinct TC Counts & Pass Rates)
  # ---------------------------------------------------------------------------

  measure: count_distinct_test_cases {
    label: "Total Distinct Test Cases"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: count_distinct
    sql: ${tc_id} ;;
    value_format_name: decimal_0
    description: "Distinct count of Test Cases (COUNT_DISTINCT(TC_Id)) in the selected Release/Baseline scope."
  }

  measure: count_passed_tc_on_release {
    label: "Passed TCs (On Release)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_release: "Passed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_Release = 'Passed'."
  }

  measure: count_failed_tc_on_release {
    label: "Failed TCs (On Release)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_release: "Failed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_Release = 'Failed'."
  }

  measure: count_blocked_tc_on_release {
    label: "Blocked TCs (On Release)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_release: "Blocked"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_Release = 'Blocked'."
  }

  measure: count_not_executed_tc_on_release {
    label: "Not Executed TCs (On Release)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_release: "Not Executed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_Release = 'Not Executed'."
  }

  measure: ts_release_pass_rate {
    label: "TS Release Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: number
    sql: SAFE_DIVIDE(${count_passed_tc_on_release}, NULLIF(${count_passed_tc_on_release} + ${count_failed_tc_on_release} + ${count_blocked_tc_on_release}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate across executed Test Cases on the SW Release: Passed / (Passed + Failed + Blocked)."
  }

  measure: count_passed_tc_on_bl {
    label: "Passed TCs (On Baseline BL)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Baseline BL)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_bl: "Passed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_BL = 'Passed'."
  }

  measure: count_failed_tc_on_bl {
    label: "Failed TCs (On Baseline BL)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Baseline BL)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_bl: "Failed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_BL = 'Failed'."
  }

  measure: count_blocked_tc_on_bl {
    label: "Blocked TCs (On Baseline BL)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Baseline BL)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_bl: "Blocked"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_BL = 'Blocked'."
  }

  measure: count_not_executed_tc_on_bl {
    label: "Not Executed TCs (On Baseline BL)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Baseline BL)"
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [last_result_on_bl: "Not Executed"]
    value_format_name: decimal_0
    description: "Distinct Test Cases with Last_Result_on_BL = 'Not Executed'."
  }

  measure: ts_bl_pass_rate {
    label: "TS Baseline (BL) Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Baseline BL)"
    type: number
    sql: SAFE_DIVIDE(${count_passed_tc_on_bl}, NULLIF(${count_passed_tc_on_bl} + ${count_failed_tc_on_bl} + ${count_blocked_tc_on_bl}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate across executed Test Cases on the Baseline (BL): Passed / (Passed + Failed + Blocked)."
  }

  measure: count_swe6_passed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_swe6_scope: "yes", last_result_on_release: "Passed"]
  }

  measure: count_swe6_executed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_swe6_scope: "yes", last_result_on_release: "Passed,Failed,Blocked"]
  }

  measure: swe6_pass_rate_on_release {
    label: "SWE.6 Validation Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: number
    sql: SAFE_DIVIDE(${count_swe6_passed_tc_on_release}, NULLIF(${count_swe6_executed_tc_on_release}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate of executed Test Cases on SW Releases within SWE.6 Validation Team scope (Board 3.1)."
  }

  measure: count_c3v_passed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_c3v_scope: "yes", last_result_on_release: "Passed"]
  }

  measure: count_c3v_executed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_c3v_scope: "yes", last_result_on_release: "Passed,Failed,Blocked"]
  }

  measure: c3v_pass_rate_on_release {
    label: "C3V Integration Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: number
    sql: SAFE_DIVIDE(${count_c3v_passed_tc_on_release}, NULLIF(${count_c3v_executed_tc_on_release}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate of executed Test Cases on SW Releases within C3V Integration Team scope (Board 3.2)."
  }

  measure: count_hil_passed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_hil_bench: "yes", last_result_on_release: "Passed"]
  }

  measure: count_hil_executed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_hil_bench: "yes", last_result_on_release: "Passed,Failed,Blocked"]
  }

  measure: hil_pass_rate_on_release {
    label: "HIL Bench Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: number
    sql: SAFE_DIVIDE(${count_hil_passed_tc_on_release}, NULLIF(${count_hil_executed_tc_on_release}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate of executed Test Cases on HIL Bench Test Sets across SW Releases (Board 3.3)."
  }

  measure: count_eipf_passed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_eipf_bench: "yes", last_result_on_release: "Passed"]
  }

  measure: count_eipf_executed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_eipf_bench: "yes", last_result_on_release: "Passed,Failed,Blocked"]
  }

  measure: eipf_pass_rate_on_release {
    label: "EIPF Bench Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: number
    sql: SAFE_DIVIDE(${count_eipf_passed_tc_on_release}, NULLIF(${count_eipf_executed_tc_on_release}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate of executed Test Cases on EIPF Bench Test Sets across SW Releases (Board 3.4)."
  }

  measure: count_vhl_passed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_vhl_bench: "yes", last_result_on_release: "Passed"]
  }

  measure: count_vhl_executed_tc_on_release {
    hidden: yes
    type: count_distinct
    sql: ${tc_id} ;;
    filters: [is_vhl_bench: "yes", last_result_on_release: "Passed,Failed,Blocked"]
  }

  measure: vhl_pass_rate_on_release {
    label: "VHL Bench Pass Rate (%)"
    group_label: "Board 3 - TS Pass Rate Metrics (By Release)"
    type: number
    sql: SAFE_DIVIDE(${count_vhl_passed_tc_on_release}, NULLIF(${count_vhl_executed_tc_on_release}, 0)) ;;
    value_format_name: percent_1
    description: "Pass rate of executed Test Cases on VHL Bench Test Sets across SW Releases (Board 3.5)."
  }
}
