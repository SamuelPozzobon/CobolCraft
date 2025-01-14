IDENTIFICATION DIVISION.
PROGRAM-ID. SendPacket-UpdateTags.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
SELECT FD-PACKET-BLOB ASSIGN TO "blobs/update_tags_packets.txt"
    ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
    FD FD-PACKET-BLOB.
        01 PACKET-BLOB-REC      PIC X(64).
WORKING-STORAGE SECTION.
    COPY DD-CLIENTS.
    01 HNDL                     PIC X(4).
    01 ERRNO                    PIC 9(3).
    01 HEX                      PIC X(64).
    01 HEXLEN                   BINARY-LONG UNSIGNED.
    01 BUFFER                   PIC X(32).
    01 BUFFERLEN                BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-CLIENT                BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-CLIENT.
    *> Don't send packet if the client is already in an error state. It will be disconnected on the next tick.
    IF CLIENT-ERRNO-SEND(LK-CLIENT) NOT = 0
        EXIT PROGRAM
    END-IF
    MOVE CLIENT-HNDL(LK-CLIENT) TO HNDL

    OPEN INPUT FD-PACKET-BLOB
    MOVE 64 TO HEXLEN
    PERFORM UNTIL HEXLEN = 0
        MOVE SPACES TO HEX(1:64)
        READ FD-PACKET-BLOB INTO HEX
            AT END
                MOVE 0 TO HEXLEN
            NOT AT END
                CALL "DecodeHexString" USING HEX HEXLEN BUFFER BUFFERLEN
                CALL "SocketWrite" USING HNDL BUFFERLEN BUFFER GIVING ERRNO
                IF ERRNO NOT = 0
                    MOVE 0 TO HEXLEN
                    MOVE ERRNO TO CLIENT-ERRNO-SEND(LK-CLIENT)
                END-IF
        END-READ
    END-PERFORM
    CLOSE FD-PACKET-BLOB

    GOBACK.

END PROGRAM SendPacket-UpdateTags.
