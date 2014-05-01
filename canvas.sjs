@ = require([
  'mho:std', 
  'mho:app', 
  {name:'bf', id:'./backfill.sjs'},
]);

function getPos(event, elem){
    if (!elem) elem = event.toElement;
    return [event.offsetX, event.offsetY];
  }

function BaseCanvas(segmentStream){
  var canvas = @Canvas('',{width:1000, height:1000})
    .. @Style('{width: 100%;}')
    .. @Mechanism(){
      |element|
      //TODO: use css for this
      document .. @events('resize') .. @each{
        |element|
        elememt.css.height = element.clientWidth + 'px';
      }
    }
    .. @Mechanism(){
      |element|
      // setup drawing context
      var context = element.getContext('2d');
      context.lineCap = "round";
      context.fillStyle = "#fdf6e3";
      //for every stroke we keep track of the last segment, so we can append after the last
      var redraw = @Emitter();
      //draw the drawing from all segments
      canvas.setSegmentStream = function(stream){
        segmentStream = stream;
        redraw.emit();
      }
      while (1){
        var strokes = {};
        waitfor {
          context.clearRect(0, 0, element.width, element.height);
          context.fillRect(0, 0, element.width, element.height);
          segmentStream .. @each{
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
              }
            strokes[segment.sid] = segment;
          }
        } or {
          redraw .. @wait();
        }
      }
    }

  return canvas;
}

function DrawingCanvas(drawing){
  //pencil properties
  var 
    color = @ObservableVar('black'),
    thickness = @ObservableVar(10);
  //segment stream
  var canvas = BaseCanvas(drawing.segments)
    .. @Style('{
        cursor:crosshair;
       }')
    .. @Mechanism(){
      |canvas|
      __js var toCanvasCoords = ([x,y]) -> [
        parseInt(x/canvas.clientWidth*1000),
        parseInt(y/canvas.clientHeight*1000)
      ];
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
        drawing.localSegments.set(segment);
        waitfor {
          canvas.. @events('mousemove') .. @each(){
            |event|
            var segment = {
              coord:getPos(event, canvas) .. toCanvasCoords,
              sid: strokeId,
            };
            spawn drawing.submitSegment(segment);
            drawing.localSegments.set(segment);
          }
        } or {
          var event = canvas .. @events(['mouseup', 'mouseleave']) .. @wait;
          var segment = {
            coord:getPos(event, canvas) .. toCanvasCoords,
            sid: strokeId,
          };
          spawn drawing.submitSegment(segment);
          drawing.localSegments.set(segment);
        }
      }
    }
  canvas.color = color; 
  canvas.thickness = thickness;
  return canvas;
}
exports.DrawingCanvas = DrawingCanvas;

function GalleryCanvas(drawing){
  var canvas = BaseCanvas(drawing.segments);
  return canvas .. @Mechanism{
      |element|
      element .. @events('mouseenter') .. @each{||
        canvas.setSegmentStream(drawing.segments .. @bf.throttle(1));
        element .. @events('mouseleave') .. @wait();
        canvas.setSegmentStream(drawing.segments); 
      }
    }
}
exports.GalleryCanvas = GalleryCanvas;
