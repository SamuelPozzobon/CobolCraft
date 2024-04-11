*> --- Test: json-parse.cob ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Test-JsonParse.

PROCEDURE DIVISION.
    DISPLAY "Test: json-parse.cob"
    CALL "Test-JsonParse-ObjectStart"
    CALL "Test-JsonParse-ObjectEnd"
    CALL "Test-JsonParse-Comma"
    CALL "Test-JsonParse-String"
    CALL "Test-JsonParse-ObjectKey"
    CALL "Test-JsonParse-Null"
    CALL "Test-JsonParse-Boolean"
    CALL "Test-JsonParse-Integer"
    CALL "Test-JsonParse-SkipValue"
    GOBACK.

    *> --- Test: JsonParse-ObjectStart ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-ObjectStart.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-ObjectStart".
    Simple.
        DISPLAY "    Case: '    {' - " WITH NO ADVANCING
        MOVE "    {" TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-ObjectStart" USING STR OFFSET FLAG
        IF OFFSET = 6 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-ObjectStart" USING STR OFFSET FLAG
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-ObjectStart.

    *> --- Test: JsonParse-ObjectEnd ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-ObjectEnd.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-ObjectEnd".
    Simple.
        DISPLAY "    Case: '    }' - " WITH NO ADVANCING
        MOVE "    }" TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-ObjectEnd" USING STR OFFSET FLAG
        IF OFFSET = 6 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-ObjectEnd" USING STR OFFSET FLAG
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-ObjectEnd.

    *> --- JsonParse-Comma ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-Comma.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-Comma".
    Simple.
        DISPLAY "    Case: '    ,  ' - " WITH NO ADVANCING
        MOVE "    ,  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-Comma" USING STR OFFSET FLAG
        IF OFFSET = 6 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Comma" USING STR OFFSET FLAG
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-Comma.

    *> --- Test: JsonParse-String ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-String.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.
        01 RESULT       PIC X(100).

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-String".
    Simple.
        DISPLAY "    Case: '    ""abc""  ' - " WITH NO ADVANCING
        MOVE "    ""abc""  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-String" USING STR OFFSET FLAG RESULT
        IF OFFSET = 10 AND FLAG = 0 AND RESULT = "abc"
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-String" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    MissingEnd.
        DISPLAY "    Case: '    ""abc' - " WITH NO ADVANCING
        MOVE SPACES TO STR
        MOVE "    ""abc" TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-String" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    EscapedChar.
        DISPLAY "    Case: '    ""1\""2\\3\/4\b5\f6\n7\r8\t9""  ' - " WITH NO ADVANCING
        MOVE "    ""1\""2\\3\/4\b5\f6\n7\r8\t9""  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-String" USING STR OFFSET FLAG RESULT
        IF OFFSET = 32 AND FLAG = 0 AND RESULT = X"3122325C332F3408350C360A370D380939"
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    EscapedUnicodeChar.
        *> TODO: test for unsupported unicode characters (i.e., outside the ASCII range)
        DISPLAY "    Case: '    ""foo \u002D bar""  ' - " WITH NO ADVANCING
        MOVE "    ""foo \u002D bar""  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-String" USING STR OFFSET FLAG RESULT
        IF OFFSET = 21 AND FLAG = 0 AND RESULT = "foo - bar"
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-String.

    *> --- Test: JsonParse-ObjectKey ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-ObjectKey.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.
        01 RESULT       PIC X(100).

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-ObjectKey".
    Simple.
        DISPLAY "    Case: '    ""abc""  :  ' - " WITH NO ADVANCING
        MOVE "    ""abc""  :  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-ObjectKey" USING STR OFFSET FLAG RESULT
        IF OFFSET = 13 AND FLAG = 0 AND RESULT = "abc"
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-ObjectKey" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    MissingEnd.
        DISPLAY "    Case: '    ""abc' - " WITH NO ADVANCING
        MOVE SPACES TO STR
        MOVE "    ""abc" TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-ObjectKey" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    MissingColon.
        DISPLAY "    Case: '    ""abc""  ' - " WITH NO ADVANCING
        MOVE "    ""abc""  " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-ObjectKey" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Consecutive.
        DISPLAY "    Case: '    ""abc"" ""def""  ' - " WITH NO ADVANCING
        MOVE "    ""abc"" ""def""  " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-ObjectKey" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-ObjectKey.

    *> --- Test: JsonParse-Null ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-Null.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-Null".
    Simple.
        DISPLAY "    Case: '    null  ' - " WITH NO ADVANCING
        MOVE "    null  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-Null" USING STR OFFSET FLAG
        IF OFFSET = 9 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    BooleanLiteral.
        DISPLAY "    Case: '    true  ' - " WITH NO ADVANCING
        MOVE "    true  " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Null" USING STR OFFSET FLAG
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Null" USING STR OFFSET FLAG
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-Null.

    *> --- Test: JsonParse-Boolean ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-Boolean.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.
        01 RESULT       BINARY-CHAR UNSIGNED.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-Boolean".
    TrueValue.
        DISPLAY "    Case: '    true  ' - " WITH NO ADVANCING
        MOVE "    true  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-Boolean" USING STR OFFSET FLAG RESULT
        IF OFFSET = 9 AND FLAG = 0 AND RESULT = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    FalseValue.
        DISPLAY "    Case: '    false  ' - " WITH NO ADVANCING
        MOVE "    false  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-Boolean" USING STR OFFSET FLAG RESULT
        IF OFFSET = 10 AND FLAG = 0 AND RESULT = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    NullLiteral.
        DISPLAY "    Case: '    null  ' - " WITH NO ADVANCING
        MOVE "    null  " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Boolean" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Boolean" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-Boolean.

    *> --- Test: JsonParse-Integer ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-Integer.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.
        01 RESULT       BINARY-LONG.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-Integer".
    Simple.
        DISPLAY "    Case: '    123  ' - " WITH NO ADVANCING
        MOVE "    123  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-Integer" USING STR OFFSET FLAG RESULT
        IF OFFSET = 8 AND FLAG = 0 AND RESULT = 123
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    Missing.
        DISPLAY "    Case: '   ' - " WITH NO ADVANCING
        MOVE "   " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Integer" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    NegativeInt.
        DISPLAY "    Case: '    -123  ' - " WITH NO ADVANCING
        MOVE "    -123  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-Integer" USING STR OFFSET FLAG RESULT
        IF OFFSET = 9 AND FLAG = 0 AND RESULT = -123
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    MinusOnly.
        DISPLAY "    Case: '    -  ' - " WITH NO ADVANCING
        MOVE "    -  " TO STR
        MOVE 1 TO OFFSET
        MOVE 0 TO FLAG
        CALL "JsonParse-Integer" USING STR OFFSET FLAG RESULT
        IF FLAG = 1
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-Integer.

    *> --- Test: JsonParse-SkipValue ---
    IDENTIFICATION DIVISION.
    PROGRAM-ID. Test-JsonParse-SkipValue.

    DATA DIVISION.
    WORKING-STORAGE SECTION.
        01 STR          PIC X(100).
        01 OFFSET       BINARY-LONG UNSIGNED.
        01 FLAG         BINARY-CHAR UNSIGNED.

    PROCEDURE DIVISION.
        DISPLAY "  Test: JsonParse-SkipValue".
    PositiveInt.
        DISPLAY "    Case: '    123  ' - " WITH NO ADVANCING
        MOVE "    123  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-SkipValue" USING STR OFFSET FLAG
        IF OFFSET = 8 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    NegativeInt.
        DISPLAY "    Case: '    -123  ' - " WITH NO ADVANCING
        MOVE "    -123  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-SkipValue" USING STR OFFSET FLAG
        IF OFFSET = 9 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    StringValue.
        DISPLAY "    Case: '    ""abc""  ' - " WITH NO ADVANCING
        MOVE "    ""abc""  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-SkipValue" USING STR OFFSET FLAG
        IF OFFSET = 10 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    SimpleObject.
        DISPLAY "    Case: '    {  }  ' - " WITH NO ADVANCING
        MOVE "    {  }  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-SkipValue" USING STR OFFSET FLAG
        IF OFFSET = 9 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.
    ComplexObject.
        DISPLAY "    Case: '    {""abc"": 123, ""foo"": { ""bar"": ""baz"" }, ""bool"": true, ""null"": null }  ' - " WITH NO ADVANCING
        MOVE "    {""abc"": 123, ""foo"": { ""bar"": ""baz"" }, ""bool"": true, ""null"": null }  " TO STR
        MOVE 1 TO OFFSET
        MOVE 1 TO FLAG
        CALL "JsonParse-SkipValue" USING STR OFFSET FLAG
        IF OFFSET = 71 AND FLAG = 0
            DISPLAY "PASS"
        ELSE
            DISPLAY "FAIL"
        END-IF.

        GOBACK.

    END PROGRAM Test-JsonParse-SkipValue.

END PROGRAM Test-JsonParse.