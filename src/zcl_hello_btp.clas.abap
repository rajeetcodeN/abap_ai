*&---------------------------------------------------------------------*
*& Class ZCL_HELLO_BTP
*& Purpose: SAP BTP ABAP Cloud Demo & Flight Analytics Engine
*& Note: Antigravity edit pushed from VS Code to Git
*&---------------------------------------------------------------------*
CLASS zcl_hello_btp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    TYPES:
      BEGIN OF ty_flight_analytic,
        carrier_id     TYPE /dmo/carrier_id,
        connection_id  TYPE /dmo/connection_id,
        flight_date    TYPE /dmo/flight_date,
        price          TYPE /dmo/flight_price,
        currency_code  TYPE /dmo/currency_code,
        seats_max      TYPE /dmo/plane_seats_max,
        seats_occupied TYPE /dmo/plane_seats_occupied,
        occupancy_rate TYPE p LENGTH 5 DECIMALS 2, " Percentage e.g. 78.50%
      END OF ty_flight_analytic,
      tt_flight_analytics TYPE STANDARD TABLE OF ty_flight_analytic WITH EMPTY KEY.

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
        out->write( | SAP BTP ABAP CLOUD - FLIGHT ANALYTICS ENGINE               | ).
        out->write( | [Antigravity AI] Edited and pushed from VS Code to Git!     | ).
        out->write( | Developer: { cl_abap_context_info=>get_user_formatted_name( ) } | ).
        out->write( | System Date: { cl_abap_context_info=>get_system_date( ) DATE = USER } | ).
        out->write( |============================================================| ).

        " 1. Query live flight data from /DMO/FLIGHT
        SELECT FROM /dmo/flight
          FIELDS carrier_id,
                 connection_id,
                 flight_date,
                 price,
                 currency_code,
                 seats_max,
                 seats_occupied
          ORDER BY flight_date ASCENDING
          INTO TABLE @DATA(lt_raw_flights)
          UP TO 10 ROWS.

        IF lt_raw_flights IS INITIAL.
          out->write( 'No flight records found.' ).
          RETURN.
        ENDIF.

        " 2. Calculate Occupancy Rates using ABAP 7.50+ Table Comprehension
        DATA lt_analytics TYPE tt_flight_analytics.

        lt_analytics = VALUE #(
          FOR ls_flight IN lt_raw_flights (
            carrier_id     = ls_flight-carrier_id
            connection_id  = ls_flight-connection_id
            flight_date    = ls_flight-flight_date
            price          = ls_flight-price
            currency_code  = ls_flight-currency_code
            seats_max      = ls_flight-seats_max
            seats_occupied = ls_flight-seats_occupied
            occupancy_rate = COND #(
              WHEN ls_flight-seats_max > 0
              THEN ( CONV decfloat34( ls_flight-seats_occupied ) / ls_flight-seats_max ) * 100
              ELSE 0 )
          )
        ).

        " 3. Output Detailed Flight Table
        out->write( 'Detailed Flight Occupancy Report:' ).
        out->write( lt_analytics ).

        " 4. Calculate Aggregate Total Seats Booked across all flights using REDUCE
        DATA(lv_total_seats_occupied) = REDUCE i(
          INIT total = 0
          FOR ls_item IN lt_analytics
          NEXT total = total + ls_item-seats_occupied ).

        DATA(lv_total_seats_capacity) = REDUCE i(
          INIT total_cap = 0
          FOR ls_item IN lt_analytics
          NEXT total_cap = total_cap + ls_item-seats_max ).

        out->write( |------------------------------------------------------------| ).
        out->write( | Total Passengers Booked: { lv_total_seats_occupied } / { lv_total_seats_capacity } seats | ).
        out->write( | Overall Fleet Occupancy: { ( CONV decfloat34( lv_total_seats_occupied ) / lv_total_seats_capacity ) * 100 DECIMALS = 2 }% | ).
        out->write( |============================================================| ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error encountered: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
