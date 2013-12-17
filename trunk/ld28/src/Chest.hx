
class Chest extends Entity{

	public function new() 
	{
		super();
		type = ET_CHEST;
		el = M.me.data.lib.getAndPlay("props_chest");
		//ofsX = el.width * 0.5;
		//ofsY = el.height * 0.5;
		hp = 10000000;
	}
	
}