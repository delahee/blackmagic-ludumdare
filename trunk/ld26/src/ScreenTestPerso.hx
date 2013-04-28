import volute.Types;
import mt.deepnight.Key;
class ScreenTestPerso extends Screen{

	var mcs : Array<starling.display.MovieClip>;
	public function new() 
	{
		super();
		mcs = [];
		
		var cx = 50;
		var cy = 100;
		var i = 0;
		for ( st in Data.me.sprites.get( "perso" ).states ) {
			var mc;
			mcs.push( mc = Data.me.getMovie("perso", st.id) );
			mc.pivotX = mc.width * 0.5;			
			mc.pivotY = mc.height;			
			mc.x = cx += 80;
			mc.y = cy;
			addChild(mc);
			i++;
		}
		
		var mc = mcs[1];
		Data.me.fillMc( mcs[1], Data.me.getFramesRectTex( "perso", "run"));
		mc.pause();
	}
	
	function getMc() return mcs[1]
	
	public override function update() {
		super.update();
		
		var mc = getMc();
		if ( Key.isDown( K.LEFT )) {
			var c = getMc().currentFrame-1;
			if ( c < 0 ) c = mc.numFrames - 1;
			mc.currentFrame =c;
		}
		
		else if ( Key.isDown( K.RIGHT )) {
			var c = getMc().currentFrame+1;
			if ( c >= getMc().numFrames ) c = 0;
			getMc().currentFrame = c;
		}
	}
}