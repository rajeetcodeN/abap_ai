CLASS zcl_order_discount_loop DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_amount TYPE p LENGTH 15 DECIMALS 2.

    "! Calculates discount for a given order amount.
    "! @parameter amount | Order net amount
    "! @parameter discount | Calculated discount amount
    "! @raising cx_abap_invalid_value | Raised if order amount is negative
    METHODS calculate_discount
      IMPORTING
        amount          TYPE ty_amount
      RETURNING
        VALUE(discount) TYPE ty_amount
      RAISING
        cx_abap_invalid_value.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      c_threshold_amount TYPE ty_amount VALUE '10000.00',
      c_discount_rate    TYPE p LENGTH 5 DECIMALS 2 VALUE '0.15'.
ENDCLASS.

CLASS zcl_order_discount_loop IMPLEMENTATION.
  METHOD calculate_discount.
    IF amount < 0.
      RAISE EXCEPTION TYPE cx_abap_invalid_value.
    ENDIF.

    discount = COND #( WHEN amount >= c_threshold_amount
                       THEN amount * c_discount_rate
                       ELSE 0 ).
  ENDMETHOD.
ENDCLASS.