import mt.gx.Dice;

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
	
	public var onCar : Bool;
	var bounds : h2d.col.Bounds;
	
	public function new(man,a,lib,c,?f=0) {
		super(a, lib, c, f);
		setCenterRatio(0.5, 1.0);
		this.man = man;
		bounds = new h2d.col.Bounds();
	}
	
	public inline function isDead() {
		return hp <= 0;
	}
	
	public function onDeath() {
		//setColor(0x0);
		
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
		
		haxe.Timer.delay( dispose, 200 );
	}
	
	public function hit(?v=10) {
		hp -= v;
		if ( hp <= 0) 
			onDeath();
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
		
		if ( !onCar) {
			rx += dx / Scroller.GLB_SPEED;
			ry += dy;
			
			x = Math.round( rx );
			y = Math.round( ry );
			
			if ( !onCar && isOnCar() ) {
				if( false ){
					onCar = true;
					ofsCarX = x - c.cacheBounds.x;
					ofsCarY = y - c.cacheBounds.y;
				}
				
				c.hit();
				dispose();
			}
		}
		else {
			dx = 0;
			dy = 0;
		
			rx = x = c.cacheBounds.x + ofsCarX;
			ry = y = c.cacheBounds.y + ofsCarY;
		}
	}
	
	var ofsCarX = 0.;
	var ofsCarY = 0.;
	var ofsHookX = 0.;
	
	public inline function isOnCar() {
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
	
	var zombies : Array<Zombie> = [];
	public var deathZone : List<DeathZone> = new List();
	
	public function new(p)  {
		sb =  new h2d.SpriteBatch(d.char.tile, p);
		rand = new mt.Rand(0);
		setLevel(0);
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
		zombies = [];
		elapsedTime = 0.0;
	}
	
	public function update(dTime:Float) {
		if ( level == 0) {
			elapsedTime = 0;
			return;
		}
			
		var i = 0;
		for ( z in zombies) {
			if( z != null){
				z.update(dTime);
				if ( z.destroyed )
					zombies[i] = null;
			}
			i++;
		}
		
		var start = Std.int( elapsedTime ) * 20;
		var end = Std.int( elapsedTime + dTime ) * 20;
		for ( n in start...end ) {
			switch(level) {
				case 1:
					if ( mt.gx.Dice.percent(rand,5)) {
						spawnZombieBase();
					}
			}
		}
		
		elapsedTime += dTime;
		
		if( deathZone.length>0)
			deathZone = new List();
	}
	
	public function spawnZombieBase() {
		var name = "zombie" + "ABC".charAt(Std.random(3));
		
		var z = new Zombie(this, sb, d.char, name );
		
		z.a.playAndLoop(name+"_run");
		if ( z.a.hasAnim())
			z.a.setCurrentAnimSpeed( 0.4 );
		
		var cb = c.cacheBounds;
		
		z.ry = Dice.rollF( cb.y + cb.height * 0.25, cb.y + cb.height * 0.6);
		z.rx = -30 + Dice.rollF( -20, 25);
		
		z.x = z.rx;
		z.y = z.ry;
		
		z.changePriority( -Math.round(z.y) );
		
		z.dx = 2 + Dice.rollF( 0, 0.25);
		z.scale( Dice.rollF(0.75, 1.0) );
		z.ofsHookX = Dice.rollF( 0.0, 8.0 );
		
		zombies.push(z);
		return z;
	}
	
	public function spawnZombieHigh() {
		var z = spawnZombieBase();
		z.ry = Dice.rollF( c.by + 20, c.by + c.cacheBounds.height - 30) + z.height * 0.4;
		z.rx = -30 + Dice.rollF( -20, 25);
		z.x = z.rx;
		z.y = z.ry;
		z.changePriority( -Math.round(z.y) );
	}
	
	public function spawnZombieLow() {
		var z = spawnZombieBase();
		
		var cb = c.cacheBounds;
		z.ry = Dice.rollF( cb.y + cb.height * 0.25, cb.y + cb.height * 0.75);
		var g = h2d.Graphics.fromRect( 20, cb.y + cb.height * 0.25, 100, cb.height * 0.5,sb.parent);
		haxe.Timer.delay( g.dispose, 200);
		z.rx = -30 + Dice.rollF( -20, 25);
		z.x = z.rx;
		z.y = z.ry;
		z.changePriority( -Math.round(z.y) );
	}
	
}