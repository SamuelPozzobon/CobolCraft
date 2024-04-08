IDENTIFICATION DIVISION.
PROGRAM-ID. SendPacket-SetCenterChunk.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 PACKET-ID        BINARY-LONG             VALUE 82.
    *> buffer used to store the packet data
    01 PAYLOAD          PIC X(16).
    01 PAYLOADLEN       BINARY-LONG UNSIGNED.
    *> temporary data
    01 BUFFER           PIC X(8).
    01 BUFFERLEN        BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-HNDL          PIC X(4).
    01 LK-ERRNO         PIC 9(3).
    01 LK-CHUNK-X       BINARY-LONG.
    01 LK-CHUNK-Z       BINARY-LONG.

PROCEDURE DIVISION USING BY REFERENCE LK-HNDL LK-ERRNO LK-CHUNK-X LK-CHUNK-Z.
    MOVE 0 TO PAYLOADLEN

    *> X
    CALL "Encode-VarInt" USING LK-CHUNK-X BUFFER BUFFERLEN
    MOVE BUFFER(1:BUFFERLEN) TO PAYLOAD(PAYLOADLEN + 1:BUFFERLEN)
    ADD BUFFERLEN TO PAYLOADLEN

    *> Z
    CALL "Encode-VarInt" USING LK-CHUNK-Z BUFFER BUFFERLEN
    MOVE BUFFER(1:BUFFERLEN) TO PAYLOAD(PAYLOADLEN + 1:BUFFERLEN)
    ADD BUFFERLEN TO PAYLOADLEN

    *> send packet
    CALL "SendPacket" USING LK-HNDL PACKET-ID PAYLOAD PAYLOADLEN LK-ERRNO
    GOBACK.

END PROGRAM SendPacket-SetCenterChunk.