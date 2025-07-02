#!/bin/bash

# Цвета ANSI
ORANGE='\033[0;33m'   # оранжевый/желтый
BLUE='\033[0;34m'     # синий
GREEN='\033[0;32m'    # зеленый
NC='\033[0m'          # сброс цвета

# --- Логотип в массив ---
read -r -d '' LOGO <<'EOF'
    ░ ░░░                            ░░░░░░
    ░░░░░░                            ░░░░░░
    ░░░▓▓░░░░   ░░░░░░░░░░░░░░░░░  ░░░░▒▒░░
     ░░▓▓▓▓▓▓░░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒░░
       ░▓▓▓▓▓▓▓▓▓░░░▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▒▒▒▒▒░
       ░░▓▓▓▓▓▓▓▓▓▓▒░░▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒░░
    ░░░▒▓▓░░░░░░░░░▓▓░░▒▒░░▒▒░░░░░░░░░▒▒░░░░
    ░░▓▓▓░   ░██░░░░▓▓░░░▒▒▒░░▒░██░░░░░▒▒▒░░
    ░░▓▓░░ ░░██░░░█░░▓▓░░▒▒░░▒░░░██░  ░░▒▒░░
    ░░▓▓░  ░░███▓█▓░░▓▓░░▒▒░░██▓███░░ ░░▒▒░░
    ░░▓▓░░   ░░█▓░░░░▓▓░░▒▒░░░░▓█░░   ░░▒▒░░
    ░░░▓▓░░░░  ░░░░▒▓▓░░░░▒▒░░░░░░  ░░░░▒▒░░
    ░░░░▓▓▓▓░░░░░▓▓▓▒░░▒▒░░▒▒▒▒░░░░░▒▒▒▒░░░░
       ░░░░▓▓▓▓▓▓▒░░░░░▒▒░░░░░▒▒▒▒▒▒▒░░░░
       ░░░▒▒░░░░░▒▒▒▒▒░░░░▒▒▒▒▒░░░░░▒▒░░░
       ░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░
          ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
             ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
             ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
               ░░░░▒▒▒▒▒▒▒▒▒▒░░░░
                  ░░░▒▒▒▒▒▒░░░
                  ░░░░░▒▒░░░░░
                     ░░░░░░
EOF
IFS=$'\n' read -rd '' -a LOGO_LINES <<< "$LOGO"

# --- Исправить первую строку лого ---
# Найти минимальное количество ведущих пробелов среди всех строк (кроме первой)
min_pad=1000
for ((i=1; i<${#LOGO_LINES[@]}; i++)); do
  line="${LOGO_LINES[i]}"
  pad=$(echo "$line" | grep -o '^ *' | wc -c)
  [ $pad -lt $min_pad ] && min_pad=$pad
  # если строка пустая, пропустить
  [ -z "$line" ] && continue
  # если строка без пробелов, min_pad=0
  [ $pad -eq 0 ] && min_pad=0

done
# Добавить min_pad пробелов к первой строке
LOGO_LINES[0]="$(printf '%*s' $min_pad)${LOGO_LINES[0]}"

# --- Информация ---

# OS
if command -v lsb_release >/dev/null 2>&1; then
  OS=$(lsb_release -d 2>/dev/null | cut -d ':' -f 2 | sed 's/^[ \t]*//')
else
  OS=""
fi
if [ -z "$OS" ] && [ -f /etc/os-release ]; then
  OS=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')
fi
OS=${OS:-N/A}

# Kernel
KERNEL=$(uname -r)

# Hostname
HOSTNAME=$(hostname)

# Uptime
UPTIME=$(uptime -p)

# Shell
SHELL=$(basename "$SHELL")

# Resolution
if command -v xrandr >/dev/null 2>&1; then
  RESOLUTION=$(xrandr | grep '*' | awk '{print $1}' | paste -sd ', ' -)
else
  RESOLUTION="N/A"
fi

# DE or WM
DE=${XDG_CURRENT_DESKTOP:-}
if [ -z "$DE" ] && command -v wmctrl >/dev/null 2>&1; then
  DE=$(wmctrl -m 2>/dev/null | grep Name | cut -d ':' -f2 | sed 's/^[ \t]*//')
fi
DE=${DE:-N/A}

# WM Theme, GTK Theme, Icon Theme — попробуем из gsettings (GNOME/GTK)
if command -v gsettings >/dev/null 2>&1; then
  GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
  ICON_THEME=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
  WM_THEME=$(gsettings get org.gnome.desktop.wm.preferences theme 2>/dev/null | tr -d "'")
else
  GTK_THEME=""
  ICON_THEME=""
  WM_THEME=""
fi

# CPU
CPU=$(grep -m 1 'model name' /proc/cpuinfo | cut -d ':' -f 2 | sed 's/^[ \t]*//')
CPU=${CPU:-N/A}

# GPU (все видеокарты)
if command -v lspci >/dev/null 2>&1; then
  GPU=$(lspci | grep -i 'vga\|3d\|2d' | cut -d ':' -f3 | sed 's/^[ \t]*//' | paste -sd '; ' -)
else
  GPU="N/A"
fi

# RAM (used/total)
if command -v free >/dev/null 2>&1; then
  RAM=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
else
  RAM="N/A"
fi

# Диски (только / и /mnt/*, каждый на отдельной строке)
DISK_LINES=()
while IFS= read -r line; do
  DISK_LINES+=("$line")
done < <(df -h --output=target,used,size -x tmpfs -x devtmpfs | awk 'NR>1 && ($1=="/" || $1 ~ /^\/mnt\//){print $1 ": " $2 " / " $3}')

# Terminal
TERMINAL="${TERM:-N/A}"

# Battery (если есть)
BATTERY=""
if command -v acpi >/dev/null 2>&1; then
  BATTERY=$(acpi -b | head -n1 | cut -d ',' -f2 | sed 's/^ //')
elif command -v upower >/dev/null 2>&1; then
  BATTERY=$(upower -i $(upower -e | grep BAT) 2>/dev/null | grep -E 'percentage' | awk '{print $2}')
fi

# Locale
LOCALE=$(locale | grep LANG= | cut -d= -f2)
LOCALE=${LOCALE:-N/A}

# CPU Usage (средняя загрузка по 1 минуте)
if command -v top >/dev/null 2>&1; then
  CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
else
  CPU_USAGE="N/A"
fi

# Определение типа графической сессии (Wayland/X11/tty)
if [ -n "$WAYLAND_DISPLAY" ]; then
  SESSION_TYPE="Wayland"
elif [ -n "$DISPLAY" ]; then
  SESSION_TYPE="X11"
else
  SESSION_TYPE="TTY/Unknown"
fi

# Swap (used/total)
if command -v free >/dev/null 2>&1; then
  SWAP=$(free -h | awk '/Swap:/ {print $3 " / " $2}')
else
  SWAP="N/A"
fi

# Формируем строку сессии
if [ "$SESSION_TYPE" = "TTY/Unknown" ]; then
  SESSION_DISPLAY="TTY"
else
  SESSION_DISPLAY="$DE ($SESSION_TYPE)"
fi

# --- Формируем массив инфы ---
INFO_LINES=(
  "${GREEN}Hostname:${NC}     $HOSTNAME"
  " ${GREEN}OS:${NC}           $OS"
  "  ${GREEN}Kernel:${NC}       $KERNEL"
  "  ${GREEN}Uptime:${NC}       $UPTIME"
  "   ${GREEN}Shell:${NC}        $SHELL"
  "    ${GREEN}Resolution:${NC}   $RESOLUTION"
  " ${GREEN}DE / WM:${NC}      $SESSION_DISPLAY"
  " ${GREEN}WM Theme:${NC}     ${WM_THEME:-N/A}"
  " ${GREEN}GTK Theme:${NC}    ${GTK_THEME:-N/A}"
  " ${GREEN}Icon Theme:${NC}   ${ICON_THEME:-N/A}"
  " ${GREEN}CPU:${NC}          $CPU"
  " ${GREEN}GPU:${NC}          $GPU"
  " ${GREEN}RAM Usage:${NC}    $RAM"
  "    ${GREEN}Swap Usage:${NC}   $SWAP"
)
if [ ${#DISK_LINES[@]} -gt 0 ]; then
  INFO_LINES+=("    ${GREEN}Disk Usage:${NC}   ${DISK_LINES[0]}")
  for ((i=1; i<${#DISK_LINES[@]}; i++)); do
    INFO_LINES+=("                  ${DISK_LINES[i]}")
  done
else
  INFO_LINES+=("    ${GREEN}Disk Usage:${NC}   N/A")
fi
INFO_LINES+=(
  "       ${GREEN}Terminal:${NC}     $TERMINAL"
)
if [ -n "$BATTERY" ]; then
  INFO_LINES+=("          ${GREEN}Battery:${NC}       $BATTERY")
fi
INFO_LINES+=(
  "         ${GREEN}Locale:${NC}       $LOCALE"
  "          ${GREEN}CPU Usage:${NC}    $CPU_USAGE"
)

# --- Выровнять массивы по длине ---
max_lines=${#LOGO_LINES[@]}
[ ${#INFO_LINES[@]} -gt $max_lines ] && max_lines=${#INFO_LINES[@]}
while [ ${#LOGO_LINES[@]} -lt $max_lines ]; do
  LOGO_LINES+=("")
done
while [ ${#INFO_LINES[@]} -lt $max_lines ]; do
  INFO_LINES+=("")
done

# --- Вывод: лого и инфа в две колонки ---
logo_pad=8  # для красивого выравнивания совы
for ((i=0; i<max_lines; i++)); do
  printf "%*s${ORANGE}%-35s${NC}  %b\n" $logo_pad "" "${LOGO_LINES[i]}" "${INFO_LINES[i]}"
done

# Цветные квадратики (0-15)
echo
printf "${BLUE}Terminal colors:${NC}\n"
for i in {0..15}; do
  printf "\033[48;5;%sm  \033[0m" "$i"
done
printf "\n"
