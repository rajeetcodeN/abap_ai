CLASS zcl_order_discount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb OPTIONAL.

    TYPES:
      tv_amount   TYPE p LENGTH 15 DECIMALS 2,
      tv_discount TYPE p LENGTH 5 DECIMALS 2.

    METHODS calculate_discount
      IMPORTING
        iv_amount          TYPE tv_amount
      RETURNING
        VALUE(rv_discount) TYPE tv_discount
      RAISING
        cx_sy_conversion_overflow.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      c_threshold TYPE tv_amount VALUE '1000.00',
      c_discount  TYPE tv_discount VALUE '10.00'.
ENDCLASS.

CLASS zcl_order_discount IMPLEMENTATION.
  METHOD calculate_discount.
    " Clean ABAP: Fail fast on invalid boundaries
    IF iv_amount < 0.
      RAISE EXCEPTION TYPE cx_sy_conversion_overflow.
    ENDIF.

    " Clean ABAP: COND expression replacing verbose IF-ELSE
    rv_discount = COND #( WHEN iv_amount > c_threshold THEN c_discount
                          ELSE '0.00' ).
  ENDMETHOD.
ENDCLASS.
