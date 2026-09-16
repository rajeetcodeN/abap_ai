CLASS zcl_order_discount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_amount TYPE p LENGTH 15 DECIMALS 2.

    CONSTANTS:
      c_discount_threshold TYPE ty_amount VALUE '1000.00',
      c_discount_rate      TYPE ty_amount VALUE '0.10'.

    " Calculates the discount amount based on order value.
    " Applies 10% discount if amount > 1000.00, otherwise 0.
    METHODS calculate_discount_amount
      IMPORTING
        amount                 TYPE ty_amount
      RETURNING
        VALUE(discount_amount) TYPE ty_amount
      RAISING
        cx_sy_conversion_overflow.

    " Calculates net amount after applying eligible discount.
    METHODS calculate_final_amount
      IMPORTING
        amount              TYPE ty_amount
      RETURNING
        VALUE(final_amount) TYPE ty_amount
      RAISING
        cx_sy_conversion_overflow.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_order_discount IMPLEMENTATION.

  METHOD calculate_discount_amount.
    IF amount < 0.
      RAISE EXCEPTION TYPE cx_sy_conversion_overflow.
    ENDIF.

    DATA(applicable_rate) = COND ty_amount(
      WHEN amount > c_discount_threshold THEN c_discount_rate
      ELSE '0.00'
    ).

    discount_amount = amount * applicable_rate.
  ENDMETHOD.

  METHOD calculate_final_amount.
    DATA(discount) = calculate_discount_amount( amount ).
    final_amount = amount - discount.
  ENDMETHOD.

ENDCLASS.