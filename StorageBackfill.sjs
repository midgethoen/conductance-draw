@ = require('mho:std');

exports.Storage = function(location, options, blockNotSupported){
  if (blockNotSupported) throw 'implement support lexical lifetime scope';
  if (options) throw 'implement options';
  
  var storage = @Storage(location);
  //storage.oldGet = storage.get;
  return storage .. @merge({
    /*
     special get, executes a block with the result if the key is found
     */
    get: function(key, found){
      try {
        found(storage.get(key));
      } catch(e){
        console.log("error gettting stuff", e)
      }
    }
  })
}
