project_name: "ampere_sdv_analytics"

# =============================================================================
# CENTRALIZED CONNECTION & DATASET CONSTANTS (Rule 1)
# =============================================================================

constant: CONNECTION_NAME {
  value: "bigquery_ampere_sdv"
  export: override_optional
}

constant: DATASET_NAME {
  value: "ampere_sdv_gold"
  export: override_optional
}

constant: codebeamer_base_url {
  value: "https://codebeamer.ampere.renault.com/cb"
  export: override_optional
}

# =============================================================================
# VISUALIZATION DRILL CONSTANTS (Rule 2 - Looker Architect)
# =============================================================================

constant: DRILL_COLUMN_VIZ {
  value: "{% assign vis_config = '{\"type\": \"looker_column\", \"x_axis_gridlines\": false, \"y_axis_gridlines\": true, \"show_view_names\": false, \"show_y_axis_labels\": true, \"show_y_axis_ticks\": true, \"show_x_axis_label\": true, \"show_x_axis_ticks\": true, \"stacking\": \"\", \"show_value_labels\": true}' %}"
}

constant: DRILL_LINE_VIZ {
  value: "{% assign vis_config = '{\"type\": \"looker_line\", \"x_axis_gridlines\": false, \"y_axis_gridlines\": true, \"show_view_names\": false, \"show_y_axis_labels\": true, \"show_y_axis_ticks\": true, \"show_x_axis_label\": true, \"show_x_axis_ticks\": true, \"show_value_labels\": true, \"point_style\": \"circle\"}' %}"
}

constant: DRILL_PIE_VIZ {
  value: "{% assign vis_config = '{\"type\": \"looker_pie\", \"value_labels\": \"legend\", \"label_type\": \"labPer\", \"inner_radius\": 50}' %}"
}

# =============================================================================
# LOCALIZATION SETTINGS
# =============================================================================

localization_settings: {
  default_locale: en
  localization_level: permissive
}
