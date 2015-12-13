
using mt.gx.Ex;
class Car {
	var d(get, null) : D; inline function get_d() return App.me.d;
	var g(get, null) : G; inline function get_g() return App.me.g;
	var z(get, null) : Zombies; inline function get_z() return App.me.g.zombies;
	
	public var lifeUi : h2d.SpriteBatch;
	public var sb : h2d.SpriteBatch;
	
	public var car : mt.deepnight.slb.HSpriteBE;
	public var light : mt.deepnight.slb.HSpriteBE;
	
	public var fx : h2d.SpriteBatch;
	
	public var bx = 324;
	public var by = 120;
	
	public static var me : Car = null;
	
	public var life = 4.0;
	public var maxLife = 4.0;
	
	public var isShaking = false;
	public var cacheBounds : h2d.col.Bounds;
	
	public var fireLeft : mt.deepnight.slb.HSpriteBE;
	public var fireRight : mt.deepnight.slb.HSpriteBE;
	
	public function new( p ) {
		me = this;
		sb = new h2d.SpriteBatch(d.char.tile, p);
		fx = new h2d.SpriteBatch(d.char.tile, p);
		fx.blendMode = Add;
		lifeUi = new h2d.SpriteBatch(d.char.tile, p);
		car = new mt.deepnight.slb.HSpriteBE( sb, d.char, "car");
		car.a.playAndLoop("car");
		car.a.setCurrentAnimSpeed( 0.33 );
		cacheBounds = new h2d.col.Bounds();
		syncLife();
		light = new mt.deepnight.slb.HSpriteBE( fx, d.char, "fxCarLight");
		light.alpha = 0.0;
		
		fireLeft = new mt.deepnight.slb.HSpriteBE( fx, d.char, "fxFire");
		fireLeft.alpha = 0.0;
		
		fireRight = new mt.deepnight.slb.HSpriteBE( fx, d.char, "fxFire");
		fireRight.alpha = 0.0;
	}
	
	public function update(dt) {
		if( !isShaking ){
			car.x = bx + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 6;
			car.y = by + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 4;
			if ( mt.gx.Dice.percent( 4 ))
				car.y++;
			if ( mt.gx.Dice.percent( 4 ))
				car.y++;
		}
		else {
			
		}
			
		cacheBounds.empty();
		cacheBounds.add4(car.x + car.width * 0.5, car.y + car.height * 0.25, car.width, car.height);
		
		light.x = car.x;
		light.y = car.y;
		
		light.alpha = hxd.Math.clamp( light.alpha, 0., light.alpha * 0.5 );
		fireLeft.alpha = hxd.Math.clamp( 	fireLeft.alpha, 0., fireLeft.alpha * 0.5 );
		fireRight.alpha = hxd.Math.clamp( 	fireRight.alpha, 0., fireRight.alpha * 0.5 );
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
		fx.onFinish = function() isShaking = false;
			
		syncLife();
	}
	
	public function reset() {
		life = maxLife;
		syncLife();
	}
	
	public function heal(?v = 1.0) {
		if ( life >= maxLife )
			return;
			
		life += v;
		new mt.heaps.fx.Flash( null,sb, 0.1 , 0x00ff72 );
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
	
	//var kickMiss;
	
	inline function kickShoot1() :mt.flash.Sfx{
		return 
		switch(Std.random(3)) {
			default:null;
			case 0:D.sfx.KICK11();
			case 1:D.sfx.KICK12();
			case 2:D.sfx.KICK13();
		}
	}
	
	public function shootRight() {
		var y = cacheBounds.y + 7;
		var e = fx.alloc( d.char.getTile("fxBullet").centerRatio(0,0.5) );
		var p = new PartBE( e );
		e.scaleY = 3;
		e.scaleX = 0.25;
		p.x = cacheBounds.x - 60;
		p.y = y;
		p.add( p.moveTo( -100, y, 20) );
		p.add( function() {
			var b = h2d.col.Bounds.fromValues(e.x, e.y, e.width, e.height);
			z.addDeathZone( b, p, 1);
		});
		light.alpha = 1.2;
		var f = fireLeft;
		f.x = p.x - f.width * 0.5 ;
		f.y = y - f.height * 0.5 + 3;
		f.alpha = 1.2;
		kickShoot1().play();
	}
	
	public function shootLeft() {
		var y = cacheBounds.y + 30;
		var e = fx.alloc( d.char.getTile("fxBullet").centerRatio(0,0.5) );
		var p = new PartBE( e );
		e.scaleY = 3;
		e.scaleX = 0.25;
		p.x = cacheBounds.x - 50;
		p.y = y;
		p.add( p.moveTo( -100, y, 20) );
		p.add( function() {
			var b = h2d.col.Bounds.fromValues(e.x, e.y, e.width, e.height);
			z.addDeathZone( b, p, 1);
		});
		light.alpha = 1.2;
		var f = fireLeft;
		f.x = p.x - f.width * 0.5 ;
		f.y = y - f.height * 0.5 + 3;
		f.alpha = 1.2;
		
		kickShoot1().play();
	}
	
	public function tryShootLeft() {
		var p = g.partition;
		var l = p.noteList.last();
		if ( l == null ) return;
		
		trace( l.t );
		if ( !p.isValidable(l) ) return;
		
		if ( p.tryValidate(l)) {
			shootLeft();
			g.onSuccess();
		}
		else 
			g.onMiss();
	}
	
	public function tryShootRight() {
		var p = g.partition;
		var l = p.noteList.last();
		
		trace( p.noteList.map(function(e) return e.t).join(" "));
		if ( l == null ) return;
		trace( l.t );
		
		
		if ( !p.isValidable(l) ) return;
		
		if ( p.tryValidate(l)) {
			shootRight();
			g.onSuccess();
		}
		else 
			g.onMiss();
	}
}