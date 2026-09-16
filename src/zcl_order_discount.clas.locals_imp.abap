*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and test classes

CLASS ltcl_order_discount_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_order_discount.

    METHODS setup.
    METHODS test_over_threshold FOR TESTING.
    METHODS test_exact_threshold FOR TESTING.
    METHODS test_under_threshold FOR TESTING.
    METHODS test_zero_amount FOR TESTING.
    METHODS test_negative_amount FOR TESTING.
ENDCLASS.

CLASS ltcl_order_discount_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_over_threshold.
    " Given: Order amount of 1500.00
    " Expected: 10% discount = 150.00
    DATA(lv_discount) = mo_cut->calculate_discount( iv_amount = '1500.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_discount
      exp = '150.00'
      msg = 'Discount for 1500.00 should be 150.00' ).
  ENDMETHOD.

  METHOD test_exact_threshold.
    " Given: Order amount of exactly 1000.00 (inclusive threshold)
    " Expected: 10% discount = 100.00
    DATA(lv_discount) = mo_cut->calculate_discount( iv_amount = '1000.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_discount
      exp = '100.00'
      msg = 'Discount for exactly 1000.00 should be 100.00' ).
  ENDMETHOD.

  METHOD test_under_threshold.
    " Given: Order amount of 999.00
    " Expected: 0.00 discount
    DATA(lv_discount) = mo_cut->calculate_discount( iv_amount = '999.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_discount
      exp = '0.00'
      msg = 'Discount for 999.00 should be 0.00' ).
  ENDMETHOD.

  METHOD test_zero_amount.
    " Given: 0.00 order amount
    " Expected: 0.00 discount
    DATA(lv_discount) = mo_cut->calculate_discount( iv_amount = '0.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_discount
      exp = '0.00'
      msg = 'Zero amount should return 0.00' ).
  ENDMETHOD.

  METHOD test_negative_amount.
    " Given: Negative order amount (-500.00)
    " Expected: 0.00 discount (no exception, returns 0)
    DATA(lv_discount) = mo_cut->calculate_discount( iv_amount = '-500.00' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_discount
      exp = '0.00'
      msg = 'Negative amount should safely return 0.00' ).
  ENDMETHOD.

ENDCLASS.
