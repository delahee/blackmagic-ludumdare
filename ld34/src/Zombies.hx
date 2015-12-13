import mt.gx.Dice;

using mt.gx.Ex;

@:enum abstract ZState(Int) {
	var Nope = -1;
	var Incoming = 0;
	var Crowding = 1;
	var Rushing = 2;
	var Dead = 3;
	var StuckToCar = 4;
}

@:publicFields
class Zombie extends mt.deepnight.slb.HSpriteBE {
	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	var c(get, null) : Car; function get_c() return Car.me;
	var man : Zombies;
	
	public var hp = 10;
	public var rx = 0.0;
	public var ry = 0.0;
	
	public var dx = 0.0;
	public var dy = 0.0;
	
	public var baseDx = 0.0;
	public var incomingZone:Float;
	
	public var onCar : Bool;
	public var rushingZombie = false;
	var state : ZState = Nope;
	var bounds : h2d.col.Bounds;
	
	public function new(man,a,lib,c,?f=0) {
		super(a, lib, c, f);
		setCenterRatio(0.5, 1.0);
		this.man = man;
		bounds = new h2d.col.Bounds();
		incomingZone = C.W * Dice.rollF(0.1, 0.2);
	}
	
	public inline function isDead() {
		return hp <= 0;
	}
	
	public inline function prio() {
		changePriority( - Math.round((( ry * 1000) + rx)) );
	}
	
	var r = ["partA", "partB", "partC", "partN"];
	
	public function addPart(e:mt.deepnight.HParticle) {
		man.sb.add(e);
		man.parts.push(e);
	}
	
	var bol = [	0xbd1a24 , 0xbd1a24 ,
				0xbd1a24 , 0xbd1a24 ,
				0xbd1a24 , 0xbd1a24 ,
				0xd6c2b2,
				0xd4434c,
				0x83a69a,
				0xbb64a6 ];
				
	public function onHit() {
		(switch( Std.random(4) ) {
			default: D.sfx.IMPACT1();
			case 1: D.sfx.IMPACT2();
			case 2: D.sfx.IMPACT3();
			case 3: D.sfx.IMPACT4();
		}).play();
		
		for ( i in 0...Dice.roll( 8 , 16 ) * 3) {
			var e = new mt.deepnight.HParticle(man.tilePixel);
			var s = Dice.rollF(0.5, 3);
			e.setSize(s, s);
			var c = bol.random();
			e.setColor(c);
			e.x = x + Std.random( 10 ) - 5;
			var oy = Std.random( 3 ) -  6;
			e.y = y - 20 + oy;
			e.groundY = y + oy;
			e.dx -= g.speed() * Dice.rollF(3,6);
			e.dy = Dice.rollF( -1, 1);
			e.life = Dice.rollF(22, 45);
			e.bounceMul = Dice.rollF(0.2, 0.6);
			if( c != 0xd6c2b2 )
			e.onBounce = function(e) {
				if ( Dice.percent( 80 )) {
					e.scaleY = 0.75;
					e.scaleX = Dice.rollF(2,4);
					e.dy = 0;
					e.dx = -g.speed() * 6;
					e.groundY = null;
					e.gy = 0;
					e.life = 100;
				}
			}
			e.gy = Dice.rollF(0.05,0.1);
			addPart(e);
		}
	}
	public function onDeath() {
		if( a.hasAnim()){
			a.playAndLoop( groupName.split("_")[0] + "_dead");
			dx = -4;
			dy = 0;
		}
		else {
			setColor(0x0);
			dx = -4;
			dy = 0;
		}
		cs( Dead );
		haxe.Timer.delay( dispose, 200 );
	}
	
	public function hit(?v=10) {
		hp -= v;
		onHit();
		if ( hp <= 0) 
			onDeath();
	}
	
	public function cs(st:ZState) {
		switch( st ) {
			case Dead:
			case Incoming:
				dx = baseDx * 0.12;
				a.setCurrentAnimSpeed( 0.25 );
			case Rushing:
			case Crowding:
				dx = baseDx * 0.075;
				a.setCurrentAnimSpeed( 0.2 );
				//setColor( 0x00ff00 );
			case Nope,StuckToCar:
		}
		state = st;
	}
	
	//var gfx : h2d.Graphics;
	public function update(dt) {
		if ( batch == null ) return;
		
		if ( isDead()) {
			rx += dx;
			ry += dy;
			x = Math.round( rx );
			y = Math.round( ry );
			return;
		}
		
		if( !isDead()){
			bounds.empty();
			bounds.add4(x - width * 0.5, y - height, width, height);
			if (man.deathZone.length > 0) {
				var i = 0;
				for ( dz in man.deathZone ) {
					if ( dz.bnd.collides(bounds) ) {
						hit();
						dz.nb--;
						if ( dz.nb <= 0) {
							if (dz.srcPart != null) dz.srcPart.kill();	
							man.deathZone.remove(dz);
						}
					}
					i++;
				}
			}
		}
		
		if ( isDead()) return;
		
		if( state != Nope ){
			rx += dx / Scroller.GLB_SPEED;
			ry += dy;
			
			x = Math.round( rx );
			y = Math.round( ry );
		}
		
		switch( state ) {
			case Dead:
			case Incoming:
				if ( x >= incomingZone && Dice.percentF( 0.5 ) ){
					cs( Crowding );
				}
			case Rushing:
			case Crowding:
				if ( rushingZombie && Dice.percentF( 0.4 )){
					dx *= Dice.rollF(5,8);
					//setColor( 0x005e3d );
					prio();
				}
				dx = hxd.Math.lerp( dx , baseDx * 0.035, 0.11);
			case Nope:
				dx = 0;
				dy = 0;
				x = Math.round( rx );
				y = Math.round( ry );
				
			case StuckToCar:
				dx = 0;
				dy = 0;
			
				rx = x = c.cacheBounds.x + ofsCarX;
				ry = y = c.cacheBounds.y + ofsCarY;
		}
		
		if ( !onCar && isNearCar() ) {
			c.hit();
			dispose();
		}
	}
	
	var ofsCarX = 0.;
	var ofsCarY = 0.;
	var ofsHookX = 0.;
	
	public inline function isNearCar() {
		return x >= c.cacheBounds.x - 12 + ofsHookX;
	}
}

typedef DeathZone = {
	bnd:h2d.col.Bounds,
	nb:Int,
	srcPart : PartBE,
}

class Zombies {
	var d(get, null) : D; inline function get_d() return App.me.d;
	var g(get, null) : G; inline function get_g() return App.me.g;
	var c(get, null) : Car; inline function get_c() return Car.me;
	
	public var sb : h2d.SpriteBatch;
	var rand : mt.Rand;
	var elapsedTime = 0.0;
	var level : Int = 0;
	
	var zombies : hxd.Stack<Zombie> = new hxd.Stack<Zombie>();
	public var deathZone : List<DeathZone> = new List();
	
	public var tilePixel : h2d.Tile;
	public var tilePart : Array<h2d.Tile>;
	
	public var parts : hxd.Stack<mt.deepnight.HParticle>;
	
	public function new(p)  {
		sb =  new h2d.SpriteBatch(d.char.tile, p);
		rand = new mt.Rand(0);
		setLevel(0);
		tilePixel = d.char.getTile("pixel").centerRatio();
		tilePart = ["partA", "partB", "partC", "partN"].map( function(str) {
			return d.char.getTile(str).centerRatio();
		} );
		
		parts = new hxd.Stack<mt.deepnight.HParticle>();
	}
	
	public inline function countCarZombies() {
		return Lambda.count( zombies );
	}
	
	public function addDeathZone(c:h2d.col.Bounds,?srcPart,?nb=1) {
		deathZone.push({bnd:c,nb:nb,srcPart:srcPart});
	}
	
	public function setLevel(level:Int) {
		var seed = 
		switch( level ) {
			default: throw "acer";
			case 0: 0;
			case 1: 0x17deadf0;
			case 2: 0x3ded3ded;
			case 3: 0x3ded0015;
		};
		rand.initSeed( seed );
		this.level = level;
		
		sb.removeAllElements();
		
		for ( z in zombies )
			z.remove();
		zombies = new hxd.Stack<Zombie>();
		elapsedTime = 0.0;
	}
	
	public function clear() {
		for ( z in zombies)
			z.remove();
		zombies = new hxd.Stack<Zombie>();
	}
	
	public function update(dTime:Float) {
		if ( level == 0) {
			elapsedTime = 0;
			return;
		}
		
		var z = zombies.length - 1;
		while( z >= 0) {
			var zz = zombies.unsafeGet(z);
			if ( zz == null)
				break;
			zz.update(true);
			if ( zz.destroyed )
				zombies.remove( zz );
			z--;
		}
		
		var start = Std.int( elapsedTime ) * 20;
		var end = Std.int( elapsedTime + dTime ) * 20;
		for ( n in start...end ) {
			switch(level) {
				case 1:
					if ( mt.gx.Dice.percentF(rand,3)) {
						spawnZombieBase();
					}
					
					if ( mt.gx.Dice.percentF(rand,1)) {
						spawnZombieBase();
					}
					
					if ( mt.gx.Dice.percentF(rand,1)) {
						spawnZombieBase();
					}
			}
		}
		
		elapsedTime += dTime;
		
		if( deathZone.length>0)
			deathZone = new List();
			
		var p = parts.length - 1;
		while( p >= 0) {
			var pp = parts.unsafeGet(p);
			pp.update(true);
			if ( pp.killed )
				parts.remove( pp );
			p--;
		}
	}
	
	public function spawnZombieBase() {
		var name = "zombie" + "A".charAt(Std.random(1));
		
		var z = new Zombie(this, sb, d.char, name );
		
		z.a.playAndLoop(name+"_run");
		if ( z.a.hasAnim())
			z.a.setCurrentAnimSpeed( 0.4 );
		
		var cb = c.cacheBounds;
		
		z.x = z.rx = -60 + Dice.rollF( -20, 30);
		z.y = z.ry = Dice.rollF( cb.y + cb.height * 0.25, cb.y + cb.height * 0.6 + 10);
		
		z.baseDx = z.dx = 2 + Dice.rollF( 0, 0.25);
		var s = Dice.rollF(1.0, 1.2);
		z.scale( s );
		z.rushingZombie = Dice.percent(33);
		z.ofsHookX = Dice.rollF( 0.0, 8.0 );
		
		z.prio();
		z.cs(Incoming);
		
		zombies.push(z);
		return z;
	}
	
	public function spawnZombieHigh() {
		var z = spawnZombieBase();
		var cb = c.cacheBounds;
		z.x = z.ry = Dice.rollF( c.by + 20, c.by + cb.height - 30) + z.height * 0.4;
		z.y = z.rx = -30 + Dice.rollF( -20, 25);
		z.prio();
	}
	
	public function spawnZombieLow() {
		var z = spawnZombieBase();
		var cb = c.cacheBounds;
		z.x = z.ry = Dice.rollF( cb.y + cb.height * 0.25, cb.y + cb.height * 0.75);
		z.y = z.rx = -30 + Dice.rollF( -20, 25);
		z.prio();
	}
	
	public function spawnZombiePack() {
		var z = [];
		for ( i in 0...Dice.roll( 4, 6)) 
			z.push( spawnZombieBase() );
		
		for ( i in 0...z.length) {
			for ( j in 0...z.length ) {
				if ( i == j) continue;
				var pi = z[i].pos();
				var pj = z[j].pos();
				var pij = pj.sub(pi);
				if ( pi.distance( pj ) < 4.0 ) {
					z[i].translate( pij.mulScalar( 0.5 ) );
					z[j].translate( pij.mulScalar( -0.5 ) );
				}
			}
		}
		
		for ( zz in z )
			zz.changePriority( -Math.round(zz.y * 100) );
			
		return z;
	}
}