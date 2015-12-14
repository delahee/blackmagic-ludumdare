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
	public var touched : Bool=false;
	
	public var onCar : Bool;
	public var rushingZombie = false;
	public var bulletPosX:Float;
	public var bulletPosY:Float;
	
	var state 	: ZState = Nope;
	var bounds 	: h2d.col.Bounds;
	var stateLife = 0.0;
	var type 	: ZType;
	var name 	: String;
	
	static var uid = 0;
	var id = 0;
	public function new(man, a, lib, c, ?f = 0) {
		id = uid++;
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
	
	override function onDispose() {
		super.onDispose();
		man.zombies.remove(this);
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
		var s : mt.flash.Sfx = d.sfxPreload.get("IMPACT" + Dice.roll(1, 10)).play();
		
		for ( i in 0...Dice.roll( 8 , 16 ) * 4) {
			var e = new mt.deepnight.HParticle(man.tilePixel);
			var isLimb = false;
			var c = 0;
			if ( Dice.percent(15)){
				e.tile = man.tilePart.random();
				isLimb = true;
			}
			else {
				var s = Dice.rollF(0.8, 3.2);
				e.setSize(s, s);
				c = bol.random();
				e.setColor(c);
			}
			
			e.x = x + Std.random( 10 ) - 5;
			var oy = Std.random( 3 ) -  6;
			e.y = y - 20 + oy;
			e.groundY = y + oy;
			e.dx -= g.speed() * Dice.rollF(3,7) * 1.3;
			e.dy = Dice.rollF( -1, 1) * 0.8;
			
			if ( Dice.percentF( 3 )) {
				e.dx *= -0.33;
			}
			
			if ( Dice.percent( 20 ))
				e.dy -= Dice.rollF( 0.8, 1.2);
				
			if ( Dice.percent( 20 )) {
				e.dx *= 0.5;
				e.dy = - Dice.rollF( 2, 3);
			}
				
			e.rotation = Dice.angle();
			e.dr = Dice.either( Dice.rollF(0.01, 0.1));
			e.life = Dice.rollF(22, 45);
			e.bounceMul = Dice.rollF(0.2, 0.6);
			if( c != 0xd6c2b2 || isLimb )
			e.onBounce = function(e) {
				if ( Dice.percent( 80 )) {
					if( ! isLimb ){
						e.scaleY = 0.75;
						e.scaleX = Dice.rollF(2, 4);
					}
					e.dy = 0;
					e.dx = -g.speed() * 6;
					e.groundY = null;
					e.gy = 0;
					e.life = 100;
				}
			}
			e.gy = Dice.rollF(0.05, 0.07);
			e.gx = - 0.01;
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
		//trace("#" + id + " is dead");
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
		g.scoreZombi(type);
		haxe.Timer.delay( dispose, 200 );
	}
	
	public function hit(?v=10) {
		hp -= v;
		onHit();
		if ( hp <= 0) 
			onDeath();
	}
	
	var ofsCarX = 0.;
	var ofsCarY = 0.;
	
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
			case Nope:
			case StuckToCar:
				ofsCarX = x - c.cacheBounds.x;
				ofsCarY = y - c.cacheBounds.y;
				
				if ( a.hasAnim()) {
					a.playAndLoop(name+"_grab");
					a.setCurrentAnimSpeed(0.33);
				}
		}
		state = st;
		stateLife = 0;
	}
	
	public function update(dt:Float) {
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
			if (man.deathZone.length > 0 && !touched) {
				var i = 0;
				for ( dz in man.deathZone ) {
					if ( dz.srcPart.data <= 0)
						break;
					if ( dz.bnd.collides(bounds) ) {
						bulletPosX = dz.bnd.getCenterX();
						bulletPosY = dz.bnd.getCenterY();
						var dmg = switch(g.car.gunType) {
							case GTNone:throw "acer";
							case GTGun:10;
							case GTShotgun:8;
							case GTCanon: {
								g.fxExplosion( bulletPosX, bulletPosY);
								18;
							}
						}
						hit( dmg );
						dz.srcPart.data--;
						touched = true;
						if ( dz.srcPart.data <= 0) {
							if (dz.srcPart != null) 
								dz.srcPart.kill();	
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
			rx += dx / Scroller.GLB_SPEED * man.speed; 
			ry += dy * man.speed;
			
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
		
		if ( ! isDead() && type == Boss ) 
			if ( Dice.percentF( 2 ))
				d.sfxPreload.get("BOSS" + Dice.roll(1, 6)).play();
		
		switch( state ) {
			case Dead:
			case Incoming:
				if ( x >= incomingZone && Dice.percentF( 1.5 ) ){
					cs( Crowding );
				}
			case Rushing:
				#if debug
				//setColor( 0xff00ff );
				#end
				if ( Dice.percentF( 2 ) ) {
					cs(Crowding);
				}
				dx = hxd.Math.lerp( dx , baseDx * 0.15, 0.08);
			case Crowding:
				#if debug
				//setColor( 0xff0000 );
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
				
				if ( stateLife > 24 ) {
					c.hit( type == Boss ? 3 : 1,this);
					dispose();
				}
		}
		
		if ( state!=StuckToCar && isNearCar() ) {
			cs(StuckToCar);
		}
		
		touched = false;
		stateLife += Lib.dt2Frame(dt);
	}
	
	var ofsHookX = 0.;
	
	public inline function isNearCar() {
		return x >= c.cacheBounds.x - 44 + ofsHookX;
	}
}

typedef DeathZone = {
	bnd:h2d.col.Bounds,
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
	
	public var zombies : hxd.Stack<Zombie> = new hxd.Stack<Zombie>();
	public var deathZone : List<DeathZone> = new List();
	
	public var tilePixel : h2d.Tile;
	public var tilePart : Array<h2d.Tile>;
	public var tileFxHit : h2d.Tile;
	public var speed = 1;
	
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
		tilePart.push( tilePixel);
		tileFxHit = d.char.getTile("fxHit").centerRatio();
		parts = new hxd.Stack<mt.deepnight.HParticle>();
	}
	
	public inline function addDeathZone( c:h2d.col.Bounds, ?srcPart)  {
		var dz = { bnd:c, srcPart:srcPart };
		//trace("adz " + dz);
		deathZone.push( dz );
	}
	
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
		sb.removeAllElements();
		sbAdd.removeAllElements();
		parts = new hxd.Stack<mt.deepnight.HParticle>();
		
		for ( z in zombies)
			z.remove();
		zombies = new hxd.Stack<Zombie>();
	}
	
	public function update(dTime:Float) {
		if ( level == 0) {
			elapsedTime = 0;
			return;
		}
		
		//trace("enter dz:" + deathZone);
		var z = zombies.length - 1;
		while( z >= 0) {
			var zz = zombies.unsafeGet(z);
			if ( zz == null)
				break;
			zz.update(dTime);
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
			case 3: shouldSpawn = g.progress <= 0.8;
			case 4: shouldSpawn = g.progress <= 0.8;
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
					if( g.progress < 0.35){
						if ( mt.gx.Dice.percentF(rand,3)) spawnZombieBase();
						else if ( mt.gx.Dice.percentF(rand,1)) spawnZombieLow();
						else if ( mt.gx.Dice.percentF(rand,1)) spawnZombieBase();
					}
					else if( g.progress < 0.55 ){
						if ( mt.gx.Dice.percentF(rand,2)) spawnZombieBase();
						else if ( mt.gx.Dice.percentF(rand,1.5)) spawnZombiePackHigh();
						else if ( mt.gx.Dice.percentF(rand,1.5)) spawnZombiePackLow();
					}
					else if( g.progress < 0.6 ){
						if ( mt.gx.Dice.percentF(rand,3)) spawnZombieBase();
						else if ( mt.gx.Dice.percentF(rand,2.25)) spawnZombiePackHigh();
						else if ( mt.gx.Dice.percentF(rand,2.25)) spawnZombiePackLow();
					}
					else {
						if ( nbBoss == 0) {
							spawnZombieBase("E");
							nbBoss++;
						}
						if ( mt.gx.Dice.percentF(rand,3)) spawnZombieBase();
						else if ( mt.gx.Dice.percentF(rand,2)) spawnZombiePackHigh();
						else if ( mt.gx.Dice.percentF(rand,2)) spawnZombiePackLow();
					}
					
				case 4:
					if ( g.progress > 0.5) {
						if ( nbBoss < 2 && mt.gx.Dice.percentF(rand,3)) {
							spawnZombieBase("E");
							nbBoss++;
						}
					}
					if ( mt.gx.Dice.percentF(rand,2)) spawnZombieBase();
					else if ( mt.gx.Dice.percentF(rand,1)) spawnZombiePackHigh();
					else if ( mt.gx.Dice.percentF(rand,1)) spawnZombiePackLow();
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
	
	var nbBoss = 0;
	public function spawnZombieBase(?inletter) {
		
		inline function x(str:String) {
			return str.charAt(Std.random(str.length));
		}
		var letter=inletter!=null?inletter:
		switch(level) {
			default: 	x("A");
			case 2: 	x("AAB");
			case 3:		x("AABBC");
			case 4:		x("ABBCCDD");
		};
		
		var name = "zombie" + letter;
		var fname = name + "_run";
		var z = new Zombie(this, sb, d.char, fname );
		
		z.name = name;
		z.type = cast letter.charCodeAt(0) - "A".code;
		
		z.a.playAndLoop(fname);
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
			case Girl: 	z.baseDx *= 2; 		z.hp += 10;
			case Bold: 	z.baseDx *= 1.75; 	z.hp += 12;
			case Armor: z.baseDx *= 1.8; 	z.hp += 25;
			case Boss : 
						z.hp += 500; 		
						z.rushingZombie = true; z.baseDx *= 1.8;
			default:
		}
		
		z.dx = z.baseDx;
		z.prio();
		z.cs(Incoming);
		
		zombies.push(z);
		return z;
	}
	
	public function explodeZombies() {
		
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
		for ( i in 0...Dice.roll( 2, 4)) 
			z.push( spawnZombieHigh() );
		splatter(z);
		for ( zz in z ) zz.prio();
		return z;
	}
}