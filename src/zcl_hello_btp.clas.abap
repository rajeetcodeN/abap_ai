CLASS zcl_hello_btp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_hello_btp IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        " 1. Print Welcome Message
        out->write( |Hello SAP BTP ABAP Cloud! Logged in as: { cl_abap_context_info=>get_user_formatted_name( ) }| ).
        out->write( |System Date: { cl_abap_context_info=>get_system_date( ) DATE = USER }| ).
        out->write( '---------------------------------------------------------' ).

        " 2. Fetch Live Flight Data from SAP /DMO/ Demo Database
        SELECT FROM /dmo/flight
          FIELDS carrier_id,
                 connection_id,
                 flight_date,
                 price,
                 currency_code,
                 seats_max,
                 seats_occupied
          ORDER BY flight_date ASCENDING
          INTO TABLE @DATA(lt_flights)
          UP TO 5 ROWS.

        " 3. Display Data in Console
        out->write( 'Flight Schedule Summary (/DMO/FLIGHT):' ).
        out->write( lt_flights ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error occurred: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

