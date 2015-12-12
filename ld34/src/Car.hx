
class Car {
	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	
	public var sb : h2d.SpriteBatch;
	
	public var car : mt.deepnight.slb.HSpriteBE;
	
	public var bx = 324;
	public var by = 112;
	
	public static var me : Car = null;
	
	public var cacheBounds : h2d.col.Bounds;
	
	public function new( p ) {
		me = this;
		sb = new h2d.SpriteBatch(d.char.tile, p);
		car = new mt.deepnight.slb.HSpriteBE( sb, d.char, "car");
		cacheBounds = new h2d.col.Bounds();
	}
	
	public function update(dt) {
		car.x = bx + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 6;
		car.y = by + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 2;
		if ( mt.gx.Dice.percent( 4 ))
			car.y++;
		if ( mt.gx.Dice.percent( 4 ))
			car.y++;
			
		cacheBounds.empty();
		cacheBounds.add4(car.x + car.width * 0.5, car.y + car.height * 0.25, car.width, car.height);
	}
	
	public function getBounds() {
		return h2d.col.Bounds.fromValues(car.x + car.width * 0.5, car.y + car.height * 0.25, car.width, car.height);
	}
	
	public function onPause(onOff) {
		//trace(car.width);
		h2d.Graphics.fromBounds( getBounds(), sb.parent);
		//trace(sb.x +" "+sb.y );
	}
}