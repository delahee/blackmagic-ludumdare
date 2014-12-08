using Math;

import T;
import SCalendar;

class TopScreen extends SCalendar {
	
	public function new(s) 	{
		//new h2d.Bitmap( h2d.Tile.fromColor(0x7DFFFF00, width, height), root );
		super(s);
		side = Top;
	}
	
	public override function getPeriod() {
		return 30.0;
	}
	
	public override function moveCadrants() {
		if ( g.cadrans[Top] == Dark && c.wave >= 10)
			return;
			
		if( pendulum != null)app.tweenie.create( pendulum, "y", C.H, 500);
		super.moveCadrants();
		pendulum.x = C.W * 0.5;
		pendulum.y = C.BAND_H * 0.5;
		new mt.heaps.fx.Spawn( pendulum );
		
		if( pendulum.elem == Dark )
			c.night();
		else 
			c.day();
	}
	
}