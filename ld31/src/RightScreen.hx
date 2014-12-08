import T;

using Math;

class RightScreen extends SCalendar{
	public function new(s) 	{
		
		super(s);
		side = Right;
	}
	
	override public function getPeriod() 
	{
		return 12.5;
	}
	
	public override function elemOf(spin) {
		if ( c.wave < 5) return None;
		return [Earth,Fire, Water, None,Water, Fire, None][spin % 4];
	}
	
	public override function moveCadrants() {
		if ( c.wave < 5 ) return;
		if( pendulum != null)app.tweenie.create( pendulum, "x", -C.W, 500);
		super.moveCadrants();
		pendulum.x = C.BAND_H * 0.5;
		pendulum.y = C.H * 0.5;
		new mt.heaps.fx.Spawn( pendulum );
	}
}