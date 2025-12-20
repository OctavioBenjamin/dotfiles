#!/bin/bash
# Este script solo imprime el logo y el nombre

CURRENT_PROFILE=$(powerprofilesctl get)

if [ "$CURRENT_PROFILE" = "balanced" ]; then
    echo '{"text": "⚡ Equilibrado", "class": "balanced"}'
elif [ "$CURRENT_PROFILE" = "performance" ]; then
    echo '{"text": "🚀 Rendimiento", "class": "performance"}'
elif [ "$CURRENT_PROFILE" = "power-saver" ]; then
    echo '{"text": "🐢 Ahorro", "class": "powersaver"}'
else
    echo '{"text": "❓ Desconocido", "class": "unknown"}'
fi
