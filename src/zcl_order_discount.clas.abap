CLASS zcl_order_discount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES tv_amount TYPE p LENGTH 8 DECIMALS 2.

    "! Calculate discount amount based on order value
    "! @parameter iv_amount | Total gross order amount
    "! @parameter rv_discount | Calculated discount amount (10% if >= 1000, else 0)
    METHODS calculate_discount
      IMPORTING
        iv_amount          TYPE tv_amount
      RETURNING
        VALUE(rv_discount) TYPE tv_amount.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      c_threshold_amount TYPE tv_amount VALUE '1000.00',
      c_discount_rate    TYPE decfloat16 VALUE '0.10'.
ENDCLASS.

CLASS zcl_order_discount IMPLEMENTATION.

  METHOD calculate_discount.
    IF iv_amount < c_threshold_amount.
      rv_discount = 0.
      RETURN.
    ENDIF.

    rv_discount = iv_amount * c_discount_rate.
  ENDMETHOD.

ENDCLASS.
