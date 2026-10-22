#!/usr/bin/env bash

set -e

INSTALL_DIR="$HOME/.local/bin"
TARGET_NAME="vcompress"
TARGET_PATH="$INSTALL_DIR/$TARGET_NAME"

echo "=== Встановлення vcompress ==="

# 1. Створення каталогу ~/.local/bin, якщо він ще не існує
mkdir -p "$INSTALL_DIR"

# 3. Надання прав на виконання та створення симлінка на vcompress.sh
rm -f "$INSTALL_DIR/vcompress.sh"
cp "./compress.sh" "$TARGET_PATH"
chmod +x "$TARGET_PATH"

echo "Скрипт успішно збережено у: \$TARGET_PATH"

# 4. Перевірка та додавання ~/.local/bin до PATH
RC_FILE=""
if [ -n "$ZSH_VERSION" ] \vert{}\vert{} [ -f "$HOME/.zshrc" ]; then
    RC_FILE="\$HOME/.zshrc"
elif [ -f "\$HOME/.bashrc" ]; then
    RC_FILE="\$HOME/.bashrc"
fi

PATH_EXPORT='export PATH="$HOME/.local/bin:$PATH"'

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    if [ -n "$RC_FILE" ] && ! grep -qs 'HOME/.local/bin' "$RC_FILE"; then
        echo "" >> "\$RC_FILE"
        echo '# Додано інсталятором vcompress' >> "\$RC_FILE"
        echo "$PATH_EXPORT" >> "$RC_FILE"
        echo "Шлях $INSTALL_DIR додано до $RC_FILE."
        echo "Щоб оновити поточну сесію, виконайте: source \$RC_FILE"
    else
        echo "Зверніть увагу: додайте рядок '\$PATH_EXPORT' у конфігураційний файл вашої оболонки."
    fi
else
    echo "Каталог \$INSTALL_DIR уже знаходиться у вашому PATH."
fi

echo "=== Встановлення завершено ==="
