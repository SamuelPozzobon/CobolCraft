*> --- Decode-Byte ---
*> Decode a byte from a buffer into an 8-bit integer (BINARY-CHAR).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-Byte.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 UNSIGNED-VALUE       BINARY-CHAR UNSIGNED.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             BINARY-CHAR.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    COMPUTE UNSIGNED-VALUE = FUNCTION ORD(LK-BUFFER(LK-BUFFERPOS:1)) - 1
    IF UNSIGNED-VALUE > 127
        COMPUTE LK-VALUE = UNSIGNED-VALUE - 256
    ELSE
        MOVE UNSIGNED-VALUE TO LK-VALUE
    END-IF
    ADD 1 TO LK-BUFFERPOS
    GOBACK.

END PROGRAM Decode-Byte.

*> --- Decode-Short ---
*> Decode a big-endian short from a buffer into a 16-bit integer (BINARY-SHORT).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-Short.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 UNSIGNED-VALUE       BINARY-SHORT UNSIGNED.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             BINARY-SHORT.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    COMPUTE UNSIGNED-VALUE = FUNCTION ORD(LK-BUFFER(LK-BUFFERPOS:1)) - 1
    ADD 1 TO LK-BUFFERPOS
    COMPUTE UNSIGNED-VALUE = UNSIGNED-VALUE * 256 + FUNCTION ORD(LK-BUFFER(LK-BUFFERPOS:1)) - 1
    ADD 1 TO LK-BUFFERPOS
    IF UNSIGNED-VALUE > 32767
        COMPUTE LK-VALUE = UNSIGNED-VALUE - 65536
    ELSE
        MOVE UNSIGNED-VALUE TO LK-VALUE
    END-IF
    GOBACK.

END PROGRAM Decode-Short.

*> --- Decode-VarInt ---
*> Decode a VarInt from a buffer into a 32-bit integer (BINARY-LONG).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-VarInt.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 VARINT-READ-COUNT    BINARY-CHAR UNSIGNED    VALUE 0.
    01 VARINT-BYTE          BINARY-CHAR UNSIGNED    VALUE 0.
    01 VARINT-BYTE-VALUE    BINARY-CHAR UNSIGNED    VALUE 0.
    01 VARINT-MULTIPLIER    BINARY-LONG UNSIGNED    VALUE 1.
    01 VARINT-CONTINUE      BINARY-CHAR UNSIGNED    VALUE 1.
    01 UINT-VALUE           BINARY-LONG UNSIGNED    VALUE 0.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             BINARY-LONG.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    PERFORM UNTIL VARINT-CONTINUE = 0
        *> Read the next byte
        COMPUTE VARINT-BYTE = FUNCTION ORD(LK-BUFFER(LK-BUFFERPOS:1)) - 1
        ADD 1 TO LK-BUFFERPOS
        ADD 1 TO VARINT-READ-COUNT
        *> Extract the lower 7 bits
        MOVE FUNCTION MOD(VARINT-BYTE, 128) TO VARINT-BYTE-VALUE
        *> This yields the value when multiplied by the position multiplier
        COMPUTE UINT-VALUE = UINT-VALUE + VARINT-BYTE-VALUE * VARINT-MULTIPLIER
        MULTIPLY VARINT-MULTIPLIER BY 128 GIVING VARINT-MULTIPLIER
        *> Check if we need to continue (if the high bit is set and the maximum number of bytes has not been reached)
        IF VARINT-BYTE < 128 OR VARINT-READ-COUNT >= 5
            MOVE 0 TO VARINT-CONTINUE
        END-IF
    END-PERFORM
    *> Check if the number should be negative (i.e., is larger than 2^31-1) and compute its signed value
    IF UINT-VALUE > 2147483647
        COMPUTE LK-VALUE = UINT-VALUE - 4294967296
    ELSE
        MOVE UINT-VALUE TO LK-VALUE
    END-IF
    GOBACK.

END PROGRAM Decode-VarInt.

*> --- Decode-UnsignedLong ---
*> Decode a big-endian long from a buffer into a 64-bit unsigned integer (BINARY-LONG-LONG UNSIGNED).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-UnsignedLong.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 CURRENT-BYTE         BINARY-CHAR UNSIGNED.
    01 MULTIPLIER           BINARY-LONG-LONG UNSIGNED   VALUE 1.
    01 I                    INDEX.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             BINARY-LONG-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > 8
        COMPUTE CURRENT-BYTE = FUNCTION ORD(LK-BUFFER(LK-BUFFERPOS + 8 - I:1)) - 1
        COMPUTE LK-VALUE = LK-VALUE + (CURRENT-BYTE * MULTIPLIER)
        COMPUTE MULTIPLIER = MULTIPLIER * 256
    END-PERFORM
    ADD 8 TO LK-BUFFERPOS
    GOBACK.

END PROGRAM Decode-UnsignedLong.

*> --- Decode-Long ---
*> Decode a big-endian long from a buffer into a 64-bit integer (BINARY-LONG-LONG).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-Long.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 UINT-VALUE           BINARY-LONG-LONG UNSIGNED   VALUE 0.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             BINARY-LONG-LONG.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    CALL "Decode-UnsignedLong" USING LK-BUFFER LK-BUFFERPOS UINT-VALUE
    *> Check if the number should be negative (i.e., is larger than 2^63-1) and compute its signed value
    IF UINT-VALUE > 9223372036854775807
        COMPUTE LK-VALUE = UINT-VALUE - 18446744073709551616
    ELSE
        MOVE UINT-VALUE TO LK-VALUE
    END-IF
    GOBACK.

END PROGRAM Decode-Long.

*> --- Decode-Double ---
*> Decode a big-endian double from a buffer into a double-precision floating-point number (FLOAT-LONG).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-Double.

DATA DIVISION.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             FLOAT-LONG.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    CALL "Util-DoubleFromBytes" USING LK-BUFFER(LK-BUFFERPOS:8) LK-VALUE
    ADD 8 TO LK-BUFFERPOS
    GOBACK.

END PROGRAM Decode-Double.

*> --- Decode-Float ---
*> Decode a big-endian float from a buffer into a single-precision floating-point number (FLOAT).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-Float.

DATA DIVISION.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE             FLOAT.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    CALL "Util-FloatFromBytes" USING LK-BUFFER(LK-BUFFERPOS:4) LK-VALUE
    ADD 4 TO LK-BUFFERPOS
    GOBACK.

END PROGRAM Decode-Float.

*> --- Decode-String ---
*> Decode a string from a buffer. The string is prefixed with a VarInt length.
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-String.

DATA DIVISION.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-STR-LENGTH        BINARY-LONG.
    01 LK-VALUE             PIC X(64000).

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-STR-LENGTH LK-VALUE.
    *> Read the length
    CALL "Decode-VarInt" USING LK-BUFFER LK-BUFFERPOS LK-STR-LENGTH
    IF LK-STR-LENGTH < 0 OR LK-STR-LENGTH > 64000
        *> TODO: Handle error
        EXIT PROGRAM
    END-IF
    *> Read the string
    MOVE LK-BUFFER(LK-BUFFERPOS:LK-STR-LENGTH) TO LK-VALUE(1:LK-STR-LENGTH)
    ADD LK-STR-LENGTH TO LK-BUFFERPOS
    GOBACK.

END PROGRAM Decode-String.

*> --- Decode-Position ---
*> Decode a block position from a buffer. The position is encoded as a 64-bit integer (BINARY-LONG-LONG).
*> The 26 least-significant bits are X, the middle 12 bits are Y, and the 26 most-significant bits are Z.
*> Each of the bit sections is signed (two's complement).
IDENTIFICATION DIVISION.
PROGRAM-ID. Decode-Position.

DATA DIVISION.
LOCAL-STORAGE SECTION.
    01 UINT-VALUE           BINARY-LONG-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-BUFFER            PIC X(2100000).
    01 LK-BUFFERPOS         BINARY-LONG UNSIGNED.
    01 LK-VALUE.
        02 LK-X             BINARY-LONG.
        02 LK-Y             BINARY-LONG.
        02 LK-Z             BINARY-LONG.

PROCEDURE DIVISION USING LK-BUFFER LK-BUFFERPOS LK-VALUE.
    CALL "Decode-UnsignedLong" USING LK-BUFFER LK-BUFFERPOS UINT-VALUE

    *> Take the last 12 bits as Y
    COMPUTE LK-Y = FUNCTION MOD(UINT-VALUE, 2 ** 12)
    IF LK-Y > 2047
        COMPUTE LK-Y = LK-Y - 4096
    END-IF

    *> Shift right by 12 bits and take the next 26 bits as Z
    COMPUTE UINT-VALUE = UINT-VALUE / (2 ** 12)
    COMPUTE LK-Z = FUNCTION MOD(UINT-VALUE, 2 ** 26)
    IF LK-Z > 33554431
        COMPUTE LK-Z = LK-Z - 67108864
    END-IF

    *> Shift right by 26 bits and take the remaining 26 bits as X
    COMPUTE UINT-VALUE = UINT-VALUE / (2 ** 26)
    COMPUTE LK-X = UINT-VALUE
    IF LK-X > 33554431
        COMPUTE LK-X = LK-X - 67108864
    END-IF

    GOBACK.

END PROGRAM Decode-Position.
