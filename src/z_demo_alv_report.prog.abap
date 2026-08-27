*&---------------------------------------------------------------------*
*& Report Z_DEMO_ALV_REPORT
*& Title: Modern ABAP SALV Report Template (Sales Order Overview)
*& ABAP Release: 7.40+ / 7.50+ / S/4HANA
*&---------------------------------------------------------------------*
REPORT z_demo_alv_report.

TABLES: vbak.

"----------------------------------------------------------------------
" Selection Screen
"----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vbeln FOR vbak-vbeln,
                  s_erdat FOR vbak-erdat,
                  s_auart FOR vbak-auart.
  PARAMETERS:     p_max   TYPE i DEFAULT 100.
SELECTION-SCREEN END OF BLOCK b1.

"----------------------------------------------------------------------
" Local Class Definition for Report Controller
"----------------------------------------------------------------------
CLASS lcl_report_controller DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_sales_data,
        vbeln TYPE vbak-vbeln,
        erdat TYPE vbak-erdat,
        erzet TYPE vbak-erzet,
        ernam TYPE vbak-ernam,
        auart TYPE vbak-auart,
        netwr TYPE vbak-netwr,
        waerk TYPE vbak-waerk,
        kunnr TYPE vbak-kunnr,
      END OF ty_sales_data,
      tt_sales_data TYPE STANDARD TABLE OF ty_sales_data WITH EMPTY KEY.

    METHODS:
      run,
      fetch_data,
      display_alv.

  PRIVATE SECTION.
    DATA: mt_sales_data TYPE tt_sales_data.
ENDCLASS.

"----------------------------------------------------------------------
" Local Class Implementation
"----------------------------------------------------------------------
CLASS lcl_report_controller IMPLEMENTATION.
  METHOD run.
    fetch_data( ).
    IF mt_sales_data IS INITIAL.
      MESSAGE 'No data found for the specified selection criteria.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    display_alv( ).
  ENDMETHOD.

  METHOD fetch_data.
    " Modern ABAP 7.40+ OpenSQL Query
    SELECT FROM vbak
      FIELDS vbeln, erdat, erzet, ernam, auart, netwr, waerk, kunnr
      WHERE vbeln IN @s_vbeln
        AND erdat IN @s_erdat
        AND auart IN @s_auart
      ORDER BY vbeln DESCENDING
      INTO CORRESPONDING FIELDS OF TABLE @mt_sales_data
      UP TO @p_max ROWS.
  ENDMETHOD.

  METHOD display_alv.
    DATA: lo_alv TYPE REF TO cl_salv_table.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lo_alv
          CHANGING
            t_table      = mt_sales_data ).

        " Enable standard ALV functions (Sort, Filter, Export to Excel)
        DATA(lo_functions) = lo_alv->get_functions( ).
        lo_functions->set_all( abap_true ).

        " Optimize column widths
        DATA(lo_columns) = lo_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        " Set zebra striping pattern
        DATA(lo_display) = lo_alv->get_display_settings( ).
        lo_display->set_striped_pattern( abap_true ).
        lo_display->set_list_header( 'Sales Order Summary' ).

        " Display output
        lo_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lx_salv_msg).
        MESSAGE lx_salv_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

"----------------------------------------------------------------------
" Report Event Blocks
"----------------------------------------------------------------------
INITIALIZATION.
  TEXT-001 = 'Selection Criteria'.

START-OF-SELECTION.
  NEW lcl_report_controller( )->run( ).

