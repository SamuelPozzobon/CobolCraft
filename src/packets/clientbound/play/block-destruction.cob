IDENTIFICATION DIVISION.
PROGRAM-ID. SendPacket-BlockDestruction.

DATA DIVISION.
WORKING-STORAGE SECTION.
    COPY DD-PACKET REPLACING IDENTIFIER BY "play/clientbound/minecraft:block_destruction".
    *> buffer used to store the packet data
    01 PAYLOAD          PIC X(16).
    01 PAYLOADPOS       BINARY-LONG UNSIGNED.
    01 PAYLOADLEN       BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-CLIENT        BINARY-LONG UNSIGNED.
    01 LK-ENTITY-ID     BINARY-LONG.
    01 LK-LOCATION.
        02 LK-X             BINARY-LONG.
        02 LK-Y             BINARY-LONG.
        02 LK-Z             BINARY-LONG.
    *> 0-9 to set it, any other value to remove it
    01 LK-DESTROY-STAGE BINARY-CHAR.

PROCEDURE DIVISION USING LK-CLIENT LK-ENTITY-ID LK-LOCATION LK-DESTROY-STAGE.
    COPY PROC-PACKET-INIT.

    MOVE 1 TO PAYLOADPOS

    CALL "Encode-VarInt" USING LK-ENTITY-ID PAYLOAD PAYLOADPOS
    CALL "Encode-Position" USING LK-LOCATION PAYLOAD PAYLOADPOS
    CALL "Encode-Byte" USING LK-DESTROY-STAGE PAYLOAD PAYLOADPOS

    *> send packet
    COMPUTE PAYLOADLEN = PAYLOADPOS - 1
    CALL "SendPacket" USING LK-CLIENT PACKET-ID PAYLOAD PAYLOADLEN
    GOBACK.

END PROGRAM SendPacket-BlockDestruction.
