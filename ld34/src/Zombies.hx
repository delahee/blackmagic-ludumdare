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

@:enum abstract ZType(Int) {
	var Noob	= 0;
	var Girl	= 1;
	var Bold	= 2;
	var Armor	= 3;
	var Boss	= 4;
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
	
	var type : ZType;
	
	public var onCar : Bool;
	public var rushingZombie = false;
	var state : ZState = Nope;
	var bounds : h2d.col.Bounds;
	
	public var bulletPosX:Float;
	public var bulletPosY:Float;
	
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
	
	public function addPartAdd(e:mt.deepnight.HParticle) {
		man.sbAdd.add(e);
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
		
		for ( i in 0...Dice.roll( 8 , 16 ) * 4) {
			var e = new mt.deepnight.HParticle(man.tilePixel);
			var s = Dice.rollF(0.8, 3.2);
			e.setSize(s, s);
			var c = bol.random();
			e.setColor(c);
			e.x = x + Std.random( 10 ) - 5;
			var oy = Std.random( 3 ) -  6;
			e.y = y - 20 + oy;
			e.groundY = y + oy;
			e.dx -= g.speed() * Dice.rollF(3,6) * 1.2;
			e.dy = Dice.rollF( -1, 1) * 0.8;
			
			if ( Dice.percent( 20 ))
				e.dy -= Dice.rollF( 0.8, 1.2);
				
			if ( Dice.percent( 20 )) {
				e.dx *= 0.5;
				e.dy = - Dice.rollF( 2, 3);
			}
				
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
			e.gy = Dice.rollF(0.04,0.06);
			addPart(e);
		}
		
		//var p;
		//addPartAdd( p = new mt.deepnight.slb.HSpriteBE(man.sbAdd, d.char,"tileFxHit" ) );
		//p.life = 5;
		for( i in 0...Dice.roll(1,2)){
			var p = new mt.deepnight.slb.HSpriteBE(man.sbAdd, d.char, "fxHit" );
			p.setCenterRatio(0, 0.5);
			p.a.play( "fxHit");
			var pe = new PartBE( p );
			pe.x = x + Std.random(2)-1;
			pe.y = bulletPosY+ Std.random(2)-1;
			pe.life = Dice.roll(5,6);
			p.scale(Dice.rollF(0.4,0.6));
			p.rotation = Dice.angle();
			p.alpha = Dice.rollF2(0.55, 0.70);
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
		g.scoreZombi();
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
				if( a.hasAnim())
					a.setCurrentAnimSpeed( 0.25 );
			case Rushing:
				dx = baseDx * Dice.rollF(0.55,0.9);
			case Crowding:
				dx = baseDx * 0.1;
				if( a.hasAnim())
					a.setCurrentAnimSpeed( 0.2 );
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
						bulletPosX = dz.bnd.getCenterX();
						bulletPosY = dz.bnd.getCenterY();
						hit();
						dz.nb--;
						if ( dz.nb <= 0) {
							if (dz.srcPart != null) dz.srcPart.kill();	
							man.deathZone.remove(dz);
							break;
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
		
		//if ( type == Girl ) {
		if ( state == Crowding) {
			//trace( "st:"+state+" "+dx+" t:"+type);
		}
		
		if ( state == Rushing) {
			//trace( "st:"+state+" "+dx+" t:"+type);
		}

		switch(man.level) {
			default:
				if ( g.progress > 0.75 && !rushingZombie )
					rushingZombie = true;
		}
		
		switch( state ) {
			case Dead:
			case Incoming:
				if ( x >= incomingZone && Dice.percentF( 1.5 ) ){
					cs( Crowding );
				}
			case Rushing:
				#if debug
				setColor( 0xff00ff );
				#end
				if ( Dice.percentF( 2 ) ) {
					cs(Crowding);
				}
				dx = hxd.Math.lerp( dx , baseDx * 0.15, 0.08);
			case Crowding:
				#if debug
				setColor( 0xff0000 );
				#end
				if ( rushingZombie && Dice.percentF( 1.3 )){
					prio();
					cs(Rushing);
				}
				dx = hxd.Math.lerp( dx , baseDx * 0.065, 0.11);
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
	public var sbAdd : h2d.SpriteBatch;
	var rand : mt.Rand;
	var elapsedTime = 0.0;
	public var level : Int = 0;
	
	var zombies : hxd.Stack<Zombie> = new hxd.Stack<Zombie>();
	public var deathZone : List<DeathZone> = new List();
	
	public var tilePixel : h2d.Tile;
	public var tilePart : Array<h2d.Tile>;
	public var tileFxHit : h2d.Tile;
	
	public var parts : hxd.Stack<mt.deepnight.HParticle>;
	
	public function new(p)  {
		sb =  new h2d.SpriteBatch(d.char.tile, p);
		sbAdd =  new h2d.SpriteBatch(d.char.tile, p); sbAdd.blendMode = Add;
		rand = new mt.Rand(0);
		setLevel(0);
		tilePixel = d.char.getTile("pixel").centerRatio();
		tilePart = ["partA", "partB", "partC", "partN"].map( function(str) {
			return d.char.getTile(str).centerRatio();
		} );
		tileFxHit = d.char.getTile("fxHit").centerRatio();
		parts = new hxd.Stack<mt.deepnight.HParticle>();
	}
	
	public inline function addDeathZone(c:h2d.col.Bounds,?srcPart,?nb=1)  deathZone.push({bnd:c,nb:nb,srcPart:srcPart});
	
	public function setLevel(level:Int) {
		var seed = 
		switch( level ) {
			default: throw "acer";
			case 0: 0;
			case 1: 0x17deadf0;
			case 2: 0x3ded3ded;
			case 3: 0x3ded0015;
			case 4: 0x3ded0015;
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
		
		var shouldSpawn = false;
		
		switch(level) {
			case 1: shouldSpawn = g.progress <= 0.75;
			case 2: shouldSpawn = g.progress <= 0.60;
			case 3: shouldSpawn = g.progress <= 0.75;
			case 4: shouldSpawn = g.progress <= 0.75;
		}
		
		for ( n in start...end ) {
			switch(level) {
				case 1:
					if ( mt.gx.Dice.percentF(rand,3)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,1)) spawnZombieLow();
					else if ( mt.gx.Dice.percentF(rand,1)) spawnZombieBase();
					
				case 2:
					if ( mt.gx.Dice.percentF(rand,2)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,1)) spawnZombiePackHigh();
					else if ( mt.gx.Dice.percentF(rand,1)) spawnZombiePackLow();
					
				case 3:
					if ( mt.gx.Dice.percentF(rand,9)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,3)) spawnZombieLow();
					else if ( mt.gx.Dice.percentF(rand,3)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,3)) spawnZombiePack();
					
				case 4:
					if ( mt.gx.Dice.percentF(rand,12)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,4)) spawnZombieLow();
					else if ( mt.gx.Dice.percentF(rand,4)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,4)) spawnZombiePack();
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
	
	public function spawnZombieBase(?inletter) {
		
		inline function x(str:String) {
			return str.charAt(Std.random(str.length));
		}
		var letter=inletter!=null?inletter:
		switch(level) {
			default: 	x("A");
			case 2: 	x("AAB");
			case 3:		x("AABBC");
			case 4:		x("AABBCCD");
		};
		
		var name = "zombie" + letter + "_run";
		var z = new Zombie(this, sb, d.char, name );

		z.type = cast letter.charCodeAt(0) - "A".code;
		
		z.a.playAndLoop(name);
		if ( z.a.hasAnim())
			z.a.setCurrentAnimSpeed( 0.4 );
		
		var cb = c.cacheBounds;
		
		z.x = z.rx = -60 + Dice.rollF( -20, 30);
		z.y = z.ry = Dice.rollF( cb.y + cb.height * 0.25, cb.y + cb.height * 0.6 + 10);
		
		z.baseDx = z.dx = 1.75 + Dice.rollF( 0, 0.5);
		var s = Dice.rollF(1.0, 1.2);
		z.scale( s );
		z.rushingZombie = Dice.percent(z.type == Girl ? 80 : 33);
		z.ofsHookX = Dice.rollF( 0.0, 8.0 );
		
		switch( z.type) {
			//case Girl: 	z.hp += 10;
			case Girl: 	z.baseDx *= 2; z.hp += 10;
			case Bold: 	z.hp += 20;
			case Armor: z.hp += 40;
			case Boss : z.hp += 100;
			default:
		}
		
		z.dx = z.baseDx;
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
		return z;
	}
	
	public function spawnZombieLow() {
		var z = spawnZombieBase();
		var cb = c.cacheBounds;
		z.x = z.ry = Dice.rollF( cb.y + cb.height * 0.25, cb.y + cb.height * 0.75);
		z.y = z.rx = -30 + Dice.rollF( -20, 25);
		z.prio();
		return z;
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
	
	function splatter(z:Array<Zombie>) {
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
		return z;
	}
	
	public function spawnZombiePackLow() {
		var z = [];
		for ( i in 0...Dice.roll( 4, 6)) 
			z.push( spawnZombieLow() );
		splatter(z);
		for ( zz in z ) zz.prio();
		return z;
	}
	
	public function spawnZombiePackHigh() {
		var z = [];
		for ( i in 0...Dice.roll( 4, 6)) 
			z.push( spawnZombieHigh() );
		splatter(z);
		for ( zz in z ) zz.prio();
		return z;
	}
}