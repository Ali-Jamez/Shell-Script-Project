#!/bin/bash

# 📁 Path to your MP3 alarm sound
SOUND="/home/aj/Desktop/Alarm.mp3"  # Change this path

# 🎵 Function to play the alarm in a loop
play_sound_loop() {
    while true; do
        mpg123 "$SOUND"
    done
}

# 🕒 Ask user for alarm time (HH:MM)
alarm_time=$(yad --entry --title="Alarm Clock" --text="Enter alarm time (24-hour, HH:MM):" --width=300)
[[ -z "$alarm_time" ]] && exit 1

# Notify that alarm is set
yad --info --text="Alarm set for $alarm_time" --timeout=3 --width=300

# 📆 Get full alarm timestamp (today's date + user time)
alarm_timestamp=$(date -d "$(date +%F) $alarm_time" +%s)
current_timestamp=$(date +%s)

# ⌛ Calculate wait time in seconds
wait_seconds=$((alarm_timestamp - current_timestamp))

# If alarm time already passed, show error
if (( wait_seconds < 0 )); then
    yad --error --text="The alarm time has already passed." --width=300
    exit 1
fi

# 🔄 Wait precisely until alarm time
sleep "$wait_seconds"

# 🔊 Start alarm sound loop in a background process group
play_sound_loop &
alarm_pid=$!
pgid=$(ps -o pgid= $alarm_pid | grep -o '[0-9]*')

# 🛑 Show Stop button
yad --title="⏰ ALARM!" \
    --text="It's $alarm_time! Click Stop to silence the alarm." \
    --button="Stop Alarm!gtk-stop:0" \
    --width=300

# 🧼 Stop all alarm sounds
kill -TERM -"$pgid" &>/dev/null
notify-send "✅ Alarm stopped." "Enjoy your day!"

