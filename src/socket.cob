*> --- Socket-Listen ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Socket-Listen.

DATA DIVISION.
LINKAGE SECTION.
    01 LK-PORT              PIC X(5).
    01 LK-LISTEN            PIC X(4).
    01 LK-ERRNO             PIC 9(3).

PROCEDURE DIVISION USING LK-PORT LK-LISTEN LK-ERRNO.
    CALL "CBL_GC_SOCKET" USING "00" LK-PORT LK-LISTEN GIVING LK-ERRNO.

END PROGRAM Socket-Listen.

*> --- Socket-Close ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Socket-Close.

DATA DIVISION.
LINKAGE SECTION.
    01 LK-HNDL              PIC X(4).
    01 LK-ERRNO             PIC 9(3).

PROCEDURE DIVISION USING LK-HNDL LK-ERRNO.
    CALL "CBL_GC_SOCKET" USING "06" LK-HNDL GIVING LK-ERRNO.

END PROGRAM Socket-Close.

*> --- Socket-Poll ---
*> Poll the server socket to retrieve a connection that wants to be accepted or send data.
*> Only connections immediately available are returned.
IDENTIFICATION DIVISION.
PROGRAM-ID. Socket-Poll.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> The socket library requires X(6) for the timeout parameter
    01 TIMEOUT-PARAM        PIC 9(6)                VALUE 1.
LINKAGE SECTION.
    01 LK-SERVER-HNDL       PIC X(4).
    01 LK-ERRNO             PIC 9(3).
    01 LK-CLIENT-HNDL       PIC X(4).

PROCEDURE DIVISION USING LK-SERVER-HNDL LK-ERRNO LK-CLIENT-HNDL.
    CALL "CBL_GC_SOCKET" USING "10" LK-SERVER-HNDL LK-CLIENT-HNDL TIMEOUT-PARAM GIVING LK-ERRNO.

END PROGRAM Socket-Poll.

*> --- Socket-Read ---
*> Read a raw byte array from the socket. At most 64000 bytes can be read at once.
*> Only bytes that are immediately available are read, and the number is returned in LK-READ-COUNT.
IDENTIFICATION DIVISION.
PROGRAM-ID. Socket-Read.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 CHUNK-BUFFER         PIC X(64000).
    *> The socket library requires X(5) for the read count and X(6) for the timeout parameter
    01 READ-COUNT-PARAM     PIC 9(5).
    01 TIMEOUT-PARAM        PIC 9(6)                VALUE 1.
LINKAGE SECTION.
    01 LK-HNDL              PIC X(4).
    01 LK-ERRNO             PIC 9(3).
    01 LK-READ-COUNT        BINARY-LONG UNSIGNED.
    01 LK-BUFFER            PIC X ANY LENGTH.

PROCEDURE DIVISION USING LK-HNDL LK-ERRNO LK-READ-COUNT LK-BUFFER.
    IF LK-READ-COUNT < 1 OR LK-READ-COUNT > 64000
        MOVE 1 TO LK-ERRNO
        GOBACK
    END-IF

    MOVE LK-READ-COUNT TO READ-COUNT-PARAM
    CALL "CBL_GC_SOCKET" USING "08" LK-HNDL READ-COUNT-PARAM LK-BUFFER TIMEOUT-PARAM GIVING LK-ERRNO

    *> Treat timeout as a successful read of 0 bytes
    IF LK-ERRNO = 4
        MOVE 0 TO LK-READ-COUNT
        MOVE 0 TO LK-ERRNO
        GOBACK
    END-IF

    *> Treat "fewer bytes read than requested" as a successful read
    IF LK-ERRNO = 2
        MOVE 0 TO LK-ERRNO
    END-IF

    MOVE READ-COUNT-PARAM TO LK-READ-COUNT

    GOBACK.

END PROGRAM Socket-Read.

*> --- Socket-Write ---
*> Write a buffer to the client.
IDENTIFICATION DIVISION.
PROGRAM-ID. Socket-Write.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 CHUNK-BUFFER         PIC X(64000).
    01 BYTES-WRITTEN        BINARY-LONG UNSIGNED.
    01 REMAINING            BINARY-LONG UNSIGNED.
    01 CHUNK-SIZE           PIC 9(5).
LINKAGE SECTION.
    01 LK-HNDL              PIC X(4).
    01 LK-ERRNO             PIC 9(3).
    01 LK-WRITE-COUNT       BINARY-LONG UNSIGNED.
    01 LK-BUFFER            PIC X ANY LENGTH.

PROCEDURE DIVISION USING LK-HNDL LK-ERRNO LK-WRITE-COUNT LK-BUFFER.
    IF LK-WRITE-COUNT < 1
        *> Nothing to write
        MOVE 0 TO LK-ERRNO
        GOBACK
    END-IF

    *> If the number of bytes to write is at most 64000, we can write it all at once
    IF LK-WRITE-COUNT <= 64000
        MOVE LK-WRITE-COUNT TO CHUNK-SIZE
        CALL "CBL_GC_SOCKET" USING "03" LK-HNDL CHUNK-SIZE LK-BUFFER GIVING LK-ERRNO
        GOBACK
    END-IF

    *> Write in chunks of up to 64000 bytes
    MOVE 0 TO BYTES-WRITTEN
    PERFORM UNTIL BYTES-WRITTEN >= LK-WRITE-COUNT
        COMPUTE REMAINING = LK-WRITE-COUNT - BYTES-WRITTEN
        COMPUTE CHUNK-SIZE = FUNCTION MIN(64000, REMAINING)
        MOVE LK-BUFFER(BYTES-WRITTEN + 1:CHUNK-SIZE) TO CHUNK-BUFFER(1:CHUNK-SIZE)
        CALL "CBL_GC_SOCKET" USING "03" LK-HNDL CHUNK-SIZE CHUNK-BUFFER GIVING LK-ERRNO
        IF LK-ERRNO NOT = 0
            EXIT PERFORM
        END-IF
        ADD CHUNK-SIZE TO BYTES-WRITTEN
    END-PERFORM

    GOBACK.

END PROGRAM Socket-Write.
