# ====================================================================
# Настройки проекта
# ====================================================================

# Имя исполняемого файла
TARGET = prime_checker

# Имя исходного файла 
SRC = ConsoleApplication5.cpp

# Компилятор C++
CXX = g++

# Флаги компиляции:
# -Wall, -Wextra: Включить все предупреждения
# -std=c++17: Использовать стандарт C++17
# -O2: Оптимизация для производительности
CXXFLAGS = -Wall -Wextra -std=c++17 -O2

# ====================================================================
# Цели (Rules)
# ====================================================================

# Цель по умолчанию 
.PHONY: all
all: $(TARGET)

# --------------------------------------------------------------------
# 1. Сборка 
# --------------------------------------------------------------------
$(TARGET): $(SRC)
	# Проверка наличия компилятора 
	@command -v $(CXX) >/dev/null 2>&1 || { \
        echo >&2 "ERROR: Compiler $(CXX) is not found on the system."; \
        echo >&2 "Please install essential build tools (e.g., 'sudo apt install build-essential')."; \
        exit 1; \
    }
	@echo "--- Compiling $(SRC) with flags: $(CXXFLAGS) ---"
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET)

# --------------------------------------------------------------------
# Тестирование
# --------------------------------------------------------------------
.PHONY: run
run: $(TARGET)
	@echo "--- Running test with input 17 ---"
	./$(TARGET) 17

# --------------------------------------------------------------------
# Очистка
# --------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "Cleaning up generated files..."
	rm -f $(TARGET)

# --------------------------------------------------------------------
# 3. Создание DEB пакета 
# --------------------------------------------------------------------
.PHONY: package
package: clean all
	@echo "--- Preparing DEB package structure ---"
	
	# Проверка
	@command -v dpkg-deb >/dev/null 2>&1 || { \
        echo >&2 "ERROR: dpkg-deb tool not found. Please install 'dpkg-dev' package (e.g., 'sudo apt install dpkg-dev')."; \
        exit 1; \
    }
	
	# 1. Создание временной структуры
	rm -rf ./prime-checker-1.0
	mkdir -p ./prime-checker-1.0/usr/bin
	
	# 2. Копирование готового исполняемого файла
	cp $(TARGET) ./prime-checker-1.0/usr/bin/
	
	# 3. Создание директории DEBIAN и файла control
	mkdir -p ./prime-checker-1.0/DEBIAN
	echo "Package: prime-checker" > ./prime-checker-1.0/DEBIAN/control
	echo "Version: 1.0" >> ./prime-checker-1.0/DEBIAN/control
	echo "Architecture: amd64" >> ./prime-checker-1.0/DEBIAN/control
	echo "Maintainer: Team Name <team.email@example.com>" >> ./prime-checker-1.0/DEBIAN/control
	
	echo "Depends: build-essential" >> ./prime-checker-1.0/DEBIAN/control
	echo "Description: A simple C++ prime number checker tool for command line." >> ./prime-checker-1.0/DEBIAN/control

	# 4. Сборка .deb пакета
	dpkg-deb --build ./prime-checker-1.0
	
	@echo "--------------------------------------------------------------------"
	@echo "SUCCESS: DEB package created: prime-checker-1.0.deb"
	@echo "--------------------------------------------------------------------"