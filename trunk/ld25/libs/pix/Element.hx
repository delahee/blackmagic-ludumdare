package pix;
import flash.display.BitmapData;
import flash.geom.Matrix;

class Element extends flash.display.Sprite {//}

	public static var DEFAULT_ALIGN_X = 0.5;
	public static var DEFAULT_ALIGN_Y = 0.5;
	public static var DEFAULT_STORE:Store;

	public static var MAT = new Matrix();
	
	var animated:Bool;
	
	public var store:Store;
	public var frameAlignX:Float;
	public var frameAlignY:Float;
	public var currentFrame:Frame;
	
	// ANIM
	public var anim:Anim;
	public var currentAnimString:String;
	
	
	public function new() {
		super();
		animated = false;
		frameAlignX = DEFAULT_ALIGN_X;
		frameAlignY = DEFAULT_ALIGN_Y;
		store = DEFAULT_STORE;
	}
	
	// V2
	public function goto(?id:Int,?str:String,?fx:Float,?fy:Float) {
		drawFrame(store.get(id, str), fx, fy);
	}
		
	// ANIM
	public function play(str:String) {
		anim = new Anim(this);
		if ( !store.timelines.exists(str) ) throw( "anim " + str + " not found !");
		anim.timeline = store.getTimeline(str);
		
		drawFrame(anim.getCurrentFrame());
		if ( !animated ) {
			ANIMATED.push(this);
			animated = true;
		}
		currentAnimString = str;
		return anim;
	}
	
	public function stop() {
		if( anim == null )return;
		anim = null;
		animated = false;
		ANIMATED.remove(this);
	}
	public function updateAnim() {
		anim.update();
		if( visible && anim != null ){
			var fr = anim.getCurrentFrame();
			if( fr != currentFrame ) {
				graphics.clear();
				if(fr!=null)
					drawFrame(fr);
			}
		}
	}
	public function swapAnim(newAnim:pix.Anim) {
		newAnim.cursor = 	anim.cursor;
		newAnim.loop = 		anim.loop;
		anim = newAnim;
	}
	
	
	// DRAW FROM FRAME
	public function drawFrame(fr:Frame,?fax:Float,?fay:Float) {
		if (fax != null) frameAlignX = fax;
		if (fay != null) frameAlignY = fay;
		
		var ox = -Std.int(fr.width * frameAlignX);
		var oy = -Std.int(fr.height * frameAlignY);
		
		ox += fr.ddx;
		oy += fr.ddy;
		
		var m = MAT;
		m.identity();
		var x = - (fr.x - ox);
		var y = - (fr.y - oy);
		
		
		m.translate(x, y);
		if ( fr.swapX ) 		m.scale( -1, 1);
		if ( fr.swapY ) 		m.scale( 1, -1);
		if ( fr.rot != null )	m.rotate(fr.rot);	// BUG : WORK ONLY WITH ALIGN 0.5
				
		graphics.clear();
		graphics.lineStyle();
		graphics.beginBitmapFill(fr.texture, m );
		graphics.drawRect(ox, oy, fr.width, fr.height);
		graphics.endFill();
		
		currentFrame = fr;
		
	}
	public function setAlign(x,y) {
		frameAlignX = x;
		frameAlignY = y;
	}
	public function pxx() {
		x = Math.round(x);
		y = Math.round(y);
	
	}
		
	public function kill() {
		stop();
		if (parent != null) parent.removeChild(this);
	}
	
	// SHORCUT
	public function randomFlip() {
		rotation = Std.random(4)*90;
		scaleX *= Std.random(2) * 2 - 1;
		scaleY *= Std.random(2) * 2 - 1;
	}
	
	// ANIMATOR
	static public var ANIMATED:Array<Element> = [];
	public static function updateAnims() {
		var a = ANIMATED.copy();
		for ( el in  a ) el.updateAnim();
	}
	
	
	
//{
}