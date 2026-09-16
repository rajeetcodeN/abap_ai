CLASS ltcl_zcl_order_discount_loop_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_order_discount_loop.

    METHODS setup.
    METHODS test_above_threshold FOR TESTING.
    METHODS test_below_threshold FOR TESTING.
    METHODS test_zero_amount     FOR TESTING.
    METHODS test_negative_amount FOR TESTING.
ENDCLASS.

CLASS ltcl_zcl_order_discount_loop_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_above_threshold.
    DATA(lv_discount) = mo_cut->calculate_discount( '1500.00' ).
    cl_aunit_assert=>assert_equals(
      act = lv_discount
      exp = '10.00'
      msg = |Expected 10.00 discount for amounts over 1000| ).
  ENDMETHOD.

  METHOD test_below_threshold.
    DATA(lv_discount) = mo_cut->calculate_discount( '500.00' ).
    cl_aunit_assert=>assert_equals(
      act = lv_discount
      exp = '0.00'
      msg = |Expected 0.00 discount for amounts under 1000| ).
  ENDMETHOD.

  METHOD test_zero_amount.
    DATA(lv_discount) = mo_cut->calculate_discount( '0.00' ).
    cl_aunit_assert=>assert_equals(
      act = lv_discount
      exp = '0.00'
      msg = |Expected 0% discount for zero amount| ).
  ENDMETHOD.

  METHOD test_negative_amount.
    TRY.
        mo_cut->calculate_discount( '-50.00' ).
        cl_aunit_assert=>fail( msg = |Negative amount must raise exception| ).
      CATCH cx_sy_conversion_overflow.
        " Expected outcome
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
