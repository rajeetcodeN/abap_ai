CLASS zcl_demo_sales DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_header,
        sales_order TYPE vbak-vbeln,
        doc_type    TYPE vbak-auart,
        created_by  TYPE vbak-ernam,
        created_on  TYPE vbak-erdat,
        net_amount  TYPE vbak-netwr,
        currency    TYPE vbak-waerk,
      END OF ty_order_header,
      tt_order_headers TYPE STANDARD TABLE OF ty_order_header WITH EMPTY KEY.

    METHODS:
      "! Constructor
      constructor,

      "! Retrieve sales orders by customer number
      "! @parameter iv_customer | Customer Number (KUNNR)
      "! @parameter rt_orders   | Resulting list of orders
      get_orders_by_customer
        IMPORTING
          iv_customer      TYPE vbak-kunnr
        RETURNING
          VALUE(rt_orders) TYPE tt_order_headers
        RAISING
          cx_t100_msg,

      "! Calculate total revenue across multiple orders
      "! @parameter it_orders    | List of sales order records
      "! @parameter rv_total_amt | Sum total amount
      calculate_total_revenue
        IMPORTING
          it_orders           TYPE tt_order_headers
        RETURNING
          VALUE(rv_total_amt) TYPE vbak-netwr.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_demo_sales IMPLEMENTATION.

  METHOD constructor.
    " Initialize service / configurations if required
  ENDMETHOD.

  METHOD get_orders_by_customer.
    IF iv_customer IS INITIAL.
      RETURN.
    ENDIF.

    " Modern ABAP SQL (Inline declarations and field projections)
    SELECT vbeln AS sales_order,
           auart AS doc_type,
           ernam AS created_by,
           erdat AS created_on,
           netwr AS net_amount,
           waerk AS currency
      FROM vbak
      WHERE kunnr = @iv_customer
      ORDER BY vbeln DESCENDING
      INTO CORRESPONDING FIELDS OF TABLE @rt_orders.
  ENDMETHOD.

  METHOD calculate_total_revenue.
    " Modern ABAP REDUCE expression for aggregation
    rv_total_amt = REDUCE #(
      INIT lv_sum = CONV vbak-netwr( 0 )
      FOR ls_order IN it_orders
      NEXT lv_sum = lv_sum + ls_order-net_amount ).
  ENDMETHOD.

ENDCLASS.

