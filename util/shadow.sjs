@ = require(['mho:std', 'mho:app']);

exports.Shadow = function(element, x, y, rad, color){
  if (x === undefined) x = 3;
  if (y === undefined) y = 3;
  if (rad === undefined) rad = 6;
  if (color === undefined) color = 'rgba(1,1,1,.6)';

  return element .. @Style("{
    -moz-box-shadow: #{x}px #{y}px #{rad}px #{color};
 -webkit-box-shadow: #{x}px #{y}px #{rad}px #{color};
         box-shadow: #{x}px #{y}px #{rad}px #{color};

  }");
};
