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
        out->write( |======================================================================| ).
        out->write( | SAP BTP ABAP CLOUD - CUSTOMER TRAVEL & REVENUE ANALYTICS          | ).
        out->write( | [Antigravity AI] Live Business Intelligence Engine Enabled!          | ).
        out->write( | Logged in as : { cl_abap_context_info=>get_user_formatted_name( ) } | ).
        out->write( | Run Timestamp: { cl_abap_context_info=>get_system_date( ) DATE = USER } | ).
        out->write( |======================================================================| ).

        " 1. Query live database records (Travel Orders joined with Customer Master)
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

        " 2. Transform and enrich records
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
              WHEN ls_row-status = 'A' THEN 'Confirmed (A)'
              WHEN ls_row-status = 'O' THEN 'Pending (O)'
              WHEN ls_row-status = 'X' THEN 'Cancelled (X)'
              ELSE 'Other' )
          )
        ).

        " 3. Output Formatted Customer & Travel Booking Table
        out->write( 'Customer Travel Bookings Dataset:' ).
        out->write( lt_analytics ).

        " 4. Calculate Aggregate Financial KPIs using Modern ABAP REDUCE Expressions
        DATA(lv_total_revenue_eur) = REDUCE /dmo/total_price(
          INIT total = 0
          FOR ls_item IN lt_analytics
          WHERE ( currency_code = 'EUR' )
          NEXT total = total + ls_item-total_price ).

        DATA(lv_confirmed_orders) = REDUCE i(
          INIT count = 0
          FOR ls_item IN lt_analytics
          WHERE ( status_text = 'Confirmed (A)' )
          NEXT count = count + 1 ).

        DATA(lv_total_orders) = lines( lt_analytics ).

        DATA(lv_avg_order_value) = COND /dmo/total_price(
          WHEN lv_total_orders > 0
          THEN lv_total_revenue_eur / lv_total_orders
          ELSE 0 ).

        out->write( |----------------------------------------------------------------------| ).
        out->write( | EXECUTIVE REVENUE & PERFORMANCE SUMMARY:                             | ).
        out->write( | • Total Sample Revenue (EUR) : { lv_total_revenue_eur NUMBER = USER } EUR | ).
        out->write( | • Average Order Value (EUR)  : { lv_avg_order_value NUMBER = USER } EUR | ).
        out->write( | • Total Bookings Evaluated   : { lv_total_orders } orders | ).
        out->write( | • Confirmed Booking Rate     : { ( CONV decfloat34( lv_confirmed_orders ) / lv_total_orders ) * 100 DECIMALS = 2 }% ({ lv_confirmed_orders }/{ lv_total_orders }) | ).
        out->write( |======================================================================| ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error encountered: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
