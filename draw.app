@ = require(['mho:std', 'mho:app', './util/shadow']);

var currentDrawingId;
if (window.location.hash.length > 1){
	currentDrawingId = window.location.hash.substr(1); 
}

function getPos(event){
		return [event.x - event.toElement.offsetLeft, event.y - event.toElement.offsetTop];
	}

@withAPI('./draw.api'){
	|api|
	//get a drawing
	var currentDrawing;
	try {
		[currentDrawingId, currentDrawing]	= api.getDrawing(currentDrawingId);
	} catch (e){
		// drawing does not exist or something like that
		console.log(e);
		//create a new drawing
		[currentDrawingId, currentDrawing] = api.getDrawing();
	}
	window.location.hash = '#'+currentDrawingId;


	//create something to draw on
	var canvas =  @Canvas('',{width:500, height:500})
		.. @Id('canvas')
 		.. @Style('{width: 500px; height: 500px;}')
		.. @Shadow();
	@mainContent .. @replaceContent(canvas);
	var canvas = document.getElementById('canvas');	
	var context = canvas.getContext('2d');
  var mySegments = @ObservableVar();
	waitfor{
		// for every stroke we keep track of the last segment, so we can append the last
		var strokes = {};
		//draw the drawing from all segments
		//there are 3 streams/sequences to be processed:
		// #1 the initial state of the drawing
		// #2 changes made locally
		// #3 changes beeing pushed from the server		
		currentDrawing.segments .. @concat( currentDrawing.changes .. @combine(mySegments) )	.. @each{
			|segment|
			if (!segment) continue; //the first element of mySegments is not a segment...
			var precSeg = strokes[segment.sid];
			if (precSeg !== undefined){
				//there is a preceding element to this stroke
				context.moveTo.apply(context, precSeg.coord); 
				context.lineTo.apply(context, segment.coord);
				context.stroke();
			}
			strokes[segment.sid] = segment;
		}
	} and {
		canvas .. @when('mousedown'){
			|event|
			var segment = {coord:getPos(event)};
			var strokeId = currentDrawing.submitSegment(segment);
			segment.sid = strokeId;
			mySegments.set(segment);
			waitfor {
				document.body .. @when('mousemove'){
					|event|
					var segment = {
						coord:getPos(event),
						sid: strokeId,
					};
					currentDrawing.submitSegment(segment);
					mySegments.set(segment);
				}
			} or {
				var event = document.body .. @wait('mouseup');
				var segment = {
					coord:getPos(event),
					sid: strokeId,
				};
				currentDrawing.submitSegment(segment);
				mySegments.set(segment);
			}
		}
	}
}
