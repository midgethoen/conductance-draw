@ = require(['mho:std', 'mho:app', './util/shadow']);

function getPos(event, elem){
    if (!elem) elem = event.toElement;
    return [event.offsetX, event.offsetY];
  }

function DrawingCanvas(drawing){
  var color = @ObservableVar('black');
  var thickness = @ObservableVar(10);
  var canvas =  @Canvas('',{width:1000, height:1000})
    .. @Id('canvas') //TODO: might want to increment the id somehow
     .. @Style('{width: 100%;cursor:crosshair;}')
    .. @Shadow()
    .. @Mechanism(){
      |canvas|
      document .. @events('resize') .. @each{
        |canvas|
        console.log('resize');
        canvas.css.height = canvas.clientWidth + 'px';
      }
    }
    .. @Mechanism(){
      |canvas|
      var context = canvas.getContext('2d');
      context.lineCap = "round";
      var localSegments = @ObservableVar();
      waitfor{
        // for every stroke we keep track of the last segment, so we can append the last
        var strokes = {};
        //draw the drawing from all segments
        //there are 3 streams/sequences to be processed:
        // #1 changes made locally
        // #2 changes beeing pushed from the server    
        drawing.changes .. @transform(function(x){x .. console.log; return x})  .. @unpack .. @combine(localSegments) .. @each{
          |segment|
          if (!segment) continue; //the first element of localSegments is not a segment...
          var precSeg = strokes[segment.sid];
          if (precSeg !== undefined){
            //there is a preceding element to this stroke
            if (!segment.color) 
              segment.color = (precSeg && precSeg.color) ? precSeg.color : 'grey';
            if (!segment.thickness) 
              segment.thickness = (precSeg && precSeg.thickness) ? precSeg.thickness : 3;
            context.beginPath();
            context.strokeStyle = segment.color;
            context.lineWidth = segment.thickness;
            context.moveTo.apply(context, precSeg.coord); 
            context.lineTo.apply(context, segment.coord);
            context.stroke();
            //context.endPath();
            context
          }
          strokes[segment.sid] = segment;
        }
      } and {
        var toCanvasCoords = ([x,y]) -> [x/canvas.clientWidth*1000,y/canvas.clientHeight*1000];
        canvas .. @events('mousedown') .. @each{
          |event|
          //start a new stroke
          var segment = {
            coord: getPos(event) .. toCanvasCoords, 
            color: color.get(),
            thickness: thickness.get(),
          };
          var strokeId = drawing.submitSegment(segment);
          segment.sid = strokeId;
          localSegments.set(segment);
          waitfor {
            canvas.. @events('mousemove') .. @each(){
              |event|
              var segment = {
                coord:getPos(event, canvas) .. toCanvasCoords,
                sid: strokeId,
              };
              spawn drawing.submitSegment(segment);
              localSegments.set(segment);
            }
          } or {
            var event = canvas .. @events(['mouseup', 'mouseleave']) .. @wait;
            var segment = {
              coord:getPos(event, canvas) .. toCanvasCoords,
              sid: strokeId,
            };
            spawn drawing.submitSegment(segment);
            localSegments.set(segment);
          }
      }
    }
  }
  canvas.color = color; 
   canvas.thickness = thickness;
  return canvas;
}

exports.DrawingCanvas = DrawingCanvas;
