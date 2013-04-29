import flash.display.Bitmap;
import starling.display.Image;

using volute.Ex;
class Screen extends starling.display.Sprite{
	public var isStarted = false;
	public var level : L;
	public var loadBg : Bool = true;
	public var bg : Image;
	
	public static var me : Screen;
	
	public function new() 
	{
		super();
		visible = false;
		me = this;
		name = getName();
	}

	public function getName() :String return Std.string(Type.getClass(this))
	
	/** Dont forget to call me */
	public function init()
	{
		me = this;
		isStarted = true;
		visible = true;
		level = new L();
		addChild(level);
		if(loadBg){
		var bmd = new Data.BmpBg(0, 0, false);
		bg = Image.fromBitmap( new Bitmap( bmd ) );
		bg.alpha = 0.5;
		M.me.addChild( bg );
		bmd.dispose();
		bmd = null;
		}
	}
	
	
	/** returns true whether you shoould continue the kill */
	public function kill()
	{
		if ( !isStarted ) return false;
		
		isStarted = false;
		visible = false;
		level.kill();
		
		if( bg !=null){
		bg.dispose();
		bg = null;
		}
		return true;
	}
	
	public function update()
	{
		if (!isStarted) return;
	}
}