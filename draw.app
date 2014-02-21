@ = require(['mho:std', 'mho:app', './util/shadow']);

@withAPI('./draw.api'){
	|api|
	var lines = api.getLines();
	var currentLine = @ObservableVar(false);

	function getPos(event){
		return {x: event.x - event.toElement.offsetLeft, y: event.y - event.toElement.offsetTop};
	}

	var canvas =  @Canvas('',{width:500, height:500})
		.. @Id('canvas')
 		.. @Style('{width: 500px; height: 500px;}')
		.. @Shadow()
	
	@mainContent .. @appendContent(canvas);
	
	var context = document.getElementById('canvas').getContext('2d');
		
	waitfor{
		@observe(lines, currentLine, (ls, cl) -> cl ? ls.concat([cl]) : ls )
		.. @each(){
			|lines|
			console.log("Will draw #{lines.length}")
			@map(lines, function(line){
				context.beginPath();
				context.moveTo(line.coords[0].x, line.coords[0].y);
				line.coords.slice(1) .. @map( (l) -> context.lineTo(l.x, l.y));
				context.stroke();
				context.closePath();
			});
		};
	} and {
		document .. @when(['mousemove','mouseup','mousedown']){
			|event|
			switch (event.type){
				case('mousedown'):
					if (event.toElement.id == 'canvas'){
						currentLine.modify(x -> {
							coords: [getPos(event)],
						});
					};
					break;
				case('mousemove'):
					if (currentLine.get()){
						currentLine.modify(function(line){
							line.coords.push(getPos(event));
							return line;
						});
					}
					break;
				case('mouseup'):
					if (currentLine.get()){
						console.log('stop');
						api.addLine(currentLine.get());
						currentLine.modify( -> false);		
					}

			}
		}
	}
}
