package mt.deepnight.slb;

import h2d.Drawable;
import h2d.SpriteBatch;
import mt.deepnight.slb.*;
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.SpriteInterface;

class HSpriteBE extends BatchElement implements SpriteInterface {
	public var a			: AnimManager;
	public var lib			: BLib;
	public var groupName	: String;
	public var group		: LibGroup;
	public var frame		: Int;
	public var frameData	: FrameData;
	var pivot				: SpritePivot;
	public var destroyed	: Bool;

	public var beforeRender	: Null<Void->Void>;
	public var onFrameChange: Null<Void->Void>;

	public function new(sb:SpriteBatch, l:BLib, g:String, ?f=0) {
		super( l.tile.clone() );
		destroyed = false;

		pivot = new SpritePivot();
		a = new AnimManager(this);

		sb.add(this);
		set(l,g,f);
	}

	public function toString() return "HSpriteBE_"+groupName+"["+frame+"]";

	public inline function set( ?l:BLib, ?g:String, ?frame=0, ?stopAllAnims=false ) {
		if( l!=null ) {
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
				setCenterRatio(lib.defaultCenterX, lib.defaultCenterY);
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

	public function constraintSize(w:Float, ?h:Null<Float>, ?useFrameDataRealSize=false) {
		if( useFrameDataRealSize )
			setScale( Math.min( w/frameData.realFrame.realWid, (h==null?w:h)/frameData.realFrame.realHei ) );
		else
			setScale( Math.min( w/tile.width, (h==null?w:h)/tile.height ) );
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

			updateTile();
		}
	}

	public inline function setPivotCoord(x:Float, y:Float) {
		pivot.setCoord(x, y);
		updateTile();
	}

	public inline function setCenterRatio(?xRatio:Float=0.5, ?yRatio:Float=0.5) {
		pivot.setCenterRatio(xRatio, yRatio);
		updateTile();
	}

	public function totalFrames() {
		return group.frames.length;
	}



	public function colorize(col:UInt, ?alpha=1.0, ?scale=1.0) {
		color = h3d.Vector.fromColor( mt.deepnight.Color.addAlphaF(col, alpha), scale );
	}



	public function clone<T>(?s:T) : T {
		throw "not implemented yet"; // HACK
		return cast this;
	}

	function updateTile() {
		if( !isReady() )
			return;

		var fd = frameData;
		tile.setPos(fd.x, fd.y);
		tile.setSize(fd.wid, fd.hei);

		if ( pivot.isUsingCoord() ) {
			tile.dx = Math.round(-pivot.coordX - fd.realFrame.x);
			tile.dy = Math.round(-pivot.coordY - fd.realFrame.y);
		}

		if ( pivot.isUsingFactor() ){
			tile.dx = -Std.int(fd.realFrame.realWid * pivot.centerFactorX + fd.realFrame.x);
			tile.dy = -Std.int(fd.realFrame.realHei * pivot.centerFactorY + fd.realFrame.y);
		}
	}

	function onDispose(){}
	public inline function dispose() {
		remove();
	}
	override function remove() {
		super.remove();

		if( !destroyed ) {
			if( lib!=null )
				lib.removeChild(this);

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
	
	public inline function pos() : h2d.col.Point {
		return new h2d.col.Point( x, y);
	}
	
	public inline function translate(p) {
		this.x += p.x;
		this.y += p.y;
	}
	
	public inline function translate2(x,y) {
		this.x += x;
		this.y += y;
	}
}
