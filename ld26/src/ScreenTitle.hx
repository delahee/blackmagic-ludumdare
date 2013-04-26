import starling.text.TextField;

class ScreenTitle extends Screen{
	
	public var info : starling.text.TextField;
	
	public function new(){
		super();
	}
	
	public override function init() {
		super.init();
		
		info = M.me.getTextField("YO :) ");
		addChild( info );
	}
}