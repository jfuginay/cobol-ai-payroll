# Makefile for COBOL Payroll Calculator

COBC = cobc
COBCFLAGS = -x -Wall
TARGET = payroll
SOURCE = payroll.cob

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(COBC) $(COBCFLAGS) -o $(TARGET) $(SOURCE)

clean:
	rm -f $(TARGET) *.int *.asm *.c.l* *.c.h *.c payroll-report.txt

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "Running COBOL payroll calculation..."
	./$(TARGET)
	@echo "\nPayroll report generated:"
	@cat payroll-report.txt

install-deps:
	npm install

start-api: $(TARGET)
	npm start

.PHONY: all clean run test install-deps start-api