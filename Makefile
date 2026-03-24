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
all: build

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
# 1. Сборка 
# --------------------------------------------------------------------
.PHONY: build
build: setup $(SRC)
	@echo "--- Компиляция $(SRC) ---"
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET)

# --------------------------------------------------------------------
# 2. Тестирование
# --------------------------------------------------------------------
.PHONY: test
test: build
	@echo "--- Запуск тестов ---"

	# Тест 1: Простое число (17)
	@echo "Тест 1: Проверка простого числа (17)..."
	./$(TARGET) 17 | grep -q "является простым" || { echo "FAIL: 17 не определено как простое"; exit 1; }
	
	# Тест 2: Составное число (18)
	@echo "Тест 2: Проверка составного числа (18)..."
	./$(TARGET) 18 | grep -q "не является простым" || { echo "FAIL: 18 не определено как составное"; exit 1; }

	# Тест 3: Некорректный ввод (строка)
	@echo "Тест 3: Проверка некорректного ввода (строка 'abc')..."
	./$(TARGET) abc | grep -q "Некорректный ввод" || { echo "FAIL: Строковый ввод обработан неверно"; exit 1; }

	@echo "--- Тесты пройдены ---"

# --------------------------------------------------------------------
# 3. Упаковка 
# --------------------------------------------------------------------
.PHONY: package
package: build test  
	@echo "--- Создание пакета .deb ---"
	
	# Подготовка структуры
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
# 4. Установка созданного пакета 
# --------------------------------------------------------------------
.PHONY: install
install: package
	@echo "--- Установка пакета (зависимости будут скачаны автоматически) ---"
	sudo apt install -y ./$(DEB_FILE)
