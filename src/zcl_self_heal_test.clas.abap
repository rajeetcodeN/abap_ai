not found|.
        ENDIF.

        DATA(item) = items[ posnr = item_number ].
        result = calculate_discount( amount = item-netwr currency = item-waerk ).
        ```
    This adds excellent modern syntax usage (`line_exists`, table expression, string templates, constructor expressions).

    Let's assemble the response cleanly.