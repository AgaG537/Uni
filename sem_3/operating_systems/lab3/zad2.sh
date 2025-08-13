#!/bin/bash

net_interface="enp0s3"
prev_bytes_received=0
prev_bytes_transmitted=0
total_bytes_received=0
total_bytes_transmitted=0
sum_bytes_received=0
sum_bytes_transmitted=0
avg_bytes_received=0
avg_bytes_transmitted=0
total_received=0
total_transmitted=0
avg_received=0
avg_transmitted=0
seconds_counter=1

# Funkcja konwersji bajtów na KB, MB lub GB
convert_bytes() {
    local bytes=$1
    if ((bytes > 1048576)); then
        echo "$(bc <<< "scale=1; $bytes / 1048576") MB/s"
    elif ((bytes > 1024)); then
        echo "$(bc <<< "scale=1; $bytes / 1024") KB/s"
    else
        echo "$bytes B/s"
    fi
}

# Funkcja do wyświetlania prędkości sieci
network_info() 
{
    echo "=== Prędkość sieci ==="
    local line=$(grep $net_interface /proc/net/dev)
    
    if [ "${prev_bytes_received}" -eq 0 ]; then
        prev_bytes_received=$(echo "${line}" | awk '{print $2}')
        prev_bytes_transmitted=$(echo "${line}" | awk '{print $10}')
    fi
    
    local bytes_received=$(echo $line | awk '{print $2}')
    local bytes_transmitted=$(echo $line | awk '{print $10}')
    
    total_bytes_received=$((bytes_received - prev_bytes_received))
    total_bytes_transmitted=$((bytes_transmitted - prev_bytes_transmitted))
    
    prev_bytes_received=$bytes_received
    prev_bytes_transmitted=$bytes_transmitted
    
    sum_bytes_received=$((sum_bytes_received + total_bytes_received))
    sum_bytes_transmitted=$((sum_bytes_transmitted + total_bytes_transmitted))

    avg_bytes_received=$(($sum_bytes_received/$seconds_counter))
    avg_bytes_transmitted=$(($sum_bytes_transmitted/$seconds_counter))
    
    total_received=$(convert_bytes $total_bytes_received)
    avg_received=$(convert_bytes $avg_bytes_received)
    total_transmitted=$(convert_bytes $total_bytes_transmitted)
    avg_transmitted=$(convert_bytes $avg_bytes_transmitted)
    
    echo "Aktualna prędkość odbierania: $total_received"
    echo "Średnia prędkość odbierania: $avg_received"
    echo "Aktualna prędkość wysyłania: $total_transmitted"
    echo "Średnia prędkość wysyłania: $avg_transmitted"
    echo ""
    
    seconds_counter=$(($seconds_counter + 1))
}

# Funkcja do wyświetlania wykorzystania CPU
cpu_usage_info() {
    core_count=$(grep -c '^processor' /proc/cpuinfo)
    echo "=== Wykorzystanie CPU ==="
    
    for ((cpu = 0; cpu < core_count; cpu++)); do
        # Statystyki CPU
        cpu_stat=($(awk -v c="cpu$cpu" '$1 == c {for(i=2;i<=8;i++) printf $i" "}' /proc/stat))
        idle_time=${cpu_stat[3]}
        total_time=0
        for value in "${cpu_stat[@]}"; do
            total_time=$((total_time + value))
        done

        # Obliczenie wykorzystania CPU
        if [[ -n ${prev_idle_time[cpu]} ]]; then
            idle_delta=$((idle_time - prev_idle_time[cpu]))
            total_delta=$((total_time - prev_total_time[cpu]))
            usage=$((100 * (total_delta - idle_delta) / total_delta))
        else
            usage=0
        fi

        # Wyświetlenie wyników
        echo "CPU$cpu: $usage%"
        prev_idle_time[cpu]=$idle_time
        prev_total_time[cpu]=$total_time
    done
    echo ""
}

# Funkcja do wyświetlania czasu działania systemu
uptime_info() {
    uptime_seconds=$(awk '{print int($1)}' /proc/uptime)
    days=$((uptime_seconds / 86400))
    hours=$(( (uptime_seconds % 86400) / 3600 ))
    minutes=$(( (uptime_seconds % 3600) / 60 ))
    seconds=$((uptime_seconds % 60))

    echo "=== Czas działania systemu ==="
    echo "$days dni, $hours godz, $minutes min, $seconds sek"
    echo ""
}

# Funkcja do wyświetlania stanu baterii
battery_info() {
    if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
        battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
        echo "=== Bateria ==="
        echo "Stan baterii: $battery_level%"
        echo ""
    fi
}

# Funkcja do wyświetlania obciążenia systemu
loadavg_info() {
    loadavg=$(cut -d ' ' -f 1-3 /proc/loadavg)
    echo "=== Obciążenie systemu ==="
    echo "(1 min, 5 min, 15 min): $loadavg"
    echo ""
}

# Funkcja do wyświetlania wykorzystania pamięci
memory_info() {
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')
    mem_buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
    mem_cached=$(awk '/^Cached/ && !/SwapCached/ {print $2}' /proc/meminfo)
    
    mem_used=$((mem_total - mem_free - mem_buffers - mem_cached))

    mem_total_mb=$(echo "scale=2; $mem_total/1024" | bc)
    mem_used_mb=$(echo "scale=2; $mem_used/1024" | bc)
    
    echo "=== Pamięć ==="
    echo "Used Memory: $mem_used_mb MB"
    echo "Total Memory: $mem_total_mb MB"
    echo ""
}

# Główna pętla wywołująca funkcje
while true; do
    clear
    cpu_usage_info
    uptime_info
    battery_info
    loadavg_info
    memory_info
    network_info
    sleep 1
done

