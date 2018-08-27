#lang racket

( require racket/file )
( require file/glob )
( require racket/dict )

( define MIN_GRAMS 1 )
( define MAX_GRAMS 3 )
( define GRAMS ( range MIN_GRAMS ( + 1 MAX_GRAMS ) ) )

( define TEXT_FILE_LIST ( for/list ([dir ( glob "data/*.txt" )]) ( path->string dir ) ) )

( define ( get-words current-file )
  ( regexp-split #px"\\b" ( string-downcase ( file->string current-file ) ) ) )

( define ( is-punctuation str )
  ( cond
    [( string=? str "." ) #t]
    [( string=? str "," ) #t]
    [( string=? str "@" ) #t]
    [else #f] ) )

( define ( add-to-tree words tree )
  ( for-each ( lambda ( current-gram )
    ( for-each ( lambda ( word-index )
      ( define pre-key ( foldl ( lambda ( key-index acc-key ) ( string-append acc-key ( list-ref words ( + word-index key-index ) ) " " ) ) "" ( range ( - current-gram 1 ) ) ) )
      ( define key ( string-append pre-key ( list-ref words ( + word-index ( - current-gram 1 ) ) ) ) )
      ( dict-update! tree key ( lambda ( count ) ( + count 1 ) ) 0 ) )
      ( range ( - ( length words ) ( - current-gram  1 ) ) ) ) )
    GRAMS ) )

( define ( create-database )
  ( define database ( make-hash ) )

  ( for-each ( lambda ( file ) 
    ( define filename-length ( string-length file ) )
    ( define year ( substring file ( - filename-length 8 ) ( - filename-length 4 ) ) )

    ( cond [( not ( hash-has-key? database year ) ) ( dict-set! database year ( make-hash ) )])

    ( define current-tree ( dict-ref database year ) )
    ( define file-words ( get-words file ) )
    ( add-to-tree file-words current-tree ) )
    ;( dict-set! database year current-tree ) )
    TEXT_FILE_LIST )
  
  database )

( define GRAM_DATABASE ( create-database ) )

( define ( get-grams words )
  ( define grams ( make-hash ) )

  ( for-each ( lambda ( word )
    ( dict-set! grams word ( for/list ([year ( dict-keys GRAM_DATABASE )])
      ( define gram-year-tree ( dict-ref GRAM_DATABASE year ) )
      ( cond
        [( hash-has-key? gram-year-tree word ) ( dict-ref gram-year-tree word )]
        [else 0] ) ) ) )
    words )
  
  grams )

( display ( get-grams ( list "hello" ) ) )