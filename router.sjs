@ = require(['mho:std','mho:app']);

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
      console.log('route');
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
        if (route === newRoute){
          console.log('dont route \'cause the dest are the same');
        }
      } while (route === newRoute);
      route = newRoute;
    }
  }
}

exports.Router = Router;
