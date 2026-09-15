*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"----------------------------------------------------------------------
" Local Business Helper Class (Clean ABAP Pattern)
"----------------------------------------------------------------------
CLASS lcl_airline_engine DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      "! Calculate seat occupancy percentage safely
      calculate_occupancy
        IMPORTING
          iv_occupied    TYPE i
          iv_max         TYPE i
        RETURNING
          VALUE(rv_rate) TYPE p LENGTH 5 DECIMALS 2,

      "! Determine carrier market performance tier
      determine_carrier_tier
        IMPORTING
          iv_occupancy   TYPE p
          iv_avg_price   TYPE /dmo/flight_price
        RETURNING
          VALUE(rv_tier) TYPE string.
ENDCLASS.

CLASS lcl_airline_engine IMPLEMENTATION.
  METHOD calculate_occupancy.
    IF iv_max <= 0.
      rv_rate = 0.
      RETURN.
    ENDIF.

    rv_rate = ( CONV decfloat34( iv_occupied ) / iv_max ) * 100.
  ENDMETHOD.

  METHOD determine_carrier_tier.
    IF iv_occupancy >= 80 AND iv_avg_price >= 2000.
      rv_tier = 'Premium High-Yield [⭐⭐⭐]'.
    ELSEIF iv_occupancy >= 60.
      rv_tier = 'Mainline Standard [⭐⭐]'.
    ELSE.
      rv_tier = 'Low Utilization    [⭐]'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

"----------------------------------------------------------------------
" ABAP Unit Test Class (Automated Quality Assurance)
"----------------------------------------------------------------------
CLASS ltcl_airline_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      "! Test normal capacity calculation
      test_normal_occupancy FOR TESTING,
      "! Test zero capacity edge case (prevent divide-by-zero dump)
      test_zero_capacity_safe FOR TESTING,
      "! Test tier assignment logic
      test_premium_tier_rating FOR TESTING.
ENDCLASS.

CLASS ltcl_airline_unit_test IMPLEMENTATION.

  METHOD test_normal_occupancy.
    " Given: 150 occupied seats out of 200 max seats
    DATA(lv_result) = lcl_airline_engine=>calculate_occupancy(
      iv_occupied = 150
      iv_max      = 200 ).

    " Expect: 75.00%
    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '75.00'
      msg = 'Occupancy calculation should be exactly 75.00%' ).
  ENDMETHOD.

  METHOD test_zero_capacity_safe.
    " Given: 0 max seats
    DATA(lv_result) = lcl_airline_engine=>calculate_occupancy(
      iv_occupied = 0
      iv_max      = 0 ).

    " Expect: 0.00% (No runtime dump)
    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '0.00'
      msg = 'Zero capacity should return 0.00% without division errors' ).
  ENDMETHOD.

  METHOD test_premium_tier_rating.
    " Given: 85% occupancy and 2500 EUR ticket price
    DATA(lv_tier) = lcl_airline_engine=>determine_carrier_tier(
      iv_occupancy = '85.00'
      iv_avg_price = 2500 ).

    " Expect: Premium High-Yield
    cl_abap_unit_assert=>assert_equals(
      act = lv_tier
      exp = 'Premium High-Yield [⭐⭐⭐]'
      msg = 'High occupancy and price should qualify as Premium High-Yield' ).
  ENDMETHOD.

ENDCLASS.
