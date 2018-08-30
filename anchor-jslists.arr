import js-file( "anchor-lib/list" ) as L
import js-file( "anchor-lib/string-dict" ) as SD
import js-file( "anchor-lib/glob" ) as G
import string as S
import file as F
import global as GL

MIN_GRAMS = 1
MAX_GRAMS = 3
GRAMS = L.range( MIN_GRAMS, MAX_GRAMS + 1 )

TEXT_FILE_LIST = G.glob( "data/*.txt" )

fun get-words( file ):
  S.split-pattern( S.string-to-lower( F.file-to-string( file ) ), "\\W+" )
end

fun is-punctuation( str ):
  check-1 = str == "."
  check-2 = str == ","
  check-3 = str == "@"

  if check-1 or check-2 or check-3:
    true
  else:
    false
  end
end

fun add-to-tree( pre-words, tree ):
  L.for-each( GRAMS, lam( current-gram ):
    offset-gram = current-gram - 1
    words = L.filter( pre-words, lam( str ): is-punctuation( str ) == false end )

    L.for-each( L.range( 0, L.length( words ) - offset-gram ), lam( word-index ) block:
      pre-key = L.reduce( L.range( 0, current-gram - 1 ), lam( acc-key, key-index ):
        S.concat( acc-key, S.concat( L.at( words, key-index + word-index ), " " ) )
      end, "" )
      key = S.concat( pre-key, L.at( words, word-index + offset-gram ) )

      if SD.has-key( tree, key ):
        SD.insert( tree, key, SD.get( tree, key ) + 1 )
      else:
        SD.insert( tree, key, 1 )
      end
    end )
  end )
end

fun create-database() block:
  database = SD.make-string-dict()

  L.for-each( TEXT_FILE_LIST, lam( file ) block:
    filename-length = S.length( file )
    year = S.substring( file, filename-length - 8, filename-length - 4 )

    if SD.has-key( database, year ):
      nothing
    else:
      SD.insert( database, year, SD.make-string-dict() )
    end

    current-tree = SD.get( database, year )
    file-words = get-words( file )
    add-to-tree( file-words, current-tree )
    SD.insert( database, year, current-tree )
  end )

  database
end

#|
GL.console-log( "1 run" )
start-time-1 = GL.time-now()
GRAM_DATABASE = create-database()
GL.console-log( GL.time-now( start-time-1 ) )
|#

GL.console-log( "5 runs" )
start-time-5 = GL.time-now()
L.for-each( L.range( 0, 5 ), lam( x ):
  create-database()
end )
GL.console-log( GL.time-now( start-time-5 ) )

#|
fun get-grams( words ) block:
  L.reduce( words, lam( grams, word ):
    SD.insert( grams, word, L.reduce( SD.keys( GRAM_DATABASE ), lam( word-gram, year ):
      if SD.has-key( SD.get( GRAM_DATABASE, year ), word ):
        SD.insert( word-gram, year, SD.get( SD.get( GRAM_DATABASE, year ), word ) )
      else:
        SD.insert( word-gram, year, 0 )
      end
    end, SD.make-string-dict() ) )
  end, SD.make-string-dict() )
end

# assertion checks
assertion-gram = get-grams( [L.list: "the", "a", "of", "of the"] )

GL.assert( SD.size( SD.get( assertion-gram, "the" ) ), 23, "Incorrect number of years" )
GL.assert( SD.get( SD.get( assertion-gram, "the" ), "1993" ), 3146, "Incorrect count of _the_" )
GL.assert( SD.get( SD.get( assertion-gram, "of the" ), "2002" ), 442, "Incorrect count of _of the_" )
|#