import T;

class BottomScreen extends SCalendar {
	public function new(s) 	{
		super(s);
		side = Bottom;
	}
	
	public override function getElemOffset() {
		return 1;
	}
	
	public override function getPeriod() {
		return 30.0;
	}
	
	public override function moveCadrants() {
		if ( g.cadrans[Top] == Dark && c.wave >= 10)
			return;
			
		if( pendulum != null) app.tweenie.create( pendulum, "y", - C.H, 500);
		super.moveCadrants();
		
		pendulum.alpha = 0.0;
		pendulum.x = C.W * 0.5;
		pendulum.y = C.BAND_H * 0.5;
		new mt.heaps.fx.Spawn( pendulum );
		
	}
}