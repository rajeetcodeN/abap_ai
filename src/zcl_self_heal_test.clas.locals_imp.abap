CLASS ltcl_zcl_self_heal_test_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_self_heal_test.
    METHODS setup.
    METHODS test_execution FOR TESTING.
ENDCLASS.

CLASS ltcl_zcl_self_heal_test_test IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD test_execution.
    cl_aunit_assert=>assert_bound(
      act = mo_cut
      msg = |Object instantiation verified| ).
  ENDMETHOD.
ENDCLASS.
