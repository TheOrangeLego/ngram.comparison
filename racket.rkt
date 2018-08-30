#lang racket

( require racket/file )
( require file/glob )
( require racket/dict )

( define MIN_GRAMS 1 )
( define MAX_GRAMS 4 )
( define GRAMS ( range MIN_GRAMS ( + 1 MAX_GRAMS ) ) )

( define TEXT_FILE_LIST ( for/list ([dir ( glob "data/*.txt" )]) ( path->string dir ) ) )

( define ( get-words current-file )
  ( regexp-split #px"\\W+" ( string-downcase ( file->string current-file ) ) ) )

( define ( is-punctuation str )
  ( cond
    [( string=? str "." ) #t]
    [( string=? str "," ) #t]
    [( string=? str "@" ) #t]
    [else #f] ) )

( define ( add-to-tree words tree )
  ( define words-vector ( vector-filter-not is-punctuation ( list->vector words ) ) )

  ( for-each ( lambda ( current-gram )
    ( for ([word-index ( in-range ( - ( length words ) ( - current-gram  1 ) ) )])
      ( define pre-key ( foldl ( lambda ( key-index acc-key ) ( string-append acc-key ( vector-ref words-vector ( + word-index key-index ) ) " " ) ) "" ( range ( - current-gram 1 ) ) ) )
      ( define key ( string-append pre-key ( vector-ref words-vector ( + word-index ( - current-gram 1 ) ) ) ) )
      
      ; using this dict-update! is causing nearly 4 times the runtime required to run and generate a tree
      ;( dict-update! tree key update-count 0 ) ) )
      ( cond
        [( hash-has-key? tree key ) ( dict-set! tree key ( + ( dict-ref tree key ) 1 ) )]
        [else ( dict-set! tree key 1 )] ) ) )
  GRAMS )
    
  tree )

( define ( create-database )
  ( define database ( make-hash ) )

  ( for-each ( lambda ( file ) 
    ( define filename-length ( string-length file ) )
    ( define year ( substring file ( - filename-length 8 ) ( - filename-length 4 ) ) )

    ( cond [( not ( hash-has-key? database year ) ) ( dict-set! database year ( make-hash ) )])

    ( define current-tree ( dict-ref database year ) )
    ( define file-words ( get-words file ) )
    ( dict-set! database year ( add-to-tree file-words current-tree ) ) )
    TEXT_FILE_LIST )
  
  database )

( display "1 run\n" )
( define start-time-1 ( current-inexact-milliseconds ) )
( define GRAM_DATABASE ( create-database ) )
( display ( - ( current-inexact-milliseconds ) start-time-1 ) )

( display "\n5 runs\n" )
( define start-time ( current-inexact-milliseconds ) )
( for-each ( lambda ( x ) ( create-database ) ) ( range 5 ) )
( display ( - ( current-inexact-milliseconds ) start-time ) )
( display "\n" )

( define ( get-grams words )
  ( define grams ( make-hash ) )
  
  ( for-each ( lambda ( word )
    ( define word-gram ( make-hash ) )

    ( for-each ( lambda ( year )
      ( cond
        [( hash-has-key? ( dict-ref GRAM_DATABASE year ) word ) ( dict-set! word-gram year ( dict-ref ( dict-ref GRAM_DATABASE year ) word ) )]
        [else ( dict-set! word-gram year 0 )] ) )
      ( dict-keys GRAM_DATABASE ) )

    ( dict-set! grams word word-gram ) )
    words )
  
  grams )

; assertion checks
( define assertion-gram ( get-grams ( list "the" "a" "of the" ) ) )

( cond
  [( not ( equal? ( dict-count ( dict-ref assertion-gram "the" ) ) 23 ) ) ( display "Incorrect number of years\n" )]
  [( not ( equal? ( dict-ref ( dict-ref assertion-gram "the" ) "1993" ) 3146 ) ) ( display "Incorrect count of _the_\n" )]
  [( not ( equal? ( dict-ref ( dict-ref assertion-gram "of the" ) "2002" ) 442 ) ) ( display "Incorrect count of _of the_\n" )] )