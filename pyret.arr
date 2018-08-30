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
  raw-array-to-list( S.split-pattern( S.string-to-lower( F.input-file( file ).read-file() ), "\\W+" ) )
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
  GRAMS.foldl( lam( current-gram, updated-tree ):
    offset-gram = current-gram - 1
    words = pre-words.filter( lam( str ): is-punctuation( str ) == false end )

    ( L.range( 0, words.length() - offset-gram ) ).foldl( lam( word-index, newer-tree ) block:
      pre-key = ( L.range( 0, current-gram - 1 ) ).foldl( lam( key-index, acc-key ):
        S.concat( acc-key, S.concat( words.get( key-index + word-index ), " " ) )
      end, "" )
      key = S.concat( pre-key, words.get( word-index + offset-gram ) )

      if newer-tree.has-key-now( key ):
        newer-tree.set-now( key, newer-tree.get-now( key ).or-else( 0 ) + 1 )
      else:
        newer-tree.set-now( key, 1 )
      end

      newer-tree
    end, updated-tree )
  end, tree )
end

fun create-database():
  TEXT_FILE_LIST.foldl( lam( file, database ) block:
    filename-length = S.length( file )
    year = S.substring( file, filename-length - 8, filename-length - 4 )
    current-tree = if database.has-key-now( year ):
      database.get-now( year )
    else:
      SD.make-mutable-string-dict()
    end

    file-words = get-words( file )
    database.set-now( year, add-to-tree( file-words, current-tree ) )

    database
  end, SD.make-mutable-string-dict() )
end

print( "1 run\n" )
start-time-1 = time-now()
GRAM_DATABASE = create-database()
print( time-now() - start-time-1 )

print( "\n5 runs\n" )
start-time-5 = time-now()
L.range( 0, 5 ).each( lam( _ ): create-database end )
print( time-now() - start-time-5 )
print( "\n" )

fun get-grams( words ):
  words.foldl( lam( word, grams ) block:
    grams.set-now( word, GRAM_DATABASE.keys-now().to-list().foldl( lam( year, word-gram ) block:
      if GRAM_DATABASE.get-now( year ).or-else( SD.make-mutable-string-dict() ).has-key-now( word ):
        word-gram.set-now( year, GRAM_DATABASE.get-now( year ).or-else( SD.make-mutable-string-dict() ).get-now( word ).or-else( 0 ) )
      else:
        word-gram.set-now( year, 0 )
      end

      word-gram
    end, SD.make-mutable-string-dict() ) )

    grams
  end, SD.make-mutable-string-dict() )
end

# assertion checks
assertion-gram = get-grams( [list: "the", "a", "of", "of the"] )

when ( assertion-gram.get-now( "the" ).or-else( SD.make-mutable-string-dict() ).get-now( "2000" ).or-else( 0 ) <> 4 ): print( "Incorrect count of _the_\n" ) end
when ( assertion-gram.get-now( "of" ).or-else( SD.make-mutable-string-dict() ).get-now( "2000" ).or-else( 0 ) <> 4 ): print( "Incorrect count of _of_\n" ) end
when ( assertion-gram.get-now( "of the" ).or-else( SD.make-mutable-string-dict() ).get-now( "2000" ).or-else( 0 ) <> 3 ): print( "Incorrect count of _of the_\n" ) end