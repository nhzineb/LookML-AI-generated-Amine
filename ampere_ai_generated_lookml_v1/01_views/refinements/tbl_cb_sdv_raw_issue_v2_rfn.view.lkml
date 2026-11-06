# -------------------------------------------------------------------------
# LookML Refinement View: +tbl_cb_sdv_raw_issue_v2 (Issue Business Logic & Metrics)
# Physical Table: TBL_CB_SDV_Raw_Issue_V2 (Issue_View in Mermaid)
# -------------------------------------------------------------------------
include: "/ampere_ai_generated_lookml_v1/01_views/sources/tbl_cb_sdv_raw_issue_v2.view.lkml"

view: +tbl_cb_sdv_raw_issue_v2 {
  label: "Issue / Defect (TBL_CB_SDV_Raw_Issue_V2)"

  # =======================================================================
  # 1. REFINED PRIMARY KEY & CORE ATTRIBUTES
  # =======================================================================

  dimension: issue_id {
    label: "[Issue ID]"
    description: "Unique Jira Issue key or identifier (TBL_CB_SDV_Raw_Issue_V2.Issue_Id)"
  }

  dimension: summary {
    label: "Issue Summary (Raw)"
    description: "Short summary title of the Issue (TBL_CB_SDV_Raw_Issue_V2.Summary)"
  }

  dimension: issue_status {
    label: "Issue Status (Raw)"
    description: "Current workflow status of the Issue (TBL_CB_SDV_Raw_Issue_V2.Issue_Status)"
  }

  dimension: issue_resolution {
    label: "Issue Resolution (Raw)"
    description: "Resolution outcome of the Issue (TBL_CB_SDV_Raw_Issue_V2.Issue_Resolution)"
  }

  dimension: id {
    label: "Issue ID"
    description: "Unique identifier of the Issue / Defect mapped from TBL_CB_SDV_Raw_Issue_V2.Issue_Id"
    type: string
    sql: ${issue_id} ;;
    link: {
      label: "Open Issue #{{ value }} in Codebeamer"
      url: "@{codebeamer_base_url}/item/{{ value }}"
    }
  }

  dimension: name {
    label: "Issue Summary"
    description: "Summary title of the Issue / Defect mapped from TBL_CB_SDV_Raw_Issue_V2.Summary"
    type: string
    sql: ${summary} ;;
  }

  dimension: status {
    label: "Issue Status"
    description: "Lifecycle status of the Issue / Defect mapped from TBL_CB_SDV_Raw_Issue_V2.Issue_Status"
    type: string
    sql: ${issue_status} ;;
    drill_fields: [resolution, id, name]
  }

  dimension: resolution {
    label: "Issue Resolution"
    description: "Resolution outcome of the Issue / Defect mapped from TBL_CB_SDV_Raw_Issue_V2.Issue_Resolution"
    type: string
    sql: ${issue_resolution} ;;
  }

  # =======================================================================
  # 2. DERIVED BUSINESS DIMENSIONS
  # =======================================================================

  dimension: is_open_issue {
    group_label: "Issue Lifecycle Flags"
    label: "Is Open Issue"
    description: "True when the Issue is still open/active (not Closed, Resolved, Done, Verified, Cancelled, or Rejected)"
    type: yesno
    sql: COALESCE(UPPER(TRIM(${issue_status})), 'OPEN') NOT IN ('CLOSED', 'RESOLVED', 'DONE', 'REJECTED', 'CANCELLED', 'VERIFIED') ;;
  }

  dimension: is_resolved_or_closed {
    group_label: "Issue Lifecycle Flags"
    label: "Is Resolved / Closed"
    description: "True when the Issue is Resolved, Closed, Verified, or Done (ready for TC retest on Board 2.5)"
    type: yesno
    sql: UPPER(TRIM(${issue_status})) IN ('CLOSED', 'RESOLVED', 'DONE', 'VERIFIED') ;;
  }

  dimension: has_jira_derogation_label {
    group_label: "Issue Lifecycle Flags"
    label: "Has Jira Derogation (r'derogat')"
    description: "True when Issue Labels, Summary, or Resolution matches regex r'derogat' (Board 2 Section 5)"
    type: yesno
    sql: REGEXP_CONTAINS(LOWER(CONCAT(IFNULL(${labels}, ''), ' ', IFNULL(${summary}, ''), ' ', IFNULL(${issue_resolution}, ''))), r'derogat') ;;
  }

  dimension: resolution_duration_days {
    group_label: "Issue Lifecycle Flags"
    label: "Resolution Duration (Days)"
    description: "Number of days between Issue creation and last update date (or current date if still open)"
    type: number
    sql: DATE_DIFF(IF(${is_resolved_or_closed}, COALESCE(${updated_date}, CURRENT_DATE()), CURRENT_DATE()), ${created_date}, DAY) ;;
    value_format_name: decimal_0
  }

  # =======================================================================
  # 3. ZERO-FANOUT ARRAY FILTERS (EXISTS UNNEST)
  # =======================================================================

  filter: labels_any {
    type: string
    group_label: "Issue Lifecycle Flags"
    label: "Filter: Issue Label (Array Item)"
    description: "Zero-fanout correlated EXISTS filter on Jira Issue Labels array."
    sql: EXISTS (SELECT 1 FROM UNNEST(${labels_list}) AS x WHERE {% condition labels_any %} x {% endcondition %}) ;;
  }

  filter: fix_versions_any {
    type: string
    group_label: "Issue Lifecycle Flags"
    label: "Filter: Issue Fix Version (Array Item)"
    description: "Zero-fanout correlated EXISTS filter on Jira Issue Fix_Versions array."
    sql: EXISTS (SELECT 1 FROM UNNEST(${fix_versions_list}) AS x WHERE {% condition fix_versions_any %} x {% endcondition %}) ;;
  }

  # =======================================================================
  # 4. MEASURES (KPIs)
  # =======================================================================

  measure: count_issues {
    label: "Total Issues"
    description: "Distinct count of Issues / Defects (TBL_CB_SDV_Raw_Issue_V2)"
    type: count_distinct
    sql: ${issue_id} ;;
    value_format_name: decimal_0
    drill_fields: [issue_default_drill*]
  }

  measure: count_open_issues {
    group_label: "Issue Resolution Metrics"
    label: "Open Issues"
    description: "Distinct count of currently Open Issues / Defects"
    type: count_distinct
    sql: ${issue_id} ;;
    filters: [is_open_issue: "yes"]
    value_format_name: decimal_0
    drill_fields: [issue_default_drill*]
  }

  measure: count_resolved_issues {
    group_label: "Issue Resolution Metrics"
    label: "Resolved / Closed Issues"
    description: "Distinct count of Resolved or Closed Issues / Defects"
    type: count_distinct
    sql: ${issue_id} ;;
    filters: [is_resolved_or_closed: "yes"]
    value_format_name: decimal_0
    drill_fields: [issue_default_drill*]
  }

  measure: count_derogation_issues {
    group_label: "Issue Resolution Metrics"
    label: "Issues with Jira Derogation"
    description: "Distinct count of Issues carrying a Jira derogation label or summary"
    type: count_distinct
    sql: ${issue_id} ;;
    filters: [has_jira_derogation_label: "yes"]
    value_format_name: decimal_0
    drill_fields: [issue_default_drill*]
  }

  measure: issue_resolution_rate {
    group_label: "Issue Resolution Metrics"
    label: "Issue Resolution Rate (%)"
    description: "Percentage of total Issues that are Resolved or Closed"
    type: number
    sql: SAFE_DIVIDE(${count_resolved_issues}, ${count_issues}) ;;
    value_format_name: percent_1
    drill_fields: [issue_default_drill*]
  }

  measure: avg_resolution_duration_days {
    group_label: "Issue Resolution Metrics"
    label: "Average Resolution Time (Days)"
    description: "Average number of days to close an Issue"
    type: average
    sql: ${resolution_duration_days} ;;
    filters: [is_resolved_or_closed: "yes"]
    value_format_name: decimal_1
  }

  # =======================================================================
  # 5. FIELD SETS
  # =======================================================================

  set: issue_default_drill {
    fields: [
      id,
      name,
      status,
      resolution,
      priority,
      labels,
      fix_versions,
      project_name,
      project_key,
      created_date,
      updated_date,
      resolution_duration_days
    ]
  }
}
