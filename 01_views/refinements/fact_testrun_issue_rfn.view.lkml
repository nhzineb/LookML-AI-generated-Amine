include: "/01_views/sources/fact_testrun_issue.view.lkml"

# =============================================================================
# REFINEMENT VIEW: +fact_testrun_issue (FACT_TestRun_Issue)
# Functional Order: Keys -> Dimensions -> Measures -> Filters -> Sets
# =============================================================================

view: +fact_testrun_issue {
  label: "FACT_TestRun_Issue (TR-Issue Bridge)"

  # ---------------------------------------------------------------------------
  # 2. DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: has_linked_issue {
    label: "Has Linked Defect/Issue"
    group_label: "Defect Linkage"
    type: yesno
    sql: ${pk2_issue_id} IS NOT NULL ;;
    description: "True when the Test Run is linked to a Jira Defect/Issue."
  }

  # ---------------------------------------------------------------------------
  # 3. MEASURES (Rule 5, 6, 7, 8 & LAMS F3)
  # ---------------------------------------------------------------------------

  measure: tr_issue_link_count {
    label: "TR-Issue Defect Links"
    group_label: "Defect Bridge Metrics"
    type: count
    filters: [pk_tr_issue_id: "-NULL"]
    value_format_name: decimal_0
    description: "Total count of TestRun-to-Issue bridge links."
    drill_fields: [detail*]
  }

  measure: distinct_runs_with_issues_count {
    label: "Distinct Test Runs with Issues"
    group_label: "Defect Bridge Metrics"
    type: count_distinct
    sql: ${pk2_tr_id} ;;
    filters: [has_linked_issue: "yes"]
    value_format_name: decimal_0
    description: "Count of distinct Test Runs linked to at least one Issue."
    drill_fields: [detail*]
  }

  measure: distinct_linked_issues_count {
    label: "Distinct Linked Issues"
    group_label: "Defect Bridge Metrics"
    type: count_distinct
    sql: ${pk2_issue_id} ;;
    value_format_name: decimal_0
    description: "Count of distinct Jira Issues linked to Test Runs."
    drill_fields: [detail*]
  }

  # ---------------------------------------------------------------------------
  # 5. SETS
  # ---------------------------------------------------------------------------

  set: detail {
    fields: [
      has_linked_issue,
      distinct_runs_with_issues_count,
      distinct_linked_issues_count
    ]
  }
}
