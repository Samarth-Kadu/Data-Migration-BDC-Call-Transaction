report ZPRG_MM01_REC1
       no standard page heading line-size 255.

TYPES: BEGIN OF STR1,
  MATNR TYPE MATNR,
  MBRSH TYPE MBRSH,
  MTART TYPE MTART,
  MAKTX TYPE MAKTX,
  MEINS TYPE MEINS,
  END OF STR1.

DATA IT_TABLE TYPE  TABLE OF STR1.
DATA WA_TABLE TYPE STR1.
DATA: LV_FILE TYPE STRING.
DATA: IT_BDCDATA TYPE TABLE OF BDCDATA.
DATA: WA_BDCDATA TYPE BDCDATA.
DATA : IT_MESSTAB TYPE TABLE OF BDCMSGCOLL.
DATA : WA_MESSTAB TYPE BDCMSGCOLL.
DATA : LV_MESSAGE TYPE STRING.


PARAMETERS: P_FILE TYPE LOCALFILE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'F4_FILENAME'
   EXPORTING
*     PROGRAM_NAME        = SYST-CPROG
*     DYNPRO_NUMBER       = SYST-DYNNR
     FIELD_NAME          =  ' '
   IMPORTING
     FILE_NAME           = P_FILE
            .

  START-OF-SELECTION.

  LV_FILE = P_FILE.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = LV_FILE
*     FILETYPE                      = 'ASC'
     HAS_FIELD_SEPARATOR           = 'X'
*     HEADER_LENGTH                 = 0
*     READ_BY_LINE                  = 'X'
*     DAT_MODE                      = ' '
*     CODEPAGE                      = ' '
*     IGNORE_CERR                   = ABAP_TRUE
*     REPLACEMENT                   = '#'
*     CHECK_BOM                     = ' '
*     VIRUS_SCAN_PROFILE            =
*     NO_AUTH_CHECK                 = ' '
*   IMPORTING
*     FILELENGTH                    =
*     HEADER                        =
    TABLES
      DATA_TAB                      = IT_TABLE
*   CHANGING
*     ISSCANPERFORMED               = ' '
   EXCEPTIONS
     FILE_OPEN_ERROR               = 1
     FILE_READ_ERROR               = 2
     NO_BATCH                      = 3
     GUI_REFUSE_FILETRANSFER       = 4
     INVALID_TYPE                  = 5
     NO_AUTHORITY                  = 6
     UNKNOWN_ERROR                 = 7
     BAD_DATA_FORMAT               = 8
     HEADER_NOT_ALLOWED            = 9
     SEPARATOR_NOT_ALLOWED         = 10
     HEADER_TOO_LONG               = 11
     UNKNOWN_DP_ERROR              = 12
     ACCESS_DENIED                 = 13
     DP_OUT_OF_MEMORY              = 14
     DISK_FULL                     = 15
     DP_TIMEOUT                    = 16
     OTHERS                        = 17
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


*
*include bdcrecx1.

*start-of-selection.

LOOP AT IT_TABLE INTO WA_TABLE.

*perform open_group.

perform bdc_dynpro      using 'SAPLMGMM' '0060'.
perform bdc_field       using 'BDC_CURSOR'
                              'RMMG1-MATNR'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_field       using 'RMMG1-MATNR'
                              'SS2'.
perform bdc_field       using 'RMMG1-MBRSH'
                              WA_TABLE-MATNR.
perform bdc_field       using 'RMMG1-MTART'
                              WA_TABLE-MTART.
perform bdc_dynpro      using 'SAPLMGMM' '0070'.
perform bdc_field       using 'BDC_CURSOR'
                              'MSICHTAUSW-DYTXT(01)'.
perform bdc_field       using 'BDC_OKCODE'
                              '=ENTR'.
perform bdc_field       using 'MSICHTAUSW-KZSEL(01)'
                              'X'.
perform bdc_dynpro      using 'SAPLMGMM' '4004'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BU'.
perform bdc_field       using 'MAKT-MAKTX'
                              WA_TABLE-MAKTX.
perform bdc_field       using 'BDC_CURSOR'
                              'MARA-MEINS'.
perform bdc_field       using 'MARA-MEINS'
                              WA_TABLE-MEINS.

CALL TRANSACTION 'MM01' USING IT_BDCDATA MODE 'A' UPDATE 'S' MESSAGES INTO IT_MESSTAB.
REFRESH IT_BDCDATA.
*perform bdc_transaction using 'MM01'.
*
*perform close_group.
ENDLOOP.


LOOP AT  IT_MESSTAB INTO WA_MESSTAB.
  CALL FUNCTION 'MESSAGE_TEXT_BUILD'
    EXPORTING
      MSGID                     = WA_MESSTAB-MSGID
      MSGNR                     = WA_MESSTAB-MSGNR
     MSGV1                     =  WA_MESSTAB-MSGV1
     MSGV2                     =  WA_MESSTAB-MSGV2
     MSGV3                     =  WA_MESSTAB-MSGV3
     MSGV4                     =  WA_MESSTAB-MSGV4
   IMPORTING
     MESSAGE_TEXT_OUTPUT       = LV_MESSAGE.
  WRITE: / LV_MESSAGE.
ENDLOOP.


FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR WA_BDCDATA.
  WA_BDCDATA-PROGRAM  = PROGRAM.
  WA_BDCDATA-DYNPRO   = DYNPRO.
  WA_BDCDATA-DYNBEGIN = 'X'.
  APPEND WA_BDCDATA TO IT_BDCDATA.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  IF FVAL IS NOT INITIAL.
    CLEAR WA_BDCDATA.
    WA_BDCDATA-FNAM = FNAM.
    WA_BDCDATA-FVAL = FVAL.
    APPEND WA_BDCDATA TO  IT_BDCDATA.
  ENDIF.
ENDFORM.