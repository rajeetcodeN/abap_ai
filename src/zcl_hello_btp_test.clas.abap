*&---------------------------------------------------------------------*
*& Class ZCL_HELLO_BTP_TEST
*& Purpose: SAP BTP ABAP Cloud - Airline Fleet & Market Share Analytics
*& Version: 2.0 - Clean ABAP with Local Engine and Automated Unit Tests
*&---------------------------------------------------------------------*
CLASS zcl_hello_btp_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    TYPES:
      BEGIN OF ty_carrier_summary,
        carrier_id      TYPE /dmo/carrier_id,
        carrier_name    TYPE /dmo/carrier_name,
        currency_code   TYPE /dmo/currency_code,
        flight_count    TYPE i,
        total_seats_max TYPE i,
        total_booked    TYPE i,
        avg_price       TYPE /dmo/flight_price,
        fleet_capacity  TYPE p LENGTH 5 DECIMALS 2,
        carrier_tier    TYPE string,
      END OF ty_carrier_summary,
      tt_carrier_summary TYPE STANDARD TABLE OF ty_carrier_summary WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hello_btp_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        out->write( |========================================================================================| ).
        out->write( |      SAP BTP ABAP CLOUD - AIRLINE FLEET & MARKET SHARE ANALYTICS ENGINE [TEST]         | ).
        out->write( |      [Antigravity AI] Clean ABAP Architecture with Local Helper & Unit Tests           | ).
        out->write( |      User : { cl_abap_context_info=>get_user_formatted_name( ) }                      | ).
        out->write( |      Date : { cl_abap_context_info=>get_system_date( ) DATE = USER }                  | ).
        out->write( |========================================================================================| ).

        " 1. Query live Flights grouped by Airline Carrier
        SELECT FROM /dmo/carrier AS carrier
          INNER JOIN /dmo/flight AS flight
            ON carrier~carrier_id = flight~carrier_id
          FIELDS carrier~carrier_id,
                 carrier~name AS carrier_name,
                 carrier~currency_code,
                 flight~price,
                 flight~seats_max,
                 flight~seats_occupied
          ORDER BY carrier~carrier_id ASCENDING
          INTO TABLE @DATA(lt_carrier_flights).

        IF lt_carrier_flights IS INITIAL.
          out->write( 'No airline flight records found in database.' ).
          RETURN.
        ENDIF.

        " 2. Aggregate metrics per Airline using Local Helper Engine
        DATA lt_summary TYPE tt_carrier_summary.

        " Get unique carriers
        DATA(lt_unique_carriers) = lt_carrier_flights.
        SORT lt_unique_carriers BY carrier_id.
        DELETE ADJACENT DUPLICATES FROM lt_unique_carriers COMPARING carrier_id.

        LOOP AT lt_unique_carriers INTO DATA(ls_unique).
          DATA(lv_flight_count) = 0.
          DATA(lv_seats_max)    = 0.
          DATA(lv_seats_occ)    = 0.
          DATA(lv_price_sum)    = CONV /dmo/flight_price( 0 ).

          LOOP AT lt_carrier_flights INTO DATA(ls_fl) WHERE carrier_id = ls_unique-carrier_id.
            lv_flight_count = lv_flight_count + 1.
            lv_seats_max    = lv_seats_max + ls_fl-seats_max.
            lv_seats_occ    = lv_seats_occ + ls_fl-seats_occupied.
            lv_price_sum    = lv_price_sum + ls_fl-price.
          ENDLOOP.

          " Leverage Local Business Engine
          DATA(lv_occupancy) = lcl_airline_engine=>calculate_occupancy(
            iv_occupied = lv_seats_occ
            iv_max      = lv_seats_max ).

          DATA(lv_avg_price) = COND /dmo/flight_price(
            WHEN lv_flight_count > 0
            THEN lv_price_sum / lv_flight_count
            ELSE 0 ).

          DATA(lv_tier) = lcl_airline_engine=>determine_carrier_tier(
            iv_occupancy = lv_occupancy
            iv_avg_price = lv_avg_price ).

          APPEND VALUE #(
            carrier_id      = ls_unique-carrier_id
            carrier_name    = ls_unique-carrier_name
            currency_code   = ls_unique-currency_code
            flight_count    = lv_flight_count
            total_seats_max = lv_seats_max
            total_booked    = lv_seats_occ
            avg_price       = lv_avg_price
            fleet_capacity  = lv_occupancy
            carrier_tier    = lv_tier
          ) TO lt_summary.
        ENDLOOP.

        " 3. Output Detailed Airline Performance Table
        out->write( 'Live Airline Carrier Performance Summary with Tier Ratings:' ).
        out->write( lt_summary ).

        " 4. Calculate Fleet-Wide Totals
        DATA(lv_total_flights) = REDUCE i(
          INIT total = 0
          FOR ls_c IN lt_summary
          NEXT total = total + ls_c-flight_count ).

        DATA(lv_total_fleet_seats) = REDUCE i(
          INIT total = 0
          FOR ls_c IN lt_summary
          NEXT total = total + ls_c-total_seats_max ).

        DATA(lv_total_fleet_booked) = REDUCE i(
          INIT total = 0
          FOR ls_c IN lt_summary
          NEXT total = total + ls_c-total_booked ).

        out->write( |----------------------------------------------------------------------------------------| ).
        out->write( | ✈️ FLEET-WIDE CAPACITY & FLIGHT SUMMARY:                                               | ).
        out->write( | • Total Active Airlines Tracked : { lines( lt_summary ) } carriers                       | ).
        out->write( | • Total Scheduled Flights       : { lv_total_flights } flights                          | ).
        out->write( | • Total Fleet Passenger Seats   : { lv_total_fleet_seats NUMBER = USER } seats          | ).
        out->write( | • Total Seats Booked by Users   : { lv_total_fleet_booked NUMBER = USER } seats         | ).
        out->write( | • Global Network Load Factor    : { ( CONV decfloat34( lv_total_fleet_booked ) / lv_total_fleet_seats ) * 100 DECIMALS = 2 }% | ).
        out->write( |========================================================================================| ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error encountered: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
