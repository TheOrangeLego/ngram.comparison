import file as F
import global as GL
import lists as L
import string-dict as SD
import js-file( "pyret-lib/string-lib" ) as S
import js-file( "pyret-lib/glob-lib" ) as G

MIN_GRAMS = 1
MAX_GRAMS = 3
GRAMS = L.range( MIN_GRAMS, MAX_GRAMS + 1 )

TEXT_FILE_LIST = raw-array-to-list( G.glob( "data/*.txt" ) )

fun get-words( file ):
  S.split-pattern( S.string-to-lower( F.input-file( file ).read-file() ), "\\W+" )
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

fun add-to-tree( pre-words, tree ) block:
  GRAMS.foldl( lam( updated-tree, current-gram ):
    offset-gram = current-gram - 1
    words = pre-words.filter( lam( str ): is-punctuation( str ) == false end )

    ( L.range( 0, words.length() - offset-gram ) ).foldl( lam( word-index, newer-tree ):
      pre-key = ( L.range( 0, current-gram - 1 ) ).foldl( lam( key-index, acc-key ):
        S.concat( acc-key, S.concat( words.get( key-index + word-index ), " " ) )
      end, "" )
      key = S.concat( pre-key, words.get( word-index + offset-gram ) )

      if newer-tree.has-key-now( key ):
        newer-tree.set-now( key, newer-tree.get-now( key ) + 1 )
      else:
        newer-tree.set-now( key, 1 )
      end
    end, updated-tree )
  end, tree )
end

fun create-database() block:
  TEXT_FILE_LIST.foldl( lam( file, database ) block:
    filename-length = S.length( file )
    year = S.substring( file, filename-length - 8, filename-length - 4 )
    current-tree = if database.has-key-now( year ):
      database.get-now( year )
    else:
      SD.make-mutable-string-dict()
    end

    file-words = L.to-list( get-words( file ) )
    database.set-now( year, add-to-tree( file-words, current-tree ) )
  end, SD.make-mutable-string-dict() )
end

print( "1 run\n" )
start-time-1 = time-now()
GRAM_DATABASE = create-database()
print( time-now() - start-time-1 )