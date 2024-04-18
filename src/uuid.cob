*> --- UUID-ToString ---
*> Convert a UUID encoded as a 128-bit big-endian integer to a 36-character string.
IDENTIFICATION DIVISION.
PROGRAM-ID. UUID-ToString.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 I                    BINARY-LONG UNSIGNED.
    01 VALUE-INDEX          BINARY-LONG UNSIGNED    VALUE 1.
    01 BYTE-VALUE           BINARY-CHAR UNSIGNED.
    01 NIBBLE-MSB           BINARY-CHAR UNSIGNED.
    01 NIBBLE-LSB           BINARY-CHAR UNSIGNED.
    01 HEX-CHAR             PIC X.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(16).
    01 LK-VALUE             PIC X(36).

PROCEDURE DIVISION USING LK-BUFFER LK-VALUE.
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > 16
        *> read one unsigned byte
        COMPUTE BYTE-VALUE = FUNCTION ORD(LK-BUFFER(I:1)) - 1
        *> output two hex digits
        DIVIDE BYTE-VALUE BY 16 GIVING NIBBLE-MSB REMAINDER NIBBLE-LSB
        CALL "EncodeHexChar" USING NIBBLE-MSB HEX-CHAR
        MOVE HEX-CHAR TO LK-VALUE(VALUE-INDEX:1)
        ADD 1 TO VALUE-INDEX
        CALL "EncodeHexChar" USING NIBBLE-LSB HEX-CHAR
        MOVE HEX-CHAR TO LK-VALUE(VALUE-INDEX:1)
        ADD 1 TO VALUE-INDEX
        *> insert dashes
        IF I = 4 OR I = 6 OR I = 8 OR I = 10
            MOVE "-" TO LK-VALUE(VALUE-INDEX:1)
            ADD 1 TO VALUE-INDEX
        END-IF
    END-PERFORM
    GOBACK.

END PROGRAM UUID-ToString.

*> --- UUID-FromString ---
*> Convert a 36-character UUID string to a 128-bit big-endian integer.
IDENTIFICATION DIVISION.
PROGRAM-ID. UUID-FromString.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 I                    BINARY-LONG UNSIGNED.
    01 VALUE-INDEX          BINARY-LONG UNSIGNED    VALUE 1.
    01 NIBBLE-VALUE         BINARY-CHAR UNSIGNED.
    01 BYTE-VALUE           BINARY-CHAR UNSIGNED.
    01 HEX-CHAR             PIC X.
LINKAGE SECTION.
    01 LK-VALUE-IN          PIC X(36).
    01 LK-VALUE-OUT         PIC X(16).

PROCEDURE DIVISION USING LK-VALUE-IN LK-VALUE-OUT.
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > 16
        *> decode the hex value into a single byte
        MOVE LK-VALUE-IN(VALUE-INDEX:1) TO HEX-CHAR
        ADD 1 TO VALUE-INDEX
        CALL "DecodeHexChar" USING HEX-CHAR BYTE-VALUE
        MOVE LK-VALUE-IN(VALUE-INDEX:1) TO HEX-CHAR
        ADD 1 TO VALUE-INDEX
        CALL "DecodeHexChar" USING HEX-CHAR NIBBLE-VALUE
        COMPUTE BYTE-VALUE = BYTE-VALUE * 16 + NIBBLE-VALUE
        MOVE FUNCTION CHAR(BYTE-VALUE + 1) TO LK-VALUE-OUT(I:1)
        *> skip dashes
        IF I = 4 OR I = 6 OR I = 8 OR I = 10
            ADD 1 TO VALUE-INDEX
        END-IF
    END-PERFORM
    GOBACK.

END PROGRAM UUID-FromString.
