

class Gauge extends h2d.Sprite {
	public var up : h2d.Graphics;
	public var down : h2d.Graphics;
	public var value : Float;
	public var targetValue : Float;
	
	public var fgCol = 0x00FF00;
	public var bgCol = 0xFF0000;
	
	public function new(p) {
		super(p);
		down = new h2d.Graphics(this);
		up = new h2d.Graphics(this);
		value = 0.0;
		targetValue = 1.0;
	}
	
	public function update(tmod:Float) {
		if( value < targetValue ){
			value += tmod * 0.1;
			if ( value > targetValue ) 
				value = targetValue;
		}
		
		if( value > targetValue ){
			value -= tmod * 0.1;
			if ( value < targetValue ) 
				value = targetValue;
		}
		
		mkGfx();
	}
	
	public function mkGfx() {
		up.clear();
		down.clear();
		
		var w = 64;
		var h = 8;
		
		down.lineStyle(1.0, 0);
		down.beginFill(bgCol);
		down.drawRect(-w*0.5,-h*0.5,w,h);
		down.endFill();
		
		up.lineStyle(1.0, 0);
		up.beginFill(fgCol);
		up.drawRect(-w*0.5,-h*0.5,w * value,h);
		up.endFill();
	}
	
	public function setPercent(v:Float) {
		targetValue = hxd.Math.clamp(v,0.,1.);
	}
}

