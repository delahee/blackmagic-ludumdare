
class Nmy extends Char {
	
	public function new() 
	{
		super();
		name = "opp";
		type = ET_OPP;
	}
	
	public override function update() {
		super.update();
		rosace4();
	}
	
	public override function onKill() {
		super.onKill();
		
		//M.me.ui.addScore( 10, l.view.x - el.x  +10, l.view.y - l.view.y + 10);
		M.me.ui.addScore(10, 
		el.x - M.me.level.view.x - el.width * 0.5,
		el.y - M.me.level.view.y - el.height  );
		//trace("scoring");
	}
}