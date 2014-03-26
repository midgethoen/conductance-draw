@ = require(['mho:std', 'mho:app', './canvas', './bootstrap', './colorpicker']);

var drawingId;
if (window.location.hash.length > 1){
  drawingId = window.location.hash.substr(1); 
}

function invite(){alert('invite')};
function startChain(){alert('chain')};

@withAPI('./draw.api'){
  |api|
  

  var drawing;
  try {
    [drawingId, drawing]  = api.getDrawing(drawingId);
  } catch (e){
    console.log(e) //drawing does not exist or something like that
    [drawingId, drawing] = api.getDrawing();
  }
  window.location.hash = '#'+drawingId;

  //create the app components
  var 
    canvas = @DrawingCanvas(drawing),
    nav = @BSNav('Conductance draw', [
              @A('Invite someone' 
                .. @Mechanism(){|a|
                  a .. @when('click', invite)
                }),
              @A('Start chain drawing' 
                .. @Mechanism(){|a|
                  a .. @when('click', startChain)
                }),
            ]),
     colorPicker = @Colorpicker(['red', 'green', 'orange'], canvas.color),
     thicknessSelector = @ThicknessSelector(canvas.thickness, 150, canvas.color),
     mdDev = 9;
  @mainContent .. @replaceContent([`
    $nav
    <div class="row">
      <div class="col-sm-12 col-md-${mdDev}">$canvas</div>
      <div class="col-xs-12 col-sm-6 xcol-md-offset-${mdDev} col-md-${12-mdDev}">
        <h4>Choose color</h4>
        $colorPicker
      </div>
      <div class="col-xs-12 col-sm-6 xcol-md-offset-${mdDev} col-md-${12-mdDev}">
        <h4>Choose brush size</h4>
        $thicknessSelector
      </div>
    </div>
    
 `]);

//  @doModal({
//    title: 'Welcome to Conducatance draw!',
//    close_button: false,
//    body: [
//      @P("A new drawing has been created on which you can start drawing immediately. But, the most fun is offcours is drawing together"),
//      @Button('Oke, let\'s do this') .. @Id('gogogo'),
//    ]
//  }){
//    |dialog|
//    document.getElementById('gogogo') .. @wait('click');
//  }

 hold();;
}
