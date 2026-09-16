# Clean ABAP 7.50+ Coding Patterns Reference

This reference documents mandatory syntax patterns and idioms to be applied during Stage 2 (Code Generation) of the autonomous ABAP development lifecycle.

---

## 1. Declarations and Type Safety

### Inline Declarations
Use inline declarations at the point of assignment instead of top-level `DATA:` blocks.
```abap
" Preferred (7.40+)
DATA(lv_total) = iv_quantity * iv_unit_price.
DATA(lo_calculator) = NEW zcl_tax_calculator( ).

" Obsolete (Avoid)
DATA lv_total TYPE p DECIMALS 2.
DATA lo_calculator TYPE REF TO zcl_tax_calculator.
lv_total = iv_quantity * iv_unit_price.
CREATE OBJECT lo_calculator.
```

### Table Expressions Instead of READ TABLE
```abap
" Preferred
TRY.
    DATA(ls_item) = lt_items[ item_id = iv_item_id ].
  CATCH cx_sy_itab_line_not_found.
    " Handle missing entry
ENDTRY.

" Obsolete (Avoid)
READ TABLE lt_items INTO DATA(ls_item) WITH KEY item_id = iv_item_id.
IF sy-subrc <> 0.
  " Handle missing entry
ENDIF.
```

---

## 2. Constructor Expressions

### Value Construction: VALUE #()
```abap
" Structure construction
DATA(ls_header) = VALUE ty_order_header(
  order_id   = '10001'
  created_on = sy-datum
  currency   = 'USD'
).

" Internal table population
DATA(lt_tiers) = VALUE ty_tier_table(
  ( tier = 'BRONZE' discount = '0.05' )
  ( tier = 'SILVER' discount = '0.10' )
  ( tier = 'GOLD'   discount = '0.15' )
).
```

### Conditional Logic: COND #() and SWITCH #()
```abap
" Conditional value assignment
DATA(lv_discount_rate) = COND decfloat16(
  WHEN iv_tier = 'GOLD'   THEN '0.15'
  WHEN iv_tier = 'SILVER' THEN '0.10'
  ELSE                         '0.00'
).

" Case switch
DATA(lv_status_text) = SWITCH string( iv_status
  WHEN 'O' THEN 'Open'
  WHEN 'P' THEN 'Processing'
  WHEN 'C' THEN 'Completed'
  ELSE          'Unknown'
).
```

### Mapping and Projection: CORRESPONDING #()
```abap
" Exact mapping
DATA(ls_target) = CORRESPONDING ty_target( ls_source ).

" Mapping with overrides
DATA(ls_order) = CORRESPONDING ty_order(
  ls_input
  MAPPING target_currency = source_curr
  EXCEPT  internal_notes
).
```

---

## 3. String Manipulation: String Templates
Never use `CONCATENATE`. Use string templates with embedded expressions.
```abap
" Preferred
DATA(lv_message) = |Order { iv_order_id } processed on { sy-datum DATE = USER }.|

" Obsolete (Avoid)
CONCATENATE 'Order' iv_order_id 'processed on' sy-datum INTO lv_message SEPARATED BY space.
```

---

## 4. Error Handling and Exceptions
* Fail fast using exception classes inheriting from `cx_static_check` or `cx_no_check`.
* Avoid returning integer `sy-subrc` codes from business methods.
* Always clean up state before propagating exceptions.
```abap
METHOD validate_order.
  IF iv_total_amount <= 0.
    RAISE EXCEPTION TYPE zcx_invalid_order_amount
      EXPORTING
        textid   = zcx_invalid_order_amount=>amount_zero_or_negative
        mv_amount = iv_total_amount.
  ENDIF.
ENDMETHOD.
```
