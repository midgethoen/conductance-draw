@ = require([
  'mho:std',
  'mho:app',
  './canvas.sjs',
  './bootstrap.sjs',
  './colorpicker.sjs',
  {name:'bf', id:'./backfill.sjs'},
]);

document.body.style.backgroundColor = '#404045';

@withAPI('./draw.api'){
  |api|

  var drawings = {};
  function getDrawing(drawingId){
    if (!drawings[drawingId]){
      var [drawingId,drawing] = api.getDrawing(drawingId);
      //wrap the segments stream so it is locally cached and reusable
      //also add an entrypoint for local segments
      drawing.localSegments = @ObservableVar();
      drawing.segments = drawing.segments
        .. @transform(function(segments){console.log("RECEIVE #{segments.length}"); return segments;})
        .. @unpack 
        .. @combine(drawing.localSegments) 
        .. @bf.MemoizedStream;
      drawings[drawingId] = drawing;
      console.log("getting drawing #{drawingId} from server");
    } else {
      console.log("getting drawing #{drawingId} from cache");
    }
    return [drawingId, drawings[drawingId]];
  }

  createDrawing = function (){
    var [drawingId,d] = getDrawing();
    console.log(api);
    window.location.hash = '#drawing/'+drawingId;
  }

  @mainContent .. @appendContent(
    @BSNav('℧ draw', [
      @A('Gallery',{href:'#'}),
      @A('New drawing')
       .. @Mechanism{|e| e.onclick = createDrawing}])
  ){||

    function showGallery(){
      var gallery = @Div(null,{'class':'row'})
        .. @Style('a {
          width: 100%;
          height: 0;
          padding-bottom: 100%;
          display: block;
          background-color: #fdf6e3;
          margin: 10px 0;
          }') .. @bf.Shadow('a');
      @mainContent .. @appendContent([gallery]){
          |gallery|
          api.getGallery() .. @each{
            |ids|
          ids .. @each(){
            |id|
            gallery .. @appendContent(
              @Div(
                @A(
                    @P('Loading...'),
                    {href: "\#drawing/#{id}", id:id}
                  ), 
                  {'class':'col-sm-2'}
                )
              )
          }
          ids .. @each.par(){
            |id|
            var [id, drawing] = getDrawing(id);
            gallery.querySelector("\##{id}") .. @replaceContent(
                  @GalleryCanvas(drawing)
            )
          }
          hold();
        }
      }

    }

    function showDrawing(route, drawingId){
      var drawing;
      try {
        [drawingId, drawing]  = getDrawing(drawingId);
      } catch (e){
        console.log(e); //drawing does not exist or something like that
        [drawingId, drawing] = getDrawing();
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
