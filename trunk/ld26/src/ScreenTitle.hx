import starling.core.Starling;
import starling.display.Sprite;
import starling.text.TextField;
import starling.display.DisplayObject;

class ScreenTitle extends Screen{
	
	public var info : starling.text.TextField;
	
	public function new(){
		super();
		
	}
	
	public function getMovie()
	{
		var vfr = Data.me.getFramesRectTex( "car","idle" );
		var el : starling.display.MovieClip = new starling.display.MovieClip( vfr,30 );
		el.readjustSize(); 
		el.loop = true;
		el.play();
		Starling.juggler.add( cast el );
		return el;
	}
	
	public override function init() {
		super.init();
		
		info = M.me.getTextField("YO :) ");
		addChild( info );
	}
	
	public override function update()
	{
		super.update();
		
	}
}