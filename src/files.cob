*> --- Files-ReadAll ---
*> Given a file name, read the entire file into a buffer. If the file is larger than the buffer, only as much of the
*> file as will fit in the buffer is read. If the file is missing or empty, the buffer is left empty.
IDENTIFICATION DIVISION.
PROGRAM-ID. Files-ReadAll.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT OPTIONAL FD-FILE-IN
        ASSIGN TO FILENAME
        ORGANIZATION IS SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD FD-FILE-IN.
    01 FILE-BUFFER              PIC X(4096).
WORKING-STORAGE SECTION.
    01 FILE-BUFFER-LENGTH       BINARY-LONG UNSIGNED.
    01 FILENAME                 PIC X(255).
LINKAGE SECTION.
    01 LK-FILENAME              PIC X ANY LENGTH.
    01 LK-BUFFER                PIC X ANY LENGTH.
    01 LK-READ-COUNT            BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-FILENAME LK-BUFFER LK-READ-COUNT.
    MOVE LK-FILENAME TO FILENAME
    MOVE 0 TO LK-READ-COUNT

    OPEN INPUT FD-FILE-IN
    PERFORM UNTIL EXIT
        READ FD-FILE-IN
            AT END
                EXIT PERFORM
        END-READ
        COMPUTE FILE-BUFFER-LENGTH = FUNCTION MIN(
            LENGTH OF FILE-BUFFER,
            FUNCTION LENGTH(LK-BUFFER) - LK-READ-COUNT)
        EVALUATE FILE-BUFFER-LENGTH
            WHEN <= 0
                EXIT PERFORM
            WHEN OTHER
                MOVE FILE-BUFFER TO LK-BUFFER(LK-READ-COUNT + 1:FILE-BUFFER-LENGTH)
                ADD FILE-BUFFER-LENGTH TO LK-READ-COUNT
        END-EVALUATE
    END-PERFORM
    CLOSE FD-FILE-IN

    GOBACK.

END PROGRAM Files-ReadAll.

*> --- Files-WriteAll ---
*> Given a file name and a buffer, write the specified amount of data from the buffer to the file.
*> The file will be written in chunks of 4 kiB. If the data length is not a multiple of 4 kiB, the file may be padded.
IDENTIFICATION DIVISION.
PROGRAM-ID. Files-WriteAll.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT OPTIONAL FD-FILE-OUT
        ASSIGN TO FILENAME
        ORGANIZATION IS SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD FD-FILE-OUT.
    01 FILE-BUFFER              PIC X(4096).
WORKING-STORAGE SECTION.
    01 BYTES-WRITTEN            BINARY-LONG UNSIGNED.
    01 CHUNK-SIZE               BINARY-LONG UNSIGNED.
    01 FILENAME                 PIC X(255).
LINKAGE SECTION.
    01 LK-FILENAME              PIC X ANY LENGTH.
    01 LK-BUFFER                PIC X ANY LENGTH.
    01 LK-WRITE-COUNT           BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-FILENAME LK-BUFFER LK-WRITE-COUNT.
    MOVE LK-FILENAME TO FILENAME
    MOVE 0 TO BYTES-WRITTEN

    OPEN OUTPUT FD-FILE-OUT
    PERFORM UNTIL BYTES-WRITTEN >= LK-WRITE-COUNT
        COMPUTE CHUNK-SIZE = FUNCTION MIN(LENGTH OF FILE-BUFFER, LK-WRITE-COUNT - BYTES-WRITTEN)
        WRITE FILE-BUFFER FROM LK-BUFFER(BYTES-WRITTEN + 1:CHUNK-SIZE)
        ADD CHUNK-SIZE TO BYTES-WRITTEN
    END-PERFORM
    CLOSE FD-FILE-OUT

    GOBACK.

END PROGRAM Files-WriteAll.