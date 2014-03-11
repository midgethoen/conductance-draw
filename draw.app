@ = require(['mho:std', 'mho:app', './util/shadow']);

var currentDrawingId;
if (window.location.hash.length > 1){
	currentDrawingId = window.location.hash.substr(1); 
}

function getCurrentDrawing(api){
	try {
		//fetches a existing or a new drawing
		[currentDrawingId, currentDrawing] = api.getDrawing(currentDrawingId);
	} catch (e){
		// drawing does not exist or something like that
		console.log(e);
		//create a new drawing
		[currentDrawingId, currentDrawing] = api.getDrawing();
	}
}
	
function getPos(event){
		return [event.x - event.toElement.offsetLeft, event.y - event.toElement.offsetTop];
	}

@withAPI('./draw.api'){
	|api|
	//get a drawing
	var currentDrawing;
	try {
		console.log(currentDrawingId);
		[currentDrawingId, currentDrawing]	= api.getDrawing(currentDrawingId);
	} catch (e){
		// drawing does not exist or something like that
		console.log(e);
		//create a new drawing
		[currentDrawingId, currentDrawing] = api.getDrawing();
	}
	window.location.hash = '#'+currentDrawingId;

	console.log([currentDrawing,  currentDrawingId]);

	//create something to draw on
	var canvas =  @Canvas('',{width:500, height:500})
		.. @Id('canvas')
 		.. @Style('{width: 500px; height: 500px;}')
		.. @Shadow();
	@mainContent .. @replaceContent(canvas);
	var canvas = document.getElementById('canvas');	
	var context = canvas.getContext('2d');

	waitfor{
		// for every stroke we keep track of the last segment, so we can append the last
		var strokes = {};
		//draw the drawing from all segments
		//there are 3 streams/sequences to be processed:
		// #1 the initial state of the drawing
		// #2 changes made locally
		// #3 changes beeing pushed from the server		
		currentDrawing.segments .. @concat( currentDrawing.changes )	.. @each{
			|segment|
			var precSeg;
			if ((precSeg = strokes[segment.sid]) !== undefined){
				//there is a preceding element to this stroke
				console.log("will draw");
				//console.log([precSeg, segment]);
				//context.beginPath(); //neccesary?
				context.moveTo.apply(context, precSeg.coord); 
				context.lineTo.apply(context, segment.coord);
				context.stroke();
				//context.closePath();
			}	
			strokes[segment.sid] = segment;
		}
					
		//@observe(, currentLine, (ls, cl) -> cl ? ls.concat([cl]) : ls )
		//	.. @each(){
		//		|lines|
		//		lines .. slice(drawnLines) ..  @each(function(line){
		//			context.beginPath();
		//			context.moveTo(line.coords[0].x, line.coords[0].y);
		//			line.coords.slice(1) .. @each( (l) -> context.lineTo(l.x, l.y));
		//			context.stroke();
		//			context.closePath();
		//		});
		//	};
	} and {
		canvas .. @when('mousedown'){
			|event|
			var strokeId = currentDrawing.submitSegment({coord:getPos(event)});
			waitfor {
				document.body .. @when('mousemove'){
					|event|
					currentDrawing.submitSegment({
						coord:getPos(event),
						sid: strokeId,
					});
				}
			} or {
				document.body .. @wait('mouseup');
				currentDrawing.submitSegment({
					coord:getPos(event),
					sid: strokeId,
				});
			}
		}
//		canvas .. @when('mousedown'){
//						|event|
//						currentLine.modify(x->{
//							coords: [getPos(event)],
//						});
//						waitfor {
//									document.body .. @when('mousemove'){
//												|event|
//												currentLine.modify(function(line){
//													line.coords.push(getPos(event));
//													return line;
//												});
//									}
//						} or {
//									document.body .. @wait('mouseup');
//									api.addLine(currentLine.get());
//									currentLine.modify( -> false);		
//						}
//		}
	}
}
