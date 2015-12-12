
class Car {
	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	
	public var lifeUi : h2d.SpriteBatch;
	public var sb : h2d.SpriteBatch;
	
	public var car : mt.deepnight.slb.HSpriteBE;
	
	public var bx = 324;
	public var by = 112;
	
	public static var me : Car = null;
	
	public var life = 4.0;
	public var maxLife = 4.0;
	
	public var isShaking = false;
	public var cacheBounds : h2d.col.Bounds;
	
	public function new( p ) {
		me = this;
		sb = new h2d.SpriteBatch(d.char.tile, p);
		lifeUi = new h2d.SpriteBatch(d.char.tile, p);
		car = new mt.deepnight.slb.HSpriteBE( sb, d.char, "car");
		cacheBounds = new h2d.col.Bounds();
		syncLife();
	}
	
	public function update(dt) {
		
		if( !isShaking ){
			car.x = bx + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 6;
			car.y = by + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 2;
			if ( mt.gx.Dice.percent( 4 ))
				car.y++;
			if ( mt.gx.Dice.percent( 4 ))
				car.y++;
		}
		else {
			
		}
			
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
	
	public function hit(?v=1.0) {
		life -= v;
		if ( life <= 0.0 ) {
			g.loose();
			life = 0.0;
		}
		new mt.heaps.fx.Flash( sb, 0.075,0xff0072 );
		isShaking = true;
		var fx = new mt.heaps.fx.Shake( sb, 3, 3 );
		fx.onFinish = function() {
			isShaking = false;
		}
			
		syncLife();
	}
	
	public function heal(?v = 1.0) {
		if ( life >= maxLife )
			return;
			
		life += v;
		new mt.heaps.fx.Flash( null,sb, 0.1 , 0x00ff72 );
		//new mt.heaps.fx.Shake( sb, 3, 3 );
		syncLife();
	}
	
	function syncLife() {
		lifeUi.removeAllElements();
		var nm = Math.ceil( maxLife );
		var n = Math.ceil( life );
		for ( i in 0...nm) {
			var e = lifeUi.alloc( d.char.getTile( "pixel").centerRatio() );
			e.setSize( 12, 12 );
			e.x = 30 + i * (30 + 4);
			e.y = 30;
			e.setColor( i < n ? 0xffffff : 0x0);
		}
	}
}