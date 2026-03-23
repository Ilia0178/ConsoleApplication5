# ====================================================================
# Настройки проекта
# ====================================================================

# ====================================================================
# Настройки проекта
# ====================================================================
TARGET = prime_checker
SRC = ConsoleApplication5.cpp
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17 -O2
PKG_NAME = prime_checker-1.0
DEB_FILE = $(PKG_NAME).deb

# Цель по умолчанию 
.PHONY: all
all: $(TARGET)

# --------------------------------------------------------------------
# 0. Подготовка среды 
# --------------------------------------------------------------------
.PHONY: setup
setup:
	@echo "--- Проверка и установка необходимых инструментов ---"
	@command -v apt >/dev/null 2>&1 || { \
        echo >&2 "ERROR: apt package manager not found. This script is for Debian/Ubuntu systems."; \
        exit 1; \
    }
	
	sudo apt update
	
	@dpkg -s build-essential >/dev/null 2>&1 || { \
        echo "Пакет build-essential не найден. Установка..."; \
        sudo apt install -y build-essential; \
    }
	
	@dpkg -s dpkg-dev >/dev/null 2>&1 || { \
        echo "Пакет dpkg-dev не найден. Установка..."; \
        sudo apt install -y dpkg-dev; \
    }
	@echo "Проверка зависимостей сборки завершена."

# --------------------------------------------------------------------
# 1. Сборка ИСПОЛНЯЕМОГО ФАЙЛА
# --------------------------------------------------------------------
$(TARGET): setup $(SRC)
	@echo "--- Компиляция $(SRC) ---"
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET)

# --------------------------------------------------------------------
# 2. Создание пакета DEB 
# --------------------------------------------------------------------
.PHONY: package
package: setup $(TARGET)
	@echo "--- Создание пакета .deb ---"
	
	# Проверка наличия dpkg-deb
	@command -v dpkg-deb >/dev/null 2>&1 || { echo >&2 "ERROR: dpkg-deb tool not found."; exit 1; }
	
	# Подготовка структуры
	rm -rf $(PKG_NAME)
	mkdir -p $(PKG_NAME)/usr/bin
	
	# Копирование скомпилированного файла в структуру пакета
	cp $(TARGET) $(PKG_NAME)/usr/bin/
	
	# Создание control-файла
	mkdir -p $(PKG_NAME)/DEBIAN
	echo "Package: prime-checker" > $(PKG_NAME)/DEBIAN/control
	echo "Version: 1.0" >> $(PKG_NAME)/DEBIAN/control
	echo "Architecture: amd64" >> $(PKG_NAME)/DEBIAN/control
	echo "Maintainer: Team Name <team.email@example.com>" >> $(PKG_NAME)/DEBIAN/control 
	echo "Depends: libc6 (>= 2.29), libstdc++6 (>= 9)" >> $(PKG_NAME)/DEBIAN/control 
	echo "Description: A simple C++ prime number checker tool." >> $(PKG_NAME)/DEBIAN/control

	# Сборка пакета
	dpkg-deb --build $(PKG_NAME)
	
	rm -rf $(PKG_NAME)
	rm -f $(TARGET)


# --------------------------------------------------------------------
# 3. Установка созданного пакета
# --------------------------------------------------------------------
.PHONY: install
install: package
	@echo "--- Установка пакета (зависимости будут скачаны автоматически) ---"
	sudo apt install -y ./$(DEB_FILE)

