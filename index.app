@ = require([
  'mho:std',
  'mho:app',
  './canvas.sjs',
  './bootstrap.sjs',
  './colorpicker.sjs',
  {name:'bf', id:'./backfill.sjs'},
]);

@withAPI('./draw.api'){
  |api|

  createDrawing = function (){
    console.log("asdasdfasdf");
    var [drawingId,d] = api.getDrawing();
    console.log(api);
    window.location.hash = '#drawing/'+drawingId;
  }

  @mainContent .. @appendContent(
    @BSNav('℧ draw', [
      @A('Gallery',{href:'/'}),
      @A('New drawing')
       .. @Mechanism{|e| e.onclick = createDrawing}])
  ){||

    function showGallery(){
      var 
        drawings = @ObservableVar(''),
        gallery = @Div(null,{'class':'row'})
      @mainContent .. @appendContent([gallery]){
        |gallery|
        api.getGallery() .. @each.par(){
          |[id, drawing]|
          //drawings.modify(function(ds){
            //return [
          //  ].concat(ds)
          //});
          gallery .. @appendContent(
          @Div(
            @A(
                @GalleryCanvas(drawing),
                {href: "\#drawing/#{drawing.id}"}
              ), 
              {'class':'col-sm-2'}
            )
          )
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
      var colors = [
          //solarized colorpalette
          '#002b36', 
          '#073642', 
          '#586e75', 
          '#657b83', 
          '#839496', 
          '#93a1a1', 
          '#eee8d5', 
          '#fdf6e3', 
          '#b58900', 
          '#cb4b16', 
          '#dc322f', 
          '#d33682', 
          '#6c71c4', 
          '#268bd2', 
          '#2aa198', 
          '#859900', 
        ]; 
      var canvas = @DrawingCanvas(drawing);
      canvas.color.set(colors[0]);
      var colorPicker = @Colorpicker(colors, canvas.color);
      var thicknessSelector = @ThicknessSelector(canvas.thickness, 150, canvas.color);

      @mainContent .. @appendContent([`
        <div class="row">
          <div class="col-sm-12 col-md-9">$canvas</div>
          <div class="col-xs-12 col-sm-6 xcol-md-offset-9 col-md-3">
            <h4>Choose color</h4>
            $colorPicker
          </div>
          <div class="col-xs-12 col-sm-6 xcol-md-offset-9 col-md-3">
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
            dialog.querySelector('#go') .. @events('click') .. @wait;
          }
        }
        hold();
      }
    }

    @bf.Router([
      /gallery/, showGallery, //acts as a default as wel
      /drawing\/([\w-]+)/, showDrawing,
    ]);

   hold();
}
}
