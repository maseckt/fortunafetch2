#!/bin/bash

# Цвета ANSI
ORANGE='\033[0;33m'   # оранжевый/желтый
BLUE='\033[0;34m'     # синий
GREEN='\033[0;32m'    # зеленый
NC='\033[0m'          # сброс цвета

# --- Логотип ---
echo -e "${ORANGE}"
cat << "EOF"
        ░ ░░░░                            ░░░░░░
        ░░░░░░                            ░░░░░░
        ░░░▓▓░░░░   ░░░░░░░░░░░░░░░░░  ░░░░▒▒░░
         ░░▓▓▓▓▓▓░░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░░░░▒▒▒▒▒▒░░
           ░▓▓▓▓▓▓▓▓▓░░░▒▒▒▒▒▒▒▒░░░▒▒▒▒▒▒▒▒▒▒░
           ░░▓▓▓▓▓▓▓▓▓▓▒░░▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒░░
        ░░░▒▓▓░░░░░░░░░▓▓░░▒▒░░▒▒░░░░░░░░░▒▒░░░░
        ░░▓▓▓░   ░██░░░░▓▓░░░▒▒▒░░▒░██░░░░░▒▒▒░░
        ░░▓▓░░ ░░██░░░█░░▓▓░░▒▒░░▒░░░██░  ░░▒▒░
        ░░▓▓░  ░░███▓█▓░░▓▓░░▒▒░░██▓███░░ ░░▒▒░░
        ░░▓▓░░   ░░█▓░░░░▓▓░░▒▒░░░░▓█░░   ░░▒▒░░
         ░░▓▓░░░░  ░░░░▒▓▓░░░░▒▒░░░░░░  ░░░░▒▒░░░
        ░░░░▓▓▓▓░░░░░▓▓▓▒░░▒▒░░▒▒▒▒░░░░░▒▒▒▒░░░░
           ░░░░▓▓▓▓▓▓▒░░░░░▒▒░░░░░▒▒▒▒▒▒▒░░░░
           ░░░▒▒░░░░░▒▒▒▒▒░░░░▒▒▒▒▒░░░░░▒▒░░░
           ░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░
              ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
                 ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░
                 ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░
                   ░░░░▒▒▒▒▒▒▒▒▒▒░░░░
                      ░░░▒▒▒▒▒▒░░░
                      ░░░░░▒▒░░░░░
                         ░░░░░░
EOF
echo -e "${NC}"

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
DISKS=$(df -h --output=target,used,size -x tmpfs -x devtmpfs | awk 'NR>1 && ($1=="/" || $1 ~ /^\/mnt\//){print $1 ": " $2 " / " $3}' )
DISKS=${DISKS:-N/A}

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

# --- Вывод с цветами ---

echo -e "${BLUE}┌───────────────────────────────┐${NC}"
echo -e "${BLUE}│       ${GREEN}System Information      ${BLUE}│${NC}"
echo -e "${BLUE}└───────────────────────────────┘${NC}"

echo -e "${GREEN}Hostname:${NC}      $HOSTNAME"
echo -e "${GREEN}OS:${NC}            $OS"
echo -e "${GREEN}Kernel:${NC}        $KERNEL"
echo -e "${GREEN}Uptime:${NC}        $UPTIME"
echo -e "${GREEN}Shell:${NC}         $SHELL"
echo -e "${GREEN}Resolution:${NC}    $RESOLUTION"
echo -e "${GREEN}DE / WM:${NC}       $SESSION_DISPLAY"
echo -e "${GREEN}WM Theme:${NC}      ${WM_THEME:-N/A}"
echo -e "${GREEN}GTK Theme:${NC}     ${GTK_THEME:-N/A}"
echo -e "${GREEN}Icon Theme:${NC}    ${ICON_THEME:-N/A}"
echo -e "${GREEN}CPU:${NC}           $CPU"
echo -e "${GREEN}GPU:${NC}           $GPU"
echo -e "${GREEN}RAM Usage:${NC}     $RAM"
echo -e "${GREEN}Swap Usage:${NC}    $SWAP"
echo -e "${GREEN}Disks Usage:${NC}   $(echo "$DISKS" | head -n1)"
if [ "$(echo "$DISKS" | wc -l)" -gt 1 ]; then
  echo "$DISKS" | tail -n +2 | while read line; do
    printf "               %s\n" "$line"
  done
fi
echo -e "${GREEN}Terminal:${NC}      $TERMINAL"
if [ -n "$BATTERY" ]; then
  echo -e "${GREEN}Battery:${NC}       $BATTERY"
fi
echo -e "${GREEN}Locale:${NC}        $LOCALE"
echo -e "${GREEN}CPU Usage:${NC}     $CPU_USAGE"

# Внизу цвета терминала для проверки темы
echo -e "\n${BLUE}Terminal colors:${NC}"
for i in {0..15}; do
  echo -ne "\033[48;5;${i}m  \033[0m"
done
echo
