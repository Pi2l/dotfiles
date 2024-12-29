#!/bin/bash
# CPU temperature value is main and this value is diplayed
# File containing fan status (replace this with the actual path)

get_cpu_mhz_info() {
  sleep 0.1
  local cpu_mhz_values=$(grep "^[c]pu MHz" /proc/cpuinfo | awk '{print $4}')

  # Initialize variables
  local total=0
  local count=0
  local cpu_mhz_array=()

  for mhz in $cpu_mhz_values; do
    cpu_mhz_array+=("$mhz")
    total=$(echo "$total + $mhz" | bc)
    count=$((count + 1))
  done

  # Calculate average
  local average=0
  if [ "$count" -ne 0 ]; then
    average=$(echo "scale=0; $total / $count" | bc)
  fi

  # Return results
  echo "$average ${cpu_mhz_array[*]}"
}

get_freq_json_per_core() {
  local args=("$@")
  local json_text="Per-core CPU MHz values:"
  for i in "${!args[@]}"; do
    json_text=$(echo "$json_text\nCore $((i + 1)): ${args[$i]} MHz")
  done
  echo "$json_text"
}

CPU_STATUS_FILE="/proc/acpi/ibm/thermal"                # CPU
GPU_STATUS_FILE="/sys/class/hwmon/hwmon4/temp1_input"   # GPU
SSD_STATUS_FILE="/sys/class/hwmon/hwmon2/temp1_input"   # SSD
PU_STATUS_FILE="/sys/class/power_supply/BAT0/power_now" # Power usage

if [[ -f "$CPU_STATUS_FILE" ]]; then
  cpu_temperature=$(cat $CPU_STATUS_FILE | awk '{print $2}')
  cpu_temperature_icon=""
  result=$(get_cpu_mhz_info)

  # Parse the output
  average=$(echo "$result" | awk '{print $1}')
  cores_freq=($(echo "$result" | cut -d' ' -f2-))

  # TODO: add cpu temperature threshold
  # if [[ cpu_temperature > $CPU_THRESHOLD]]; then fi

  if [[ -f "$GPU_STATUS_FILE" ]]; then
    gpu_temperature=$(($(cat $GPU_STATUS_FILE) / 1000))
    gpu_temperature_icon=""
  fi

  if [[ -f "$SSD_STATUS_FILE" ]]; then
    ssd_temperature=$((($(cat $SSD_STATUS_FILE) + 500) / 1000))
    ssd_temperature_icon=""
  fi

  if [[ -f "$PU_STATUS_FILE" ]]; then
    pu_temperature_raw=$(cat $PU_STATUS_FILE)
    pu_temperature=$(((($pu_temperature_raw + 5) / 1000000)))
    pu_temperature_icon="󱩘"
  fi

  # TODO: add function that composes text value according to input argument. Argument is passed based on click:
  # left click -> show CPU;
  # right click -> GPU;
  # middle click -> SSD;

  celsius="℃"
  wat="W"
  tooltip_cpu_freqs=$(get_freq_json_per_core "${cores_freq[@]}")
  # Output for Waybar. Text: cpu icon cpu_temperature @ cpu_freq
  echo "{\"text\": \"$cpu_temperature_icon $cpu_temperature$celsius @$average\", \"tooltip\": \"$tooltip_cpu_freqs\nCPU: $cpu_temperature$celsius\nGPU: $gpu_temperature$celsius\nSSD: $ssd_temperature$celsius\nPower: $pu_temperature$wat\", \"class\": \"$status\", \"icon\": \"$cpu_temperature\"}"
else
  echo "{\"text\": \"Error\", \"tooltip\": \"Fan status file not found\", \"class\": \"error\", \"icon\": \"❗\"}"
fi
