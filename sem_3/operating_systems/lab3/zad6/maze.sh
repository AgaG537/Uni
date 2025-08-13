#!/bin/bash

# ANSI escape sequences
ESC=$(printf "\033")
WHITE_BG="${ESC}[47m"
RESET="${ESC}[0m"
PLAYER="${ESC}[44m  ${RESET}"  # Gracz - niebieskie tło
EXIT="${ESC}[42m  ${RESET}"    # Wyjście - zielone tło
EMPTY="  "                     # Puste pole
WALL="${WHITE_BG}  ${RESET}"   # Ściana - białe tło

set -euo pipefail
trap 'echo "Error at line $LINENO: $BASH_COMMAND"' ERR

# czyszczenie ekranu terminala
clear_screen() {
    echo -ne "${ESC}[2J${ESC}[H"
}

# Pobranie wielkości terminala
get_terminal_size() {
    local size
    size=$(stty size)
    rows=$(echo "$size" | cut -d' ' -f1)
    cols=$(echo "$size" | cut -d' ' -f2)
}

# Początkowe generowanie samych ścian
initialize_maze() {
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            maze[$((i * width + j))]=1  # Na początku wszystkie pola są ścianą
        done
    done
}

# Recursive Backtracking do generowania labiryntu
generate_maze() {
    local x=$1
    local y=$2

    local directions=("UP" "DOWN" "LEFT" "RIGHT")
    directions=($(shuf -e "${directions[@]}"))

    for dir in "${directions[@]}"; do
        case $dir in
            "UP")
                nx=$((x - 2)); ny=$y
                ;;
            "DOWN")
                nx=$((x + 2)); ny=$y
                ;;
            "LEFT")
                nx=$x; ny=$((y - 2))
                ;;
            "RIGHT")
                nx=$x; ny=$((y + 2))
                ;;
        esac

        if ((nx > 0 && nx < height - 1 && ny > 0 && ny < width - 1)) && [[ ${maze[$((nx * width + ny))]:-1} -eq 1 ]]; then
            maze[$((nx * width + ny))]=0  # Wolne pole
            maze[$((((nx + x) / 2) * width + ((ny + y) / 2)))]=0  # Przejście
            generate_maze $nx $ny
        fi
    done
}

# Rysowanie pola
draw_cell() {
    local x=$1
    local y=$2
    local cell=${maze[$((x * width + y))]:-1}  # Domyślna wartość 1, jeśli brak danych

    echo -ne "${ESC}[$((x + 1));$((y * 2 + 1))H"  # Ustaw kursor na właściwej pozycji
    if ((x == px && y == py)); then
        echo -ne "$PLAYER"  # Gracz
    elif ((x == end_x && y == end_y)); then
        echo -ne "$EXIT"  # Wyjście
    elif ((cell == 1)); then
        echo -ne "$WALL"  # Ściana
    else
        echo -ne "$EMPTY"  # Puste pole
    fi
}

# Rysowanie labiryntu
draw_maze() {
    clear_screen
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            draw_cell $i $j
        done
    done
}

# Główna funkcja gry
game_loop() {
    local nx ny
    while true; do
        draw_cell $px $py  # Aktualizuj tylko gracza
        read -rsn1 input
        case $input in
            w) nx=$((px - 1)); ny=$py ;;  # Up
            s) nx=$((px + 1)); ny=$py ;;  # Down
            a) nx=$px; ny=$((py - 1)) ;;  # Left
            d) nx=$px; ny=$((py + 1)) ;;  # Right
            q) clear_screen; break ;;  # Quit
            *) continue ;;
        esac

        if [[ ${maze[$((nx * width + ny))]:-1} -eq 0 ]]; then
            px=$nx
            py=$ny
        fi

        if ((px == end_x && py == end_y)); then
            draw_cell $px $py
            echo -e "\n${ESC}[$((height + 1));1HCongrats! You have made it through the maze!\n"
            break
        fi
    done
}


# Inicjalizacja
get_terminal_size
width=$((cols / 2))
height=$((rows - 1))

if ((width % 2 == 0)); then width=$((width - 1)); fi
if ((height % 2 == 0)); then height=$((height - 1)); fi

declare -a maze
initialize_maze
generate_maze 1 1

start_x=1
start_y=1
end_x=$((height - 2))
end_y=$((width - 2))
maze[$((end_x * width + end_y))]=0

px=$start_x
py=$start_y

draw_maze
game_loop

