package volute;
import postfx.Bloom.BloomFlags;

//todo http://philippseifried.com/blog/2011/07/24/flash-effects-creating-metaball-style-effects-in-as3/
//todo http://philippseifried.com/blog/2011/07/30/real-time-bloom-effects-in-as3/
class Main 
{
	public static var me 			= new Main();
	public var cur : scene.Scene;
	public var bloomNode : postfx.Bloom;
	
	public function new() { 
		addChild( new com.Stats() );
		//cur = new scene.FallingStar();
		cur = new scene.ThrowingStars();
		addChild(cur);
		
		var fl = haxe.EnumFlags.ofInt(0);
		fl.set( FULLSCREEN );
		bloomNode = new postfx.Bloom( cur, fl );
		
		//bloomNode.setBlurFactors( 12 , 1 );
		//bloomNode.rtRes = 0.5;
		//bloomNode.nbPowPass = 1;
		
		bloomNode.setBlurFactors( 8 , 1 );
		bloomNode.nbPowPass = 0;
		bloomNode.rtRes = 0.5;
	}
	
	
	
	public function addChild(c) return flash.Lib.current.addChild(c)
	
	static var prev = flash.Lib.getTimer();
	
	public function update() 
	{
		var dt = 0.001 * (flash.Lib.getTimer() - prev);//turn back to ms
		if ( dt > 0.5) dt = 0; //first frame & loads capping
		
		if (cur != null)
			cur.update(dt);
			
		if( null!=bloomNode )
			bloomNode.update(dt);
	}
	
	
	static function main() 
	{
		var stage = flash.Lib.current.stage;
		stage.addEventListener( flash.events.Event.ENTER_FRAME, function(_) Main.me.update());
	}
	
}