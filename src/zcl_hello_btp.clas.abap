*&---------------------------------------------------------------------*
*& Class ZCL_HELLO_BTP
*& Purpose: SAP BTP ABAP Cloud - Travel & Customer Analytics Engine
*& Note: Antigravity edit pushed from VS Code to Git
*&---------------------------------------------------------------------*
CLASS zcl_hello_btp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    TYPES:
      BEGIN OF ty_travel_analytic,
        travel_id      TYPE /dmo/travel_id,
        customer_name  TYPE string,
        city           TYPE /dmo/city,
        country_code   TYPE /dmo/country_code,
        begin_date     TYPE /dmo/begin_date,
        end_date       TYPE /dmo/end_date,
        total_price    TYPE /dmo/total_price,
        currency_code  TYPE /dmo/currency_code,
        status_text    TYPE string,
      END OF ty_travel_analytic,
      tt_travel_analytics TYPE STANDARD TABLE OF ty_travel_analytic WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hello_btp IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        " -----------------------------------------------------------------
        " [Antigravity AI] Edited and pushed from VS Code to Git
        " -----------------------------------------------------------------
        out->write( |============================================================| ).
        out->write( | SAP BTP ABAP CLOUD - TRAVEL & CUSTOMER ANALYTICS           | ).
        out->write( | [Antigravity AI] Upgraded Live Data Sources & Aggregation! | ).
        out->write( | Developer: { cl_abap_context_info=>get_user_formatted_name( ) } | ).
        out->write( | System Date: { cl_abap_context_info=>get_system_date( ) DATE = USER } | ).
        out->write( |============================================================| ).

        " 1. Fetch Live Travel & Customer Data with an SQL JOIN
        SELECT FROM /dmo/travel AS travel
          INNER JOIN /dmo/customer AS customer
            ON travel~customer_id = customer~customer_id
          FIELDS travel~travel_id,
                 customer~first_name,
                 customer~last_name,
                 customer~city,
                 customer~country_code,
                 travel~begin_date,
                 travel~end_date,
                 travel~total_price,
                 travel~currency_code,
                 travel~status
          ORDER BY travel~travel_id ASCENDING
          INTO TABLE @DATA(lt_travel_db)
          UP TO 10 ROWS.

        IF lt_travel_db IS INITIAL.
          out->write( 'No travel booking records found in database.' ).
          RETURN.
        ENDIF.

        " 2. Transform Data with Formatted Customer Names & Status Descriptions
        DATA lt_analytics TYPE tt_travel_analytics.

        lt_analytics = VALUE #(
          FOR ls_row IN lt_travel_db (
            travel_id     = ls_row-travel_id
            customer_name = |{ ls_row-first_name } { ls_row-last_name }|
            city          = ls_row-city
            country_code  = ls_row-country_code
            begin_date    = ls_row-begin_date
            end_date      = ls_row-end_date
            total_price   = ls_row-total_price
            currency_code = ls_row-currency_code
            status_text   = COND #(
              WHEN ls_row-status = 'A' THEN 'Accepted / Confirmed'
              WHEN ls_row-status = 'O' THEN 'Open / Pending'
              WHEN ls_row-status = 'X' THEN 'Cancelled'
              ELSE 'Unknown Status' )
          )
        ).

        " 3. Display Detailed Travel & Customer Table
        out->write( 'Live Travel Booking Records (/DMO/TRAVEL + /DMO/CUSTOMER):' ).
        out->write( lt_analytics ).

        " 4. Calculate Financial Metrics using Modern ABAP REDUCE
        DATA(lv_total_revenue) = REDUCE /dmo/total_price(
          INIT total = 0
          FOR ls_item IN lt_analytics
          WHERE ( currency_code = 'EUR' )
          NEXT total = total + ls_item-total_price ).

        DATA(lv_confirmed_count) = REDUCE i(
          INIT count = 0
          FOR ls_item IN lt_analytics
          WHERE ( status_text = 'Accepted / Confirmed' )
          NEXT count = count + 1 ).

        out->write( |------------------------------------------------------------| ).
        out->write( | Total EUR Revenue for Sample: { lv_total_revenue NUMBER = USER } EUR | ).
        out->write( | Confirmed Bookings: { lv_confirmed_count } of { lines( lt_analytics ) } orders | ).
        out->write( |============================================================| ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error encountered: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
