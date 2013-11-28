package fx;

class FxMan implements haxe.Public
{
	var fxs : List<Fx>;
	
	public function new()
	{
		fxs = new List();
	}
	public function update()
	{
		if(fxs.length>0)
			fxs = fxs.filter( function(fx) return fx.update());
	}
}