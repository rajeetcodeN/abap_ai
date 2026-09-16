CLASS ltcl_discount_calculator DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_order_discount_loop.

    METHODS setup.
    METHODS test_10000_gives_1500 FOR TESTING RAISING cx_static_check.
    METHODS test_5000_gives_zero FOR TESTING RAISING cx_static_check.
    METHODS test_negative_raises_exception FOR TESTING.
ENDCLASS.

CLASS ltcl_discount_calculator IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD test_10000_gives_1500.
    DATA(calculated_discount) = cut->calculate_discount( '10000.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = calculated_discount
      exp = '1500.00'
      msg = |Expected 1500 discount for 10000 amount, got { calculated_discount }| ).
  ENDMETHOD.

  METHOD test_5000_gives_zero.
    DATA(calculated_discount) = cut->calculate_discount( '5000.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = calculated_discount
      exp = '0.00'
      msg = |Expected 0 discount for 5000 amount, got { calculated_discount }| ).
  ENDMETHOD.

  METHOD test_negative_raises_exception.
    TRY.
        cut->calculate_discount( '-100.00' ).
        cl_abap_unit_assert=>fail( msg = 'Expected cx_abap_invalid_value exception for negative order amount' ).
      CATCH cx_abap_invalid_value.
        " Test succeeds as expected exception was raised
    ENDTRY.
  ENDMETHOD.
ENDCLASS.