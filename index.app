@ = require([
  'mho:std',
  'mho:app',
  './canvas',
  './bootstrap',
  './colorpicker',
  './router',
]);

@mainContent .. @appendContent(
  @BSNav('Conductance draw', [
    ])
);

@withAPI('./draw.api'){
  |api|

  function showGallery(){
    var 
      welcome = `
      <div class="row">
        <div class="col-sm-offset-1 col-sm-10">
          <h1>Welcome to draw</h1>
          ${@A('Create drawing',{href:'#create', 'class':'btn'})}
          ${@A('Join drawing',{href:'#join', 'class':'btn'})}
        </div>
      </div>`,
      drawings = @ObservableVar(''),
      gallery = `
      <div class="row">
        ${drawings}
      </div>`;
    @mainContent .. @appendContent([welcome, gallery]){
      ||
      api.getGallery() .. @each(){
        |[id, drawing]|
        var c = @DrawingCanvas(drawing);
        console.log(drawing);
        drawings.modify(function(ds){
          return [
            @Div(c,{'class':'col-sm-2'})
          ].concat(ds)
        });
      }
      hold();
    }

  }
  
  function showDrawing(route, drawingId){
    var drawing;
    try {
      [drawingId, drawing]  = api.getDrawing(drawingId);
    } catch (e){
      console.log(e); //drawing does not exist or something like that
      [drawingId, drawing] = api.getDrawing();
    }
    
    window.location.hash = '#drawing/'+drawingId;
    
    console.log(drawing);
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
      if (route === 'create'){
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
