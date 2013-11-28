
typedef PnjData = 
{
	var id : Int;
	var name : String;
	var desc : String;
	var cat : Int;
	var score : Int;
}

class Ods 
{
	public static var pnj = ods.Data.parse("Data.ods", "pnj", PnjData);
	
	public static var _ =
	{
		for ( p in pnj)
		{
			Tools.assert( p.desc.length < 100);
		}
		null;
	}
}