#!/bin/bash

# Directorio donde estás parado (dotfiles)
DIR=$(pwd)

echo "🚀 Iniciando copia de dotfiles..."

# 1. Copiar el contenido de .config a ~/.config
if [ -d "$DIR/.config" ]; then
    echo "📂 Copiando configuraciones a ~/.config..."
    mkdir -p ~/.config
    # Copia recursiva y forzada del contenido
    cp -rf "$DIR/.config/"* ~/.config/
fi

# 2. Copiar archivos sueltos de la raíz al Home (~)
# Lista explícita para no copiar basura (.git, README, etc.)
FILES_TO_HOME=(".zshrc" ".oh-my-zsh" "fastfetch")

echo "🏠 Copiando archivos al Home..."
for file in "${FILES_TO_HOME[@]}"; do
    if [ -e "$DIR/$file" ]; then
        echo "  -> Copiando $file"
        cp -rf "$DIR/$file" ~/
    else
        echo "⚠️  No se encontró: $file"
    fi
done

echo "✅ ¡Instalación completada!"
