
using mt.gx.Ex;
import mt.gx.Dice;
import Zombies;
enum GunType {
	GTNone;
	GTGun;
	GTCanon;
	GTShotgun;
}

class Car {
	var d(get, null) : D; inline function get_d() return App.me.d;
	var g(get, null) : G; inline function get_g() return App.me.g;
	var z(get, null) : Zombies; inline function get_z() return App.me.g.zombies;
	
	public var lifeUi : h2d.SpriteBatch;
	public var ui : h2d.SpriteBatch;
	public var sb : h2d.SpriteBatch;
	
	public var car : mt.deepnight.slb.HSpriteBE;
	public var light : mt.deepnight.slb.HSpriteBE;
	
	public var fx : h2d.SpriteBatch;
	
	public static inline var BASE_BX = 324;
	public static inline var BASE_BY = 120;
	
	public var bx = BASE_BX;
	public var by = BASE_BY;
	
	public static var me : Car = null;
	
	public var life = 4.0;
	public var maxLife = 4.0;
	
	public var isShaking = false;
	public var cacheBounds : h2d.col.Bounds;
	
	public var fireLeft : mt.deepnight.slb.HSpriteBE;
	public var fireRight : mt.deepnight.slb.HSpriteBE;
	
	public var progCar : mt.deepnight.slb.HSpriteBE;
	public var progRoad : mt.deepnight.slb.HSpriteBE;
	public var gun:mt.deepnight.slb.HSpriteBE;
	
	public var gunType(default, set):GunType = GTNone;
	
	public var showDirt : Bool = true;
	public var dirts : Array<mt.deepnight.slb.HSpriteBE> = [];
	
	#if debug
	public var forceGun = false;
	#end
	
	public var invincible = true;
	
	public var visible = true;
	public function new( p ) {
		me = this;
		sb = new h2d.SpriteBatch(d.char.tile, p);
		ui = new h2d.SpriteBatch(d.char.tile, p);
		fx = new h2d.SpriteBatch(d.char.tile, p);
		fx.blendMode = Add;
		lifeUi = new h2d.SpriteBatch(d.char.tile, p);
		
		for(i in 0...2){
			var dirt = new mt.deepnight.slb.HSpriteBE( sb, d.char, "fxDirt");
			dirt.setCenterRatio(0.2, 0.5);
			dirt.a.playAndLoop("fxDirt");
			dirt.a.setGeneralSpeed( 0.33 );
			dirts.push(dirt);
		}
		
		car = new mt.deepnight.slb.HSpriteBE( sb, d.char,"carStop");
		car.a.setGeneralSpeed( 0.33 );
		bx = - C.W;
		by = BASE_BY;
		cacheBounds = new h2d.col.Bounds();
		syncLife();
		light = new mt.deepnight.slb.HSpriteBE( fx, d.char, "fxCarLight");
		light.alpha = 0.0;
		
		fireLeft = new mt.deepnight.slb.HSpriteBE( fx, d.char, "fxFire");
		fireLeft.alpha = 0.0;
		
		fireRight = new mt.deepnight.slb.HSpriteBE( fx, d.char, "fxFire");
		fireRight.alpha = 0.0;
		
		progRoad = new mt.deepnight.slb.HSpriteBE( ui, d.char, "goal");
		progRoad.x = baseXProg;
		progRoad.y = 10;
		
		progCar = new mt.deepnight.slb.HSpriteBE( ui, d.char, "cursor");
		progCar.x = baseXProg;
		progCar.y = 10;
		
		gun = new mt.deepnight.slb.HSpriteBE( sb, d.char, "carGuns");
	}
	
	var baseXProg = 150;
	var isCarAutomaticMove = true;
	
	var upDownBalance = 0.0;
	var upDownPerShoot = 2.0;
	
	var curBalance = 0.0;
	public function update(dt) {
		if ( !isShaking ) {
			
			car.x = bx + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 4;
			
			if( isCarAutomaticMove ) {
				car.y = by + Math.sin( hxd.Math.angle( hxd.Timer.oldTime) ) * 4;
			}
			else {
				car.y = by;
				var fr = Lib.dt2Frame( dt );
				for( i in 0...Math.round(fr) ){
					if(	Math.abs(upDownBalance) > 0.001 ) {
						var sign = upDownBalance < 0 ? -1 : 1; 
						upDownBalance = sign * (hxd.Math.abs(upDownBalance)-0.033);
					}
				}
				upDownBalance = hxd.Math.clamp( upDownBalance, -24, 24);
				curBalance = hxd.Math.lerp( curBalance, hxd.Math.clamp( upDownBalance, -16, 16), 0.1 );
				car.y += curBalance;
			}
			
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
		
		progCar.x = baseXProg + hxd.Math.clamp(g.progress, 0, 1) * 280.0;
		
		gun.setPos(car.x, car.y);
		
		var i = 0;
		for(dirt in dirts){
			dirt.x = car.x  - 24 + ((i == 0)?8:22);
			dirt.y = car.y  + 42 + ((i == 0)?0:25);
			dirt.visible = showDirt;
			i++;
		}
		
		lifeUi.visible = fx.visible = ui.visible = sb.visible = visible;
	}
	
	function set_gunType(gt:GunType) {
		if ( gt == gunType)
			return gt;
		switch( gt ) {
			case GTNone:
			case GTGun: gun.a.playAndLoop("carGuns"); 			g.partition.curWeapon.text = "GUN";
			case GTCanon: gun.a.playAndLoop("carCanon");		g.partition.curWeapon.text = "CANON";
			case GTShotgun: gun.a.playAndLoop("carShotgun");	g.partition.curWeapon.text = "SHOTGUN";
		}
		gunType = gt;
		d.sfxPreload.get("CHANGE_GUN").play();
		return gt;
	}
	
	public function getBounds() {
		return h2d.col.Bounds.fromValues(car.x + car.width * 0.5, car.y + car.height * 0.25, car.width, car.height);
	}
	
	public function onPause(onOff) {
		//trace(car.width);
		//h2d.Graphics.fromBounds( getBounds(), sb.parent);
		//trace(sb.x +" "+sb.y );
	}
	
	public function hit(?v = 1.0, z:Zombie) {
		if ( invincible ) return;
		
		life -= v;
		
		new mt.heaps.fx.Flash( sb, 0.075,0xff0000,2.0 );
		isShaking = true;
		var sfx = new mt.heaps.fx.Shake( sb, 3, 3 );
		sfx.onFinish = function() isShaking = false;
		
		for( i in 0...3){
			var fx = new mt.deepnight.slb.HSpriteBE( sb, d.char, "fxExplosion");
			fx.setCenterRatio();
			fx.a.play("fxExplosion");
			fx.a.killAfterPlay();
			fx.a.setCurrentAnimSpeed( 0.33 );
			if( Dice.percent( 33 )){
				fx.x = z.x + Dice.rollF( -5,5);
				fx.y = z.y + Dice.rollF( -5, 5);
			}
			else {
				fx.x = cacheBounds.randomX() + Dice.rollF( -5,5);
				fx.y = cacheBounds.randomY()+ Dice.rollF( -5,5);
			}
			d.sfxPreload.get("EXPLOSION").play();
		}
		
		syncLife();
		
		if ( life <= 0.0 ) {
			g.loose();
			life = 0.0;
		}
	}
	
	public function reset() {
		life = maxLife;
		syncLife();
	}
	
	public function heal(?v = 1.0) {
		if ( life >= maxLife )
			return;
			
		life += v;
		//new mt.heaps.fx.Flash( null,sb, 0.1 , 0x00ff72 );
		syncLife();
	}
	
	var lifeTile:h2d.Tile;
	function syncLife() {
		if ( lifeTile == null) lifeTile = d.char.getTile( "life").centerRatio();
		lifeUi.removeAllElements();
		var nm = Math.ceil( maxLife );
		var n = Math.ceil( life );
		for ( i in 0...n-1) {
			var e = lifeUi.alloc( lifeTile,-i );
			e.x = (C.W - 48) + i * 10;
			e.y = 14;
		}
	}
	
	inline function setupBullet(e:h2d.SpriteBatch.BatchElement, p:PartBE) {
		p.sample = 1;
		switch ( gunType ) {
			default:
			case GTCanon:
				e.scaleY+=2;
				e.scaleX -= 0.025;
				e.setColor( 0xC83214, 2.0 );
			case GTShotgun:
				e.scaleY *= 0.5;
				e.scaleX *= 0.33;
				e.x -= Dice.rollF( 0, 15);
				e.y += Dice.rollF( -10, 10);
				e.setColor( 0x1E28C8, 2.0 );
		}
		p.data = 1;
		switch(gunType) {
				default: 		
				case GTCanon:	
					p.vx *= 0.55;
					p.vy *= 0.55;
					p.data = Dice.roll(4, 6);
			}
			
		p.y -= 5;
			
		p.add( function() {
			//reeval bounds
			var b : h2d.col.Bounds = h2d.col.Bounds.fromValues(e.x, e.y, e.width, e.height);
			z.addDeathZone( b, p  );
		});
	}
	
	public inline function sndShoot() {
		switch( gunType) {
			default:
			case GTGun: 	d.sfxPreload.get("GUN1").play();
			case GTShotgun: d.sfxPreload.get("GUN2").play();
			case GTCanon: 	d.sfxPreload.get("GUN3").play();
		}
	}
	
	public function shootRight() {
		sndShoot();
		
		var nb = 1;
		var sp = 15;
		if ( gunType == GTShotgun){
			nb += Dice.roll(1, 3);
			sp = 10;
		}
		
		var baseY = cacheBounds.y + 9;
		for ( i in 0...nb ) {
			var y = baseY;
			var e = fx.alloc( d.char.getTile("fxBullet").centerRatio(0,0.5) );
			var p = new PartBE( e );
			e.scaleY = 3;
			e.scaleX = 0.25;
			p.x = cacheBounds.x - 60;
			p.y = y;
			p.add( p.moveTo( -100, y, sp) );
			setupBullet(e, p );
		}
		light.alpha = 1.4;
		var f = fireLeft;
		f.x = cacheBounds.x - 60 - f.width * 0.5 ;
		f.y = baseY - f.height * 0.5 + 3;
		f.alpha = 1.2;
		//upDownBalance -= upDownPerShoot;
	}
	
	public function shootLeft() {
		sndShoot();
		
		var nb = 1;
		var sp = 15;
		if ( gunType == GTShotgun){
			nb += Dice.roll(1, 2);
			sp = 10;
		}
			
		var baseY = cacheBounds.y + 33;
		for( i in 0...nb ) {
			var y = baseY;
			var e = fx.alloc( d.char.getTile("fxBullet").centerRatio(0,0.5) );
			var p = new PartBE( e );
			e.scaleY = 3;
			e.scaleX = 0.25;
			p.x = cacheBounds.x - 50;
			p.y = y;
			p.add( p.moveTo( -100, y, sp) );
			setupBullet(e, p );
		}
		
		light.alpha = 1.4;
		var f = fireLeft;
		f.x = cacheBounds.x - 50 - f.width * 0.5 ;
		f.y = baseY - f.height * 0.5 + 3;
		f.alpha = 1.2;
		//upDownBalance += upDownPerShoot;
	}
	
	public function tryShootLeft() {
		var p = g.partition;
		var l = p.noteList.last();
		if ( l == null ) return;
		
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
		
		if ( l == null ) return;
		if ( !p.isValidable(l) ) return;
		
		if ( p.tryValidate(l)) {
			shootRight();
			g.onSuccess();
		}
		else 
			g.onMiss();
	}
}