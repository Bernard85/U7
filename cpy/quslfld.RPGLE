     D*******************************************************************
     D*Type Definition for the Header Section of the user space in the
     D*QUSLFLD API.       
     D*******************************************************************
     DQUSQLH           DS
     D*                                             Qdb Lfld Header
     D QUSFILNU                1     10
     D*                                             File Name Used
     D QUSLIBN                11     20
     D*                                             Library Name
     D QUSFILT                21     30
     D*                                             File Type
     D QUSRFN00               31     40
     D*                                             Record Format Name
     D QUSRL                  41     44B 0
     D*                                             Record Length
     D QUSRFI                 45     57
     D*                                             Record Format Id
     D QUSRTD                 58    107
     D*                                             Record Text Description
     D QUSERVED01            108    108
     D*                                             Reserved
     D QUSCCSID              109    112B 0
     D*                                             Record Description CCSID
     D QUSVLF                113    113
     D*                                             Variable Length Fields
     D QUSGFI                114    114
     D*                                             Graphic Fields Indicator
     D QUSDTFI               115    115
     D*                                             Date Time Fields Indicator
     D QUSNCFI               116    116
     D*                                             Null Capable Fields Indicato
     D*******************************************************************
     D*Type Definition for the FLDL0100 format of the userspace in the
     D*QUSLFLD API.       @A2C
     D*******************************************************************
     DQUSL0100         DS
     D*                                             Qdb Lfld FLDL0100
     D QUSFN02                 1     10
     D*                                             Field Name
     D QUSDT                  11     11
     D*                                             Data Type
     D QUSU                   12     12
     D*                                             Use
     D QUSOBP                 13     16B 0
     D*                                             Output Buffer Position
     D QUSIBP                 17     20B 0
     D*                                             Input Buffer Position
     D QUSFLB                 21     24B 0
     D*                                             Field Length Bytes
     D QUSIGITS               25     28B 0
     D*                                             Digits
     D QUSDP                  29     32B 0
     D*                                             Decimal Positions
     D QUSFTD                 33     82
     D*                                             Field Text Description
     D QUSEC00                83     84
     D*                                             Edit Code
     D QUSEWL                 85     88B 0
     D*                                             Edit Word Length
     D QUSEW                  89    152
     D*                                             Edit Word
     D QUSCH1                153    172
     D*                                             Column Heading1
     D QUSCH2                173    192
     D*                                             Column Heading2
     D QUSCH3                193    212
     D*                                             Column Heading3
     D QUSIFN                213    222
     D*                                             Internal Field Name
     D QUSAFN                223    252
     D*                                             Alternate Field Name
     D QUSLAF                253    256B 0
     D*                                             Length Alternate Field
     D QUSDBCSC              257    260B 0
     D*                                             Number DBCS Characters
     D QUSNVA                261    261
     D*                                             Null Values Allowed
     D QUSVFI                262    262
     D*                                             Variable Field Indicator
     D QUSDTF                263    266
     D*                                             Date Time Format
     D QUSDTS                267    267
     D*                                             Date Time Separator
     D QUSVLFI               268    268
     D*                                             Variable Length Field Ind
     D QUSCCSID00            269    272B 0
     D*                                             Field Description CCSID
     D QUSCCSID01            273    276B 0
     D*                                             Field Data CCSID
     D QUSCCSID02            277    280B 0
     D*                                             Field Column Heading CCSID
     D QUSCCSID03            281    284B 0
     D*                                             Field Edit Words CCSID
     D QUSCS2DL              285    288B 0
     D*                                             UCS2 Displayed Length
     D QUSFDES               289    292B 0
     D*                                             Field Data Encoding Scheme
     D QUSMLOL               293    296B 0
     D*                                             Maximum Large Object Length
     D QUSLOPL               297    300B 0
     D*                                             Large Object Pad Length
     D QUSUDTNL              301    304B 0
     D*                                             UDT Name Length
     D QUSUDTN               305    432
     D*                                             UDT Name
     D QUSUDTLN              433    442
     D*                                             UDT Library Name
     D QUSDC03               443    443
     D*                                             Datalink Control
     D QUSDI03               444    444
     D*                                             Datalink Integrity
     D QUSDRP                445    445
     D*                                             Datalink Read Permission
     D QUSDWP                446    446
     D*                                             Datalink Write Permission
     D QUSDR                 447    447
     D*                                             Datalink Recovery
     D QUSDUC02              448    448
     D*                                             Datalink Unlink Control
     D QUSRNBR               449    452B 0
     D*                                             Row Number
     D QUSCNBR               453    456B 0
     D*                                             Column Number
     D QUSOWIDC              457    457
     D*                                             ROWID Column
     D QUSIC                 458    458
     D*                                             Identity Column
     D QUSTEDBY              459    459
     D*                                             GENERATED BY
     D QUSICC                460    460
     D*                                             IC Cycle
     D QUSICOSW              461    476P 0
     D*                                             IC Orig Start With
     D QUSICCSW              477    492P 0
     D*                                             IC Curr Start With
     D QUSICIB               493    496B 0
     D*                                             IC Increment By
     D QUSVALUE              497    512P 0
     D*                                             IC MINVALUE
     D QUSVALUE00            513    528P 0
     D*                                             IC MAXVALUE
     D QUSCACHE              529    532U 0
     D*                                             IC CACHE
     D QUSORDER              533    533
     D*                                             IC ORDER
     D QUSIH                 534    534
     D*                                             Implicitly Hidden
     D QUSRCTG               535    535
     D*                                             Row Change Timestamp Generat
     D QUSFPPN               536    545
     D*                                             Field Procedure Program Name
     D QUSFPLN               546    555
     D*                                             Field Procedure Library Name
     D QUSERVED47            556    560
     D*                                             Reserved
