IDENTIFICATION DIVISION.
PROGRAM-ID. SendPacket-SetEquipment.

DATA DIVISION.
WORKING-STORAGE SECTION.
    COPY DD-PACKET REPLACING IDENTIFIER BY "play/clientbound/minecraft:set_equipment".
    *> buffer used to store the packet data
    01 PAYLOAD          PIC X(64000).
    01 PAYLOADPOS       BINARY-LONG UNSIGNED.
    01 PAYLOADLEN       BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-CLIENT        BINARY-LONG UNSIGNED.
    01 LK-ENTITY-ID     BINARY-LONG.
    *> 0..5: main hand, off hand, boots, leggings, chestplate, helmet; 6=body (for non-player entities)
    01 LK-SLOT-ENUM     BINARY-CHAR UNSIGNED.
    01 LK-EQUIPMENT.
        COPY DD-INVENTORY-SLOT REPLACING LEADING ==PREFIX== BY ==LK-EQUIPMENT==.

PROCEDURE DIVISION USING LK-CLIENT LK-ENTITY-ID LK-SLOT-ENUM LK-EQUIPMENT.
    COPY PROC-PACKET-INIT.

    MOVE 1 TO PAYLOADPOS

    *> entity ID
    CALL "Encode-VarInt" USING LK-ENTITY-ID PAYLOAD PAYLOADPOS

    *> equipment slot
    MOVE FUNCTION CHAR(LK-SLOT-ENUM + 1) TO PAYLOAD(PAYLOADPOS:1)
    ADD 1 TO PAYLOADPOS

    CALL "Encode-Byte" USING LK-EQUIPMENT-SLOT-COUNT PAYLOAD PAYLOADPOS
    IF LK-EQUIPMENT-SLOT-COUNT > 0
        CALL "Encode-VarInt" USING LK-EQUIPMENT-SLOT-ID PAYLOAD PAYLOADPOS
        MOVE LK-EQUIPMENT-SLOT-NBT-DATA(1:LK-EQUIPMENT-SLOT-NBT-LENGTH) TO PAYLOAD(PAYLOADPOS:LK-EQUIPMENT-SLOT-NBT-LENGTH)
        ADD LK-EQUIPMENT-SLOT-NBT-LENGTH TO PAYLOADPOS
    END-IF

    *> send packet
    COMPUTE PAYLOADLEN = PAYLOADPOS - 1
    CALL "SendPacket" USING LK-CLIENT PACKET-ID PAYLOAD PAYLOADLEN
    GOBACK.

END PROGRAM SendPacket-SetEquipment.
