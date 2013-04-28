import flash.display.Bitmap;
import starling.display.Image;

class Screen extends starling.display.Sprite{
	public var isStarted = false;
	public var level : L;
	public var loadBg : Bool = true;
	public var img : Image;
	
	public static var me : Screen;
	
	public function new() 
	{
		super();
		visible = false;
		touchable = true;
		me = this;
	}

	public function getName() :String return Std.string(Type.getClass(this))
	
	/** Dont forget to call me */
	public function init()
	{
		isStarted = true;
		visible = true;
		level = new L();
		addChild(level);
		
		if(loadBg){
		var bmd = new Data.BmpBg(0, 0, false);
		img = Image.fromBitmap( new Bitmap( bmd ) );
		M.me.addChild( img );
		bmd.dispose();
		bmd = null;}
	}
	
	
	/** returns true whether you shoould continue the kill */
	public function kill()
	{
		if ( !isStarted ) return false;
		
		isStarted = false;
		visible = false;
		level.kill();
		return true;
	}
	
	public function update()
	{
		if (!isStarted) return;
	}
}