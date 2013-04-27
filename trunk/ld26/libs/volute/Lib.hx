package volute;
import haxe.PosInfos;
import starling.display.DisplayObject;
/**
 * ...
 * @author de
 */
class Lib 
{
	public static inline function w() return flash.Lib.current.stage.stageWidth
	public static inline function h() return flash.Lib.current.stage.stageHeight
	
	public static inline function assert(b:Bool, ?msg:String, ?PosInfos) if(!b) throw msg == null?b:cast msg
	
	public static inline function detach( doc:DisplayObject ) {
		if ( doc.parent != null) 
			doc.parent.removeChild( doc );
	}
	
	public static function toFront( mc : DisplayObject ){
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , mc.parent.numChildren-1 );
	}
	
	public static function toBack( mc : DisplayObject){
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , 0);
	}
	
	public static inline function rangeMinMax(min:Int,max:Int){
		var a = [];
		for ( i in min...max)
			a.push(i);
		return a;
	}
	
	public static function splat( v:  Int,n:Int){
		var a = [];
		for ( i in 0...n) a.push( v );
		return a;
	}
	
	//courtesy of deepnight
	public static inline function rad(a:Float) : Float {
		return a*3.1416/180;
	}
	
	public static inline function deg(a:Float) : Float {
		return a*180/3.1416;
	}
	public static function flatten(o:flash.display.DisplayObject, ?uniqId:String, ?padding=0.0, ?copyTransforms=false, ?quality:flash.display.StageQuality) {
		var qold = try { flash.Lib.current.stage.quality; } catch(e:Dynamic) { flash.display.StageQuality.MEDIUM; };
		if( quality!=null )
			try {
				flash.Lib.current.stage.quality = quality;
			} catch( e:Dynamic ) {
				throw("flatten quality error");
			}
		var b = o.getBounds(o);
		var bmp = new flash.display.Bitmap( new flash.display.BitmapData(Math.ceil(b.width+padding*2), Math.ceil(b.height+padding*2), true, 0x0) );
		var m = new flash.geom.Matrix();
		m.translate(-b.x, -b.y);
		m.translate(padding, padding);
		bmp.bitmapData.draw(o, m, o.transform.colorTransform);

		var m = new flash.geom.Matrix();
		m.translate(b.x, b.y);
		m.translate(-padding, -padding);
		if( copyTransforms ) {
			m.scale(o.scaleX, o.scaleY);
			m.rotate( rad(o.rotation) );
			m.translate(o.x, o.y);
		}
		bmp.transform.matrix = m;
		
		if( quality!=null )
			try {
				flash.Lib.current.stage.quality = qold;
			} catch( e:Dynamic ) {
				throw("flatten quality error");
			}
		return bmp;
	}
}