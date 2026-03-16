# ====================================================================
# КОНФИГУРАЦИЯ
# ====================================================================

# Имя компилируемого файла 
TARGET := prime-checker

# Имя исходного файла
SRC := ConsoleApplication5.cpp 

# Переменные для сборки пакета
PKG_NAME := $(TARGET)-1.0
DEB_FILE := $(PKG_NAME).deb

# Компилятор и флаги
CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++17
LDFLAGS := 

# Директория для временной сборки пакета
BUILD_DIR := $(PKG_NAME)

# ====================================================================
# ОСНОВНЫЕ ЦЕЛИ
# ====================================================================

.PHONY: all clean package install

# Цель по умолчанию
all: $(TARGET)

# Компиляция: Создание исполняемого файла
$(TARGET): $(SRC)
	@echo "--- Компиляция $(TARGET) ---"
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

# --------------------------------------------------------------------
# 2. Создание пакета DEB 
# --------------------------------------------------------------------
package: clean setup_deb all
	@echo "--- Подготовка структуры пакета DEB ---"
	
	# 1. Создание временной структуры
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/usr/bin
	
	# 2. Копирование готового исполняемого файла
	cp $(TARGET) $(BUILD_DIR)/usr/bin/
	
	# 3. Создание директории DEBIAN и файла control
	mkdir -p $(BUILD_DIR)/DEBIAN
	
	echo "Package: $(TARGET)" > $(BUILD_DIR)/DEBIAN/control
	echo "Version: 1.0" >> $(BUILD_DIR)/DEBIAN/control
	echo "Architecture: amd64" >> $(BUILD_DIR)/DEBIAN/control
	echo "Maintainer: Team Name <team.email@example.com>" >> $(BUILD_DIR)/DEBIAN/control 
	
	# Зависимости: 
	echo "Depends: libc6 (>= 2.29)" >> $(BUILD_DIR)/DEBIAN/control 
	echo "Description: A simple C++ prime number checker tool." >> $(BUILD_DIR)/DEBIAN/control

	# 4. Сборка .deb пакета
	dpkg-deb --build $(BUILD_DIR)
	
	# Очистка временной папки (сохраняем .deb файл)
	rm -rf $(BUILD_DIR)
	@echo "--------------------------------------------------------------------"
	@echo "SUCCESS: DEB package created: $(DEB_FILE)"
	@echo "--------------------------------------------------------------------"

# --------------------------------------------------------------------
# 3. Установка созданного пакета 
# --------------------------------------------------------------------
.PHONY: install
install: package
	@echo "--- Installing the generated DEB package using apt ---"
	sudo apt install -y ./$(DEB_FILE)

# --------------------------------------------------------------------
# Очистка
# --------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "Очистка сгенерированных файлов..."
	rm -f $(TARGET)
	rm -f $(DEB_FILE)
	rm -rf $(BUILD_DIR)

# --------------------------------------------------------------------
# Вспомогательные цели
# --------------------------------------------------------------------
setup:
	# Проверка наличия dpkg-deb (для надежности в CI)
	@command -v dpkg-deb >/dev/null 2>&1 || { \
        echo >&2 "ERROR: dpkg-deb tool not found. Running apt install..."; \
        sudo apt-get update && sudo apt-get install -y dpkg-dev; \
    }

setup_deb: setup 