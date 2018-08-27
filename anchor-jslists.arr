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
  if ( str == "." ) or ( str == "," ) or ( str == "@" ):
    true
  else:
    false
  end
end

fun add-to-tree( words, tree ):
  L.for-each( GRAMS, lam( current-gram ):
    offset-gram = current-gram - 1
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

start-time = GL.time-now()
GRAM_DATABASE = create-database()
GL.console-log( GL.time-now( start-time ) )

fun get-grams( words ) block:
  grams = SD.make-string-dict()

  L.for-each( words, lam( word ):
    SD.insert( grams, word, L.map( SD.keys( GRAM_DATABASE ), lam( year ):
      gram-year-tree = SD.get( GRAM_DATABASE, year )

      if SD.has-key( gram-year-tree, word ):
        {Y: year, C: SD.get( gram-year-tree, word )}
      else:
        {Y: year, C: 0}
      end
    end ) )
  end )

  grams
end

test-grams = get-grams( [L.list: "hello", "world"] )
comparison-gram = get-grams( [L.list: "the", "a", "of"] )

GL.assert( L.length( SD.get( test-grams, "hello" ) ), 23, "Incorrect number of years" )
GL.assert( L.length( SD.get( test-grams, "hello" ) ), L.length( SD.get( test-grams, "world" ) ), "Non-matching between word-keys" )

# GL.console-log( test-grams )
# GL.console-log( comparison-gram )
