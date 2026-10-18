#!/bin/bash
set -e

echo "🚀 Начинаем установку локального Джарвиса..."

# 1. Проверка прав (скрипт использует pacman)
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root (sudo ./install.sh)"
  exit 1
fi

# Определяем реального пользователя (если запущено через sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# 2. Установка зависимостей (Ollama и aichat)
echo "📦 Проверка и установка зависимостей..."
# ВОТ ЗДЕСЬ БЫЛА ПРОПУЩЕНА СТРОКА:
pacman -S --needed --noconfirm ollama aichat curl

# 3. Запуск и включение сервиса Ollama
echo "🔄 Запуск сервиса Ollama..."
systemctl enable --now ollama

# Ждём пару секунд, чтобы сервис поднялся
sleep 3

# 4. Скачивание базовой модели
echo "🧠 Скачивание модели Qwen3 8B (это может занять время)..."
sudo -u "$REAL_USER" ollama pull qwen3:8b

# 5. Создание кастомной модели Джарвиса
echo "🎭 Создание модели jarvis-v2..."
sudo -u "$REAL_USER" ollama create jarvis-v2 -f ./configs/Modelfile-jarvis-v2

# 6. Настройка aichat
echo "⚙️ Настройка aichat..."
mkdir -p "$REAL_HOME/.config/aichat/roles"
cp ./configs/aichat-config.yaml "$REAL_HOME/.config/aichat/config.yaml"
cp ./configs/jarvis-role.md "$REAL_HOME/.config/aichat/roles/jarvis.md"

# Меняем владельца скопированных файлов на реального пользователя
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/aichat"

echo "✅ Установка завершена!"
echo "Попробуйте: aichat \"привет\""
echo "Или выполните команду: aichat -e \"покажи использование диска\""
