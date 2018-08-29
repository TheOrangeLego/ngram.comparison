import re
import time
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
def addToTree( preWords, tree ):
  words = filter( lambda word: not isPunctuation( word ), preWords )
  
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
    fileWords = getWords( file )
    database[year] = addToTree( fileWords, currentTree )
  
  return database

# database containing all the grams for each year
# measure the time it takes to generate one and five databases
print "Single database"
startTime = time.time()
GRAM_DATABASE = createDatabase()
print time.time() - startTime

print "Five databases"
startTime = time.time()
for x in range( 5 ):
  createDatabase()
print time.time() - startTime

# get the count of instances of each word from the provided list
def getGrams( words ):
  grams = dict()

  for word in words:
    wordGram = dict()

    for year in GRAM_DATABASE:
      if word not in GRAM_DATABASE[year]:
        wordGram[year] = 0
      else:
        wordGram[year] = GRAM_DATABASE[year][word]

    grams[word] = wordGram
  
  return grams

# assertion checks
assertionGram = getGrams( ["the", "a", "of", "of the"] )

assert( len( assertionGram["the"] ) == 23 ), "Incorrect number of years"
assert( assertionGram["the"]["1993"] == 3146 ), "Incorrect count of \"the\""
assert( assertionGram["of the"]["2002"] == 442 ), "Incorrect count of \"of the\""