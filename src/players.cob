*> --- Players-Init ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-Init.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> shared data
    COPY DD-PLAYERS.
    *> temporary data
    01 PLAYER-INDEX             BINARY-CHAR.

PROCEDURE DIVISION.
    PERFORM VARYING PLAYER-INDEX FROM 1 BY 1 UNTIL PLAYER-INDEX > MAX-PLAYERS
        MOVE 0 TO PLAYER-CLIENT(PLAYER-INDEX)
    END-PERFORM
    GOBACK.

END PROGRAM Players-Init.

*> --- Players-PlayerFileName ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-PlayerFileName.

DATA DIVISION.
WORKING-STORAGE SECTION.
    01 UUID-STR                 PIC X(36).
LOCAL-STORAGE SECTION.
    01 STR-POS                  BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-PLAYER-UUID           PIC X(16).
    01 LK-PLAYER-FILE-NAME      PIC X ANY LENGTH.

PROCEDURE DIVISION USING LK-PLAYER-UUID LK-PLAYER-FILE-NAME.
    *> prefix
    MOVE "save/players/" TO LK-PLAYER-FILE-NAME
    COMPUTE STR-POS = FUNCTION STORED-CHAR-LENGTH(LK-PLAYER-FILE-NAME) + 1
    *> UUID
    CALL "UUID-ToString" USING LK-PLAYER-UUID UUID-STR
    MOVE UUID-STR TO LK-PLAYER-FILE-NAME(STR-POS:)
    COMPUTE STR-POS = STR-POS + FUNCTION STORED-CHAR-LENGTH(UUID-STR)
    *> suffix
    MOVE ".dat" TO LK-PLAYER-FILE-NAME(STR-POS:)
    GOBACK.

END PROGRAM Players-PlayerFileName.

*> --- Players-SavePlayer ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-SavePlayer.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT OPTIONAL FD-PLAYER-FILE-OUT
        ASSIGN TO PLAYER-FILE-NAME
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD FD-PLAYER-FILE-OUT.
    COPY DD-PLAYER-FILE.
WORKING-STORAGE SECTION.
    *> Constants
    01 C-MINECRAFT-ITEM         PIC X(16) VALUE "minecraft:item".
    01 C-MINECRAFT-AIR          PIC X(16) VALUE "minecraft:air".
    *> File name
    01 PLAYER-FILE-NAME         PIC X(64).
    *> shared data
    COPY DD-PLAYERS.
    *> temporary data
    01 INVENTORY-INDEX          BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-PLAYER-ID             BINARY-CHAR.

PROCEDURE DIVISION USING LK-PLAYER-ID.
    *> Create directories. Ignore errors, as they are likely to be caused by the directories already existing.
    CALL "CBL_CREATE_DIR" USING "save"
    CALL "CBL_CREATE_DIR" USING "save/players"

    *> open the file
    CALL "Players-PlayerFileName" USING PLAYER-UUID(LK-PLAYER-ID) PLAYER-FILE-NAME
    OPEN OUTPUT FD-PLAYER-FILE-OUT

    *> save player data
    MOVE PLAYER-UUID(LK-PLAYER-ID) TO FILE-PLAYER-UUID
    MOVE PLAYER-NAME(LK-PLAYER-ID)(1:PLAYER-NAME-LENGTH(LK-PLAYER-ID)) TO FILE-PLAYER-NAME
    MOVE PLAYER-POSITION(LK-PLAYER-ID) TO FILE-PLAYER-POSITION
    MOVE PLAYER-ROTATION(LK-PLAYER-ID) TO FILE-PLAYER-ROTATION
    MOVE PLAYER-HOTBAR(LK-PLAYER-ID) TO FILE-PLAYER-HOTBAR

    PERFORM VARYING INVENTORY-INDEX FROM 1 BY 1 UNTIL INVENTORY-INDEX > 46
        IF PLAYER-INVENTORY-SLOT-ID(LK-PLAYER-ID, INVENTORY-INDEX) > 0 AND PLAYER-INVENTORY-SLOT-COUNT(LK-PLAYER-ID, INVENTORY-INDEX) > 0
            *> item ID needs to be converted to a string for future-proofing
            CALL "Registries-Get-EntryName" USING C-MINECRAFT-ITEM PLAYER-INVENTORY-SLOT-ID(LK-PLAYER-ID, INVENTORY-INDEX) FILE-PLAYER-INVENTORY-SLOT-ID(INVENTORY-INDEX)
            MOVE PLAYER-INVENTORY-SLOT-COUNT(LK-PLAYER-ID, INVENTORY-INDEX) TO FILE-PLAYER-INVENTORY-SLOT-COUNT(INVENTORY-INDEX)
            MOVE PLAYER-INVENTORY-SLOT-NBT-LENGTH(LK-PLAYER-ID, INVENTORY-INDEX) TO FILE-PLAYER-INVENTORY-SLOT-NBT-LENGTH(INVENTORY-INDEX)
            MOVE PLAYER-INVENTORY-SLOT-NBT-DATA(LK-PLAYER-ID, INVENTORY-INDEX) TO FILE-PLAYER-INVENTORY-SLOT-NBT-DATA(INVENTORY-INDEX)
        ELSE
            MOVE C-MINECRAFT-AIR TO FILE-PLAYER-INVENTORY-SLOT-ID(INVENTORY-INDEX)
            MOVE 0 TO FILE-PLAYER-INVENTORY-SLOT-COUNT(INVENTORY-INDEX)
            MOVE 0 TO FILE-PLAYER-INVENTORY-SLOT-NBT-LENGTH(INVENTORY-INDEX)
        END-IF
    END-PERFORM

    *> finish
    WRITE FILE-PLAYER
    CLOSE FD-PLAYER-FILE-OUT

    GOBACK.

END PROGRAM Players-SavePlayer.

*> --- Players-LoadPlayer ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-LoadPlayer.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT OPTIONAL FD-PLAYER-FILE-IN
        ASSIGN TO PLAYER-FILE-NAME
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD FD-PLAYER-FILE-IN.
    COPY DD-PLAYER-FILE.
WORKING-STORAGE SECTION.
    *> Constants
    01 C-MINECRAFT-ITEM         PIC X(16) VALUE "minecraft:item".
    *> File name
    01 PLAYER-FILE-NAME         PIC X(64).
    *> shared data
    COPY DD-PLAYERS.
    *> temporary data
    01 INVENTORY-INDEX          BINARY-LONG UNSIGNED.
LINKAGE SECTION.
    01 LK-PLAYER-ID             BINARY-CHAR.
    01 LK-PLAYER-UUID           PIC X(16).
    01 LK-FAILURE               BINARY-CHAR UNSIGNED.

PROCEDURE DIVISION USING LK-PLAYER-ID LK-PLAYER-UUID LK-FAILURE.
    MOVE 0 TO LK-FAILURE

    *> open the file
    CALL "Players-PlayerFileName" USING LK-PLAYER-UUID PLAYER-FILE-NAME
    OPEN INPUT FD-PLAYER-FILE-IN

    *> load player data
    READ FD-PLAYER-FILE-IN
        AT END
            MOVE 1 TO LK-FAILURE
        NOT AT END
            MOVE FILE-PLAYER-UUID TO PLAYER-UUID(LK-PLAYER-ID)
            MOVE FILE-PLAYER-NAME TO PLAYER-NAME(LK-PLAYER-ID)
            MOVE FUNCTION STORED-CHAR-LENGTH(FILE-PLAYER-NAME) TO PLAYER-NAME-LENGTH(LK-PLAYER-ID)
            MOVE FILE-PLAYER-POSITION TO PLAYER-POSITION(LK-PLAYER-ID)
            MOVE FILE-PLAYER-ROTATION TO PLAYER-ROTATION(LK-PLAYER-ID)
            MOVE FILE-PLAYER-HOTBAR TO PLAYER-HOTBAR(LK-PLAYER-ID)

            PERFORM VARYING INVENTORY-INDEX FROM 1 BY 1 UNTIL INVENTORY-INDEX > 46
                IF FILE-PLAYER-INVENTORY-SLOT-COUNT(INVENTORY-INDEX) > 0
                    *> item ID needs to be converted from a string to a number
                    CALL "Registries-Get-EntryId" USING C-MINECRAFT-ITEM FILE-PLAYER-INVENTORY-SLOT-ID(INVENTORY-INDEX) PLAYER-INVENTORY-SLOT-ID(LK-PLAYER-ID, INVENTORY-INDEX)
                    MOVE FILE-PLAYER-INVENTORY-SLOT-COUNT(INVENTORY-INDEX) TO PLAYER-INVENTORY-SLOT-COUNT(LK-PLAYER-ID, INVENTORY-INDEX)
                    MOVE FILE-PLAYER-INVENTORY-SLOT-NBT-LENGTH(INVENTORY-INDEX) TO PLAYER-INVENTORY-SLOT-NBT-LENGTH(LK-PLAYER-ID, INVENTORY-INDEX)
                    MOVE FILE-PLAYER-INVENTORY-SLOT-NBT-DATA(INVENTORY-INDEX) TO PLAYER-INVENTORY-SLOT-NBT-DATA(LK-PLAYER-ID, INVENTORY-INDEX)
                ELSE
                    MOVE 0 TO PLAYER-INVENTORY-SLOT-ID(LK-PLAYER-ID, INVENTORY-INDEX)
                    MOVE 0 TO PLAYER-INVENTORY-SLOT-COUNT(LK-PLAYER-ID, INVENTORY-INDEX)
                    MOVE 0 TO PLAYER-INVENTORY-SLOT-NBT-LENGTH(LK-PLAYER-ID, INVENTORY-INDEX)
                END-IF
            END-PERFORM
    END-READ

    *> finish
    CLOSE FD-PLAYER-FILE-IN

    GOBACK.

END PROGRAM Players-LoadPlayer.

*> --- Players-Save ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-Save.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> shared data
    COPY DD-PLAYERS.
    *> temporary data
    01 PLAYER-INDEX             BINARY-CHAR.

PROCEDURE DIVISION.
    PERFORM VARYING PLAYER-INDEX FROM 1 BY 1 UNTIL PLAYER-INDEX > MAX-PLAYERS
        IF PLAYER-CLIENT(PLAYER-INDEX) > 0
            CALL "Players-SavePlayer" USING PLAYER-INDEX
        END-IF
    END-PERFORM
    GOBACK.

END PROGRAM Players-Save.

*> --- Players-FindConnectedByUUID ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-FindConnectedByUUID.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> shared data
    COPY DD-PLAYERS.
LINKAGE SECTION.
    01 LK-PLAYER-UUID           PIC X(16).
    01 LK-PLAYER-ID             BINARY-CHAR.

PROCEDURE DIVISION USING LK-PLAYER-UUID LK-PLAYER-ID.
    PERFORM VARYING LK-PLAYER-ID FROM 1 BY 1 UNTIL LK-PLAYER-ID > MAX-PLAYERS
        IF PLAYER-CLIENT(LK-PLAYER-ID) > 0 AND PLAYER-UUID(LK-PLAYER-ID) = LK-PLAYER-UUID
            GOBACK
        END-IF
    END-PERFORM
    *> not found
    MOVE 0 TO LK-PLAYER-ID
    GOBACK.

END PROGRAM Players-FindConnectedByUUID.

*> --- Players-Connect ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-Connect.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> shared data
    COPY DD-PLAYERS.
    *> temporary data
    01 IO-FAILURE               BINARY-CHAR UNSIGNED.
    01 PLAYER-INVENTORY-INDEX   BINARY-CHAR.
LINKAGE SECTION.
    01 LK-CLIENT-ID             BINARY-LONG UNSIGNED.
    01 LK-PLAYER-UUID           PIC X(16).
    01 LK-PLAYER-NAME           PIC X(16).
    01 LK-PLAYER-NAME-LENGTH    BINARY-LONG UNSIGNED.
    *> resulting player id
    01 LK-PLAYER-ID             BINARY-CHAR.

PROCEDURE DIVISION USING LK-CLIENT-ID LK-PLAYER-UUID LK-PLAYER-NAME LK-PLAYER-NAME-LENGTH LK-PLAYER-ID.
    *> find a free player slot
    PERFORM VARYING LK-PLAYER-ID FROM 1 BY 1 UNTIL LK-PLAYER-ID > MAX-PLAYERS
        IF PLAYER-CLIENT(LK-PLAYER-ID) = 0
            *> attempt to load player data
            CALL "Players-LoadPlayer" USING LK-PLAYER-ID LK-PLAYER-UUID IO-FAILURE
            IF IO-FAILURE NOT = 0
                *> no player data, spawn a new player
                MOVE 0 TO PLAYER-X(LK-PLAYER-ID)
                MOVE 64 TO PLAYER-Y(LK-PLAYER-ID)
                MOVE 0 TO PLAYER-Z(LK-PLAYER-ID)
                MOVE 0 TO PLAYER-YAW(LK-PLAYER-ID)
                MOVE 0 TO PLAYER-PITCH(LK-PLAYER-ID)
                MOVE 0 TO PLAYER-HOTBAR(LK-PLAYER-ID)
                PERFORM VARYING PLAYER-INVENTORY-INDEX FROM 1 BY 1 UNTIL PLAYER-INVENTORY-INDEX > 46
                    MOVE 0 TO PLAYER-INVENTORY-SLOT-ID(LK-PLAYER-ID, PLAYER-INVENTORY-INDEX)
                    MOVE 0 TO PLAYER-INVENTORY-SLOT-COUNT(LK-PLAYER-ID, PLAYER-INVENTORY-INDEX)
                    MOVE 0 TO PLAYER-INVENTORY-SLOT-NBT-LENGTH(LK-PLAYER-ID, PLAYER-INVENTORY-INDEX)
                END-PERFORM
            END-IF
            *> connect the player
            MOVE LK-CLIENT-ID TO PLAYER-CLIENT(LK-PLAYER-ID)
            MOVE LK-PLAYER-UUID TO PLAYER-UUID(LK-PLAYER-ID)
            MOVE LK-PLAYER-NAME(1:LK-PLAYER-NAME-LENGTH) TO PLAYER-NAME(LK-PLAYER-ID)
            MOVE LK-PLAYER-NAME-LENGTH TO PLAYER-NAME-LENGTH(LK-PLAYER-ID)
            GOBACK
        END-IF
    END-PERFORM
    *> no free player slots
    MOVE 0 TO LK-PLAYER-ID
    GOBACK.

END PROGRAM Players-Connect.

*> --- Players-Disconnect ---
IDENTIFICATION DIVISION.
PROGRAM-ID. Players-Disconnect.

DATA DIVISION.
WORKING-STORAGE SECTION.
    *> shared data
    COPY DD-PLAYERS.
LINKAGE SECTION.
    01 LK-PLAYER-ID             BINARY-CHAR.

PROCEDURE DIVISION USING LK-PLAYER-ID.
    *> save the player data
    CALL "Players-SavePlayer" USING LK-PLAYER-ID
    *> make the player slot available
    MOVE 0 TO PLAYER-CLIENT(LK-PLAYER-ID)
    GOBACK.

END PROGRAM Players-Disconnect.