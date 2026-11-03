# =============================================================================
# SOURCE VIEW: tbl_cb_sdv_raw_tr_v2 (Physical Table: TBL_CB_SDV_Raw_TR_V2 - 114 Columns)
# =============================================================================

view: tbl_cb_sdv_raw_tr_v2 {
  sql_table_name: `@{DATASET_NAME}.TBL_CB_SDV_Raw_TR_V2` ;;

  # ---------------------------------------------------------------------------
  # PRIMARY KEY (LAMS K1, K3, K4, K7, K8)
  # ---------------------------------------------------------------------------

  dimension: pk1_tr_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.Id ;;
    description: "Primary key of TBL_CB_SDV_Raw_TR_V2 (Id)."
  }

  # ---------------------------------------------------------------------------
  # ALL 114 COLUMNS FROM TBL_CB_SDV_Raw_TR_V2
  # ---------------------------------------------------------------------------

  dimension: id {
    type: number
    sql: ${pk1_tr_id} ;;
    value_format_name: id
    description: "Unique identifier of the Test Run execution in CodeBeamer."
  }

  dimension: name {
    type: string
    sql: ${TABLE}.Name ;;
    description: "Name or title of the Test Run."
  }

  dimension: description {
    type: string
    sql: ${TABLE}.Description ;;
    description: "Detailed execution notes and description of the Test Run."
  }

  dimension: type {
    type: string
    sql: ${TABLE}.Type ;;
    description: "Type classification of the Test Run."
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Created ;;
    description: "Timestamp when the Test Run was initiated."
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}.Created_By ;;
    description: "User or service account that initiated the Test Run."
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Updated ;;
    description: "Timestamp when the Test Run was last updated."
  }

  dimension: updated_by {
    type: string
    sql: ${TABLE}.Updated_By ;;
    description: "User who last updated the Test Run."
  }

  dimension: version {
    type: number
    sql: ${TABLE}.Version ;;
    description: "Version number of the Test Run record."
  }

  dimension: assigned_to {
    type: string
    sql: ${TABLE}.Assigned_To ;;
    description: "Tester or engineer assigned to execute the Test Run."
  }

  dimension: parent {
    type: number
    hidden: yes
    sql: ${TABLE}.Parent ;;
    value_format_name: id
    description: "Parent Test Run ID (e.g., parent campaign run)."
  }

  dimension: project_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Project_Id ;;
    value_format_name: id
    description: "CodeBeamer Project ID hosting the Test Run."
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.Project_Name ;;
    description: "CodeBeamer Project Name hosting the Test Run."
  }

  dimension: tracker_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Tracker_Id ;;
    value_format_name: id
    description: "CodeBeamer Tracker ID hosting the Test Run."
  }

  dimension: tracker {
    type: string
    sql: ${TABLE}.Tracker ;;
    description: "CodeBeamer Tracker name hosting the Test Run."
  }

  dimension: status {
    type: string
    sql: ${TABLE}.Status ;;
    description: "Workflow lifecycle state of the Test Run (e.g., Finished, In Progress, Suspended)."
  }

  dimension: categories {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Categories, ', ') ;;
    description: "Categories assigned to the Test Run."
  }

  dimension: engineering_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Engineering_Level, ', ') ;;
    description: "Engineering V-cycle level(s) of the Test Run."
  }

  dimension: regulation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Regulation, ', ') ;;
    description: "Regulations associated with the Test Run."
  }

  dimension: asil {
    type: string
    sql: ${TABLE}.ASIL ;;
    description: "Automotive Safety Integrity Level (ASIL) of the Test Run."
  }

  dimension: safety_related {
    type: string
    sql: ${TABLE}.Safety_Related ;;
    description: "Indicates whether the Test Run is safety-related."
  }

  dimension: domain {
    type: string
    sql: ${TABLE}.Domain ;;
    description: "Engineering domain of the Test Run."
  }

  dimension: sub_domain {
    type: string
    sql: ${TABLE}.Sub_Domain ;;
    description: "Engineering sub-domain of the Test Run."
  }

  dimension: allocation {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Allocation, ', ') ;;
    description: "System or component allocation of the Test Run."
  }

  dimension: validation_teams {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Validation_Teams, ', ') ;;
    description: "Validation teams executing the Test Run."
  }

  dimension: priority {
    type: string
    sql: ${TABLE}.Priority ;;
    description: "Execution priority of the Test Run."
  }

  dimension: sweet {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.SWEET, ', ') ;;
    description: "SWEET architecture version(s) of the Test Run."
  }

  dimension: vehicle_project {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Vehicle_Project) AS x), ', ') ;;
    description: "Vehicle project numeric IDs linked to the Test Run."
  }

  dimension: validation_leader {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Validation_Leader, ', ') ;;
    description: "Validation Leader(s) overseeing the Test Run."
  }

  dimension: system_owner {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.System_Owner, ', ') ;;
    description: "System Owner(s) associated with the Test Run."
  }

  dimension: bench_type {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Bench_Type, ', ') ;;
    description: "Test bench environment types (e.g., HIL, SIL, Vehicle) used for the Test Run."
  }

  dimension: items_under_test {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Items_Under_Test, ', ') ;;
    description: "Items Under Test (IUT) in the Test Run."
  }

  dimension: estimated_duration {
    type: number
    sql: ${TABLE}.Estimated_Duration ;;
    description: "Estimated duration of the Test Run."
  }

  dimension: sw_releases {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.SW_Releases) AS x), ', ') ;;
    description: "Software release IDs tested in the Test Run."
  }

  dimension: test_set {
    type: number
    hidden: yes
    sql: ${TABLE}.Test_Set ;;
    value_format_name: id
    description: "Foreign key ID of the Test Set executed by this Test Run."
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.VIN ;;
    description: "Vehicle Identification Number (VIN) of the test vehicle."
  }

  dimension_group: completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.Completed_At ;;
    description: "Timestamp when the Test Run execution completed."
  }

  dimension: reported_bugs {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Reported_Bugs) AS x), ', ') ;;
    description: "Bug/Issue IDs reported during the Test Run."
  }

  dimension: test_cases {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Test_Cases) AS x), ', ') ;;
    description: "Test Case IDs executed in this Test Run."
  }

  dimension: feature_id {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Feature_Id, ', ') ;;
    description: "Feature identifiers associated with the Test Run."
  }

  dimension: jira_id {
    type: number
    hidden: yes
    sql: ${TABLE}.Jira_Id ;;
    value_format_name: id
    description: "Synchronized internal Jira ID."
  }

  dimension: jira_key {
    type: string
    sql: ${TABLE}.Jira_Key ;;
    description: "Synchronized Jira issue key."
  }

  dimension: isp {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.ISP) AS x), ', ') ;;
    description: "ISP IDs associated with the Test Run."
  }

  dimension: uid {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.UID) AS x), ', ') ;;
    description: "Unique step/item UIDs in the Test Run."
  }

  dimension: action_type {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Action_Type, ', ') ;;
    description: "Step action types executed in the Test Run."
  }

  dimension: action {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Action, ', ') ;;
    description: "Step actions executed in the Test Run."
  }

  dimension: hlk {
    type: string
    sql: TO_JSON_STRING(${TABLE}.HLK) ;;
    description: "JSON representation of HLK metadata on the Test Run."
  }

  dimension: local_parameters {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Local_Parameters, ', ') ;;
    description: "Local parameters applied during the Test Run."
  }

  dimension: referred_step_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(${TABLE}.Referred_Step_Id, ', ') ;;
    description: "Referred step IDs in the Test Run."
  }

  dimension: referred_test_case_id {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Referred_Test_Case_Id) AS x), ', ') ;;
    description: "Referred Test Case IDs in the Test Run."
  }

  dimension: measure_values {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Measure) AS x), ', ') ;;
    description: "Recorded measurement values during the Test Run."
  }

  dimension: requirements {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Requirements) AS x), ', ') ;;
    description: "Requirement IDs linked to the Test Run."
  }

  dimension: result {
    type: string
    sql: ${TABLE}.Result ;;
    description: "Execution verdict of the Test Run (e.g., Passed, Failed, Blocked)."
  }

  dimension: actual_result {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Actual_Result, ', ') ;;
    description: "Actual observed results recorded during the Test Run."
  }

  dimension: expected_result {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Expected_Result, ', ') ;;
    description: "Expected results for the Test Run steps."
  }

  dimension: object_type {
    type: string
    sql: ${TABLE}.Object_Type ;;
    description: "Object type classification in CodeBeamer."
  }

  dimension: capitalization {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Capitalization) AS x), ', ') ;;
    description: "Capitalization metrics on the Test Run."
  }

  dimension: security_level {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Security_level, ', ') ;;
    description: "Security classification of the Test Run."
  }

  dimension: safety_derived_from {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Safety_Derived_From) AS x), ', ') ;;
    description: "Safety item IDs from which the Test Run is derived."
  }

  dimension: validation_methods {
    type: string
    sql: ${TABLE}.Validation_Methods ;;
    description: "Validation method used for the Test Run."
  }

  dimension: mysfx {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.MySFx) AS x), ', ') ;;
    description: "Internal MySF numeric IDs on the Test Run."
  }

  dimension: planned_for {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Planned_For) AS x), ', ') ;;
    description: "Planned release or milestone IDs for the Test Run."
  }

  dimension: legacy_identifier {
    type: string
    sql: ${TABLE}.Legacy_Identifier ;;
    description: "Legacy system identifier for the Test Run."
  }

  dimension: supplier {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Supplier, ', ') ;;
    description: "Suppliers associated with the Test Run."
  }

  dimension: final_status {
    type: string
    sql: ${TABLE}.Final_Status ;;
    description: "Final consolidated status of the Test Run."
  }

  dimension: validity {
    type: string
    sql: ${TABLE}.Validity ;;
    description: "Validity indicator of the Test Run."
  }

  dimension: baselines {
    type: string
    sql: ${TABLE}.Baselines ;;
    description: "Baseline under which the Test Run was executed."
  }

  dimension: support_module {
    type: string
    sql: ${TABLE}.Support_Module ;;
    description: "Support module associated with the Test Run."
  }

  dimension: cyber {
    type: string
    sql: ${TABLE}.Cyber ;;
    description: "Cybersecurity relevance indicator of the Test Run."
  }

  dimension: sw_components {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.SW_Components) AS x), ', ') ;;
    description: "Software component IDs tested during the Test Run."
  }

  dimension: milestone {
    type: string
    sql: ${TABLE}.Milestone ;;
    description: "Milestone associated with the Test Run."
  }

  dimension: vehicle_project_name {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Vehicle_Project_Name, ', ') ;;
    description: "Vehicle project names associated with the Test Run."
  }

  dimension: child_required {
    type: string
    sql: ${TABLE}.Child_Required ;;
    description: "Indicates whether child items are required."
  }

  dimension: brand {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Brand, ', ') ;;
    description: "Vehicle brands applicable to the Test Run."
  }

  dimension: my_feature {
    type: string
    sql: ${TABLE}.MyFeature ;;
    description: "MyFeature name linked to the Test Run."
  }

  dimension: tr_measure {
    type: number
    sql: ${TABLE}.TR_Measure ;;
    description: "Quantitative execution measure or duration recorded on the Test Run."
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
    description: "Feature numeric IDs linked to the Test Run."
  }

  dimension: fix_version {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Fix_Version) AS x), ', ') ;;
    description: "Fix version numeric IDs linked to the Test Run."
  }

  dimension: system {
    type: string
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.System) AS x), ', ') ;;
    description: "System numeric IDs linked to the Test Run."
  }

  dimension: technical_stream {
    type: string
    sql: ${TABLE}.Technical_stream ;;
    description: "Technical stream associated with the Test Run."
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
    description: "Linked ISP keys on the Test Run."
  }

  dimension: ownership {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Ownership, ', ') ;;
    description: "Ownership team or role for the Test Run."
  }

  dimension: framework {
    type: string
    sql: ${TABLE}.Framework ;;
    description: "Test automation framework executed during the Test Run."
  }

  dimension: reference_ticket {
    type: string
    sql: ${TABLE}.Reference_Ticket ;;
    description: "External reference ticket associated with the Test Run."
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
    description: "Domain Leader for the Test Run."
  }

  dimension: grade_rating {
    type: string
    sql: ${TABLE}.Grade_Rating ;;
    description: "Grade rating of the Test Run."
  }

  dimension: target_planned_for {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Target_Planned_for, ', ') ;;
    description: "Target release milestones planned for the Test Run."
  }

  dimension: criticity {
    type: string
    sql: ${TABLE}.Criticity ;;
    description: "Criticality level of the Test Run."
  }

  dimension: affects_versions {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Affects_Versions, ', ') ;;
    description: "Software versions affected by the Test Run."
  }

  dimension: additional_information {
    type: string
    sql: ${TABLE}.Additional_Information ;;
    description: "Additional execution remarks and metadata on the Test Run."
  }

  dimension: hwsw {
    type: string
    sql: ${TABLE}.HWSW ;;
    description: "Hardware / Software (HWSW) scope indicator of the Test Run."
  }

  dimension: refers_to_name {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Refers_To_Name, ', ') ;;
    description: "Names of items referenced by the Test Run."
  }

  dimension: refers_to_id {
    type: string
    hidden: yes
    sql: ARRAY_TO_STRING(ARRAY(SELECT CAST(x AS STRING) FROM UNNEST(${TABLE}.Refers_To_Id) AS x), ', ') ;;
    description: "Numeric IDs of items referenced by the Test Run."
  }

  dimension: gitlab_url {
    type: string
    sql: ${TABLE}.Gitlab_URL ;;
    description: "URL to the automated test execution script in GitLab."
  }

  dimension: regulation_applicability {
    type: string
    sql: ${TABLE}.Regulation_Applicability ;;
    description: "Indicates whether regulatory compliance applies to the Test Run."
  }

  dimension: pv_variants {
    type: string
    sql: ${TABLE}.pvVariants ;;
    description: "Pure::variants variant configuration expression for the Test Run."
  }

  dimension: pv_restriction {
    type: string
    sql: ${TABLE}.pvRestriction ;;
    description: "Pure::variants restriction rules for the Test Run."
  }

  dimension: obsolete_from {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.Obsolete_From, ', ') ;;
    description: "Milestone or release from which the item is obsolete."
  }

  dimension: mysf {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.MySF, ', ') ;;
    description: "Direct MySystemFunction (MySF) identifiers on the Test Run record."
  }

  dimension: automation_status {
    type: string
    sql: ${TABLE}.Automation_Status ;;
    description: "Automation status of the Test Run."
  }

  dimension: automation_resolution {
    type: string
    sql: ${TABLE}.Automation_Resolution ;;
    description: "Automation resolution state."
  }

  dimension: automation_assigned_to {
    type: string
    sql: ${TABLE}.Automation_Assigned_to ;;
    description: "Engineer assigned to automation."
  }

  dimension: automation_priority {
    type: string
    sql: ${TABLE}.Automation_Priority ;;
    description: "Automation priority level."
  }

  dimension: dut_variants {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.DUT_Variants, ', ') ;;
    description: "Device Under Test (DUT) variants used during the Test Run."
  }
}
