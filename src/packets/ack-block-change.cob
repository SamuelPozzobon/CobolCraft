IDENTIFICATION DIVISION.
PROGRAM-ID. SendPacket-AckBlockChange.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 PACKET-ID        BINARY-LONG             VALUE H'05'.
    *> buffer used to store the packet data
    01 PAYLOAD          PIC X(8).
    01 PAYLOADLEN       BINARY-LONG UNSIGNED.
    *> temporary data
    01 BUFFER           PIC X(8).
    01 BUFFERLEN        BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-CLIENT        BINARY-LONG UNSIGNED.
    01 LK-SEQUENCE-ID   BINARY-LONG.

PROCEDURE DIVISION USING LK-CLIENT LK-SEQUENCE-ID.
    MOVE 0 TO PAYLOADLEN

    *> sequence ID
    CALL "Encode-VarInt" USING LK-SEQUENCE-ID BUFFER BUFFERLEN
    MOVE BUFFER(1:BUFFERLEN) TO PAYLOAD(PAYLOADLEN + 1:BUFFERLEN)
    ADD BUFFERLEN TO PAYLOADLEN

    *> send packet
    CALL "SendPacket" USING LK-CLIENT PACKET-ID PAYLOAD PAYLOADLEN
    GOBACK.

END PROGRAM SendPacket-AckBlockChange.
