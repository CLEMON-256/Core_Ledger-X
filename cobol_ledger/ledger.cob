       IDENTIFICATION DIVISION.
       PROGRAM-ID. LEDGER-PROCESSOR.
       AUTHOR. CLEMON-256.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TX-FILE ASSIGN TO "tx_input.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT AUDIT-LOG ASSIGN TO "ledger_audit.log"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  TX-FILE.
       01  TX-RECORD.
           05  FILLER            PIC X(9).
           05  TX-AMOUNT         PIC 9(7)V99.
           05  FILLER            PIC X(16).

       FD  AUDIT-LOG.
       01  LOG-RECORD            PIC X(80).

       WORKING-STORAGE SECTION.
       01  SWITCHES.
           05  WS-EOF-SWITCH     PIC X     VALUE "N".
               88  END-OF-FILE             VALUE "Y".

       01  BALANCES.
           05  WS-TOTAL-BALANCE  PIC S9(9)V99 VALUE +000000000.00.
           05  WS-DISPLAY-BAL    PIC ----,---,---.99.
           05  WS-DISPLAY-AMT    PIC ZZZ,ZZZ.99.

       01  LOG-OUTPUT-LINES.
           05  LOG-HEADER.
               10  FILLER        PIC X(32) 
                   VALUE "=== IMMUTABLE LEDGER AUDIT ===".
           05  LOG-DETAIL.
               10  FILLER        PIC X(14) VALUE "PROCESSED TX: ".
               10  DET-AMT       PIC X(10).
               10  FILLER        PIC X(13) VALUE " | BALANCE: ".
               10  DET-BAL       PIC X(15).

       PROCEDURE DIVISION.
       000-MAIN-LOGIC.
           OPEN INPUT TX-FILE
                OUTPUT AUDIT-LOG.
           
           WRITE LOG-RECORD FROM LOG-HEADER.
           
           READ TX-FILE
               AT END SET END-OF-FILE TO TRUE
           END-READ.
           
           PERFORM 100-PROCESS-TRANSACTIONS UNTIL END-OF-FILE.
           
           CLOSE TX-FILE
                 AUDIT-LOG.
           STOP RUN.

       100-PROCESS-TRANSACTIONS.
           ADD TX-AMOUNT TO WS-TOTAL-BALANCE.
           
           MOVE TX-AMOUNT TO WS-DISPLAY-AMT.
           MOVE WS-TOTAL-BALANCE TO WS-DISPLAY-BAL.
           
           MOVE WS-DISPLAY-AMT TO DET-AMT.
           MOVE WS-DISPLAY-BAL TO DET-BAL.
           
           WRITE LOG-RECORD FROM LOG-DETAIL.
           DISPLAY "COBOL Core updated. Ledger balance: " WS-DISPLAY-BAL.
           
           READ TX-FILE
               AT END SET END-OF-FILE TO TRUE
           END-READ.
