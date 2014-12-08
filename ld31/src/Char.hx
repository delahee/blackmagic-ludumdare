import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.SpriteInterface;
import mt.deepnight.Tweenie;
import mt.deepnight.HParticle;
import mt.deepnight.slb.HSpriteBE;
import T;
import Part;
import h2d.*;
import volute.Dice;
using volute.Ex;

/**
 * 
 * 
 * round 1 
 * on pop le wawa a droite
 * on pop un zombie a gauche
 * 
 * on explique
 * 
 * on pop le healer
 * 
 * 2 zombie
 * 
 * puis 3 zombie 
 * 
 * on pop le mage
 * 
 * puis zou 
 * 
 * un peu apres on vait des vagues
 * 
 * 1 2 3 2 2 3 2 2 3 3 3 
 * 
 * puis le boss !
 * 
 */

class Char extends h2d.Sprite {
	var app(get, null) : App; 			function get_app() return App.me;
	var d(get, null) : D;				function get_d() return App.me.d;
	var g(get, null) : G;				function get_g() return App.me.g;
	var c(get, null) : CenterScreen; 	function get_c() return CenterScreen.me;
	
	public var bar : Float = 0.0;
	public var maxBar : Float = 16.0;
	public var atbSpeed = 1.0;
	public var maxAtbSpeed:Float = 1.0;
	
	public var defense : Float = 0.0; //percent
	public var hp : Float = 0.0;
	public var maxHp : Float = 0.0;
	
	public var baseElem : Elem;
	public var pendingSpell : Spell;
	public var spells : Array<SpellDef>;

	public var isGood : Bool;
	public var isDead : Bool;
	public var atk : Float;
	public var atkMag : Float;
	public var cl:CharClass;
	
	public var lifeText : h2d.Text;
	
	public var atb:Sprite;
	
	public var pendingArrow : HSprite;
	public var pendingAction : HSprite;
	public var nextAction : HSprite;
	
	public var gaugeBg : HSprite;
	public var gaugeFg : HSprite;
	public var gaugeLeft : HSprite;
	public var gaugeGlow : HSprite;
	
	public var dot : {dpfr:Float,fr:Float};
	var lockTimer:Float;
	var lockTimerCap:Float = 60.0;
	static var uiLineY = -150;
	
	public var seed : Int;
	public var line : Int;
	public var column : Int;
	public var sp:HSprite;
	
	public function new(cl:CharClass, p:h2d.Sprite) {
		super(p);
		this.cl = cl;
		name = ""+cl;
		
		baseClass();
		specClass();
		
		bar = Dice.rollF( 0.0, maxBar * 0.5);
		makeGfx();
		
		if ( spells.length == 0 ) throw "assert";
			
		maxHp = hp;
		maxAtbSpeed = atbSpeed;
		seed = Std.random(15152534) + 45335435;
	}
	
	public function setTile(str:String) {
		if ( sp == null) {
			sp = d.char.h_getAndPlay(str, 999, false);
			addChild( sp );
		}
		else 
			sp.a.playAndLoop( str );
		sp.setFrame( Dice.roll(0,sp.totalFrames()-1 ));
		sp.setCenter(0.5, 1.0);
	}
	
	public function makeGfx() {
		lifeText = new h2d.Text(d.wendyBig, this);
		lifeText.dropShadow = { dx:0, dy:2, color:0xFF250713, alpha:1.0 };
		lifeText.textColor = 0xFFffd673;
		lifeText.filter = false;
	}
	
	public function baseClass() {
		hp = 100;
		atk = atkMag = 10;
	}
	
	public function goodClass() {
		maxBar *= 0.9;
	}
	
	public function badClass() {
		
	}
	
	public function specClass() {
		function mk(s:Spell, w) : SpellDef return { s:s, weight:w };
		switch(cl) {
			
			case Dummy:
				badClass();
				hp = 20;
				spells = [ mk(Atk, 10),mk(Swap,10) ];
			case Skel:
				badClass();
				hp = 25;
				spells = [ mk(Atk, 10) ];
			case Thug:
				badClass();
				hp = 40;
				spells = [ mk(Atk, 10) , mk(Swap,2)];
			case Taxman:
				badClass();
				hp = 30;
				atk *= 1.5;
				spells = [ mk(Atk, 10), mk( BlackSpell( Water, Spike), 10), mk(Swap,5)];
			case Leech: 
				badClass();
				hp = 40;
				atkMag *= 2;
				spells = [ 
					mk(Atk, 10),
					mk( BlackSpell( Water, Spike), 10),
					mk( BlackSpell( Fire, Bolt), 10),
					mk(Swap, 3)];
			case Tentacle:
				badClass();
				hp = 50;
				//maxBar *= 1.0;
				spells = [ 
					mk( Atk, 10), 
					mk( Def, 10),
					mk( BlackSpell( Fire, Bolt), 10),
					mk( BlackSpell( Water, Spike), 10),
					mk( BlackSpell( Earth, Root), 10),
				];
			
			case Warrior:
				goodClass();
				hp = 150;
				atk *= 2;
				lockTimerCap = 1.0;
				spells = [ 
					mk(Atk, 5), mk(Def, 5),
					mk(Atk, 5), mk(Def, 5),
				];
				maxBar = maxBar * 1.1;
				
			case Whitemage:
				goodClass();
				hp = 100;
				atk *= 0.5;
				atkMag *= 1.8;
				spells = [ 
					mk( Def, 5), 
					mk( Atk, 10),
					mk( WhiteSpell( Water, Heal), 15),
					mk( WhiteSpell( Earth, Armor), 15),
					mk( WhiteSpell( Fire, Speed), 15),
					mk( BlackSpell( Earth, Root), 5),
				];
				
				maxBar = maxBar * 0.9;
			case Blackmage:
				goodClass();
				hp = 70;
				atkMag *= 2;
				spells = [ 
					mk( Atk, 15), 
					mk( Def, 5),
					mk( BlackSpell( Fire, Bolt), 15),
					mk( BlackSpell( Water, Spike), 15),
					mk( BlackSpell( Earth, Root), 15),
				];
				maxBar = maxBar * 1.2;
		}
		
		if ( isGood ) {
			baseElem = Light;
		}
		else {
			baseElem = Dark;
		}
	}
	
	public function getMyIndex() {
		var idx = 0;
		if ( isGood){
			for ( c in c.char ){
				if ( c == this ) 
					return idx;
				idx++;
		}}
		else {
			for ( c in c.nmy ){
				if ( c == this ) 
					return idx;
				idx++;
		}}
		return -1;
	}
	
	public function getTarget() : Char {
		var idx = getMyIndex();
		var c = isGood ? c.nmy[idx] : c.char[idx];
		if ( c!=null && c.isDead )
			c = null;
		return c;
	}
	
	public function getNeighBours() {
		var a = [];
		var idx = getMyIndex();
		var src = isGood ? c.char : c.nmy;
		if ( idx == 0 ){
			if(src[idx + 1]!=null) a.push( src[idx + 1]);
		}else if ( idx == 2 ){
			if(src[idx - 1]!=null) a.push( src[idx - 1]);
		}else if ( idx == 1 ){
			if(src[idx - 1]!=null) a.push( src[idx - 1]);
			if(src[idx + 1]!=null) a.push( src[idx + 1]);
		}
		a = a.filter( function(c) return !c.isDead );
		return a;
	}
	
	public function getNeighBoursAndMe() {
		var n = getNeighBours();
		if ( n.indexOf(this) >= 0 )
			throw "self assert";
		n.push(this);
		return n;
	}
	
	public function hit(v:Float, ?s : Spell) : Bool {
		if ( isDead )  //die only once
			return false;
			
		#if godMode
		//TODO god mode
		if ( isGood ) {
			return false;
		}
		#end
		
		var dratio = hxd.Math.clamp((100 - defense) / 100,0.,1.);
		v *= dratio;
		hp -= v;
		//defense = 0.0;//cancel def
		if ( Math.round(hp) <= 0 ) {
			onDeath();
			return true;
		}
		else {
			
			if( v > 0 && s != DotSideFx){
				var t = new h2d.Text(lifeText.font,lifeText.parent);
				t.text = "-" + Math.round(v);
				t.x = lifeText.x;
				t.y = lifeText.y;
				t.textColor = 0xFFFF0000;
				var tw = app.tweenie.create( t , "y", t.y - 30, 600 );
				tw.onEnd = function() new mt.heaps.fx.Vanish(t);
				
			}
				
			if ( hp > 0.0 ) 
				onHit(s);
			return false;
		}
	}
	
	public function heal(v:Float) {
		if ( isDead ) return;
		
		hp += v;
		if( v > 0 ){
			var t = new h2d.Text(lifeText.font,lifeText.parent);
			t.text = "+" + Math.round(v);
			t.x = lifeText.x;
			t.y = lifeText.y;
			t.textColor = 0xFF00FF00;
			var tw = app.tweenie.create( t , "y", t.y - 20, 600 );
			tw.onEnd = function() new mt.heaps.fx.Vanish(t);
		}
		if ( hp > maxHp ) hp = maxHp;
	}
	
	public inline function getGaugeGlowTime() : String {
		return
		switch(pendingSpell) {
			default:"pixel_transparent";
			case Atk:"glowSword";
			case Def:"glowShield";
			case WhiteSpell(e, _):"glow" + Std.string(e);
			case BlackSpell(e,_):"glow" + Std.string(e);
		}
	}
	
	var gaugeShown = false;
	
	public function update(tmod:Float) {
		if ( hp == 0 ) lockTimer = 0;
		
		lockTimer -= tmod;
		
		if ( isDead ) {
			atb.visible = false;
			lifeText.visible = false;
			return;
		}
			
		if ( atbSpeed < maxAtbSpeed ) {
			atbSpeed += tmod / maxBar;
			if ( atbSpeed >= maxAtbSpeed ) 
				atbSpeed = maxAtbSpeed;
		}
		
		if ( atbSpeed > maxAtbSpeed ) {
			atbSpeed -= tmod / maxBar;
			if ( atbSpeed <= maxAtbSpeed ) 
				atbSpeed = maxAtbSpeed;
		}
		
		//update bar
		if( c.canInteract() ) 	{
			bar += atbSpeed * tmod / 30.0;
			
			var r = hxd.Math.clamp(bar / maxBar, 0.0, 1.0);
			gaugeGlow.visible = line == 0;
			gaugeGlow.toFront();
			
			if ( r >= 0.7 && !gaugeShown) {
				gaugeGlow.set(getGaugeGlowTime());
				gaugeGlow.setCenter(0.5, 0.5);
				gaugeGlow.alpha = 0.8;
				gaugeGlow.y = uiLineY + 10;
				gaugeShown = true;
				
				if ( pendingSpell != Def) {
					gaugeGlow.x += 8;
					gaugeGlow.y -= 8;
				}
			}
			
			if ( r >= 0.8 )
				gaugeGlow.alpha = Math.sin( hxd.Timer.oldTime * 0.1 ) * 0.1 + 0.89;
			
			if ( gaugeFg != null) gaugeFg.scaleX = r * 25.0;
			
			if ( bar >= maxBar ) onTurn();
			lockTimer -= tmod;
		}
		
		lifeText.text = Math.round( hp ) + "HP";
		lifeText.x = Std.int(-lifeText.textWidth * 0.5);
		
		if ( dot != null ) {
			dot.fr -= tmod;
			onDot();
			hit( dot.dpfr * tmod,DotSideFx );
			if ( dot.fr <= 0 ) 
				dot = null;
		}
	}
	
	public function onDot() {
		var bolt : HSprite = d.getSphereAdd(parent);
		bolt.blendMode = Add;
		bolt.color = h3d.Vector.fromColor(0xFF00cd00);
		var a = Dice.randAngle();
		var d = Dice.rollF( 8, 20) * 3;
		bolt.x = x + Math.cos( a ) * d;
		bolt.y = y + Math.sin( a ) * d - 40;
		var fx = new mt.heaps.fx.Blink(bolt);
		fx.onFinish = function() {
			var v = new mt.heaps.fx.Vanish(bolt);
			v.setFadeScale( 1, 1);
		}
	}
	
	public function lock() {
		lockTimer = lockTimerCap;
		if ( isShaking && curShake != null){
			curShake.kill();
		}
	}
	
	public function isLocked() {
		return lockTimer >= 0;
	}
	
	public function execute(pendingSpell) { 
		#if debug
		if ( isDead ) 
			throw "assert";
		#end
		var tgt = getTarget();
		var c : Float = critRatio();
		if( tgt != null ) tgt.lock();
		switch(pendingSpell) {
			case Nop, DotSideFx:
			case Swap:				{
				var a = [];
				var i = 0;
				var myIndex = getMyIndex();
				for ( n in this.c.nmy) {
					if ( i == myIndex || n == this) continue;
					if ( n ==null || !n.isLocked() )
						a.push( i );
					i++;
				}
				
				var oIndex :Null<Int>= a.random();
				if( oIndex != null && oIndex >= 0)
					CenterScreen.me.oppSwap(myIndex, oIndex );
			}
			
			case Atk: 				
				if ( tgt != null ) {
					if ( tgt.defense > 1 )
						D.sfx.sword_impact_shield().play();
					else 
						D.sfx.sword_impact().play();
				
					tgt.hit( atk * c, pendingSpell );
				}
				else 
					D.sfx.sword_miss().play();
				
			case Def: 				
				defense = 40 * c;
				sp.a.playAndLoop( defend() );
			case WhiteSpell(_, t):
				switch(t) {
					case Heal: 
						var targets = getNeighBoursAndMe();
						function effect() {
							for ( n in targets)
								n.heal( 0.8 * atkMag * c );
						}
						
						D.sfx.heal().play();
						for(n in targets)
							for ( i in 0...12 ) {
								haxe.Timer.delay( function(){
									var bolt = d.char.h_get("fxHeal_blend",parent); //getSphereAdd(parent);
									bolt.setCenter(0.5, 0.5);
									bolt.blendMode = Add;
									bolt.color = h3d.Vector.fromColor(0xFF00FF29);
									
									var a = Dice.randAngle();
									var d = Dice.rollF( 15, 25) * 3;
									bolt.x = n.x + Math.cos( a ) * d;
									bolt.y = n.y + Math.sin( a ) * d - 40;
									
									var p = new Part(bolt); 
									var ca = Math.cos( a );
									var sa = Math.sin( a );
									
									p.vx = ca * 1.0;
									p.vy = sa * 1.0;
									p.add( p.accel );
									p.add( p.speed );
									
									var fx = new mt.heaps.fx.Blink(bolt);
									fx.onFinish = function() new mt.heaps.fx.Vanish(bolt);
								}, Dice.roll( 50, 300));
							}
						
						haxe.Timer.delay( effect, 300 );
						
					case Armor:
						D.sfx.protect().play();
						var targets = getNeighBoursAndMe();
						function effect() 
							for ( n in targets)
								n.defense += atkMag * c;
						
						for(n in targets)
							for ( i in 0...40 ) {
								haxe.Timer.delay( function(){
									var bolt : HSprite = d.getSphereAdd(parent);
									bolt.blendMode = Add;
									bolt.color = h3d.Vector.fromColor(0xFFcdcdcd);
									var a = Dice.randAngle();
									var d = Dice.rollF( 8, 20) * 3;
									bolt.x = n.x + Math.cos( a ) * d;
									bolt.y = n.y + Math.sin( a ) * d - 40;
									var fx = new mt.heaps.fx.Blink(bolt);
									fx.onFinish = function() {
										var d = 50;
										var fx = new mt.heaps.fx.Tween( bolt, 
											n.x + Math.cos( a ) * d, 
											n.y + Math.sin( a ) * d -40);
										fx.onFinish = function(){
											var v = new mt.heaps.fx.Vanish(bolt);
											v.setFadeScale( 1, 1);
										}
									}
								}, Dice.roll( 50, 300));
							}
							
						haxe.Timer.delay( effect, 300 );
					case Speed:
						D.sfx.speed_up().play();
						var targets = getNeighBoursAndMe();
						function effect() 
							for ( n in targets) {
								n.atbSpeed += c * 0.40;
							}
						
						for(n in targets)
							for ( i in 0...30 ) {
								haxe.Timer.delay( function(){
									var bolt : HSprite = d.getSphereAdd(parent);
									bolt.blendMode = Add;
									bolt.color = h3d.Vector.fromColor(0xFFE8A10C);
									var a = Dice.randAngle();
									var d = Dice.rollF( 8, 20) * 3;
									var ca = Math.cos( a );
									var sa = Math.sin( a );
									bolt.x = n.x + ca * d;
									bolt.y = n.y + sa * d -40;
									bolt.scaleX = 0.5;
									
									var fx = new mt.heaps.fx.Blink(bolt,15);
									fx.onFinish = function() {
										var fx = new mt.heaps.fx.Tween( bolt, bolt.x, bolt.y - Dice.roll(35, 40) );
										haxe.Timer.delay( function(){
										var v = new mt.heaps.fx.Vanish(bolt,20,10); 
										v.setFadeScale(1, -1);
										},275);
									}
								}, Dice.roll( 50, 300));
							}
						haxe.Timer.delay( effect, 300 );
					default: throw "unsupported";
				}
			case BlackSpell(_, t):
				switch(t) {
					case Bolt: {
						function effect() 
							if( tgt != null)
								tgt.hit( atkMag * c,pendingSpell );
						
						var bolt : HSprite = d.getSphereAdd(parent);
						bolt.setCenter( 0.5, 0.5 );
						bolt.blendMode = Add;
						bolt.scaleX = bolt.scaleY = 4.0;
						bolt.color = h3d.Vector.fromColor(0xFFFFB900);
						bolt.x = x;
						bolt.y = y;
						
						D.sfx.spell_charge().play();
						for ( i in 0...10 ) {
							haxe.Timer.delay( function(){
								var bolt : HSprite = d.getSphereAdd(parent);
								bolt.blendMode = Add;
								bolt.scaleX = bolt.scaleY = 1.0;
								bolt.color = h3d.Vector.fromColor(0xFFFFB900);
								var a = Dice.randAngle();
								var d = Dice.rollF( 8, 20) * 3;
								bolt.x = x + Math.cos( a ) * d;
								bolt.y = y + Math.sin( a ) * d - 40;
								var fx = new mt.heaps.fx.Tween(bolt, x, y );
								fx.onFinish = function() new mt.heaps.fx.Vanish(bolt);
							}, Dice.roll( 50, 150));
						}
						
						var p = new Part( bolt );
						var fx = new mt.heaps.fx.Grow( bolt,0.075 );
						fx.onFinish = function() {
							var pos = new h2d.col.Point();
							
							if( tgt != null){
								pos.x = tgt.x;
								pos.y = tgt.y;
							}
							else 	
								if( isGood ) {
									pos.x = x;
									pos.y = y -200;
								}
								else 
									{
										pos.x = x;
										pos.y = y+200;
									}
							D.sfx.spell_fire_launch().play();
							p.add( p.moveTo(pos.x, pos.y, 10.0, 3.0) );
							p.add(function() {
								var b = d.getSphereAdd(parent);
								b.blendMode = Add;
								b.x = bolt.x;
								b.y = bolt.y;
								b.color = bolt.color;
								b.scaleX = b.scaleY = 3.2 + Dice.rollF(-0.1,0.1);
								var t = app.tweenie.create(  b, "scaleX", 0.0, TType.TBurnOut, 400);
								t.onUpdate = function() {
									b.scaleY = b.scaleX;
									b.alpha *= 0.8 + Dice.rollF(-0.1,0.1);
								};
								t.onEnd = b.detach;
							});
							
							if( tgt != null)
								p.add( p.intersectCircle( tgt.x,tgt.y, 20, function() {
									bolt.remove();
									var sp = new h2d.Sprite( parent );
									D.sfx.spell_fire_impact().play();
									for ( i in 0...50) {
										var bolt : mt.deepnight.slb.HSprite = d.getSphereAdd(sp);
										bolt.setCenter(0.5, 0.5);
										bolt.blendMode = Add;
										var a = Dice.randAngle();
										var d = Dice.rollF( 5, 15);
										var ca = Math.cos( a );
										var sa = Math.sin( a );
										bolt.x = tgt.x		 + ca * d;
										bolt.y = tgt.y - 40  + ca * d;
										bolt.color = h3d.Vector.fromColor(0xFFFFB900);
										var p = new Part( bolt );
										
										var d = Dice.rollF( 5, 15 );
										if ( Dice.percent( 10 ))
											d *= 5.0;
											
										if ( Dice.percent( 80 ))
											bolt.scaleX = bolt.scaleY = Dice.rollF( 0.5, 0.75);
										p.vx = ca * d;
										p.vy = sa * d;
										p.fadeScale( 0.90 + Dice.rollF( 0.,0.08) );
										p.add(p.accel);
										p.add(p.speed);
										p.add(p.frictSpeed(0.95));
										p.add(p.frictAlpha(0.9));
									}
									
									haxe.Timer.delay( function() {
										sp.dispose();
									},750);
									effect();
								}));
						};
					}
						
					case Spike:
						function effect() {
							if ( tgt == null) return;
							tgt.hit( atkMag * c * 0.8,pendingSpell );
							tgt.atbSpeed *= 0.33 / c ;
						}
						
						var pos = new h2d.col.Point();
						if( tgt != null){
								pos.x = tgt.x;
								pos.y = tgt.y;
						}
						else 	
							if( isGood ) {
								pos.x = x;
								pos.y = y -200;
							}
							else 
								{
									pos.x = x;
									pos.y = y+200;
								}
								
						
						if( tgt!=null){
							if ( critLevel() >= 1)
								D.sfx.spell_ice_boost().play();
							else 
								D.sfx.spell_ice().play();
						}
						else 
							D.sfx.spell_ice_no_impact().play();
								
						for ( i in 0...5) {
							haxe.Timer.delay( function(){
								var bolt : HSprite = d.char.h_get("fxSpike_blend",parent);
								bolt.setCenter( 0.5, 0.5);
								var b: HSprite = d.char.h_get("fxSpike_add", bolt);
								b.setCenter( 0.5, 0.5);
								b.blendMode = Add;
								bolt.x = x ;
								if ( !isGood ) 
									bolt.rotation = Math.PI;
								var d = Dice.roll( 0, -24);
								bolt.y = y  + d - 40;
								bolt.scaleX = bolt.scaleY = 0.5 * (1.0 + c*0.1 );
								bolt.color = h3d.Vector.fromColor(0xFF0005FF);
								var dx = Dice.rollF( -20, 20);
								bolt.x += -10 + dx;
								var p = new Part( bolt );
								p.add( p.moveTo(pos.x+dx, pos.y, 10.0, 3.0) );
								p.add( p.life );
								p.iLife = Dice.roll(12,20);
								
								if(tgt!=null)
									p.add( p.intersectCircle( tgt.x, tgt.y - 40, 40, function() {
										bolt.remove();
										if( i == 0 )
											effect();
									}));
							},Dice.roll(0,150));
						}
					case Root:
						if( tgt!=null){
							var bolt : HSprite = d.char.h_getAndPlay("roots",1,true);
							bolt.setCenter( 0.5, 0.5);
							parent.addChild(bolt);
							bolt.x = tgt.x;
							bolt.y = tgt.y - 40;
							if ( critLevel() >= 1 )
								D.sfx.spell_earth_boost().play();
							else 
								D.sfx.spell_earth().play();
						}
						function effect() {
							var dur = 30 * 4;//4 secs;
							var val = 6.0 * c;
							if (tgt == null ) return;
							tgt.dot = { dpfr: val / dur,  fr : 30 * 4 };
						}
						
						haxe.Timer.delay( effect, 300 );
						
					default: throw "unsupported";
				}
		}
	}
	
	public function onTurn() {
		var tgt = getTarget();
		if ( pendingSpell == null ) return;
		lock();
		
		gaugeGlow.visible = false;
		gaugeGlow.alpha = 0.0;
		defense = 0.0;
		
		onStrike();
		
		execute(pendingSpell );
		pendingSpell = nextSpell();
		bar = 0.0;
		atbSpeed = 1.0;
		if ( pendingSpell == null ) throw "assert";
	}
	
	public function idle() {
		if ( defense > 1.0 ) 
			return defend();
		else 
		return isGood 
		?  	"char" + c.getLetter(cl)
		:	"mob" + c.getLetter(cl);
	}
	
	public function hitFrame() {
		return isGood 
		?  	"char" + c.getLetter(cl)+"Hit"
		: 	"mob" + c.getLetter(cl)+"Hit";
	}
	
	public function win() {
		return isGood 
		?  	"char" + c.getLetter(cl)+"Win"
		: 	"mob" + c.getLetter(cl)+"Win";
	}
	
	public function attack() {
		return isGood 
		?  	"char" + c.getLetter(cl) + "Attack" 
		:	"mob" + c.getLetter(cl) + "Attack" ;
	}
	
	public function defend() {
		return isGood 
		?  	"char" + c.getLetter(cl) + "Defend" 
		:	"mob" + c.getLetter(cl) + "Defend" ;
	}
	
	public function onStrike() {
		sp.a.play( attack());
		sp.a.play( idle(),999, true );
		
		if ( !isShaking ) {
			isShaking = true;
			var d = 10;
			if ( !isGood ) d *= -1;
			y -= d;
			haxe.Timer.delay( function() { y += d; isShaking = false; } , 250 );
		}
	}
	
	public function setToFront() {
		//toFront();
		scaleX = 1.0;
		scaleY = 1.0;
		x -= 16;  
		y += 64;
		mt.heaps.fx.Lib.traverseDrawables(this, function (d) {
			d.colorMatrix = null;
		});
	}
	
	public function spellToTile(s:Spell) {
		return
		switch(s) {
			case Atk:"sword";
			case Def:"shield";
			case Swap:"swap";
			case WhiteSpell(_, fx): Std.string(fx).toLowerCase();
			case BlackSpell(_, fx):	Std.string(fx).toLowerCase();
			case DotSideFx,Nop:"pixel_transparent";
		}
	}
	
	public function finish(col,line) {
		column = col;
		this.line = line;
		var xofs = 8;
		var yofs = 10;
		
		atb = new Sprite(this);
		pendingArrow = d.char.h_get("gaugeLeft",atb);
		pendingArrow.y += uiLineY;
		pendingArrow.x += 30;
		pendingArrow.visible = isGood;
		
		gaugeLeft = d.char.h_get("gaugeLeft", atb);
		gaugeLeft.setCenter( 0, 0.5);
		gaugeLeft.y = uiLineY + yofs;
		gaugeLeft.x -= 70; 
		gaugeLeft.x += xofs;
		
		gaugeBg = d.char.h_get("gaugeBg", atb);
		gaugeBg.setCenter( 0, 0.5);
		gaugeBg.y = uiLineY + yofs;
		gaugeBg.x -= 70; 
		gaugeBg.x += xofs;
		gaugeBg.scaleX = 35;
		
		gaugeFg = d.char.h_get("gaugeShield", atb);
		gaugeFg.setCenter( 0, 0.5);
		gaugeFg.y = uiLineY + yofs;
		gaugeFg.x -= 50; 
		gaugeBg.x += xofs;
		gaugeFg.scaleX = 0;
		
		var s = d.char.h_get( "shadow", this);
		s.setCenter(0.5, 1.0);
		s.toBack();
		switch(cl) {
			default:
			case Skel,Thug,Taxman,Leech:
				s.x -= 12;
				s.y += 8 + Dice.roll( 0, 5 );
				
			case Warrior, Whitemage, Blackmage:
				s.y += 12 + Dice.roll( 0, 5 );
				s.x += 15;
		}
		
		pendingSpell = nextSpell();
		
		var gg = gaugeGlow = d.char.h_get("glowSword", this);
		gg.setCenter(0.5, 0.5);
		gg.y = uiLineY + yofs;
		gg.blendMode = Add;
		gg.visible = false;
		gg.alpha = 0.0;
	}
	
	public function refreshGaugeTile() {
		if( gaugeFg!=null){
			switch(pendingSpell) {
				default:
				case Atk: gaugeFg.set( "gaugeSword");
				case Def: gaugeFg.set( "gaugeShield");
				case WhiteSpell(e, _): 
					if( isSpellElemBoost() )	gaugeFg.set( "gauge" + Std.string(e));
					else 						gaugeFg.set( "gaugeWand" );
						
				case BlackSpell(e, _): 
					if( isSpellElemBoost() )	gaugeFg.set( "gauge" + Std.string(e));
					else 						gaugeFg.set( "gaugeWand" );
			}
			gaugeFg.setCenter(0, 0.5);
		}
	}
	
	public function nextSpell() : Spell {
		var r = new volute.Rand(seed);
		var idx = spells.normRd(r);
		if (idx == null ) throw "assert";
		
		if ( pendingAction != null) 
			pendingAction.remove();
		
		var s = spells[idx].s;
		pendingAction = d.char.h_get( spellToTile(s),atb );
		pendingAction.setCenter( 0.5, 0.5);
		pendingAction.y += uiLineY + 10;
		pendingAction.x += 10;
			
		pendingAction.visible = false;
		
		if (line == 0)  {
			haxe.Timer.delay( function(){
				pendingAction.visible = true;
				refreshGaugeTile();
			}, 150);
		}
		
		seed = r.random(1024 * 1024) ^ r.random(1024 * 1024);
		if( isGood ){
			var idx = spells.normRd(new volute.Rand(seed));
			if (idx == null ) throw "assert";
			if ( nextAction != null) {
				var n = nextAction;
				var t = app.tweenie.create(n, "x", nextAction.x - 20, TType.TEase, 200);
				t.onUpdateT = function(t)  n.alpha = t;
				t.onEnd = function() n.remove();
			}
			
			var s = spells[idx].s;
			nextAction = d.char.h_get( spellToTile(s),atb );
			nextAction.setCenter( 0.5, 0.5);
			nextAction.x += 66;
			nextAction.y += uiLineY + 10;
			new mt.heaps.fx.Spawn(nextAction, 0.1, false, true);
		}
		
		return s;
	}
	
	public function onDeath() {
		if( ! isGood ) {
			g.colGeneration[getMyIndex()]++;
			D.sfx.monster_death().play();
		}
		else 
		{
			if ( cl == Whitemage )
				D.sfx.hero_female_death().play();
			else 
				D.sfx.hero_male_death().play();
		}
			
		hp = 0;
		isDead = true;
		shake();
		
		c.onDeath();
		
		if ( isGood )
			setTile("char" + c.getLetter(cl) + "Dead");
		else {
			var v = new mt.heaps.fx.Vanish( this );
			v.onFinish = function() {
				var idx = getMyIndex();
				if( idx >= 0 )
					if ( c.nmy[idx] == this )
						c.nmy[idx] = null;
			}
		}
	}
	
	var isShaking = false;
	var isBlinking = false;
	
	public function onHit(?s:Spell) {
		if ( isDead )
			return;
			
		if ( s == Atk ){
			var s = d.char.h_getAndPlay("slash", 1, true);
			s.setCenter( 0.5, 0.5 );
			s.blendMode = Add;
			addChild(s);
		}
		sp.a.play( hitFrame() );
		sp.a.play( idle(),999, true );
		if( s!= DotSideFx )	shake();
	}
	
	/*
	public function blink() {
		if( !isBlinking ) {
			isBlinking = true;
			var fx = new mt.heaps.fx.Blink( this );
			fx.onFinish = function() isBlinking = false;
		}
	}*/
	
	public var curShake :mt.heaps.fx.Shake;
	public function shake() {
		if ( !isShaking ) {
			isShaking = true;
			var fx = new mt.heaps.fx.Shake( this, 6, 6 );
			curShake = fx;
			fx.onFinish = function() {
				curShake = null;
				isShaking = false;
			}
		}
	}

	public function critRatio() : Float {
		return Math.pow( kOf(pendingSpell) , critLevel() );
	}
	
	public function kOf(s:Spell) : Float {
		return 
		switch(s) {
			default:1.333;
		}
	}
	
	/**
	 * @return a crit level of 0...2
	 */
	public function critLevel() {
		var l = 0;
		if( isGood ){
			if ( baseElem == g.cadrans[Bottom] )
				l++;
			else if( baseElem == g.cadrans[Top] )
				l++;
		}
		
		if ( isSpellElemBoost())
			l++;
		
		return l;
	}
	
	
	public function isSpellElemBoost() : Bool {
		return
		switch(pendingSpell) {
			case DotSideFx, Atk, Def, Nop,Swap: false;
			case WhiteSpell(e, _):	( e == g.cadrans[Left] || e == g.cadrans[Right] );
			case BlackSpell(e, _): 	( e == g.cadrans[Left] || e == g.cadrans[Right] );
		}
	}
	
}