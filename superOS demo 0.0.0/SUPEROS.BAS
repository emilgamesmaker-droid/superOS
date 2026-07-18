DECLARE SUB makefile (i$)
DIM h$
          
path0$ = "c:\superOS\reg\1.reg"
           
OPEN path0$ FOR INPUT AS #2
          
LINE INPUT #2, content0$

CLOSE #2

h$ = "root "
h$ = content0$
SCREEN 12
LINE (300, 300)-(200, 200)
LOCATE 13
COLOR 1
PRINT "                           sssss"
PRINT "                           s"
PRINT "                            sssss"
PRINT "                                 s"
PRINT "                                 s"
PRINT "                                 s"
PRINT "                            sssss  OS"
COLOR 7
PRINT "press enter"
INPUT "", q
CLS
DO
    CLS
    PRINT " ____"
    PRINT "(menu)"
    LOCATE 13
    LINE (300, 300)-(200, 200)
    PRINT "                            sssss"
    PRINT "                           s"
    PRINT "                            sssss"
    PRINT "                                 s"
    PRINT "                                 s"
    PRINT "                                 s"
    PRINT "                            sssss  OS"
    DO
        q$ = INKEY$
    LOOP WHILE q$ = ""
    IF q$ = "m" THEN
        CLS
        PRINT "(B)(E)(C)(S)(R)(H)                                                       (x)"
        SLEEP 5
    END IF
    IF q$ = "e" THEN
        DO
            CLS
            PRINT " ________"
            PRINT "(explorer)"
            FILES
            INPUT ">", r$
            IF r$ = "run" THEN
                INPUT ">>", y$
                RUN y$
            END IF
            IF r$ = "x" THEN
                EXIT DO
            END IF
            IF r$ = "cd" THEN
                INPUT ">>", t$
                CHDIR t$
            END IF
            IF r$ = "create" THEN
                INPUT ">>", y$
                IF y$ = "dir" THEN
                    INPUT ">>>", u$
                    MKDIR u$
                END IF
                IF y$ = "file" THEN
                    INPUT ">>>", i$
                    makefile i$
                END IF
            END IF
            IF r$ = "open" THEN
                INPUT ">>", o$
                SHELL "type " + o$
                INPUT ">>>", q
            END IF
            IF r$ = "edit" THEN
                INPUT ">>", p$
                OPEN p$ FOR APPEND AS #1
                INPUT ">>>", a$
                PRINT #1, a$
                CLOSE 1
            END IF
            IF r$ = "del" THEN
                INPUT ">>", s$
                IF s$ = "file" THEN
                    INPUT ">>>", d$
                    KILL d$
                END IF
                IF s$ = "dir" THEN
                    INPUT ">>>", f$
                    RMDIR f$
                END IF
            END IF
        LOOP
    END IF
    IF q$ = "c" THEN
        DO
            CLS
            PRINT " _______"
            PRINT "(console)"
            PRINT "username*" + h$;
            INPUT "", j$
            IF j$ = "exit" THEN
                EXIT DO
            END IF
            IF j$ = "H" THEN
                PRINT "      __________________________________________"
                PRINT "/\_/\<hello commands in console exit, paf, help.|"
                PRINT "|0 0| =========================================="
                PRINT "|__/"
                SLEEP 5
                PRINT "noKa"
            END IF
            IF j$ = "paf" THEN
                FILES
                SLEEP 67676767
            END IF
            IF j$ = "help" THEN
                PRINT "cmd:exit, help, paf"
                SLEEP 67676767
            END IF
        LOOP
    END IF
    IF q$ = "h" THEN
        DO
            PRINT "/\_/\"
            PRINT "|0 0|"
            PRINT "|__/"
            SLEEP 1
            CLS
            PRINT " ____"
            PRINT "(menu)"
            LOCATE 13
            LINE (300, 300)-(200, 200)
            PRINT "                            sssss"
            PRINT "                           s"
            PRINT "                            sssss"
            PRINT "                                 s"
            PRINT "  __________________             s"
            PRINT " |hello! you a russ?|            s"
            PRINT "  Y=================        sssss  OS"
            PRINT "/\_/\"
            PRINT "|0 0|"
            PRINT "|__/"
            INPUT ">", v$
            IF v$ = "yes" THEN
                CLS
                PRINT " ____"
                PRINT "(menu)"
                LOCATE 13
                LINE (300, 300)-(200, 200)
                PRINT "                            sssss"
                PRINT "                           s"
                PRINT "                            sssss"
                PRINT "                                 s"
                PRINT "  ______________________________ s"
                PRINT " |oK TN npoxodN|_|_|. B conso...|s"
                PRINT "  Y=========================sssss  OS"
                PRINT "/\_/\"
                PRINT "|0 0|"
                PRINT "|__/"
                SLEEP 10
                CLS
                PRINT " ____"
                PRINT "(menu)"
                LOCATE 13
                LINE (300, 300)-(200, 200)
                PRINT "                            sssss"
                PRINT "                           s"
                PRINT "                            sssss"
                PRINT "                                 s"
                PRINT "  ______________________________ s"
                PRINT " |le press shift+h enter. bro...|s"
                PRINT "  Y=========================sssss  OS"
                PRINT "/\_/\"
                PRINT "|0 0|"
                PRINT "|__/"
                SLEEP 10
                CLS
                PRINT " ____"
                PRINT "(menu)"
                LOCATE 13
                LINE (300, 300)-(200, 200)
                PRINT "                            sssss"
                PRINT "                           s"
                PRINT "                            sssss"
                PRINT "                                 s"
                PRINT "  _______________________        s"
                PRINT " |wser press shift+h N Td|       s"
                PRINT "  Y======================   sssss  OS"
                PRINT "/\_/\"
                PRINT "|0 0|"
                PRINT "|__/"
                SLEEP 10
                EXIT DO
            END IF
        LOOP
    END IF

    IF q$ = "r" THEN
        DO
            CLS

            PRINT " _______"
            PRINT "(regedit)"

            path$ = "c:\superOS\reg\0.reg"

            OPEN path$ FOR INPUT AS #1

            LINE INPUT #1, content$

            CLOSE #1

            IF content$ = "0" THEN
                PRINT "0|0"
            ELSEIF content$ = "1" THEN
                PRINT "0|1"
            ELSE
                PRINT "?"
            END IF
           
            path0$ = "c:\superOS\reg\1.reg"
            
            OPEN path0$ FOR INPUT AS #2
           
            LINE INPUT #2, content0$

            CLOSE #2

            IF content0$ = "root" THEN
                PRINT "no yMo/\4aHN|-O"
            ELSE
                PRINT "?"
            END IF
            INPUT q
            EXIT DO
        LOOP
    END IF
    IF q$ = "s" THEN
        DO
            CLS
            PRINT " ________"
            PRINT "(settings)"
            PRINT " _______   __________"
            PRINT "(profile) |    ()    |"
            PRINT "          |   ||||   |"
            PRINT "          |__________|"
            DO
                k$ = INKEY$
            LOOP WHILE k$ = ""
            IF k$ = "p" THEN
                PRINT "username:" + h$
                INPUT ">", l$
                IF l$ = "exit" THEN
                    EXIT DO
                END IF
                IF l$ = "x" THEN
                    EXIT DO
                END IF
                IF l$ = "setUsername" THEN
                    INPUT ">>", h$
                END IF
                SLEEP 67676767
            END IF
        LOOP
    END IF
    IF q$ = "b" THEN
        DO
            CLS
            PRINT " _______"
            PRINT "(browser)"
            INPUT "bs://", w$
            IF w$ = "bs.com" THEN
                DO
                        PRINT "bs this a new techonologic in web no http, https, url and internet"
                        INPUT ">", e$
                        IF e$ = "exit" THEN
                            EXIT DO
                        END IF
                        IF e$ = "translate" THEN
                            PRINT "bs ETo HoBaR TexHo/\oINR B WEB HeT http, https, url N NHTepHeTa"
                        END IF
                LOOP
            END IF
            IF w$ = "dostube" THEN
                PRINT "DOStube youtube in dos"
                SLEEP 5
            END IF
            IF w$ = "DOStube" THEN
                DO
                        COLOR 1
                        PRINT "DOStube"
                        COLOR 7
                        PRINT " __________"
                        PRINT "| test!    |"
                        PRINT "|          |"
                        PRINT "|__________|"
                        INPUT ">", g$
                        IF g$ = "exit" THEN
                            EXIT DO
                        END IF
                        IF g$ = "test!" THEN
                            CLS
                            PRINT "t"
                            SLEEP 1
                            CLS
                            PRINT "te"
                            SLEEP 1
                            CLS
                            PRINT "tes"
                            SLEEP 1
                            CLS
                            PRINT "test"
                            SLEEP 1
                            CLS
                            PRINT "test!"
                            INPUT ">>", g$
                        END IF
                        IF g$ = "exit" THEN
                            EXIT DO
                        END IF
                LOOP
            END IF
            IF w$ = "x" THEN
                EXIT DO
            END IF
            IF w$ = "bs" THEN
                PRINT "bs.com the official site"
                SLEEP 5
            END IF
        LOOP
    END IF
    IF q$ = "x" THEN
        END
    END IF
LOOP

                    SUB makefile (i$)
OPEN i$ FOR OUTPUT AS #99
CLOSE #99
END SUB

