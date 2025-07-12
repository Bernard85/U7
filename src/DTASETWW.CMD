             CMD        PROMPT('Data set - work with')

             PARM       KWD(FILE) TYPE(Q1) MIN(1) PROMPT('File')

 Q1:         QUAL       TYPE(*NAME) LEN(10)

             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')

             PARM       KWD(FORMAT) TYPE(*CHAR) LEN(20) DFT(*FILE) +
                        SPCVAL((*FILE)) VARY(*YES *INT2)

             PARM       KWD(WHERE) TYPE(*CHAR) LEN(60) VARY(*YES +
                          *INT2) CASE(*MIXED) PROMPT('Where')

             PARM       KWD(ORDERBY) TYPE(*CHAR) LEN(60) MIN(0) +
                          MAX(1) VARY(*YES *INT2) CASE(*MIXED) +
                          PROMPT('Order by')

