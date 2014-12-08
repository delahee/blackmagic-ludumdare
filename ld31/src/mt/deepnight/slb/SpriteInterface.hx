package mt.deepnight.slb;

import mt.deepnight.slb.BLib;

interface SpriteInterface {

	public var destroyed			: Bool;
	public var lib					: BLib;
	public var group				: Null<LibGroup>;
	public var groupName			: Null<String>;
	public var frame				: Int;
	public var pivot				: SpritePivot;
	public var a					: AnimManager;
	private var frameData			: FrameData;

	// Callbacks
	public var beforeRender			: Null<Void->Void>;
	public var onFrameChange		: Null<Void->Void>;


	public function clone() : SpriteInterface;
	public function toString() : String;
	public function destroy() : Void;
	public function isReady() : Bool;

	public function set(?l:BLib, ?g:String, ?frame:Int, ?stopAllAnims:Bool) : Void;
	public function setFrame(f:Int) : Void;
	public function setRandom(?l:BLib, g:String, rndFunc:Int->Int) : Void;
	public function setRandomFrame(?rndFunc:Int->Int) : Void;

	public function isGroup(k:String) : Bool;
	public function is(k:String, f:Int) : Bool;

	public function setPos(x:Float, y:Float) : Void;
	public function setPivotCoord(x:Float, y:Float) : Void;
	public function setCenter(x:Float, y:Float) : Void;

	public function getAnimDuration() : Int;
	public function totalFrames() : Int;
}
