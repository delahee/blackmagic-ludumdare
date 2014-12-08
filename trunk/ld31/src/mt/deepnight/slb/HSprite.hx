package mt.deepnight.slb;

import h2d.Drawable;
import mt.deepnight.slb.*;
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.SpriteInterface;

class HSprite extends h2d.Drawable implements SpriteInterface {
	public var a			: AnimManager;
	public var lib			: BLib;
	public var groupName	: String;
	public var group		: LibGroup;
	public var frame		: Int;
	public var frameData	: FrameData;
	public var pivot		: SpritePivot;
	public var destroyed	: Bool;

	public var beforeRender	: Null<Void->Void>;
	public var onFrameChange: Null<Void->Void>;

	var mTile					: h2d.Tile;
	public var tile(get,null)	: h2d.Tile;


	public function new(?l:BLib, ?g:String, ?f=0, ?parent:h2d.Sprite, ?sh : h2d.Drawable.DrawableShader) {
		super(parent,sh);
		destroyed = false;

		pivot = new SpritePivot();
		a = new AnimManager(this);

		if( l!=null )
			set(l, g, f);
		else
			mTile = tile = h2d.Tile.fromTexture( getEmptyTexture() );
	}

	public function toString() return "HSprite_"+groupName+"["+frame+"]";

	//inline function get_lib() return bs.lib;
	//inline function get_groupName() return bs.groupName;
	//inline function get_group() return bs.group;
	//inline function get_frame() return bs.frame;
	//inline function get_frameData() return bs.frameData;
	//inline function get_pivot() return bs.pivot;
	//inline function get_a() return bs.a;

	override function set_width(v:Float) {
		scaleX = v/tile.width;
		return v;
	}
	override function set_height(v:Float) {
		scaleY = v/tile.height;
		return v;
	}


	public
	function set( ?l:BLib, ?g:String, ?frame=0, ?stopAllAnims=false ) {
		if( l!=null ) {
			// Update internal tile
			if ( l.tile==null )
				throw "sprite sheet has no backing texture, please generate one";

			mTile = tile = l.tile.clone();

			// Reset existing frame data
			if( g==null ) {
				groupName = null;
				group = null;
				frameData = null;
			}

			// Register blib
			if( lib!=null )
				lib.removeChild(this);
			lib = l;
			lib.addChild(this);
			if( pivot.isUndefined )
				setCenter(lib.defaultCenterX, lib.defaultCenterY);
		}

		if( g!=null && g!=groupName )
			groupName = g;

		if( isReady() ) {
			if( stopAllAnims )
				a.stopWithoutStateAnims();

			group = lib.getGroup(groupName);
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';
			setFrame(frame);
		}
	}



	public inline function setRandom(?l:BLib, g:String, rndFunc:Int->Int) {
		set(l, g, lib.getRandomFrame(g, rndFunc));
	}

	public inline function setRandomFrame(?rndFunc:Int->Int) {
		if( isReady() )
			setRandom(groupName, rndFunc==null ? Std.random : rndFunc);
	}

	public function getAnimDuration() {
		var a = getAnim();
		return a!=null ? a.length : 0;
	}

	inline function getAnim() {
		return isReady() && group.anim.length>=0 ? group.anim : null;
	}

	inline function hasAnim() {
		return getAnim()!=null;
	}

	public inline function isGroup(k) {
		return groupName==k;
	}

	public inline function is(k, f) {
		return groupName==k && frame==f;
	}

	public inline function isReady() {
		return !destroyed && groupName!=null;
	}

	public function setFrame(f:Int) {
		var old = frame;
		frame = f;

		if( isReady() ) {
			var prev = frameData;
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';

			if( onFrameChange!=null )
				onFrameChange();
		}
	}

	public inline function setPivotCoord(x:Float, y:Float) {
		pivot.setCoord(x, y);
	}

	public inline function setCenter(xRatio:Float, yRatio:Float) {
		pivot.setCenter(xRatio, yRatio);
	}

	public function totalFrames() {
		return group.frames.length;
	}





	//public inline function setRandom( ?l, g, rndFunc ) bs.setRandom(l, g, rndFunc);
	//public inline function setRandomFrame(?rndFunc) bs.setRandomFrame(rndFunc);
	//public inline function is(k,f) return bs.is(k,f);
	//public inline function isGroup(k) return bs.isGroup(k);
//
	//public inline function getAnimDuration() return bs.getAnimDuration();
	//public inline function totalFrames() return bs.totalFrames();
//
	//public inline function setCenter(xf:Float, yf:Float) bs.setCenter(xf, yf);
	//public inline function setPivotCoord(xf:Float, yf:Float) bs.setPivotCoord(xf, yf);
	//public inline function setFrame(f) bs.setFrame(f);
	//public inline function isReady() return bs!=null && bs.isReady();



	static inline function getEmptyTexture() {
		return h2d.Tools.getCoreObjects().getEmptyTexture();
	}


	public inline function destroy() dispose();
	override function dispose() {
		super.dispose();

		if( !destroyed ) {
			if( lib!=null )
				lib.removeChild(this);

			tile = null;
			mTile = null;

			destroyed = true;
			a.destroy();
			a = null;
			lib = null;
			frameData = null;
			group = null;
			groupName = null;
			pivot = null;
			beforeRender = null;
			onFrameChange = null;
		}
	}


	public function clone() : HSprite {
		var s = new HSprite(lib, groupName, frame);
		s.pivot = pivot.clone();
		return s;
	}

	override function getBoundsRec( relativeTo, out ) {
		super.getBoundsRec(relativeTo, out);
		if( tile != null ) addBounds(relativeTo, out, tile.dx, tile.dy, tile.width, tile.height);
	}

	public inline function get_tile() {
		if( !isReady() )
			return mTile;

		var fd = frameData;
		mTile.setPos(fd.x, fd.y);
		mTile.setSize(fd.wid, fd.hei);

		if( pivot.isUsingCoord() ) {
			mTile.dx = -Std.int(pivot.coordX + fd.realFrame.x);
			mTile.dy = -Std.int(pivot.coordY + fd.realFrame.y);
		}
		else if( pivot.isUsingFactor() ) {
			mTile.dx = -Std.int(fd.realFrame.realWid*pivot.centerFactorX + fd.realFrame.x);
			mTile.dy = -Std.int(fd.realFrame.realHei*pivot.centerFactorY + fd.realFrame.y);
		}
		return mTile;
	}

	override function draw( ctx : h2d.RenderContext ) {
		if ( canEmit() )	emitTile(ctx, tile);
		else 				drawTile(ctx, tile);
	}
}