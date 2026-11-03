# -------------------------------------------------------------------------
# LookML Refinement View: +tbl_cb_sdv_raw_issue_v2 (Issue Business Logic & Metrics)
# Physical Table: TBL_CB_SDV_Raw_Issue_V2 (Issue_View in Mermaid)
# -------------------------------------------------------------------------
include: "/01_views/sources/tbl_cb_sdv_raw_issue_v2.view.lkml"

view: +tbl_cb_sdv_raw_issue_v2 {
  label: "Issue / Defect (TBL_CB_SDV_Raw_Issue_V2)"

  # =======================================================================
  # 1. REFINED PRIMARY KEY & CORE ATTRIBUTES
  # =======================================================================

  dimension: id {
    label: "Issue ID"
    description: "Unique identifier of the Issue / Defect (TBL_CB_SDV_Raw_Issue_V2.Id)"
    value_format_name: id
    link: {
      label: "Open Issue #{{ value }} in Codebeamer"
      url: "@{codebeamer_base_url}/item/{{ value }}"
    }
  }

  dimension: name {
    label: "Issue Summary"
    description: "Summary title of the Issue / Defect"
  }

  dimension: status {
    label: "Issue Status"
    description: "Lifecycle status of the Issue / Defect"
    drill_fields: [resolution, id, name]
  }

  dimension: resolution {
    label: "Issue Resolution"
    description: "Resolution outcome of the Issue / Defect"
  }

  # =======================================================================
  # 2. DERIVED BUSINESS DIMENSIONS
  # =======================================================================

  dimension: is_open_issue {
    group_label: "Issue Lifecycle Flags"
    label: "Is Open Issue"
    description: "True when the Issue is still open/active (not Closed, Resolved, Done, or Rejected)"
    type: yesno
    sql: COALESCE(UPPER(${status}), 'OPEN') NOT IN ('CLOSED', 'RESOLVED', 'DONE', 'REJECTED', 'CANCELLED', 'VERIFIED') ;;
  }

  dimension: is_resolved_or_closed {
    group_label: "Issue Lifecycle Flags"
    label: "Is Resolved / Closed"
    description: "True when the Issue is Resolved, Closed, Verified, or Done"
    type: yesno
    sql: UPPER(${status}) IN ('CLOSED', 'RESOLVED', 'DONE', 'VERIFIED') ;;
  }

  dimension: resolution_duration_days {
    group_label: "Issue Lifecycle Flags"
    label: "Resolution Duration (Days)"
    description: "Number of days between Issue creation and close date (or current date if still open)"
    type: number
    sql: DATE_DIFF(COALESCE(${closed_date}, CURRENT_DATE()), ${created_date}, DAY) ;;
    value_format_name: decimal_0
  }

  # =======================================================================
  # 3. MEASURES (KPIs)
  # =======================================================================

  measure: count_issues {
    label: "Total Issues"
    description: "Distinct count of Issues / Defects (TBL_CB_SDV_Raw_Issue_V2)"
    type: count_distinct
    sql: ${id} ;;
    value_format_name: decimal_0
    drill_fields: [issue_default_drill*]
  }

  measure: count_open_issues {
    group_label: "Issue Resolution Metrics"
    label: "Open Issues"
    description: "Distinct count of currently Open Issues / Defects"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_open_issue: "yes"]
    value_format_name: decimal_0
    drill_fields: [issue_default_drill*]
  }

  measure: count_resolved_issues {
    group_label: "Issue Resolution Metrics"
    label: "Resolved / Closed Issues"
    description: "Distinct count of Resolved or Closed Issues / Defects"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_resolved_or_closed: "yes"]
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
  # 4. FIELD SETS
  # =======================================================================

  set: issue_default_drill {
    fields: [
      id,
      name,
      status,
      resolution,
      tracker,
      created_by,
      created_date,
      closed_date,
      resolution_duration_days
    ]
  }
}
