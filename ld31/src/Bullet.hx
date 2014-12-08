@:publicFields
class Part{
	var update : Array < Void->Void >;
	var sp : mt.deepnight.SpriteInterface;
	
	var vx = 0.;
	var vy = 0.;
	
	var ax = 0.;
	var ay = 0.;
	
	var iLife = 999;
	
	var x(get, set):Float; 
	var y(get, set):Float; 
	var alpha(get, set):Float; 
	
	var g = 2.0;
	var name : String;
	static var ALL = [];
	
	public function new(sp,?speedX = 0.,?speedY = 10.,?name:String) {
		this.sp = sp;
		update = [];
		vx = speedX; vy = speedY;
		ALL.pushBack( this );
		
		update = [gravity, bounds, speed];
		this.name = name;
	}
	
	public function get_x() return sp.x
	public function set_x(v) return sp.x = v
	
	public function get_y() return sp.y
	public function set_y(v) return sp.y = v
	
	public function get_alpha() return sp.alpha
	public function set_alpha(v) return sp.alpha=v
	
	public function kill()
	{
		if ( Std.is( sp, Element ))
			(cast sp).kill();
			
		sp.detach();
		ALL.remove(this);
	}
	
	public function add(bhv ) {
		update.push(bhv);
	}
	
	public function frX() {
		vx = vx * 0.95;
	}
	
	public function speed(){
		sp.x += vx;
		sp.y += vy;
	}
	
	public function delay(max,proc) {
		var n = 0;
		return function()
		{
			n++;
			if ( n >= max ) 
				proc();
		};
	}
	
	public function fadeOut( nbFr, ?dur ) {
		return once(nbFr, function() {
			var v = new mt.fx.Vanish(sp, dur);
			v.fadeAlpha = true;
		});
	}
	
	public function limit(lm, proc) {
		return function()
		{
			if ( lm >= iLife - lm)
				proc();
		};
	}
	
	public function once(max,proc) {
		var n = 0;
		return function()
		{
			n++;
			if ( n == max ) 
				proc();
		};
	}
	
	public function life() {
		iLife--;
		if (iLife < 0)
			kill();
	}
	
	public function fadeScale(fr:Float) {
		return function()
		{
			if (sp.scaleX <= 0.001 )
				kill();
			else 
				sp.scaleX = sp.scaleY *= fr;
		}
	}
	
	public function fadeAlpha() {
		if (sp.alpha <= 0.001 )		kill();
		else 						sp.alpha *= 0.98;
	}
	
	public function bounds() {
		boundX(); boundY();
	}
	
	public function boundY() {
		if ( sp.y - sp.height > Level.H * 1.3 )
			kill();
	}
	
	public function boundX() {
		if ( sp.x - sp.width > Level.W * 1.3 || sp.x + sp.width < 0 )
			kill();
	}
	
	public function accel() {
		vx += ax * tmod;
		vy += ay;
	}
	
	public function gravity(){
		vy += g;
	}
	
	public function updateAll() {
		for ( u  in update ) u();
	}
	
}