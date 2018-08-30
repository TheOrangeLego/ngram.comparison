({
  requires: [],
  nativeRequires: [],
  provides: {
    shorthands: {
    },
    values: {
    },
    aliases: {
    },
    datatypes: {
    }
  },
  theModule: function(runtime, namespace, uri){
    const F = runtime.makeFunction;
    
    var length = function( str ) { return str.length; }
    var stringToLower = function( str ) { return str.toLowerCase(); }
    var concat = function( strA, strB ) { return strA.concat( strB ); }
    var substring = function( str, start, end ) { return str.substring( start, end ); }
    var charAt = function( str, index ) { return str.charAt( index ); }
    var split = function( str, separator ) { return str.split( separator ); }
    var splitPattern = function( str, pattern ) { return str.split( RegExp( pattern ) ); }

    return runtime.makeModuleReturn({
      'length': F(length),
      'string-to-lower': F(stringToLower),
      'concat': F(concat),
      'substring': F(substring),
      'char-at': F(charAt),
      'split': F(split),
      'split-pattern': F(splitPattern)
    }, {}, {});
  }
})
