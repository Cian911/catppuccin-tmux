#!/usr/bin/env bash

xdrip_local_server=""
xdrip_server_key=""

show_xdrip() {
  local index=$1
  local result
  xdrip_local_server="$(get_tmux_option "@catppuccin_xdrip_server" "")"
  xdrip_local_key="$(get_tmux_option "@catppuccin_xdrip_key" "")"
  result="$(main)"

  local icon="$(get_tmux_option "@catppuccin_xdrip_icon" "")"
  local color="$(get_tmux_option "@catppuccin_xdrip_color" "$(get_color)")")
  local text="$(get_tmux_option "@catppuccin_xdrip_text" "$result")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}

data_value=0

slope_single_down_icon="󰁅"
slope_double_down_icon="󰁅󰁅"
slope_forty_five_down_icon="󰁃"
slope_forty_five_up_icon="󰁜"
slope_flat_icon="󰁔"
slope_single_up_icon="󰁝"
slope_double_up_icon="󰁝󰁝"
slope_none_icon="󱫃"

threshold_low="4"
threshold_high="9"

threshold_low_color="$thm_red"
threshold_in_range_color="$thm_red"
threshold_high_color="$thm_yellow"

get_status() {
  local data=$(curl -s $xdrip_local_server --header "api-secret: $xdrip_server_key")
  data_value=$(echo $data | jq -r .bgs[].sgv)
  data_value=$(printf '%.*f\n' 0 $data_value)

  local slope=$(echo $data | jq -r .bgs[].direction)
  local slope_icon=""

  case $slope in
    SingleUp)
      slope_icon=$slope_single_up_icon
      ;;
    DoubleUp)
      slope_icon=$slope_double_up_icon
      ;;
    FortyFiveUp)
      slope_icon=$slope_forty_five_up_icon
      ;;
    FortyFiveDown)
      slope_icon=$slope_forty_five_down_icon
      ;;
    Flat)
      slope_icon=$slope_flat_icon
      ;;
    SingleDown)
      slope_icon=$slope_single_down_icon
      ;;
    DoubleDown)
      slope_icon=$slope_double_down_icon
      ;;
  esac

  echo "$(echo $data | jq -r .bgs[].sgv) $slope_icon"
}

get_color() {
  if [[ $data_value -gt $threshold_high ]]
  then
    echo $threshold_high_color
  elif [[ $data_value -le $threshold_low ]]
  then
    echo $threshold_low_color
  else
    echo $threshold_in_range_color
  fi
}

main() {
  get_status
}
