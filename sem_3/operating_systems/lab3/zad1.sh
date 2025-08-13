#!/bin/bash

# Funkcja do pobierania danych procesu z pliku /proc/[PID]/stat
function get_process_info {
    local pid=$1
    local stat_file="/proc/$pid/stat"
    
    # Sprawdzenie, czy plik stat istnieje
    if [[ ! -f $stat_file ]]; then
        return
    fi

    # Wczytanie całego wiersza z pliku stat do tablicy
    read -ra stat_array < "$stat_file"

    # Wyodrębnienie nazwy procesu (COMM)
    local comm=""
    local i=1
    while [[ "${stat_array[i]}" != *")"* ]]; do
        comm+="${stat_array[i]} "
        ((i++))
    done
    comm+="${stat_array[i]}"            # Dodanie ostatniej części nazwy z zamykającym nawiasem
    comm="${comm//[()]/}"               # Usunięcie nawiasów z nazwy
    comm="${comm// /_}"
    local data_start=$((i + 1))
    
    local state="${stat_array[data_start]}"           # Stan procesu
    local ppid="${stat_array[data_start + 1]}"        # PPID (Parent PID)
    local pgid="${stat_array[data_start + 2]}"        # PGID (Process Group ID)
    local sid="${stat_array[data_start + 3]}"         # SID (Session ID)
    local tty_id="${stat_array[data_start + 4]}"      # TTY ID jako liczba
    
    local rss=$(awk '/^VmRSS:/ {print $2}' /proc/$pid/status)  # RSS (Resident Set Size)
    
    if [[ -z "$rss" ]]; then
        rss=0
    fi

    # Konwersja TTY na czytelny format
    local tty
    if [[ "$tty_id" -eq 0 ]]; then
        tty="?"  # Brak terminala
    else
        tty=$(ls -l /proc/$pid/fd/0 2>/dev/null | awk '{print $11}' | sed 's/\/dev\///')
    fi

    # Liczba otwartych plików
    local opened_files=$(ls /proc/$pid/fd 2>/dev/null | wc -l)

    # Wyświetlenie informacji o procesie w jednym wierszu (dane oddzielone tabulatorem)
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$ppid" "$pid" "$state" "$tty" "$rss" "$pgid" "$sid" "$opened_files" "$comm"
}

# Generowanie danych procesów i wyrównanie kolumn z `column -t`
{
    # Wydrukowanie nagłówka
    echo -e "PPID\tPID\tSTATE\tTTY\tRSS\tPGID\tSID\tOPENED_FILES\tCOMM"
    
    # Iteracja po każdym procesie
    for pid in $(ls /proc | grep -E '^[0-9]+$'); do
        get_process_info "$pid"
    done
} | column -t

