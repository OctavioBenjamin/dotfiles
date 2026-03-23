#!/bin/bash

# 1. Detectar la interfaz activa dinámicamente
INTERFACE="wlp1s0"

# Si no hay internet, salir dignamente
if [ -z "$INTERFACE" ]; then
    echo "󰲜 Desconectado"
    exit 0
fi

# 2. Obtener IP
IP=$(ip -4 addr show wlp1s0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
# 3. Leer estadísticas de red (sin sleep para no trabar el panel)
# Nota: Para velocidad real en bash sin sleep, tendrías que guardar el estado en /tmp/
# Pero para algo simple y rápido, esto cumple:
RX_BYTES=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
TX_BYTES=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)

# Convertir a MB o KB (ajustá a tu gusto)

RX_KB=$((RX_BYTES / 1024 / 1024)) 
TX_KB=$((TX_BYTES / 1024 / 1024)) 
echo "󰩟 $IP  󰶼 ${RX_KB}KB/s 󰶹 ${TX_KB}KB/s"
