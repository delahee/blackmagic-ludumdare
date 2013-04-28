package volute.fx;

using Lambda;

class FXManager
{
	var rep : List<FX>;
	
	public static var self : FXManager = new FXManager();
	public function new()
	{
		rep = new List<FX>();
	}
	
	public function update()
	{
		if ( rep.length > 0) 
			rep = rep.filter( function(fx) return fx.update() );
	}
	
	//adding to null queue
	public function add(  x :FX ){
		rep.add(x);
		trace('add fx');
	}
}