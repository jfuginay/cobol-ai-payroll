       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYROLL-CALCULATOR.
       AUTHOR. AI-GENERATED-FOR-GAUNTLET.
       DATE-WRITTEN. 2025-01-21.
      *----------------------------------------------------------------
      * COBOL Payroll Calculator - Demonstrates AI COBOL Generation
      * Calculates gross pay, taxes, and net pay with high precision
      *----------------------------------------------------------------
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPLOYEE-FILE ASSIGN TO "employee-data.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REPORT-FILE ASSIGN TO "payroll-report.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD  EMPLOYEE-FILE.
       01  EMPLOYEE-RECORD.
           05  EMP-ID              PIC 9(5).
           05  EMP-NAME            PIC X(30).
           05  EMP-HOURLY-RATE     PIC 999V99.
           05  EMP-HOURS-WORKED    PIC 999V99.
           05  EMP-STATE           PIC XX.
           05  EMP-STATUS          PIC X.
           05  EMP-ALLOWANCES      PIC 9.
       
       FD  REPORT-FILE.
       01  REPORT-LINE             PIC X(80).
       
       WORKING-STORAGE SECTION.
       01  WS-EOF                  PIC X VALUE 'N'.
       01  WS-CURRENT-DATE.
           05  WS-YEAR             PIC 9(4).
           05  WS-MONTH            PIC 99.
           05  WS-DAY              PIC 99.
       
       01  PAYROLL-CALCULATIONS.
           05  WS-REGULAR-HOURS    PIC 999V99.
           05  WS-OVERTIME-HOURS   PIC 999V99.
           05  WS-REGULAR-PAY      PIC 9(5)V99.
           05  WS-OVERTIME-PAY     PIC 9(5)V99.
           05  WS-GROSS-PAY        PIC 9(5)V99.
           05  WS-FEDERAL-TAX      PIC 9(5)V99.
           05  WS-STATE-TAX        PIC 9(5)V99.
           05  WS-SOC-SEC          PIC 9(5)V99.
           05  WS-MEDICARE         PIC 9(5)V99.
           05  WS-TOTAL-DED        PIC 9(5)V99.
           05  WS-NET-PAY          PIC 9(5)V99.
       
       01  TAX-RATES.
           05  FEDERAL-RATE        PIC V999 VALUE .120.
           05  CA-STATE-RATE       PIC V999 VALUE .060.
           05  NY-STATE-RATE       PIC V999 VALUE .065.
           05  TX-STATE-RATE       PIC V999 VALUE .000.
           05  FL-STATE-RATE       PIC V999 VALUE .000.
           05  WA-STATE-RATE       PIC V999 VALUE .000.
           05  SOC-SEC-RATE        PIC V9999 VALUE .0620.
           05  MEDICARE-RATE       PIC V9999 VALUE .0145.
       
       01  DISPLAY-AMOUNTS.
           05  DSP-REGULAR-HOURS   PIC ZZ9.99.
           05  DSP-OVERTIME-HOURS  PIC ZZ9.99.
           05  DSP-HOURLY-RATE     PIC $$$9.99.
           05  DSP-REGULAR-PAY     PIC $$,$$9.99.
           05  DSP-OVERTIME-PAY    PIC $$,$$9.99.
           05  DSP-GROSS-PAY       PIC $$,$$9.99.
           05  DSP-FEDERAL-TAX     PIC $$,$$9.99.
           05  DSP-STATE-TAX       PIC $$,$$9.99.
           05  DSP-SOC-SEC         PIC $$,$$9.99.
           05  DSP-MEDICARE        PIC $$,$$9.99.
           05  DSP-TOTAL-DED       PIC $$,$$9.99.
           05  DSP-NET-PAY         PIC $$,$$9.99.
       
       01  REPORT-HEADER.
           05  FILLER              PIC X(35) VALUE
               "EMPLOYEE PAYROLL STATEMENT".
           05  FILLER              PIC X(45) VALUE SPACES.
       
       01  SEPARATOR-LINE          PIC X(80) VALUE ALL "=".
       01  BLANK-LINE              PIC X(80) VALUE SPACES.
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZATION
           PERFORM PROCESS-EMPLOYEES UNTIL WS-EOF = 'Y'
           PERFORM TERMINATION
           STOP RUN.
       
       INITIALIZATION.
           OPEN INPUT EMPLOYEE-FILE
           OPEN OUTPUT REPORT-FILE
           ACCEPT WS-CURRENT-DATE FROM DATE YYYYMMDD
           PERFORM READ-EMPLOYEE.
       
       READ-EMPLOYEE.
           READ EMPLOYEE-FILE
               AT END MOVE 'Y' TO WS-EOF
           END-READ.
       
       PROCESS-EMPLOYEES.
           PERFORM CALCULATE-PAY
           PERFORM CALCULATE-DEDUCTIONS
           PERFORM CALCULATE-NET-PAY
           PERFORM PRINT-PAY-STUB
           PERFORM READ-EMPLOYEE.
       
       CALCULATE-PAY.
           IF EMP-HOURS-WORKED > 40
               MOVE 40 TO WS-REGULAR-HOURS
               COMPUTE WS-OVERTIME-HOURS = EMP-HOURS-WORKED - 40
           ELSE
               MOVE EMP-HOURS-WORKED TO WS-REGULAR-HOURS
               MOVE ZERO TO WS-OVERTIME-HOURS
           END-IF
           
           COMPUTE WS-REGULAR-PAY = WS-REGULAR-HOURS * EMP-HOURLY-RATE
           COMPUTE WS-OVERTIME-PAY = WS-OVERTIME-HOURS * 
                                     EMP-HOURLY-RATE * 1.5
           COMPUTE WS-GROSS-PAY = WS-REGULAR-PAY + WS-OVERTIME-PAY.
       
       CALCULATE-DEDUCTIONS.
           COMPUTE WS-FEDERAL-TAX = WS-GROSS-PAY * FEDERAL-RATE
           
           EVALUATE EMP-STATE
               WHEN "CA" COMPUTE WS-STATE-TAX = 
                         WS-GROSS-PAY * CA-STATE-RATE
               WHEN "NY" COMPUTE WS-STATE-TAX = 
                         WS-GROSS-PAY * NY-STATE-RATE
               WHEN "TX" COMPUTE WS-STATE-TAX = 
                         WS-GROSS-PAY * TX-STATE-RATE
               WHEN "FL" COMPUTE WS-STATE-TAX = 
                         WS-GROSS-PAY * FL-STATE-RATE
               WHEN "WA" COMPUTE WS-STATE-TAX = 
                         WS-GROSS-PAY * WA-STATE-RATE
               WHEN OTHER MOVE ZERO TO WS-STATE-TAX
           END-EVALUATE
           
           COMPUTE WS-SOC-SEC = WS-GROSS-PAY * SOC-SEC-RATE
           COMPUTE WS-MEDICARE = WS-GROSS-PAY * MEDICARE-RATE
           
           COMPUTE WS-TOTAL-DED = WS-FEDERAL-TAX + WS-STATE-TAX +
                                  WS-SOC-SEC + WS-MEDICARE.
       
       CALCULATE-NET-PAY.
           COMPUTE WS-NET-PAY = WS-GROSS-PAY - WS-TOTAL-DED.
       
       PRINT-PAY-STUB.
           MOVE WS-REGULAR-HOURS TO DSP-REGULAR-HOURS
           MOVE WS-OVERTIME-HOURS TO DSP-OVERTIME-HOURS
           MOVE EMP-HOURLY-RATE TO DSP-HOURLY-RATE
           MOVE WS-REGULAR-PAY TO DSP-REGULAR-PAY
           MOVE WS-OVERTIME-PAY TO DSP-OVERTIME-PAY
           MOVE WS-GROSS-PAY TO DSP-GROSS-PAY
           MOVE WS-FEDERAL-TAX TO DSP-FEDERAL-TAX
           MOVE WS-STATE-TAX TO DSP-STATE-TAX
           MOVE WS-SOC-SEC TO DSP-SOC-SEC
           MOVE WS-MEDICARE TO DSP-MEDICARE
           MOVE WS-TOTAL-DED TO DSP-TOTAL-DED
           MOVE WS-NET-PAY TO DSP-NET-PAY
           
           WRITE REPORT-LINE FROM BLANK-LINE
           WRITE REPORT-LINE FROM REPORT-HEADER
           WRITE REPORT-LINE FROM SEPARATOR-LINE
           
           STRING "Employee ID: " EMP-ID DELIMITED BY SIZE
               INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "Employee Name: " EMP-NAME DELIMITED BY SIZE
               INTO REPORT-LINE
           WRITE REPORT-LINE
           
           MOVE "Pay Period: WEEKLY" TO REPORT-LINE
           WRITE REPORT-LINE
           WRITE REPORT-LINE FROM BLANK-LINE
           
           MOVE "EARNINGS:" TO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  Regular Hours: " DSP-REGULAR-HOURS 
                  " @ " DSP-HOURLY-RATE " = " DSP-REGULAR-PAY
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  Overtime Hours: " DSP-OVERTIME-HOURS 
                  " @ " DSP-HOURLY-RATE " x 1.5 = " DSP-OVERTIME-PAY
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  GROSS PAY: " DSP-GROSS-PAY
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           WRITE REPORT-LINE FROM BLANK-LINE
           
           MOVE "DEDUCTIONS:" TO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  Federal Tax: " DSP-FEDERAL-TAX
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  State Tax (" EMP-STATE "): " DSP-STATE-TAX
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  Social Security: " DSP-SOC-SEC
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  Medicare: " DSP-MEDICARE
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           
           STRING "  TOTAL DEDUCTIONS: " DSP-TOTAL-DED
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           WRITE REPORT-LINE FROM BLANK-LINE
           
           STRING "NET PAY: " DSP-NET-PAY
                  DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           WRITE REPORT-LINE FROM SEPARATOR-LINE
           
           DISPLAY "Processed: " EMP-NAME " - Net Pay: " DSP-NET-PAY.
       
       TERMINATION.
           CLOSE EMPLOYEE-FILE
           CLOSE REPORT-FILE
           DISPLAY "Payroll processing complete!"
           DISPLAY "Report saved to payroll-report.txt".