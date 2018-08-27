const glob = require( 'glob' );

"use strict"

module.exports = {
  'glob': function( path ) { return glob.sync( path ); }
};