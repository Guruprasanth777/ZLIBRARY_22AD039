CLASS lcl_handler DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Book RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Book.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Book.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Book.

    METHODS read FOR READ
      IMPORTING keys FOR READ Book RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Book.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA: lt_books TYPE TABLE OF ZLIBBOOK_22AD039.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT entities INTO DATA(ls_entity).
      APPEND VALUE #(
        book_id   = ls_entity-book_id
        book_name = ls_entity-book_name
        author    = ls_entity-author
        category  = ls_entity-category
        available = ls_entity-available
      ) TO lt_books.

      APPEND VALUE #( %cid    = ls_entity-%cid
                      book_id = ls_entity-book_id ) TO mapped-book.
    ENDLOOP.

    IF lt_books IS NOT INITIAL.
      MODIFY ZLIBBOOK_22AD039 FROM TABLE @lt_books.
    ENDIF.
  ENDMETHOD.

  METHOD update.
    DATA: ls_db_book TYPE ZLIBBOOK_22AD039.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT entities INTO DATA(ls_entity).
      " 1. Grab the existing row from the DB to protect untouched data
      SELECT SINGLE * FROM ZLIBBOOK_22AD039
        WHERE book_id = @ls_entity-book_id
        INTO @ls_db_book.

      IF sy-subrc = 0.
        " 2. SMART MERGE: Only overwrite if the UI sent actual text!
        " This stops the framework from wiping your data with blanks.
        IF ls_entity-book_name IS NOT INITIAL.
          ls_db_book-book_name = ls_entity-book_name.
        ENDIF.

        IF ls_entity-author IS NOT INITIAL.
          ls_db_book-author = ls_entity-author.
        ENDIF.

        IF ls_entity-category IS NOT INITIAL.
          ls_db_book-category = ls_entity-category.
        ENDIF.

        IF ls_entity-available IS NOT INITIAL.
          ls_db_book-available = ls_entity-available.
        ENDIF.

        " 3. Save the safely merged data back to the DB
        MODIFY ZLIBBOOK_22AD039 FROM @ls_db_book.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.
    LOOP AT keys INTO DATA(ls_key).
      DELETE FROM ZLIBBOOK_22AD039 WHERE book_id = @ls_key-book_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    " Fetch fresh data so the Home Page updates instantly
    SELECT * FROM ZLIBBOOK_22AD039
      FOR ALL ENTRIES IN @keys
      WHERE book_id = @keys-book_id
      INTO TABLE @DATA(lt_db_books).

    " CORRESPONDING ensures perfect mapping back to the UI
    result = CORRESPONDING #( lt_db_books ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.
