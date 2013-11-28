package mt.deepnight;

class Key {

	static var kcodes = new Array<Null<Int>>();
	static var prevkcodes = new Array<Null<Int>>();

	static var ktime = 0;

	public static function init() {
		var stage = flash.Lib.current.stage;
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,callback(onKey,true));
		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,callback(onKey,false));
		stage.addEventListener(flash.events.Event.DEACTIVATE,function(_) kcodes = new Array());
		stage.addEventListener(flash.events.Event.ENTER_FRAME,onEnterFrame);
	}

	static function onEnterFrame(_) {
		ktime++;
	}

	static function onKey( down, e : flash.events.KeyboardEvent ) {
		event(e.keyCode,down);
	}

	public static function event( code, down ) {
		kcodes[code] = down ? ktime : null;
	}


	public static function isDown(c) {
		return kcodes[c] != null;
	}


	public static function isToggled(c) {
		return kcodes[c] == ktime;
	}
}
