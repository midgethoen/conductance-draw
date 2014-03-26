@ = require(['mho:std', 'mho:app']);

/**
  Create a bootstrap navigation bar
 */
function BSNav(title, buttons,  options){
  return @Nav([
    @Div([
      @A(title) .. @Class('navbar-brand'),
    ]) ..@Class('navbar-header'),
    @Ul([
        buttons .. @map(btn -> @Li(btn)),
    ]) .. @Class('nav navbar-nav navbar-right'),
  ]) ..@Class('navbar navbar-default') .. @Attrib('role', 'navigation');  

}
exports.BSNav = BSNav
