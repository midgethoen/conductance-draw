if (__oni_rt.hostenv == 'nodejs'){
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
        }
      }
    })
  }
} else if (__oni_rt.hostenv == 'xbrowser'){
  @ = require(['mho:std', 'mho:app']);
  /**
   * Router 
   */
  function Router(routes){
    function determineRoute(){
      var hash = window.location.toString().split('#')[1];
      var theRoute = routes[1]; //use the first by default
      var args = [hash];
      routes .. @pack(p -> [p(), p()]) .. @each{
        |route|
        var [regex, func] = route;
        var matches = regex.exec(hash);
        if (matches !== null){
          theRoute = func;
          args = args.concat(matches.splice(1));
          break;
        }
      }
      return [theRoute, args];
    }
    var [route, args] = determineRoute();
    while (1){
      waitfor {
        var result = route.apply(undefined, args);
        if (result !== undefined){
          return result; //allow routes to stop the router 
        }
        hold(); //hold in case the route is non-blocking
      } or {
        var newRoute;
        do {
          window .. @events('hashchange') .. @wait();
          [newRoute, args] = determineRoute(); 
        } while (route === newRoute);
        route = newRoute;
      }
    }
  }
  exports.Router = Router;

  function Shadow(element /*, selector, x, y, rad, color*/){
    args = Array.prototype.slice.call(arguments,1);;
    var selector = isNaN(parseInt(args[0])) ? "" : args.splice(0,1);
    var [x,y,rad,color] = args;
    if (x === undefined) x = 3;
    if (y === undefined) y = 3;
    if (rad === undefined) rad = 6;
    if (color === undefined) color = 'rgba(1,1,1,.6)';

    return element .. @Style("#{selector} {
      -moz-box-shadow: #{x}px #{y}px #{rad}px #{color};
   -webkit-box-shadow: #{x}px #{y}px #{rad}px #{color};
           box-shadow: #{x}px #{y}px #{rad}px #{color};

    }");
  };
  exports.Shadow = Shadow;
}

var { each, map, makeIterator, Stream } = require('sjs:sequence');
var { exclusive } = require('sjs:function');
function MemoizedStream(s) {
  var memoized_results = [], done = false;
  var iterator = makeIterator(s);
  var next = exclusive(function() {
    if (!iterator.hasMore())
      done = true;
    else
      memoized_results.push(iterator.next());
  }, true);

  var rv = Stream(function(receiver) {
    var i=0;
    while (true) {
      while (i< memoized_results.length)
        receiver(memoized_results[i++] .. @clone);
      if (done) return;
      next();
    }
  });

  // XXX can we use this?
//  rv.destroy = iterator.destroy();

  return rv;
}
exports.MemoizedStream = MemoizedStream

/*
 Ensure there is at least a duration of 'time' ms between every element of stream
*/
function throttle(seq, duration) {
 return @Stream(function(receiver) {
   
   var start;

   seq .. @each {
     |x|
     if (start) {
       var elapsed = (new Date()) - start;
       if (elapsed < duration)
         hold(duration - elapsed);
     }
     receiver(x);
     start = new Date();
   }
   
 });
}
exports.throttle = throttle;
