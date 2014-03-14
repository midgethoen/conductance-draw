@ = require(['mho:std', 'mho:app', './canvas', './bootstrap', './colorpicker']);

var drawingId;
if (window.location.hash.length > 1){
	drawingId = window.location.hash.substr(1); 
}

function invite(){alert('invite')};
function startChain(){alert('chain')};

@withAPI('./draw.api'){
	|api|
	

	var drawing;
	try {
		[drawingId, drawing]	= api.getDrawing(drawingId);
	} catch (e){
		console.log(e) //drawing does not exist or something like that
		var l = api.getDrawing(); //?????????? whuuuuuut, why can't I assign directly
		[drawingId, drawing] = l;
	}
	window.location.hash = '#'+drawingId;

	//create something to draw on
	var canvas = @DrawingCanvas(drawing);
	@mainContent .. @replaceContent([
		@BSNav('Conductance draw', [
			@A('Invite someone' 
				.. @Mechanism(){|a|
					a .. @when('click', invite)
				}),
			@A('Start chain drawing' 
				.. @Mechanism(){|a|
					a .. @when('click', startChain)
				}),
		]),
		canvas,
		@Colorpicker(['red', 'green', 'orange'], canvas.color),
		//@Div(`select color: ${canvas.color .. @transform( c -> c.toUpperCase())}`),
		@ThicknessSelector(canvas.thickness, 150, canvas.color),
	]);

//	@doModal({
//		title: 'Welcome to Conducatance draw!',
//		close_button: false,
//		body: [
//			@P("A new drawing has been created on which you can start drawing immediately. But, the most fun is offcours is drawing together"),
//			@Button('Oke, let\'s do this') .. @Id('gogogo'),
//		]
//	}){
//		|dialog|
//		document.getElementById('gogogo') .. @wait('click');
//	}

 hold();;
}
