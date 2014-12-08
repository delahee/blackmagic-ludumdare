package mt.deepnight;

#if !h3d
#error "h3d is required for HParticle"
#end

import mt.MLib;
import h2d.Tile;
import h2d.SpriteBatch;

class HParticle extends BatchElement {
	public static var ALL : Array<HParticle> = new Array();
	public static var DEFAULT_BOUNDS : flash.geom.Rectangle = null;
	public static var LIMIT = 500;

	var rx						: Float; // real x,y
	var ry						: Float;
	public var dx				: Float;
	public var dy				: Float;
	public var da				: Float; // alpha
	public var ds				: Float; // scale
	public var dsx				: Float; // scaleX
	public var dsy				: Float; // scaleY
	public var dr				: Float;
	public var scale(never,set)	: Float;
	public var frict(never,set)	: Float;
	public var frictX			: Float;
	public var frictY			: Float;
	public var gx				: Float;
	public var gy				: Float;
	public var bounceMul		: Float;
	public var life(default,set): Float;
	var rlife					: Float;
	var maxLife					: Float;
	public var bounds			: Null<flash.geom.Rectangle>;
	public var groundY			: Null<Float>;
	public var groupId			: Null<String>;
	public var fadeOutSpeed		: Float;
	public var time(get,never)	: Float;
	public var maxAlpha(default,set): Float;

	public var delay(default, set)	: Float;

	public var onStart			: Null<Void->Void>;
	public var onBounce			: Null<Void->Void>;
	public var onUpdate			: Null<Void->Void>;
	public var onKill			: Null<Void->Void>;

	public var pixel			: Bool;
	public var killOnLifeOut	: Bool;
	public var destroyed		: Bool;

	public function new(t:Tile, ?x:Float, ?y:Float, ?pt:{x:Float, y:Float}) {
		super(t.clone());
		if( pt!=null ) {
			x = pt.x;
			y = pt.y;
		}

		setPos(x,y);
		setCenter(0.5, 0.5);

		destroyed = false;
		maxAlpha = 1;
		dx = dy = da = ds = dsx = dsy = 0;
		gx = gy = 0;
		fadeOutSpeed = 0.1;
		bounceMul = 0.85;
		dr = 0;
		frictX = frictY = 1;
		delay = 0;
		life = 30;

		pixel = false;
		bounds = DEFAULT_BOUNDS;
		killOnLifeOut = false;
		ALL.push(this);
	}

	inline function set_maxAlpha(v) {
		if( alpha>v )
			alpha = v;
		maxAlpha = v;
		return v;
	}

	//public function offsetPivot(dx:Float,dy:Float) {
		//tile.dx -= MLib.round(dx);
		//tile.dy -= MLib.round(dy);
	//}
//
	//public function offsetPivotRatio(xr:Float,yr:Float) {
		//tile.dx -= MLib.round(xr*tile.width);
		//tile.dy -= MLib.round(yr*tile.height);
	//}

	public inline function setCenter(xr:Float, yr:Float) tile.setCenterRatio(xr,yr);
	public inline function setPivotCoord(x:Float,y:Float) tile.setCenter(Std.int(x), Std.int(y));
	inline function set_scale(v) return scaleX = scaleY = v;
	inline function set_frict(v) return frictX = frictY = v;

	inline function set_delay(d:Float):Float {
		visible = d <= 0;
		return delay = d;
	}


	public function clone() : HParticle {
		var s = new haxe.Serializer();
		s.useCache = true;
		s.serialize(this);
		return haxe.Unserializer.run( s.toString() );
	}

	function set_life(l:Float):Float {
		if( l<0 )
			l = 0;
		life = l;
		rlife = l;
		maxLife = l;
		return l;
	}

	inline function get_time() {
		return 1 - (rlife+alpha)/(maxLife+1);
	}

	public function destroy(?unregisterNow=false) {
		alpha = 0;
		life = 0;

		if( unregisterNow )
			unregister();
	}

	public function unregister() {
		remove();
		bounds = null;
		destroyed = true;
	}

	public inline function getSpeed() {
		return Math.sqrt( dx*dx + dy*dy );
	}


	public static inline function sign() {
		return Std.random(2)*2-1;
	}

	public static inline function randFloat(f:Float) {
		return Std.random( Std.int(f*10000) ) / 10000;
	}

	public inline function moveAng(a:Float, spd:Float) {
		dx = Math.cos(a)*spd;
		dy = Math.sin(a)*spd;
	}

	public inline function moveTo(x:Float,y:Float, spd:Float) {
		var a = Math.atan2(y-ry, x-rx);
		dx = Math.cos(a)*spd;
		dy = Math.sin(a)*spd;
	}

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}

	public inline function setPos(x,y) {
		rx = this.x = x;
		ry = this.y = y;
	}

	public static function clearAll() {
		for(p in ALL)
			p.destroy();
		ALL = [];
	}

	public function update(?rendering=true) {
		delay--;
		if( delay>0 )
			return true;
		else {
			if( onStart!=null ) {
				var cb = onStart;
				onStart = null;
				cb();
			}

			// gravité
			dx+= gx;
			dy+= gy;

			// friction
			dx *= frictX;
			dy *= frictY;

			// mouvement
			rx += dx;
			ry += dy;

			// Ground
			if( groundY!=null && dy>0 && ry>=groundY ) {
				dy = -dy*bounceMul;
				ry = groundY-1;
				if( onBounce!=null )
					onBounce();
			}

			// Display coords
			if( rendering )
				if( pixel ) {
					x = Std.int(rx);
					y = Std.int(ry);
				}
				else {
					x = rx;
					y = ry;
				}

			rotation += dr;
			scaleX += ds + dsx;
			scaleY += ds + dsy;

			// Fade in
			if( rlife>0 && da!=0 ) {
				alpha += da;
				if( alpha>maxAlpha ) {
					da = 0;
					alpha = maxAlpha;
				}
			}

			rlife--;

			// Fade out (life)
			if( rlife<=0 )
				alpha -= fadeOutSpeed;

			// Death
			if( rlife<=0 && (alpha<=0 || killOnLifeOut) || bounds!=null && !bounds.contains(rx, ry)  ) {
				if( onKill!=null )
					onKill();

				unregister();
				return false;

			}
			else {
				if( onUpdate!=null )
					onUpdate();
				return true;
			}
		}
	}

	public static function updateAll(?rendering=true) {
		var i = 0;
		var all = ALL;
		var overflow = all.length - LIMIT;
		while(i < all.length) {
			if( overflow>0 ) {
				overflow--;
				all[i].destroy(true);
			}
			else
				if( all[i].update(rendering) )
					i++;
				else
					all.splice(i,1);
		}
	}
}

