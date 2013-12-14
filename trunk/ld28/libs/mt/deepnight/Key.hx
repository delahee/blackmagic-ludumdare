package mt.deepnight;

class Key {

	 public static inline var BACKSPACE        = 8;
	public static inline var TAB                = 9;
	public static inline var ENTER                = 13;
	public static inline var SHIFT                = 16;
	public static inline var CTRL                = 17;
	public static inline var ALT                = 18;
	public static inline var ESCAPE                = 27;
	public static inline var SPACE                = 32;
	public static inline var PGUP                = 33;
	public static inline var PGDOWN                = 34;
	public static inline var END                = 35;
	public static inline var HOME                = 36;
	public static inline var LEFT                = 37;
	public static inline var UP                        = 38;
	public static inline var RIGHT                = 39;
	public static inline var DOWN                = 40;
	public static inline var INSERT                = 45;
	public static inline var DELETE                = 46;
	
	public static inline var NUMBER_0        = 48;
	public static inline var NUMPAD_0        = 96;
	public static inline var A                        = 65;
	public static inline var F1                        = 112;
	public static inline var F2                        = 113;
	public static inline var F3                        = 114;
	public static inline var F4                        = 115;
	public static inline var F5                        = 116;
	public static inline var F6                        = 117;
	public static inline var F7                        = 118;
	public static inline var F8                        = 119;
	public static inline var F9                        = 120;
	public static inline var F10                = 121;
	public static inline var F11                = 122;
	public static inline var F12                = 123;
	
	public static inline var NUMPAD_MULT = 106;
	public static inline var NUMPAD_ADD        = 107;
	public static inline var NUMPAD_ENTER = 108;
	public static inline var NUMPAD_SUB = 109;
	public static inline var NUMPAD_DOT = 110;
	public static inline var NUMPAD_DIV = 111;
	
	static var kcodes = new Array<Null<Int>>();
	static var prevkcodes = new Array<Null<Int>>();

	static var ktime = 0;

	public static function init() {
		var stage = flash.Lib.current.stage;
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,onKey.bind(true));
		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,onKey.bind(false));
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
