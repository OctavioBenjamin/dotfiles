#!/bin/bash

# 1. Detectar la interfaz activa dinámicamente
INTERFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')
if [ -z "$INTERFACE" ]; then
    INTERFACE=$(ip link show | grep 'state UP' | awk -F': ' '{print $2}' | head -n 1)
fi

# Si no hay internet, salir dignamente
if [ -z "$INTERFACE" ]; then
    echo "󰲜 Desconectado"
    exit 0
fi

# 2. Obtener IP
IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

# 3. Leer estadísticas de red para calcular velocidad real
RX_BYTES_FILE="/tmp/net_info_rx_$INTERFACE"
TX_BYTES_FILE="/tmp/net_info_tx_$INTERFACE"
LAST_TIME_FILE="/tmp/net_info_time_$INTERFACE"

NOW=$(date +%s%N)
RX_BYTES_NOW=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
TX_BYTES_NOW=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)

if [ -f "$RX_BYTES_FILE" ]; then
    RX_BYTES_OLD=$(cat "$RX_BYTES_FILE")
    TX_BYTES_OLD=$(cat "$TX_BYTES_FILE")
    LAST_TIME=$(cat "$LAST_TIME_FILE")
    
    # Tiempo transcurrido en segundos (con decimales)
    DIFF_TIME_NS=$((NOW - LAST_TIME))
    # Evitar división por cero
    if [ "$DIFF_TIME_NS" -le 0 ]; then DIFF_TIME_NS=1000000000; fi
    
    RX_DIFF=$((RX_BYTES_NOW - RX_BYTES_OLD))
    TX_DIFF=$((TX_BYTES_NOW - TX_BYTES_OLD))
    
    # Velocidad en KB/s ( bytes / (ns/10^9) / 1024 )
    # Usamos awk para manejar los decimales del tiempo si fuera necesario, 
    # pero aquí simplificamos a escala entera para bash.
    RX_KS=$(( RX_DIFF * 1000000000 / DIFF_TIME_NS / 1024 ))
    TX_KS=$(( TX_DIFF * 1000000000 / DIFF_TIME_NS / 1024 ))
else
    RX_KS=0
    TX_KS=0
fi

# Guardar estado para la próxima ejecución
echo "$RX_BYTES_NOW" > "$RX_BYTES_FILE"
echo "$TX_BYTES_NOW" > "$TX_BYTES_FILE"
echo "$NOW" > "$LAST_TIME_FILE"

# Formatear salida (si supera 1024 KB/s, mostrar MB/s)
format_speed() {
    local speed=$1
    if [ "$speed" -gt 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $speed/1024}")MB/s"
    else
        echo "${speed}KB/s"
    fi
}

RX_F=$(format_speed $RX_KS)
TX_F=$(format_speed $TX_KS)

echo "󰩟 $IP  󰶼 $RX_F 󰶹 $TX_F"
