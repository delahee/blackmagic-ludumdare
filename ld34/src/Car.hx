
class Car {
	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	
	public var sb : h2d.SpriteBatch;
	
	public var car : mt.deepnight.slb.HSpriteBE;
	
	var bx = 324;
	var by = 112;
	
	public function new( p ) {
		sb = new h2d.SpriteBatch(d.char.tile, p);
		car = new mt.deepnight.slb.HSpriteBE( sb, d.char, "car");
		car.setCenterRatio(0,0);
	}
	
	public function update(dt) {
		car.x = bx+Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 6;
		car.y = by + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 2;
		if ( mt.gx.Dice.percent( 4 ))
			car.y++;
		if ( mt.gx.Dice.percent( 4 ))
			car.y++;
	}
	
}