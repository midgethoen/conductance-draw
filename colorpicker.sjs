@ = require(['mho:std', 'mho:app']);

function calcDistanceFromCenter(elem, absPos){
  return Math.sqrt(  
    Math.pow(elem.offsetLeft + elem.offsetWidth/2 - absPos[0], 2) + //x
    Math.pow(elem.offsetTop + elem.offsetHeight/2 - absPos[1], 2)   //y
  );
}

function Colorpicker(colors, color){
  return @Div(
    colors .. @map( clr->[
      @Input('radio', 'clr', {id:clr, name:'color'}), 
      @Label(
        @Div('', {style: "background-color: #{clr};"}), 
        {'for':clr} 
      ),

    ] ) 
  ) .. @Style('
    input[type=radio] {
      display: none;
    }
    div {
      display: inline-block;
      width: 40px;
      height: 40px;
      border-radius: 20px;
      border: solid thick white;
    }
    input[type=radio]:checked + label div {
      border-color: black;
    }
') .. @Mechanism(){
    |picker|
    picker.querySelectorAll('input') .. @when(['change']){
      |event|
      color.set(event.srcElement.nextSibling.children[0].style.backgroundColor);
    }
  }
}
exports.Colorpicker = Colorpicker;

function ThicknessSelector(thickness, max, backgroundColor){
  max = (max)?max:100;
  backgroundColor = (backgroundColor)?backgroundColor : 'black';
  return @Div()
    .. @Style(`{
      display: inline-block;
      background-color: ${backgroundColor};
      width: ${max}px;
      height: ${max}px;
      cursor:ew-resize;
      border-radius: ${max/2}px;
      border: solid white ${thickness .. @transform(t->max/2-t)}px;
      }`
    ) .. @Mechanism(){
      |div|
      div .. @when('mousedown'){||
        waitfor {
          div.. @when('mousemove'){
            |event|
            thickness.set(2 * Math.sqrt(  
              Math.pow(event.offsetX-event.target.getBoundingClientRect().height/2, 2) +
              Math.pow(event.offsetY-event.target.getBoundingClientRect().width/2, 2) 
            ));
          }
        } or {
          div .. @wait(['mouseup', 'mouseleave']);
        }
      }
    };
}
exports.ThicknessSelector = ThicknessSelector; 
