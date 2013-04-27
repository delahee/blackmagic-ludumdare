
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
	}
	
	
	public override function update() {
		super.update();
		for( mc in mcs) mc.rotation = M.me.timer.ufr * 0.1;
	}
}