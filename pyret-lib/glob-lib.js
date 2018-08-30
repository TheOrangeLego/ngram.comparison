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
    const globModule = require( 'glob' );
    
    var glob = function( pattern ){ return globModule.sync( pattern ); }

    return runtime.makeModuleReturn({
      'glob': F(glob),
    }, {}, {});
  }
})
