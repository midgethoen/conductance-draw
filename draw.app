@ = require(['mho:std', 'mho:app', './util/shadow']);

@withAPI('./draw.api'){
	|api|
	var lines = api.getLines();
	var currentLine = @ObservableVar(false);

	var div =  @Canvas('',{width:500, height:500})
		.. @Id('canvas')
 		.. @Style('{width: 500px; height: 500px;}')
		.. @Shadow()
		.. @Mechanism(){
			|c|
			c .. @when('mousedown'){
				|event|
				currentLine.modify(x -> {
					coords: [{x: event.x, y: event.y}],
				});
			};
		}
		
	@mainContent .. @appendContent(div);
	
	var context = document.getElementById('canvas').getContext('2d');
		
	waitfor{
		@observe(lines, currentLine, (ls, cl) -> cl ? ls.concat([cl]) : ls )
		.. @map(){
			|newLines|
			@map(newLines, function(line){
				context.beginPath();
				context.moveTo(line.coords[0].x, line.coords[0].y);
				line.coords.slice(1) .. @map( (l) -> context.lineTo(l.x, l.y));
				context.stroke();
				context.closePath();
			});
		};
	} and {
		document .. @when('mousemove'){
				|event|
				if (currentLine.get()){
					currentLine.modify(function(line){
						line.coords.push({x: event.x, y: event.y});
						return line;
					});
				}
			};
	} and {
		document .. @when('mouseup'){
					|event|
					if (currentLine.get()){
						api.addLine(currentLine.get());
						//lines.modify(v -> v.concat([currentLine.get()]));
						currentLine.modify(x -> false);		
					}
	
				};
	}
}
