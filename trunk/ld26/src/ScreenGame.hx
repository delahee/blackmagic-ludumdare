
class ScreenGame extends Screen
{
	public function new() {
		super();
	}
	
	
	public override  function init(){
		super.init();
		addChild( G.me );
	}
	
	
	public override function update(){
		super.update();
		
		G.me.update();
	}
	
	public override function kill() {
		var b = super.kill();
		G.me.kill();
		return b;
	}
}