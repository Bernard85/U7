             CMD        PROMPT('Analyse journal the outfile')
             PARM       KWD(JRN) TYPE(Q10DA) MIN(1) PROMPT('Outfile +
                          for journal analysis')
             PARM       KWD(SAVPATH) TYPE(*CHAR) LEN(50) MIN(1) +
                          VARY(*YES) CASE(*MIXED) PROMPT('Save path')

             PARM       KWD(TEXT) TYPE(*CHAR) LEN(50) MIN(1) +
                          VARY(*YES) CASE(*MIXED) PROMPT('Analyse +
                          description')
 Q10DA:      QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL) (*CURLIB  '*CURLIB   ')) +
                          EXPR(*YES) PROMPT('Library')
