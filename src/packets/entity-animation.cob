IDENTIFICATION DIVISION.
PROGRAM-ID. SendPacket-EntityAnimation.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 PACKET-ID        BINARY-LONG             VALUE 3.
    *> buffer used to store the packet data
    01 PAYLOAD          PIC X(8).
    01 PAYLOADLEN       BINARY-LONG UNSIGNED.
    *> temporary data
    01 BUFFER           PIC X(8).
    01 BUFFERLEN        BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-HNDL          PIC X(4).
    01 LK-ERRNO         PIC 9(3).
    01 LK-ENTITY-ID     BINARY-LONG.
    *> Possible values: https://wiki.vg/Protocol#Entity_Animation
    01 LK-ANIMATION     BINARY-CHAR UNSIGNED.

PROCEDURE DIVISION USING BY REFERENCE LK-HNDL LK-ERRNO LK-ENTITY-ID LK-ANIMATION.
    MOVE 0 TO PAYLOADLEN

    *> entity ID
    CALL "Encode-VarInt" USING LK-ENTITY-ID BUFFER BUFFERLEN
    MOVE BUFFER(1:BUFFERLEN) TO PAYLOAD(PAYLOADLEN + 1:BUFFERLEN)
    ADD BUFFERLEN TO PAYLOADLEN

    *> animation
    MOVE FUNCTION CHAR(LK-ANIMATION + 1) TO PAYLOAD(PAYLOADLEN + 1:1)
    ADD 1 TO PAYLOADLEN

    *> send packet
    CALL "SendPacket" USING LK-HNDL PACKET-ID PAYLOAD PAYLOADLEN LK-ERRNO
    GOBACK.

END PROGRAM SendPacket-EntityAnimation.