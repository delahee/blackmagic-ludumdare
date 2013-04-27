import starling.core.Starling;
import starling.display.Sprite;
import starling.text.TextField;
import starling.display.DisplayObject;

class ScreenTitle extends Screen{
	
	public var info : starling.text.TextField;
	public var car : DisplayObject;
	
	public var car2 : Array<DisplayObject>;
	
	public function new(){
		super();
		
		car = getMovie();
		addChild( car );
		
		car2 = [];
		for ( i in 0...100){
			car2[i] = getMovie();
			addChild( car2[i] );
		}
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
		
		for ( c in car2 ) {
			c.x = volute.Dice.roll( 0, volute.Lib.w() -100);
			c.y = volute.Dice.roll( 0, volute.Lib.h() -100);
		}
	}
}