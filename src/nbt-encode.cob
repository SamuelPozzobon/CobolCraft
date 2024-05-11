*> --- NbtEncode-WriteString ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-WriteString.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 UINT16           BINARY-SHORT UNSIGNED.
LINKAGE SECTION.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-OFFSET        BINARY-LONG UNSIGNED.
    01 LK-STRING        PIC X ANY LENGTH.
    01 LK-STRING-LENGTH BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-BUFFER LK-OFFSET LK-STRING LK-STRING-LENGTH.
    *> string length
    MOVE LK-STRING-LENGTH TO UINT16
    CALL "Encode-UnsignedShort" USING UINT16 LK-BUFFER LK-OFFSET
    *> string value
    MOVE LK-STRING(1:LK-STRING-LENGTH) TO LK-BUFFER(LK-OFFSET:LK-STRING-LENGTH)
    ADD LK-STRING-LENGTH TO LK-OFFSET
    GOBACK.

END PROGRAM NbtEncode-WriteString.

*> --- NbtEncode-Byte ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-Byte.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-VALUE         BINARY-CHAR.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-VALUE.
    EVALUATE TRUE
        *> If the parent element is a list, update its type and count.
        WHEN LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
            MOVE X"01" TO LK-STACK-LIST-TYPE(LK-LEVEL)
            ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
        *> If the parent element is a matching array type, count down.
        WHEN LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"07"
            SUBTRACT 1 FROM LK-STACK-LIST-COUNT(LK-LEVEL)
            *> Pop the array once the count reaches 0.
            IF LK-STACK-LIST-COUNT(LK-LEVEL) = 0
                SUBTRACT 1 FROM LK-LEVEL
            END-IF
        *> Write the tag.
        WHEN OTHER
            MOVE X"01" TO LK-BUFFER(LK-OFFSET:1)
            ADD 1 TO LK-OFFSET
            IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
                CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
            END-IF
    END-EVALUATE

    *> value
    CALL "Encode-Byte" USING LK-VALUE LK-BUFFER LK-OFFSET
    GOBACK.

END PROGRAM NbtEncode-Byte.

*> --- NbtEncode-Int ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-Int.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-VALUE         BINARY-LONG.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-VALUE.
    EVALUATE TRUE
        *> If the parent element is a list, update its type and count.
        WHEN LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
            MOVE X"03" TO LK-STACK-LIST-TYPE(LK-LEVEL)
            ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
        *> If the parent element is a matching array type, count down.
        WHEN LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"0B"
            SUBTRACT 1 FROM LK-STACK-LIST-COUNT(LK-LEVEL)
            *> Pop the array once the count reaches 0.
            IF LK-STACK-LIST-COUNT(LK-LEVEL) = 0
                SUBTRACT 1 FROM LK-LEVEL
            END-IF
        *> Write the tag.
        WHEN OTHER
            MOVE X"03" TO LK-BUFFER(LK-OFFSET:1)
            ADD 1 TO LK-OFFSET
            IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
                CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
            END-IF
    END-EVALUATE

    *> value
    CALL "Encode-Int" USING LK-VALUE LK-BUFFER LK-OFFSET
    GOBACK.

END PROGRAM NbtEncode-Int.

*> --- NbtEncode-Long ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-Long.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-VALUE         BINARY-LONG-LONG.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-VALUE.
    EVALUATE TRUE
        *> If the parent element is a list, update its type and count.
        WHEN LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
            MOVE X"04" TO LK-STACK-LIST-TYPE(LK-LEVEL)
            ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
        *> If the parent element is a matching array type, count down.
        WHEN LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"0C"
            SUBTRACT 1 FROM LK-STACK-LIST-COUNT(LK-LEVEL)
            *> Pop the array once the count reaches 0.
            IF LK-STACK-LIST-COUNT(LK-LEVEL) = 0
                SUBTRACT 1 FROM LK-LEVEL
            END-IF
        *> Write the tag.
        WHEN OTHER
            MOVE X"04" TO LK-BUFFER(LK-OFFSET:1)
            ADD 1 TO LK-OFFSET
            IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
                CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
            END-IF
    END-EVALUATE

    *> value
    CALL "Encode-Long" USING LK-VALUE LK-BUFFER LK-OFFSET
    GOBACK.

END PROGRAM NbtEncode-Long.

*> --- NbtEncode-Float ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-Float.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-VALUE         FLOAT-SHORT.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-VALUE.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"05" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"05" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> value
    CALL "Encode-Float" USING LK-VALUE LK-BUFFER LK-OFFSET
    GOBACK.

END PROGRAM NbtEncode-Float.

*> --- NbtEncode-Double ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-Double.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-VALUE         FLOAT-LONG.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-VALUE.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"06" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"06" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> value
    CALL "Encode-Double" USING LK-VALUE LK-BUFFER LK-OFFSET
    GOBACK.

END PROGRAM NbtEncode-Double.

*> --- NbtEncode-String ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-String.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-VALUE         PIC X ANY LENGTH.
    01 LK-VALUE-LEN     BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-VALUE LK-VALUE-LEN.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"08" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"08" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> value
    CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-VALUE LK-VALUE-LEN
    GOBACK.

END PROGRAM NbtEncode-String.

*> --- NbtEncode-ByteArray ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-ByteArray.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-ARRAY-LEN     BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-ARRAY-LEN.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"07" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"07" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> array length
    CALL "Encode-Int" USING LK-ARRAY-LEN LK-BUFFER LK-OFFSET

    *> Unless empty, push the array onto the stack.
    IF LK-ARRAY-LEN > 0
        ADD 1 TO LK-LEVEL
        MOVE X"07" TO LK-STACK-TYPE(LK-LEVEL)
        MOVE X"01" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        MOVE LK-ARRAY-LEN TO LK-STACK-LIST-COUNT(LK-LEVEL)
    END-IF

    GOBACK.

END PROGRAM NbtEncode-ByteArray.

*> --- NbtEncode-ByteBuffer ---
*> This is a utility subroutine that writes a byte array with content directly.
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-ByteBuffer.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-DATA          PIC X ANY LENGTH.
    01 LK-DATA-LEN      BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-DATA LK-DATA-LEN.
    CALL "NbtEncode-ByteArray" USING LK-STATE LK-BUFFER LK-NAME LK-NAME-LEN LK-DATA-LEN
    MOVE LK-DATA(1:LK-DATA-LEN) TO LK-BUFFER(LK-OFFSET:LK-DATA-LEN)
    ADD LK-DATA-LEN TO LK-OFFSET
    SUBTRACT 1 FROM LK-LEVEL
    GOBACK.

END PROGRAM NbtEncode-ByteBuffer.

*> --- NbtEncode-List ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-List.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 LIST-LENGTH      BINARY-LONG UNSIGNED        VALUE 0.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"09" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"09" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> Push the list onto the stack.
    ADD 1 TO LK-LEVEL
    MOVE X"09" TO LK-STACK-TYPE(LK-LEVEL)
    MOVE LK-OFFSET TO LK-STACK-INDEX(LK-LEVEL)
    MOVE X"00" TO LK-STACK-LIST-TYPE(LK-LEVEL)
    MOVE 0 TO LK-STACK-LIST-COUNT(LK-LEVEL)

    *> value type and count are initially 0; they are set when ending the list.
    MOVE X"00" TO LK-BUFFER(LK-OFFSET:1)
    ADD 1 TO LK-OFFSET
    CALL "Encode-Int" USING LIST-LENGTH LK-BUFFER LK-OFFSET

    GOBACK.

END PROGRAM NbtEncode-List.

*> --- NbtEncode-EndList ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-EndList.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 TEMP-OFFSET      BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER.
    IF LK-LEVEL < 1 OR LK-STACK-TYPE(LK-LEVEL) NOT = X"09"
        DISPLAY "ERROR: Missing list start tag."
        STOP RUN
    END-IF

    *> Fix up the list type and value count.
    MOVE LK-STACK-LIST-TYPE(LK-LEVEL) TO LK-BUFFER(LK-STACK-INDEX(LK-LEVEL):1)
    COMPUTE TEMP-OFFSET = LK-STACK-INDEX(LK-LEVEL) + 1
    CALL "Encode-Int" USING LK-STACK-LIST-COUNT(LK-LEVEL) LK-BUFFER TEMP-OFFSET

    *> Pop the list from the stack.
    SUBTRACT 1 FROM LK-LEVEL

    GOBACK.

END PROGRAM NbtEncode-EndList.

*> --- NbtEncode-Compound ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-Compound.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"0A" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"0A" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> Push the compound onto the stack.
    ADD 1 TO LK-LEVEL
    MOVE X"0A" TO LK-STACK-TYPE(LK-LEVEL)

    GOBACK.

END PROGRAM NbtEncode-Compound.

*> --- NbtEncode-RootCompound ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-RootCompound.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER.
    IF LK-LEVEL > 0
        DISPLAY "ERROR: Root compound must be at level 0."
        STOP RUN
    END-IF

    *> The root compound is a special case of the named compound.
    *> It wraps all save data on disk. However, it isn't used on the network.
    MOVE X"0A" TO LK-BUFFER(LK-OFFSET:1)
    MOVE X"00" TO LK-BUFFER(LK-OFFSET + 1:1)
    MOVE X"00" TO LK-BUFFER(LK-OFFSET + 2:1)
    ADD 3 TO LK-OFFSET

    *> Push the root compound onto the stack.
    ADD 1 TO LK-LEVEL
    MOVE X"0A" TO LK-STACK-TYPE(LK-LEVEL)

    GOBACK.

END PROGRAM NbtEncode-RootCompound.

*> --- NbtEncode-EndCompound ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-EndCompound.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER.
    IF LK-LEVEL < 1 OR LK-STACK-TYPE(LK-LEVEL) NOT = X"0A"
        DISPLAY "ERROR: Missing compound start tag."
        STOP RUN
    END-IF

    *> Write the end tag.
    MOVE X"00" TO LK-BUFFER(LK-OFFSET:1)
    ADD 1 TO LK-OFFSET

    *> Pop the compound from the stack.
    SUBTRACT 1 FROM LK-LEVEL

    GOBACK.

END PROGRAM NbtEncode-EndCompound.

*> --- NbtEncode-IntArray ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-IntArray.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-ARRAY-LEN     BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-ARRAY-LEN.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"0B" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"0B" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> array length
    CALL "Encode-Int" USING LK-ARRAY-LEN LK-BUFFER LK-OFFSET

    *> Unless empty, push the array onto the stack.
    IF LK-ARRAY-LEN > 0
        ADD 1 TO LK-LEVEL
        MOVE X"0B" TO LK-STACK-TYPE(LK-LEVEL)
        MOVE X"03" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        MOVE LK-ARRAY-LEN TO LK-STACK-LIST-COUNT(LK-LEVEL)
    END-IF

    GOBACK.

END PROGRAM NbtEncode-IntArray.

*> --- NbtEncode-LongArray ---
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-LongArray.

DATA DIVISION.
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-ARRAY-LEN     BINARY-LONG UNSIGNED.

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-ARRAY-LEN.
    *> If the parent element is a list, update its type and count.
    IF LK-LEVEL > 0 AND LK-STACK-TYPE(LK-LEVEL) = X"09"
        MOVE X"0C" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        ADD 1 TO LK-STACK-LIST-COUNT(LK-LEVEL)
    ELSE
        *> Write the tag.
        MOVE X"0C" TO LK-BUFFER(LK-OFFSET:1)
        ADD 1 TO LK-OFFSET
        IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
            CALL "NbtEncode-WriteString" USING LK-BUFFER LK-OFFSET LK-NAME LK-NAME-LEN
        END-IF
    END-IF

    *> array length
    CALL "Encode-Int" USING LK-ARRAY-LEN LK-BUFFER LK-OFFSET

    *> Unless empty, push the array onto the stack.
    IF LK-ARRAY-LEN > 0
        ADD 1 TO LK-LEVEL
        MOVE X"0C" TO LK-STACK-TYPE(LK-LEVEL)
        MOVE X"04" TO LK-STACK-LIST-TYPE(LK-LEVEL)
        MOVE LK-ARRAY-LEN TO LK-STACK-LIST-COUNT(LK-LEVEL)
    END-IF

    GOBACK.

END PROGRAM NbtEncode-LongArray.

*> --- NbtEncode-UUID ---
*> While there is no NBT tag for UUIDs, they are commonly stored as an array of 4 integers, for which this subroutine
*> is provided.
IDENTIFICATION DIVISION.
PROGRAM-ID. NbtEncode-UUID.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 INT-COUNT        BINARY-LONG UNSIGNED                VALUE 4.
    01 UUID-OFFSET      BINARY-LONG UNSIGNED.
    01 INT32            BINARY-LONG.
    01 INT32-BYTES      REDEFINES INT32 PIC X(4).
LINKAGE SECTION.
    COPY DD-NBT-ENCODER REPLACING LEADING ==NBT-ENCODER== BY ==LK==.
    01 LK-BUFFER        PIC X ANY LENGTH.
    01 LK-NAME          PIC X ANY LENGTH.
    01 LK-NAME-LEN      BINARY-LONG UNSIGNED.
    01 LK-UUID          PIC X(16).

PROCEDURE DIVISION USING LK-STATE LK-BUFFER OPTIONAL LK-NAME OPTIONAL LK-NAME-LEN LK-UUID.
    *> The following check may seem redundant, but without it, GnuCOBOL won't compile.
    IF LK-NAME IS NOT OMITTED AND LK-NAME-LEN IS NOT OMITTED
        CALL "NbtEncode-IntArray" USING LK-STATE LK-BUFFER LK-NAME LK-NAME-LEN INT-COUNT
    ELSE
        CALL "NbtEncode-IntArray" USING LK-STATE LK-BUFFER OMITTED OMITTED INT-COUNT
    END-IF
    PERFORM VARYING UUID-OFFSET FROM 1 BY 4 UNTIL UUID-OFFSET > 16
        MOVE FUNCTION REVERSE(LK-UUID(UUID-OFFSET:4)) TO INT32-BYTES
        CALL "NbtEncode-Int" USING LK-STATE LK-BUFFER OMITTED OMITTED INT32
    END-PERFORM
    GOBACK.

END PROGRAM NbtEncode-UUID.
