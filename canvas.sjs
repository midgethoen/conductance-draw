@ = require(['mho:std', 'mho:app', './util/shadow']);

function getPos(event, elem){
		if (!elem) elem = event.toElement;
		return [event.x - elem.offsetLeft, event.y - elem.offsetTop];
	}

function DrawingCanvas(drawing){
	var color = @ObservableVar('black');
	var thickness = @ObservableVar(10);
	var canvas =  @Canvas('',{width:500, height:500})
		.. @Id('canvas') //TODO: might want to increment the id somehow
 		.. @Style('{width: 500px; height: 500px;cursor:crosshair;}')
		.. @Shadow()
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
				// #1 the initial state of the drawing
				// #2 changes made locally
				// #3 changes beeing pushed from the server		
				drawing.segments 
					.. @concat( 
						drawing.changes 
						.. @combine(localSegments))
					.. @each{
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
				canvas .. @when('mousedown'){
					|event|
					//start a new stroke
					var segment = {
						coord: getPos(event), 
						color: color.get(),
						thickness: thickness.get(),
					};
					var strokeId = drawing.submitSegment(segment);
					segment.sid = strokeId;
					localSegments.set(segment);
					waitfor {
						document.body .. @when('mousemove'){
							|event|
							var segment = {
								coord:getPos(event, canvas),
								sid: strokeId,
							};
							drawing.submitSegment(segment);
							localSegments.set(segment);
						}
					} or {
						var event = document.body .. @wait('mouseup');
						var segment = {
							coord:getPos(event, canvas),
							sid: strokeId,
						};
						drawing.submitSegment(segment);
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
