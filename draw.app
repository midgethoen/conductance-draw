@ = require([
  'mho:std',
  'mho:app',
  './canvas',
  './bootstrap',
  './colorpicker',
  './router',
]);

var EZButton = (content, func) -> (@Button(content) .. @Mechanism{|btn|btn .. @when('click', func)});

//var drawingId;
//if (window.location.hash.length > 1){
//  drawingId = window.location.hash.substr(1); 
//}

@mainContent .. @appendContent(
  @BSNav('Conductance draw', [
//      @A('Invite someone' 
//        .. @Mechanism(){|a|
//          a .. @when('click', invite)
//        }),
//      @A('Start chain drawing' 
//        .. @Mechanism(){|a|
//          a .. @when('click', startChain)
//        }),
    ])
);

@withAPI('./draw.api'){
  |api|

  function showGallery(){
    function create(){
    }
    function join(){alert('Yeah, this thould really be implemented...')};
    var 
      welcome = `
      <div class="row">
        <div class="col-sm-offset-1 col-sm-10">
          <h1>Welcome to draw</h1>
          ${@A('Create drawing',{href:'#create', 'class':'btn'})}
          ${@A('Join drawing',{href:'#join', 'class':'btn'})}
        </div>
      </div>`,
      gallery= '';
    @mainContent .. @appendContent([welcome, gallery]){
      ||
      hold();//do i need this?      
    }
  }
  
  function showDrawing(bla,drawingId){
console.log(drawingId);    
    var drawing;
    if (drawingId){
      try {
        [drawingId, drawing]  = api.getDrawing(drawingId);
      } catch (e){
        console.log(e); //drawing does not exist or something like that
        [drawingId, drawing] = api.getDrawing();
      }
    } else {
      
    }

    var 
      canvas = @DrawingCanvas(drawing),
      colorPicker = @Colorpicker(['red', 'green', 'orange'], canvas.color),
      thicknessSelector = @ThicknessSelector(canvas.thickness, 150, canvas.color),
      mdDev = 9;
    @mainContent .. @appendContent([`
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
      
   `]){
      |drawingUI|
      if (window.location.hash === '#create'){
        @doModal({
            title: 'Create drawing',
            body: [
            @P('A new drawing has been created, 
                share the following url to invite other people'),
            @Div(window.location.href) .. @Class('well'),
            @Button('Let\'s draw!') .. @Id('go'),
          ]}){
          |dialog|
          dialog.querySelector('#go') .. @wait('click');
        }
        window.location.hash = '#drawing/'+drawingId;
      }
      hold();
    }
  }

  @Router([
    /gallery/, showGallery, //acts as a default as wel, because the first is used whenever none match
    /create/, showDrawing, //wil be created when id is omitted
    /join/, showDrawing, 
    /drawing\/([\w-]+)/, showDrawing,
  ]);

 hold();;
}
