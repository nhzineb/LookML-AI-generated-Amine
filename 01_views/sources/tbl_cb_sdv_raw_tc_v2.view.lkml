# =============================================================================
# SOURCE VIEW: tbl_cb_sdv_raw_tc_v2 (Physical Table: TBL_CB_SDV_Raw_TC_V2 - 114 Columns)
# =============================================================================

view: tbl_cb_sdv_raw_tc_v2 {
  sql_table_name: `@{DATASET_NAME}.TBL_CB_SDV_Raw_TC_V2` ;;

  # ---------------------------------------------------------------------------
  # PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk1_tc_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.Id ;;
    description: "Primary key of TBL_CB_SDV_Raw_TC_V2 (Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 114 COLUMNS FROM TBL_CB_SDV_Raw_TC_V2
  # ---------------------------------------------------------------------------

  dimension: id {
    type: number
    sql: ${pk1_tc_id} ;;
    value_format_name: id
    description: "Unique identifier of the Test Case in CodeBeamer."
  }

  dimension: name {
    type: string
    sql: ${TABLE}.Name ;;
    description: "Name or title of the Test Case."
  }

  dimension: description {
    type: string
    sql: ${TABLE}.Description ;;
    description: "Full description and specification of the Test Case."
  }

  dimension: type {
    type: string
    sql: ${TABLE}.Type ;;
    description: "Classification type of the Test Case."
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Created ;;
    description: "Timestamp when the Test Case was created."
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}.Created_By ;;
    description: "Author who created the Test Case."
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Updated ;;
    description: "Timestamp when the Test Case was last updated."
  }

  dimension: updated_by {
    type: string
    sql: ${TABLE}.Updated_By ;;
    description: "User who last modified the Test Case."
  }

  dimension: version {
    type: number
    sql: ${TABLE}.Version ;;
    description: "Revision version number of the Test Case."
  }

  dimension: assigned_to {
    type: string
    sql: ${TABLE}.Assigned_To ;;
    description: "User assigned to the Test Case."
  }

  dimension: parent {
    type: number
    hidden: yes
    sql: ${TABLE}.Parent ;;
    value_format_name: id
    description: "Parent item ID of the Test Case in CodeBeamer."
  }

  dimension: project_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Project_Id ;;
    value_format_name: id
    description: "CodeBeamer Project ID hosting the Test Case."
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.Project_Name ;;
    description: "CodeBeamer Project Name hosting the Test Case."
  }

  dimension: tracker_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Tracker_Id ;;
    value_format_name: id
    description: "CodeBeamer Tracker ID hosting the Test Case."
  }

  dimension: tracker {
    type: string
    sql: ${TABLE}.Tracker ;;
    description: "CodeBeamer Tracker name hosting the Test Case."
  }

  dimension: status {
    type: string
    sql: ${TABLE}.Status ;;
    description: "Workflow status of the Test Case (e.g., Approved, Accepted, In Progress, Obsolete)."
  }

  dimension: categories {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Categories, ', ') ;;
    description: "Functional categories of the Test Case."
  }

  dimension: engineering_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Engineering_Level, ', ') ;;
    description: "Engineering V-cycle validation level(s) of the Test Case."
  }

  dimension: regulation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Regulation, ', ') ;;
    description: "Regulations verified by the Test Case."
  }

  dimension: asil {
    type: string
    sql: ${TABLE}.ASIL ;;
    description: "Automotive Safety Integrity Level (ASIL) of the Test Case."
  }

  dimension: safety_related {
    type: string
    sql: ${TABLE}.Safety_Related ;;
    description: "Indicates whether the Test Case is safety-related."
  }

  dimension: domain {
    type: string
    sql: ${TABLE}.Domain ;;
    description: "Primary engineering domain of the Test Case."
  }

  dimension: sub_domain {
    type: string
    sql: ${TABLE}.Sub_Domain ;;
    description: "Engineering sub-domain of the Test Case."
  }

  dimension: allocation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Allocation, ', ') ;;
    description: "System or component allocation of the Test Case."
  }

  dimension: validation_teams {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Validation_Teams, ', ') ;;
    description: "Validation teams responsible for the Test Case."
  }

  dimension: priority {
    type: string
    sql: ${TABLE}.Priority ;;
    description: "Execution priority of the Test Case."
  }

  dimension: sweet {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.SWEET, ', ') ;;
    description: "SWEET architecture version(s) associated with the Test Case."
  }

  dimension: vehicle_project {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Vehicle_Project) AS x), ', ') ;;
    description: "Vehicle project numeric IDs linked to the Test Case."
  }

  dimension: validation_leader {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Validation_Leader, ', ') ;;
    description: "Validation Leader(s) responsible for the Test Case."
  }

  dimension: system_owner {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.System_Owner, ', ') ;;
    description: "System Owner(s) accountable for the Test Case."
  }

  dimension: bench_type {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Bench_Type, ', ') ;;
    description: "Target test bench environment type(s) for executing the Test Case."
  }

  dimension: items_under_test {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Items_Under_Test, ', ') ;;
    description: "Items Under Test (IUT) verified by the Test Case."
  }

  dimension: estimated_duration {
    type: number
    sql: ${TABLE}.Estimated_Duration ;;
    description: "Estimated execution duration of the Test Case."
  }

  dimension: sw_releases {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.SW_Releases) AS x), ', ') ;;
    description: "Software release IDs associated with the Test Case."
  }

  dimension: test_set {
    type: number
    hidden: yes
    sql: ${TABLE}.Test_Set ;;
    value_format_name: id
    description: "Direct Test Set reference on the Test Case record."
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.VIN ;;
    description: "Vehicle Identification Number (VIN) if applicable."
  }

  dimension_group: completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Completed_At ;;
    description: "Completion timestamp on the Test Case item."
  }

  dimension: reported_bugs {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Reported_Bugs) AS x), ', ') ;;
    description: "Bug IDs linked directly to the Test Case."
  }

  dimension: test_cases {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Test_Cases) AS x), ', ') ;;
    description: "Nested Test Case IDs if this item is a composite Test Case."
  }

  dimension: feature_id {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Feature_Id, ', ') ;;
    description: "Feature identifiers linked to the Test Case."
  }

  dimension: jira_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Jira_Id ;;
    value_format_name: id
    description: "Internal numeric Jira identifier synchronized with the Test Case."
  }

  dimension: jira_key {
    type: string
    sql: ${TABLE}.Jira_Key ;;
    description: "External Jira issue key synchronized with the Test Case."
  }

  dimension: isp {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.ISP) AS x), ', ') ;;
    description: "ISP IDs linked to the Test Case."
  }

  dimension: uid {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.UID) AS x), ', ') ;;
    description: "Unique step/item UIDs associated with the Test Case."
  }

  dimension: action_type {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Action_Type, ', ') ;;
    description: "Test step action types defined in the Test Case."
  }

  dimension: action {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Action, ', ') ;;
    description: "Test step actions defined in the Test Case."
  }

  dimension: hlk {
    type: string
    sql: TO_JSON_STRING(${TABLE}.HLK) ;;
    description: "JSON representation of HLK metadata on the Test Case."
  }

  dimension: local_parameters {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Local_Parameters, ', ') ;;
    description: "Local test parameters defined on the Test Case."
  }

  dimension: referred_step_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(${TABLE}.Referred_Step_Id, ', ') ;;
    description: "Referred test step IDs."
  }

  dimension: referred_test_case_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Referred_Test_Case_Id) AS x), ', ') ;;
    description: "Referred reusable Test Case IDs."
  }

  dimension: measure_values {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Measure) AS x), ', ') ;;
    description: "Numeric measurement values recorded on the Test Case."
  }

  dimension: requirements {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Requirements) AS x), ', ') ;;
    description: "Requirement IDs verified by this Test Case."
  }

  dimension: result {
    type: string
    sql: ${TABLE}.Result ;;
    description: "Result attribute on the Test Case record."
  }

  dimension: actual_result {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Actual_Result, ', ') ;;
    description: "Actual step results recorded on the Test Case."
  }

  dimension: expected_result {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Expected_Result, ', ') ;;
    description: "Expected step results specified in the Test Case."
  }

  dimension: object_type {
    type: string
    sql: ${TABLE}.Object_Type ;;
    description: "Object type classification in CodeBeamer."
  }

  dimension: capitalization {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Capitalization) AS x), ', ') ;;
    description: "Capitalization metrics or flags on the Test Case."
  }

  dimension: security_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Security_level, ', ') ;;
    description: "Security and confidentiality classification of the Test Case."
  }

  dimension: safety_derived_from {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Safety_Derived_From) AS x), ', ') ;;
    description: "Safety item IDs from which the Test Case is derived."
  }

  dimension: validation_methods {
    type: string
    sql: ${TABLE}.Validation_Methods ;;
    description: "Validation method(s) used by the Test Case."
  }

  dimension: mysfx {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.MySFx) AS x), ', ') ;;
    description: "Internal MySF numeric IDs linked to the Test Case."
  }

  dimension: planned_for {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Planned_For) AS x), ', ') ;;
    description: "Planned release or milestone IDs for the Test Case."
  }

  dimension: legacy_identifier {
    type: string
    sql: ${TABLE}.Legacy_Identifier ;;
    description: "Legacy system identifier for the Test Case."
  }

  dimension: supplier {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Supplier, ', ') ;;
    description: "Suppliers associated with the Test Case."
  }

  dimension: final_status {
    type: string
    sql: ${TABLE}.Final_Status ;;
    description: "Final consolidated status of the Test Case."
  }

  dimension: validity {
    type: string
    sql: ${TABLE}.Validity ;;
    description: "Validity indicator of the Test Case."
  }

  dimension: baselines {
    type: string
    sql: ${TABLE}.Baselines ;;
    description: "Baselines associated with the Test Case."
  }

  dimension: support_module {
    type: string
    sql: ${TABLE}.Support_Module ;;
    description: "Support module associated with the Test Case."
  }

  dimension: cyber {
    type: string
    sql: ${TABLE}.Cyber ;;
    description: "Cybersecurity relevance indicator of the Test Case."
  }

  dimension: sw_components {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.SW_Components) AS x), ', ') ;;
    description: "Software component IDs verified by the Test Case."
  }

  dimension: milestone {
    type: string
    sql: ${TABLE}.Milestone ;;
    description: "Target project milestone of the Test Case."
  }

  dimension: vehicle_project_name {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Vehicle_Project_Name, ', ') ;;
    description: "Vehicle project names associated with the Test Case."
  }

  dimension: child_required {
    type: string
    sql: ${TABLE}.Child_Required ;;
    description: "Indicates whether child items are required."
  }

  dimension: brand {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Brand, ', ') ;;
    description: "Vehicle brands applicable to the Test Case."
  }

  dimension: my_feature {
    type: string
    sql: ${TABLE}.MyFeature ;;
    description: "MyFeature name linked to the Test Case."
  }

  dimension: tr_measure {
    type: number
    sql: ${TABLE}.TR_Measure ;;
    description: "Numeric test measure value on the Test Case."
  }

  dimension: baselines_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Baselines_Id ;;
    value_format_name: id
    description: "Internal numeric Baseline ID."
  }

  dimension: domain_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Domain_Id ;;
    value_format_name: id
    description: "Internal numeric Domain ID."
  }

  dimension: engineering_level_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Engineering_Level_Id) AS x), ', ') ;;
    description: "Internal numeric Engineering Level IDs."
  }

  dimension: items_under_test_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Items_Under_Test_Id) AS x), ', ') ;;
    description: "Internal numeric Items Under Test IDs."
  }

  dimension: my_feature_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.MyFeature_Id) AS x), ', ') ;;
    description: "Internal numeric MyFeature IDs."
  }

  dimension: sub_domain_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Sub_Domain_Id ;;
    value_format_name: id
    description: "Internal numeric Sub-Domain ID."
  }

  dimension: validation_teams_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Validation_Teams_Id) AS x), ', ') ;;
    description: "Internal numeric Validation Team IDs."
  }

  dimension: feature {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Feature) AS x), ', ') ;;
    description: "Feature numeric IDs linked to the Test Case."
  }

  dimension: fix_version {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Fix_Version) AS x), ', ') ;;
    description: "Fix version numeric IDs linked to the Test Case."
  }

  dimension: system {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.System) AS x), ', ') ;;
    description: "System numeric IDs linked to the Test Case."
  }

  dimension: technical_stream {
    type: string
    sql: ${TABLE}.Technical_stream ;;
    description: "Technical stream responsible for the Test Case."
  }

  dimension: sweet_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.SWEET_Id) AS x), ', ') ;;
    description: "Internal numeric SWEET IDs."
  }

  dimension: linked_isp {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Linked_ISP, ', ') ;;
    description: "Linked ISP keys or names on the Test Case."
  }

  dimension: ownership {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Ownership, ', ') ;;
    description: "Ownership team or role for the Test Case."
  }

  dimension: framework {
    type: string
    sql: ${TABLE}.Framework ;;
    description: "Test automation framework used by the Test Case."
  }

  dimension: reference_ticket {
    type: string
    sql: ${TABLE}.Reference_Ticket ;;
    description: "External reference ticket associated with the Test Case."
  }

  dimension: parent_required {
    type: string
    sql: ${TABLE}.Parent_Required ;;
    description: "Indicates whether an upstream parent link is required."
  }

  dimension: bench_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Bench_Id) AS x), ', ') ;;
    description: "Internal numeric Bench IDs."
  }

  dimension: domain_leader {
    type: string
    sql: ${TABLE}.Domain_Leader ;;
    description: "Domain Leader responsible for the Test Case domain."
  }

  dimension: grade_rating {
    type: string
    sql: ${TABLE}.Grade_Rating ;;
    description: "Quality or complexity grade rating of the Test Case."
  }

  dimension: target_planned_for {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Target_Planned_for, ', ') ;;
    description: "Target release milestones planned for the Test Case."
  }

  dimension: criticity {
    type: string
    sql: ${TABLE}.Criticity ;;
    description: "Criticality level of the Test Case."
  }

  dimension: affects_versions {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Affects_Versions, ', ') ;;
    description: "Software versions affected by the Test Case."
  }

  dimension: additional_information {
    type: string
    sql: ${TABLE}.Additional_Information ;;
    description: "Additional notes and supplementary metadata on the Test Case."
  }

  dimension: hwsw {
    type: string
    sql: ${TABLE}.HWSW ;;
    description: "Hardware / Software (HWSW) scope indicator of the Test Case."
  }

  dimension: refers_to_name {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Refers_To_Name, ', ') ;;
    description: "Names of items referenced by the Test Case."
  }

  dimension: refers_to_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Refers_To_Id) AS x), ', ') ;;
    description: "Numeric IDs of items referenced by the Test Case."
  }

  dimension: gitlab_url {
    type: string
    sql: ${TABLE}.Gitlab_URL ;;
    description: "URL to the automated test script repository in GitLab."
  }

  dimension: regulation_applicability {
    type: string
    sql: ${TABLE}.Regulation_Applicability ;;
    description: "Indicates whether regulatory compliance applies to the Test Case."
  }

  dimension: pv_variants {
    type: string
    sql: ${TABLE}.pvVariants ;;
    description: "Pure::variants variant configuration expression."
  }

  dimension: pv_restriction {
    type: string
    sql: ${TABLE}.pvRestriction ;;
    description: "Pure::variants restriction rules for the Test Case."
  }

  dimension: obsolete_from {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Obsolete_From, ', ') ;;
    description: "Milestone or release from which the Test Case is obsolete."
  }

  dimension: mysf {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.MySF, ', ') ;;
    description: "Direct MySystemFunction (MySF) identifiers on the Test Case."
  }

  dimension: automation_status {
    type: string
    sql: ${TABLE}.Automation_Status ;;
    description: "Test automation status (e.g., Automated, Manual, To Be Automated)."
  }

  dimension: automation_resolution {
    type: string
    sql: ${TABLE}.Automation_Resolution ;;
    description: "Resolution state of the test automation task."
  }

  dimension: automation_assigned_to {
    type: string
    sql: ${TABLE}.Automation_Assigned_to ;;
    description: "Engineer assigned to automate the Test Case."
  }

  dimension: automation_priority {
    type: string
    sql: ${TABLE}.Automation_Priority ;;
    description: "Priority level for automating the Test Case."
  }

  dimension: dut_variants {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.DUT_Variants, ', ') ;;
    description: "Device Under Test (DUT) variants applicable to the Test Case."
  }
}
