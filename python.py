import re
import glob

# set minimum and maximum grams to be accounted for
MIN_GRAMS = 1
MAX_GRAMS = 3
GRAMS = range( MIN_GRAMS, MAX_GRAMS + 1 )

# get a list of all data text files
TEXT_FILE_LIST = [file for file in glob.glob( "data/*.txt" )]

# extract the words from the file
def getWords( file ):
  return re.findall( r'\w+', open( file ).read().lower() )

# check if the string is of some punctuation
def isPunctuation( str ):
  return str == "." or str == "," or str == "@"

# update tree with all of the possible grams from the given text
def addToTree( words, tree ):
  for currentGram in GRAMS:
    for wordIndex in range( len( words ) - currentGram + 1 ):
      key = ""

      for keyIndex in range( currentGram - 1 ):
        key += words[wordIndex + keyIndex] + " "
      
      key += words[wordIndex + currentGram - 1]

      tree[key] = tree.get( key, 0 ) + 1
  
  return tree  

# create the database that contains all grams from all data text files
def createDatabase():
  database = dict()

  for file in TEXT_FILE_LIST:
    year = file[-8:-4]

    if year not in database:
      database[year] = dict()
    
    currentTree = database[year]
    fileWords = [word for word in getWords( file )]
    database[year] = addToTree( fileWords, currentTree )
  
  return database

# database containing all the grams for each year
GRAM_DATABASE = createDatabase()

# get the count of instances of each word from the provided list
def getGrams( words ):
  grams = dict()

  for word in words:
    grams[word] =[GRAM_DATABASE[year][word] if word in GRAM_DATABASE[year] else 0 for year in GRAM_DATABASE]
  
  return grams

# get a list containing all the counts of both words per year
testGrams = getGrams( ["hello", "world"] )

# make sure that all 23 years are accounted for
assert( len( testGrams["hello"] ) == 23 )
assert( len( testGrams["world"] ) == len( testGrams["hello"] ) )